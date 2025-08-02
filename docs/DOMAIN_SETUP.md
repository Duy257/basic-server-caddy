# Hướng dẫn cấu hình Domain với Caddy

## 📋 Tổng quan

Hướng dẫn này sẽ giúp bạn cấu hình domain tùy chỉnh cho Express Basic Server sử dụng Caddy reverse proxy với SSL tự động.

## 🎯 Yêu cầu

- Domain đã mua (ví dụ: `sushidev.top`)
- Server có IP public
- Docker và Docker Compose đã cài đặt
- Quyền truy cập DNS management

## 🌐 Bước 1: Cấu hình DNS

### Tại nhà cung cấp domain (Vietnix, GoDaddy, Cloudflare, etc.)

Tạo các DNS records sau:

```
Type: A
Name: @
Value: [IP_PUBLIC_CUA_SERVER]
TTL: 300

Type: A  
Name: www
Value: [IP_PUBLIC_CUA_SERVER]
TTL: 300
```

### Ví dụ với domain `sushidev.top`:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 123.456.789.10 | 300 |
| A | www | 123.456.789.10 | 300 |

## 📝 Bước 2: Cập nhật Caddyfile

Thay thế nội dung file `Caddyfile`:

```caddy
# Production domain configuration
sushidev.top, www.sushidev.top {
    # Reverse proxy đến Express server
    reverse_proxy express-app:3000
    
    # TLS tự động với Let's Encrypt
    tls {
        protocols tls1.2 tls1.3
    }
    
    # Logging
    log {
        output file /var/log/caddy/sushidev.log
        format json
    }
    
    # Headers bảo mật
    header {
        # Prevent MIME type sniffing
        X-Content-Type-Options nosniff
        
        # XSS Protection
        X-Frame-Options DENY
        
        # HSTS
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        
        # Hide Caddy version
        -Server
        
        # Additional security headers
        Referrer-Policy strict-origin-when-cross-origin
        Permissions-Policy "geolocation=(), microphone=(), camera=()"
    }
    
    # Compression
    encode gzip
    
    # Rate limiting (optional)
    rate_limit {
        zone dynamic_zone {
            key {remote_host}
            events 100
            window 1m
        }
    }
}

# Development/localhost (giữ lại cho testing local)
localhost:8080 {
    reverse_proxy express-app:3000
    
    log {
        output file /var/log/caddy/localhost.log
        format json
    }
    
    header {
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        -Server
    }
    
    encode gzip
}

# Health check endpoint
:8081 {
    respond /health "OK" 200
    
    log {
        output file /var/log/caddy/health.log
    }
}
```

## 🐳 Bước 3: Cập nhật Docker Compose

Cập nhật file `docker-compose.yml`:

```yaml
version: '3.8'

services:
  # Express Server
  express-app:
    build: .
    container_name: express-basic-server
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
    volumes:
      - .:/app
      - /app/node_modules
    restart: unless-stopped
    networks:
      - app-network

  # Caddy Reverse Proxy
  caddy:
    image: caddy:2-alpine
    container_name: caddy-proxy
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
      - "8081:8081"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
      - ./logs:/var/log/caddy
    restart: unless-stopped
    networks:
      - app-network
    depends_on:
      - express-app
    # Đảm bảo Caddy có thể resolve domain
    extra_hosts:
      - "sushidev.top:127.0.0.1"
      - "www.sushidev.top:127.0.0.1"

volumes:
  caddy_data:
  caddy_config:

networks:
  app-network:
    driver: bridge
```

## 🚀 Bước 4: Deploy và Kiểm tra

### 1. Tạo thư mục logs

```bash
mkdir -p logs
chmod 755 logs
```

### 2. Validate cấu hình

```bash
# Kiểm tra Caddyfile syntax
docker run --rm -v $(pwd)/Caddyfile:/etc/caddy/Caddyfile caddy:2-alpine caddy validate --config /etc/caddy/Caddyfile
```

### 3. Deploy

```bash
# Stop containers hiện tại
docker-compose down

# Rebuild và start
docker-compose up -d --build

# Xem logs
docker-compose logs -f caddy
```

### 4. Kiểm tra DNS propagation

```bash
# Kiểm tra DNS đã cập nhật chưa
nslookup sushidev.top
dig sushidev.top

# Hoặc dùng online tools
# https://dnschecker.org/
```

## 🔍 Bước 5: Testing

### Test local trước (nếu DNS chưa propagate)

```bash
# Test với host header
curl -H "Host: sushidev.top" http://localhost

# Test qua localhost
curl http://localhost:8080
```

### Test domain thật (sau khi DNS propagate)

```bash
# Homepage
curl https://sushidev.top
curl https://www.sushidev.top

# Health check
curl https://sushidev.top/health

# API endpoints
curl https://sushidev.top/api/users

# Test tạo user
curl -X POST https://sushidev.top/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'
```

