# Express Basic Server - Hướng dẫn sử dụng chi tiết

## 📖 Tổng quan

Express Basic Server là một template server Node.js đơn giản nhưng đầy đủ tính năng, được thiết kế để khởi tạo nhanh các dự án web. Server tích hợp sẵn các middleware bảo mật, reverse proxy với Caddy, và hỗ trợ Docker deployment.

## 🎯 Mục đích sử dụng

- **Prototype nhanh**: Tạo API server trong vài phút
- **Learning**: Học Express.js và reverse proxy
- **Production ready**: Có thể deploy production với minimal setup
- **Microservices**: Base cho các microservice nhỏ

## 🏗️ Kiến trúc hệ thống

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client/Web    │───▶│   Caddy Proxy   │───▶│ Express Server  │
│   (Port 8080)   │    │   (Port 8080)   │    │   (Port 3000)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │ Static Files    │
                       │ SSL/TLS         │
                       │ Compression     │
                       └─────────────────┘
```

## 🚀 Cài đặt và khởi chạy

### Phương pháp 1: Local Development

```bash
# Clone hoặc tạo project
git clone <repo-url> express-basic-server
cd express-basic-server

# Cài đặt dependencies
npm install

# Tạo file environment
cp .env.example .env

# Chạy development mode
npm run dev
```

### Phương pháp 2: Docker (Khuyến nghị)

```bash
# Chạy toàn bộ stack (Express + Caddy)
docker-compose up -d

# Kiểm tra logs
docker-compose logs -f app
```

### Phương pháp 3: Production với PM2

```bash
# Cài đặt PM2 global
npm install -g pm2

# Build và chạy
npm run build
pm2 start ecosystem.config.js
```

## 🔧 Cấu hình chi tiết

### Environment Variables (.env)

```bash
# Server Configuration
PORT=3000                    # Port cho Express server
NODE_ENV=development         # development | production | test

# Security
CORS_ORIGIN=*               # CORS allowed origins
RATE_LIMIT_WINDOW=900000    # Rate limit window (15 phút)
RATE_LIMIT_MAX=100          # Max requests per window

# Logging
LOG_LEVEL=info              # error | warn | info | debug
LOG_FORMAT=combined         # combined | common | dev

# Database (nếu có)
DATABASE_URL=               # MongoDB/PostgreSQL connection string
```

### Caddyfile Configuration

```caddy
# Development
:8080 {
    reverse_proxy localhost:3000
    log {
        output file /var/log/caddy/access.log
    }
}

# Production với domain
yourdomain.com {
    reverse_proxy localhost:3000
    encode gzip
    
    # Security headers
    header {
        X-Frame-Options DENY
        X-Content-Type-Options nosniff
        Referrer-Policy strict-origin-when-cross-origin
    }
}
```

## 📡 API Endpoints

### Core Endpoints

| Method | Endpoint | Mô tả | Body |
|--------|----------|-------|------|
| GET | `/` | Homepage | - |
| GET | `/health` | Health check | - |
| GET | `/api/users` | Lấy danh sách users | - |
| POST | `/api/users` | Tạo user mới | `{name, email}` |

### Ví dụ sử dụng API

#### 1. Health Check

```bash
curl http://localhost:3000/health

# Response
{
  "status": "OK",
  "timestamp": "2024-01-01T10:00:00.000Z",
  "uptime": 3600,
  "environment": "development"
}
```

#### 2. Lấy danh sách Users

```bash
curl http://localhost:3000/api/users

# Response
{
  "users": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "createdAt": "2024-01-01T10:00:00.000Z"
    }
  ],
  "total": 1
}
```

#### 3. Tạo User mới

```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Smith",
    "email": "jane@example.com"
  }'

