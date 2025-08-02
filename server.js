const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

// Khởi tạo Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet()); // Bảo mật cơ bản
app.use(cors()); // Cho phép CORS
app.use(morgan('combined')); // Logging requests
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies

// Routes cơ bản
app.get('/', (req, res) => {
  res.json({
    message: 'Xin chào! Server Express đang chạy thành công!',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// API routes
app.get('/api/users', (req, res) => {
  res.json({
    users: [
      { id: 1, name: 'Nguyễn Văn A', email: 'nguyenvana@email.com' },
      { id: 2, name: 'Trần Thị B', email: 'tranthib@email.com' },
      { id: 3, name: 'Lê Văn C', email: 'levanc@email.com' }
    ]
  });
});

app.post('/api/users', (req, res) => {
  const { name, email } = req.body;
  
  if (!name || !email) {
    return res.status(400).json({
      error: 'Thiếu thông tin name hoặc email'
    });
  }

  res.status(201).json({
    message: 'Tạo user thành công',
    user: {
      id: Date.now(),
      name,
      email,
      createdAt: new Date().toISOString()
    }
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route không tồn tại',
    path: req.originalUrl
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Có lỗi xảy ra trên server!',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Internal Server Error'
  });
});

// Khởi động server
app.listen(PORT, () => {
  console.log(`🚀 Server đang chạy tại http://localhost:${PORT}`);
  console.log(`📝 Health check: http://localhost:${PORT}/health`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;