### Test SSL certificate

```bash
# Kiểm tra SSL certificate
openssl s_client -connect sushidev.top:443 -servername sushidev.top

# Hoặc dùng online tools
# https://www.ssllabs.com/ssltest/
```

## 📊 Monitoring và Logs

### Xem logs

```bash
# Logs tổng quát
docker-compose logs -f

# Logs Caddy
docker-compose logs -f caddy

# Logs Express
docker-compose logs -f express-app

# Logs SSL/TLS
docker-compose logs caddy | grep -i "certificate\|tls\|acme"
```

### Xem logs files

```bash
# Access logs
tail -f logs/sushidev.log

# Health check logs
tail -f logs/health.log

# Localhost logs
tail -f logs/localhost.log
```

### Kiểm tra certificates

```bash
# List certificates trong Caddy
docker exec caddy-proxy caddy list-certificates

# Certificate info
docker exec caddy-proxy ls -la /data/caddy/certificates/
```

## 🔒 SSL Certificate Management

### Tự động với Let's Encrypt

Caddy sẽ tự động:
- Lấy SSL certificate từ Let's Encrypt
- Redirect HTTP → HTTPS
- Renew certificate trước khi hết hạn
- Backup certificates trong volume `caddy_data`

### Manual certificate renewal (nếu cần)

```bash
# Force renew certificate
docker exec caddy-proxy caddy reload --config /etc/caddy/Caddyfile
```

## 🛠️ Troubleshooting

### DNS không resolve

```bash
# Kiểm tra DNS
nslookup sushidev.top 8.8.8.8
dig @8.8.8.8 sushidev.top

# Clear local DNS cache
sudo systemctl flush-dns  # Linux
sudo dscacheutil -flushcache  # macOS
```

### SSL certificate issues

```bash
# Xem logs chi tiết
docker-compose logs caddy | grep -i error

# Kiểm tra Let's Encrypt rate limits
# https://letsencrypt.org/docs/rate-limits/

# Test với staging environment
# Thêm vào Caddyfile: tls internal
```

### Port không accessible

```bash
# Kiểm tra firewall
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Kiểm tra ports
netstat -tulpn | grep :80
netstat -tulpn | grep :443
```

### Container issues

```bash
# Restart containers
docker-compose restart

# Rebuild từ đầu
docker-compose down --volumes
docker-compose up -d --build

# Xem container status
docker-compose ps
```

## 🔧 Advanced Configuration

### Custom SSL certificate

```caddy
sushidev.top {
    tls /path/to/cert.pem /path/to/key.pem
    reverse_proxy express-app:3000
}
```

### Multiple domains

```caddy
sushidev.top, api.sushidev.top, admin.sushidev.top {
    reverse_proxy express-app:3000
}
```

### Subdomain routing

```caddy
api.sushidev.top {
    reverse_proxy express-app:3000/api/*
}

admin.sushidev.top {
    reverse_proxy express-app:3000/admin/*
}
```

### Load balancing

```caddy
sushidev.top {
    reverse_proxy express-app1:3000 express-app2:3000 express-app3:3000 {
        lb_policy round_robin
        health_uri /health
    }
}
```

## 📋 Checklist

- [ ] DNS records đã tạo và propagate
- [ ] Caddyfile đã cập nhật với domain
- [ ] Docker Compose đã cập nhật
- [ ] Firewall đã mở port 80, 443
- [ ] Containers đã restart
- [ ] SSL certificate đã được issue
- [ ] Domain accessible qua HTTPS
- [ ] API endpoints hoạt động
- [ ] Logs không có errors

## 🔄 Backup và Recovery

### Backup certificates

```bash
# Backup Caddy data volume
docker run --rm -v caddy_data:/data -v $(pwd):/backup alpine tar czf /backup/caddy-certificates.tar.gz /data

# Restore certificates
docker run --rm -v caddy_data:/data -v $(pwd):/backup alpine tar xzf /backup/caddy-certificates.tar.gz -C /
```

### Configuration backup

```bash
# Backup configuration files
tar czf config-backup.tar.gz Caddyfile docker-compose.yml .env
```

## 📚 Tài liệu tham khảo

- [Caddy Documentation](https://caddyserver.com/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Docker Compose Networking](https://docs.docker.com/compose/networking/)
- [DNS Propagation Checker](https://dnschecker.org/)
- [SSL Test Tool](https://www.ssllabs.com/ssltest/)

## 🆘 Support

Nếu gặp vấn đề:

1. Kiểm tra logs: `docker-compose logs -f`
2. Validate cấu hình: `caddy validate`
3. Test DNS: `nslookup domain.com`
4. Kiểm tra firewall và ports
5. Tham khảo Caddy community forum