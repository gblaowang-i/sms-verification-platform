#!/bin/bash

echo "🚀 开始部署短信验证码接收平台到Linux服务器..."

# 检查Node.js是否安装
if ! command -v node &> /dev/null; then
    echo "📦 安装Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "✅ Node.js已安装: $(node --version)"
fi

# 检查npm是否安装
if ! command -v npm &> /dev/null; then
    echo "❌ npm未安装，请检查Node.js安装"
    exit 1
else
    echo "✅ npm已安装: $(npm --version)"
fi

# 安装PM2（如果未安装）
if ! command -v pm2 &> /dev/null; then
    echo "📦 安装PM2..."
    sudo npm install -g pm2
else
    echo "✅ PM2已安装: $(pm2 --version)"
fi

# 安装项目依赖
echo "📦 安装项目依赖..."
npm install

# 构建项目
echo "🔨 构建Vue应用..."
npm run build

# 检查构建是否成功
if [ ! -d "dist" ]; then
    echo "❌ 构建失败，dist目录不存在"
    echo "当前目录: $(pwd)"
    echo "目录内容:"
    ls -la
    exit 1
fi

echo "✅ 构建完成！"

# 使用PM2启动应用
echo "🚀 启动应用..."
pm2 start server.js --name "sms-verification"

# 保存PM2配置
pm2 save

# 设置开机自启
pm2 startup

echo ""
echo "🎉 部署完成！"
echo "📱 应用名称: sms-verification"
echo "🌐 访问地址: http://your-server-ip:3000"
echo ""
echo "📋 常用命令："
echo "  pm2 status          # 查看应用状态"
echo "  pm2 logs sms-verification    # 查看日志"
echo "  pm2 restart sms-verification # 重启应用"
echo "  pm2 stop sms-verification    # 停止应用"
echo "  pm2 delete sms-verification  # 删除应用" 