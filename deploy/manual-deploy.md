# 📋 手动部署指南

如果自动部署脚本卡住，请按照以下步骤手动部署：

## 步骤1：修复主机名问题

```bash
# 修复主机名解析
echo "127.0.0.1 $(hostname)" | sudo tee -a /etc/hosts
```

## 步骤2：切换到项目目录

```bash
cd /root/sms-verification-platform
```

## 步骤3：安装依赖

```bash
npm install
```

## 步骤4：构建项目

```bash
npm run build
```

## 步骤5：复制服务器文件

```bash
cp deploy/server.js dist/
```

## 步骤6：安装PM2（如果未安装）

### 方法1：直接安装
```bash
npm install -g pm2 --unsafe-perm --no-fund --no-audit
```

### 方法2：使用sudo（如果方法1失败）
```bash
sudo npm install -g pm2 --unsafe-perm --no-fund --no-audit
```

### 方法3：使用yarn（如果npm有问题）
```bash
sudo yarn global add pm2
```

### 方法4：使用npx（临时使用）
```bash
# 如果PM2安装失败，可以直接使用npx运行
cd dist
npx pm2 start server.js --name "sms-verification"
```

## 步骤7：启动应用

```bash
cd dist
pm2 start server.js --name "sms-verification"
pm2 save
```

## 步骤8：验证部署

```bash
# 查看应用状态
pm2 status

# 查看日志
pm2 logs sms-verification

# 检查端口
netstat -tulpn | grep :3000
```

## 常见问题解决

### PM2安装卡住
如果PM2安装一直卡住，可以：

1. **取消当前安装**：按 `Ctrl+C`
2. **清理npm缓存**：
   ```bash
   npm cache clean --force
   ```
3. **使用国内镜像**：
   ```bash
   npm config set registry https://registry.npmmirror.com
   npm install -g pm2 --unsafe-perm
   ```

### 权限问题
```bash
# 修复文件权限
sudo chown -R $USER:$USER /root/sms-verification-platform
chmod +x deploy/*.sh
```

### 端口被占用
```bash
# 查找占用端口的进程
lsof -i :3000

# 杀死进程
kill -9 <PID>
```

### 网络问题
```bash
# 检查网络连接
ping -c 3 registry.npmjs.org

# 如果网络有问题，使用国内镜像
npm config set registry https://registry.npmmirror.com
```

## 不使用PM2的替代方案

如果PM2安装有问题，可以使用以下替代方案：

### 方案1：使用node直接运行
```bash
cd dist
node server.js
```

### 方案2：使用nohup后台运行
```bash
cd dist
nohup node server.js > app.log 2>&1 &
```

### 方案3：使用screen
```bash
screen -S sms-app
cd dist
node server.js
# 按 Ctrl+A+D 分离screen
```

## 验证应用

部署完成后，访问：
- http://服务器IP:3000
- 或者 http://localhost:3000

如果无法访问，检查：
1. 防火墙设置
2. 端口是否开放
3. 应用是否正常启动 