# Response
{
  "message": "User created successfully",
  "user": {
    "id": 2,
    "name": "Jane Smith",
    "email": "jane@example.com",
    "createdAt": "2024-01-01T10:05:00.000Z"
  }
}
```

## 🛡️ Bảo mật

### Middleware được tích hợp

- **Helmet**: Security headers tự động
- **CORS**: Cross-origin resource sharing
- **Rate Limiting**: Giới hạn requests per IP
- **Body Parser Limits**: Giới hạn size request body

### Security Headers

```javascript
// Tự động được thêm bởi Helmet
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000
```

### Best Practices

1. **Environment Variables**: Không commit file `.env`
2. **HTTPS**: Luôn sử dụng HTTPS trong production
3. **Rate Limiting**: Điều chỉnh rate limit phù hợp
4. **Input Validation**: Validate tất cả input từ client
5. **Error Handling**: Không expose stack trace

## 🐳 Docker Deployment

### Development

```bash
# Chạy với hot reload
docker-compose -f docker-compose.dev.yml up

# Rebuild khi có thay đổi dependencies
docker-compose build --no-cache
```

### Production

```bash
# Build production image
docker build -t express-basic-server:latest .

# Chạy với production config
docker-compose -f docker-compose.prod.yml up -d

# Scale multiple instances
docker-compose up --scale app=3
```

### Health Checks

Docker container có built-in health check:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js
```

## 📊 Monitoring và Logging

### Logs

```bash
# Development logs
npm run dev

# Production logs với PM2
pm2 logs

# Docker logs
docker-compose logs -f app

# Caddy logs
tail -f /var/log/caddy/access.log
```

### Metrics

Endpoint `/health` cung cấp:
- Server uptime
- Memory usage
- Response time
- Environment info

### Monitoring Tools

Tích hợp dễ dàng với:
- **Prometheus**: Metrics collection
- **Grafana**: Visualization
- **ELK Stack**: Log aggregation
- **New Relic**: APM monitoring

## 🔧 Troubleshooting

### Lỗi thường gặp

#### 1. Port đã được sử dụng

```bash
# Kiểm tra process đang dùng port
lsof -i :3000

# Kill process
kill -9 $(lsof -ti:3000)

# Hoặc đổi port trong .env
PORT=3001
```

#### 2. Caddy không khởi động

```bash
# Validate Caddyfile
caddy validate --config Caddyfile

# Chạy với debug mode
caddy run --config Caddyfile --debug

# Kiểm tra port conflicts
netstat -tulpn | grep :8080
```

#### 3. Docker issues

```bash
# Kiểm tra Docker daemon
docker info

# Clean up containers
docker-compose down --volumes --remove-orphans

# Rebuild từ đầu
docker-compose build --no-cache
```

#### 4. Permission errors

```bash
# Fix file permissions
chmod +x install-caddy.sh

# Docker permission issues
sudo usermod -aG docker $USER
```

## 🚀 Production Deployment

### 1. Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

### 2. Application Deployment

```bash
# Clone repository
git clone <repo-url> /opt/express-basic-server
cd /opt/express-basic-server

# Set production environment
cp .env.example .env
# Edit .env với production values

# Deploy với Docker
docker-compose -f docker-compose.prod.yml up -d
```

### 3. Reverse Proxy Setup

```bash
# Install Caddy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install caddy

# Configure Caddyfile cho production
sudo nano /etc/caddy/Caddyfile

# Start Caddy service
sudo systemctl enable caddy
sudo systemctl start caddy
```

### 4. Firewall và SSL

```bash
# Configure UFW firewall
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS
sudo ufw enable

# SSL certificates tự động qua Caddy
# Chỉ cần cấu hình domain trong Caddyfile
```

### 5. Process Management

```bash
# Sử dụng PM2 cho Node.js
npm install -g pm2

# Tạo ecosystem file
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'express-basic-server',
    script: 'server.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
}
EOF

# Start với PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## 🔄 CI/CD Pipeline

### GitHub Actions Example

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Deploy to server
        uses: appleboy/ssh-action@v0.1.5
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.KEY }}
          script: |
            cd /opt/express-basic-server
            git pull origin main
            docker-compose -f docker-compose.prod.yml up -d --build
```

## 📚 Tài liệu tham khảo

- [Express.js Documentation](https://expressjs.com/)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Docker Compose](https://docs.docker.com/compose/)
- [PM2 Documentation](https://pm2.keymetrics.io/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

## 🤝 Đóng góp

1. Fork repository
2. Tạo feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Tạo Pull Request

## 📄 License

MIT License - xem file `LICENSE` để biết thêm chi tiết.