#!/bin/bash

# 快速部署脚本 - 解决主机名解析问题
set -e

echo "🚀 开始快速部署..."

# 1. 修复主机名解析问题
echo "📝 修复主机名解析问题..."
CURRENT_HOSTNAME=$(hostname)
if ! grep -q "$CURRENT_HOSTNAME" /etc/hosts; then
    echo "127.0.0.1 $CURRENT_HOSTNAME" | sudo tee -a /etc/hosts > /dev/null
    echo "✅ 主机名已添加到/etc/hosts"
fi

# 2. 切换到项目目录
cd "$(dirname "$0")/.."
echo "📁 项目目录: $(pwd)"

# 3. 安装依赖
echo "📦 安装依赖..."
npm install

# 4. 构建项目
echo "🔨 构建项目..."
npm run build

# 5. 复制server.js到dist目录
echo "📋 复制服务器文件..."
cp deploy/server.js dist/

# 6. 安装PM2（如果未安装）
if ! command -v pm2 &> /dev/null; then
    echo "📥 安装PM2..."
    sudo npm install -g pm2 --unsafe-perm
fi

# 7. 停止旧进程
echo "🛑 停止旧进程..."
pm2 stop sms-verification 2>/dev/null || true
pm2 delete sms-verification 2>/dev/null || true

# 8. 启动新进程
echo "▶️ 启动应用..."
cd dist
pm2 start server.js --name "sms-verification"
pm2 save

# 9. 显示状态
echo "📊 应用状态:"
pm2 status

echo ""
echo "🎉 部署完成！"
echo "🌐 访问地址: http://$(hostname -I | awk '{print $1}'):3000"
echo "📋 查看日志: pm2 logs sms-verification" 