# 🚀 Quick Start Guide

## Chạy Server Express

```bash
# 1. Cài đặt dependencies
npm install

# 2. Tạo file .env
echo "PORT=3000" > .env
echo "NODE_ENV=development" >> .env

# 3. Chạy server (development)
npm run dev

# Hoặc chạy production
npm start
```

## 🌐 Test Server

```bash
# Test endpoint chính
curl http://localhost:3000

# Test health check
curl http://localhost:3000/health

# Test API users
curl http://localhost:3000/api/users

# Tạo user mới
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'
```

## 🔧 Setup Caddy

### 1. Cài đặt Caddy

```bash
# Chạy script tự động
./install-caddy.sh

# Hoặc cài thủ công (macOS với Homebrew)
brew install caddy

# Linux (Ubuntu/Debian)
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
```

### 2. Chạy với Caddy

```bash
# Terminal 1: Chạy Express server
npm run dev

# Terminal 2: Chạy Caddy
caddy run --config Caddyfile
```

### 3. Test với Caddy

```bash
# Qua Caddy (port 8080)
curl http://localhost:8080

# Health check của Caddy
curl http://localhost:8081/health
```

## 🐳 Docker Setup

```bash
# Build và chạy với Docker Compose
docker-compose up --build -d

# Xem logs
docker-compose logs -f

# Dừng services
docker-compose down
```

## 📁 Cấu trúc File

```
express-basic-server/
├── server.js              # Main Express server
├── healthcheck.js          # Health check cho Docker
├── package.json           # Dependencies
├── .env                   # Environment variables
├── Dockerfile             # Docker image
├── docker-compose.yml     # Docker services
├── Caddyfile             # Caddy configuration
├── install-caddy.sh      # Script cài Caddy
└── README.md             # Documentation
```

## 🔍 Troubleshooting

### Express server không khởi động

```bash
# Kiểm tra port có đang được sử dụng
lsof -i :3000

# Kill process nếu cần
kill -9 $(lsof -ti:3000)
```

### Caddy không chạy được

```bash
# Kiểm tra cấu hình Caddyfile
caddy validate --config Caddyfile

# Chạy với log chi tiết
caddy run --config Caddyfile --debug
```

### Docker issues

```bash
# Kiểm tra Docker daemon
docker info

# Rebuild image
docker-compose build --no-cache
```

## 🌟 Production Deployment

1. **Cập nhật Caddyfile** với domain thật
2. **Set environment variables**:
   ```
   NODE_ENV=production
   PORT=3000
   ```
3. **Sử dụng process manager** như PM2
4. **Enable firewall** và **SSL certificates**

## 📚 Tài liệu thêm

- [Express.js Documentation](https://expressjs.com/)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Docker Compose](https://docs.docker.com/compose/)
