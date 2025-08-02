#!/bin/bash

# Script cài đặt Caddy cho macOS và Linux

echo "🚀 Đang cài đặt Caddy..."

# Kiểm tra hệ điều hành
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo "🖥️  Hệ điều hành: ${MACHINE}"

if [[ "$MACHINE" == "Mac" ]]; then
    # macOS - sử dụng Homebrew
    if command -v brew >/dev/null 2>&1; then
        echo "📦 Cài đặt Caddy qua Homebrew..."
        brew install caddy
    else
        echo "❌ Homebrew chưa được cài đặt. Hãy cài đặt Homebrew trước:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo "   Sau đó chạy lại script này."
        exit 1
    fi
elif [[ "$MACHINE" == "Linux" ]]; then
    # Linux - sử dụng script chính thức
    echo "📦 Cài đặt Caddy cho Linux..."
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update
    sudo apt install caddy
else
    echo "❌ Hệ điều hành không được hỗ trợ: ${MACHINE}"
    echo "Hãy tham khảo: https://caddyserver.com/docs/install"
    exit 1
fi

# Kiểm tra cài đặt
if command -v caddy >/dev/null 2>&1; then
    echo "✅ Caddy đã được cài đặt thành công!"
    echo "📖 Phiên bản: $(caddy version)"
    echo ""
    echo "🎉 Bây giờ bạn có thể chạy:"
    echo "   caddy run --config Caddyfile"
    echo ""
    echo "🌐 Truy cập server qua:"
    echo "   - http://localhost:8080 (qua Caddy)"
    echo "   - http://localhost:3000 (trực tiếp Express)"
else
    echo "❌ Có lỗi khi cài đặt Caddy"
    exit 1
fi