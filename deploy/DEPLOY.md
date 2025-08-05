# 🚀 部署指南

## 快速部署（推荐）

```bash
# 1. 拉取最新代码
git pull origin main

# 2. 使用快速部署脚本
chmod +x deploy/quick-deploy.sh
./deploy/quick-deploy.sh
```

## 手动部署

如果自动脚本有问题，请按以下步骤手动部署：

### 步骤1：环境准备
```bash
# 修复主机名解析
echo "127.0.0.1 $(hostname)" | sudo tee -a /etc/hosts

# 切换到项目目录
cd /root/sms-verification-platform
```

### 步骤2：安装依赖
```bash
npm install
npm run build
cp deploy/server.js dist/
```

### 步骤3：安装PM2
```bash
# 方法1：直接安装
npm install -g pm2 --unsafe-perm --no-fund --no-audit

# 方法2：如果失败，使用sudo
sudo npm install -g pm2 --unsafe-perm --no-fund --no-audit

# 方法3：使用国内镜像
npm config set registry https://registry.npmmirror.com
npm install -g pm2 --unsafe-perm
```

### 步骤4：启动应用
```bash
cd dist
pm2 start server.js --name "sms-verification"
pm2 save
```

## 常见问题

### PM2安装卡住
```bash
# 取消安装
Ctrl+C

# 清理缓存
npm cache clean --force

# 使用国内镜像重试
npm config set registry https://registry.npmmirror.com
npm install -g pm2 --unsafe-perm
```

### 不使用PM2的替代方案
```bash
# 直接运行
cd dist
node server.js

# 或后台运行
nohup node server.js > app.log 2>&1 &
```

## 验证部署

```bash
# 查看状态
pm2 status

# 查看日志
pm2 logs sms-verification

# 访问应用
curl http://localhost:3000
```

## 文件说明

- `quick-deploy.sh` - 快速部署脚本（推荐）
- `deploy.sh` - 完整部署脚本（包含更多检查）
- `manual-deploy.md` - 详细手动部署指南
- `server.js` - Express服务器文件 