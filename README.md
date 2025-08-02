# Express Basic Server

Server Express cơ bản với Node.js và Caddy reverse proxy.

## 🚀 Tính năng

- ✅ Express.js server cơ bản
- ✅ Middleware bảo mật (Helmet, CORS)
- ✅ Logging với Morgan
- ✅ Caddy reverse proxy
- ✅ Docker & Docker Compose
- ✅ Health check endpoint
- ✅ API routes mẫu

## 📋 Yêu cầu

- Node.js >= 16
- npm hoặc yarn
- Docker & Docker Compose (tùy chọn)
- Caddy (nếu chạy local không dùng Docker)

## 🛠️ Cài đặt

### 1. Clone hoặc tạo project

```bash
mkdir express-basic-server
cd express-basic-server
npm init -y
```

### 2. Cài đặt dependencies

```bash
npm install express cors helmet morgan dotenv
npm install --save-dev nodemon
```

### 3. Tạo file .env

```bash
cp .env.example .env
```

Chỉnh sửa file `.env` theo nhu cầu:

```
PORT=3000
NODE_ENV=development
```

## 🏃‍♂️ Chạy ứng dụng

### Development mode

```bash
npm run dev
```

### Production mode

```bash
npm start
```

### Với Docker Compose (bao gồm Caddy)

```bash
docker-compose up -d
```

## 🌐 Endpoints

### API Routes

- `GET /` - Trang chủ
- `GET /health` - Health check
- `GET /api/users` - Lấy danh sách users
- `POST /api/users` - Tạo user mới

### Examples

#### Lấy danh sách users

```bash
curl http://localhost:3000/api/users
```

#### Tạo user mới

```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Nguyễn Văn Test","email":"test@email.com"}'
```

## 🔧 Cấu hình Caddy

Caddy được cấu hình để:

- Reverse proxy từ port 8080 đến Express server (port 3000)
- Tự động HTTPS với Let's Encrypt (production)
- Compression gzip
- Security headers
- Logging

### Chạy Caddy local

```bash
caddy run --config Caddyfile
```

Truy cập: http://localhost:8080

## 🐳 Docker

### Build image

```bash
docker build -t express-basic-server .
```

### Chạy container

```bash
docker run -p 3000:3000 express-basic-server
```

### Docker Compose

```bash
# Chạy cả Express và Caddy
docker-compose up -d

# Xem logs
docker-compose logs -f

# Dừng services
docker-compose down
```

## 📁 Cấu trúc project

```
express-basic-server/
├── server.js              # Main server file
├── healthcheck.js          # Health check cho Docker
├── package.json           # Dependencies
├── Dockerfile             # Docker configuration
├── docker-compose.yml     # Docker Compose setup
├── Caddyfile             # Caddy configuration
├── .gitignore            # Git ignore rules
└── README.md             # Documentation
```

## 🔒 Bảo mật

Server đã được tích hợp các middleware bảo mật cơ bản:

- **Helmet**: Security headers
- **CORS**: Cross-Origin Resource Sharing
- **Body parsing limits**: Giới hạn size request
- **Error handling**: Không expose stack trace trong production

## 📊 Monitoring

- Health check: `GET /health`
- Logs: Morgan logging middleware
- Docker health check với custom script

## 🚀 Production

Để deploy production:

1. Cập nhật Caddyfile với domain thật
2. Set environment variables:
   ```
   NODE_ENV=production
   PORT=3000
   ```
3. Sử dụng process manager như PM2 hoặc Docker

## 🤝 Contributing

1. Fork the project
2. Create feature branch
3. Commit changes
4. Push to branch
5. Open Pull Request

## 📝 License

ISC License
