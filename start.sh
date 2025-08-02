#!/bin/bash

# Script khởi động Express server và Caddy
echo "🚀 Khởi động Express Basic Server..."

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function để print màu
print_green() {
    echo -e "${GREEN}$1${NC}"
}

print_yellow() {
    echo -e "${YELLOW}$1${NC}"
}

print_red() {
    echo -e "${RED}$1${NC}"
}

print_blue() {
    echo -e "${BLUE}$1${NC}"
}

# Kiểm tra file .env
if [ ! -f .env ]; then
    print_yellow "📄 Tạo file .env..."
    echo "PORT=3000" > .env
    echo "NODE_ENV=development" >> .env
fi

# Kiểm tra node_modules
if [ ! -d "node_modules" ]; then
    print_yellow "📦 Cài đặt dependencies..."
    npm install
fi

# Function để kiểm tra port có đang được sử dụng
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        return 0  # Port đang được sử dụng
    else
        return 1  # Port trống
    fi
}

# Kiểm tra và dọn dẹp port 3000
if check_port 3000; then
    print_yellow "⚠️  Port 3000 đang được sử dụng. Đang dọn dẹp..."
    kill -9 $(lsof -ti:3000) 2>/dev/null || true
    sleep 2
fi

# Chọn mode chạy
echo ""
print_blue "🤔 Chọn cách chạy server:"
echo "1) Chỉ Express server (port 3000)"
echo "2) Express + Caddy (port 8080)"
echo "3) Docker Compose"
echo -n "Nhập lựa chọn (1-3): "
read choice

case $choice in
    1)
        print_green "🚀 Khởi động Express server..."
        npm run dev
        ;;
    2)
        # Kiểm tra Caddy có cài đặt không
        if ! command -v caddy &> /dev/null; then
            print_red "❌ Caddy chưa được cài đặt!"
            echo "Bạn muốn cài đặt Caddy ngay bây giờ? (y/n)"
            read install_caddy
            if [[ $install_caddy == "y" || $install_caddy == "Y" ]]; then
                ./install-caddy.sh
            else
                print_yellow "💡 Hãy chạy: ./install-caddy.sh để cài đặt Caddy"
                exit 1
            fi
        fi

        print_green "🚀 Khởi động Express server..."
        npm run dev &
        EXPRESS_PID=$!
        
        # Đợi Express server khởi động
        sleep 3
        
        # Kiểm tra Express server có chạy không
        if check_port 3000; then
            print_green "✅ Express server đã khởi động (PID: $EXPRESS_PID)"
        else
            print_red "❌ Express server không khởi động được"
            exit 1
        fi

        print_green "🌐 Khởi động Caddy..."
        caddy run --config Caddyfile &
        CADDY_PID=$!
        
        # Đợi Caddy khởi động
        sleep 2
        
        print_green "✅ Hệ thống đã khởi động thành công!"
        echo ""
        print_blue "🌐 Truy cập server:"
        echo "   - Express trực tiếp: http://localhost:3000"
        echo "   - Qua Caddy:        http://localhost:8080"
        echo "   - Health check:     http://localhost:8081/health"
        echo ""
        print_yellow "⏹️  Để dừng, nhấn Ctrl+C"
        
        # Trap để dọn dẹp khi exit
        trap "kill $EXPRESS_PID $CADDY_PID 2>/dev/null" EXIT
        
        # Đợi
        wait
        ;;
    3)
        print_green "🐳 Khởi động với Docker Compose..."
        if command -v docker-compose &> /dev/null; then
            docker-compose up --build
        elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
            docker compose up --build
        else
            print_red "❌ Docker hoặc Docker Compose chưa được cài đặt!"
            print_yellow "💡 Hãy cài đặt Docker Desktop: https://www.docker.com/products/docker-desktop"
            exit 1
        fi
        ;;
    *)
        print_red "❌ Lựa chọn không hợp lệ!"
        exit 1
        ;;
esac