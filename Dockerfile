# Sử dụng Node.js LTS version
FROM node:18-alpine

# Tạo thư mục app
WORKDIR /app

# Copy package files
COPY package*.json ./

# Cài đặt dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Tạo user non-root
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Chuyển ownership của /app cho nodejs user
RUN chown -R nodejs:nodejs /app
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1

# Start the application
CMD ["node", "server.js"]