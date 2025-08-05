#!/bin/bash

# 简化部署脚本 - 避免PM2安装卡住
set -e

echo "🚀 开始简化部署..."

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

# 6. 检查PM2是否已安装
if command -v pm2 &> /dev/null; then
    echo "✅ PM2已安装: $(pm2 --version)"
else
    echo "📥 安装PM2..."
    # 使用npm直接安装，避免sudo权限问题
    npm install -g pm2 --unsafe-perm --no-fund --no-audit
    if [ $? -ne 0 ]; then
        echo "⚠️  PM2安装失败，尝试使用sudo..."
        sudo npm install -g pm2 --unsafe-perm --no-fund --no-audit
    fi
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