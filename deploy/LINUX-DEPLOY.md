# 🐧 Linux服务器部署指南

## 📋 部署前准备

### 服务器要求
- **操作系统**: Ubuntu 20.04+ / CentOS 7+ / Debian 10+
- **内存**: 最少1GB，推荐2GB+
- **存储**: 最少10GB可用空间
- **网络**: 公网IP或域名

### 软件要求
- Node.js 18.0+
- npm 8.0+
- PM2 (自动安装)
- Nginx (可选，用于反向代理)

---

## 🚀 快速部署

### 方法1：使用自动部署脚本（推荐）

1. **上传项目文件到服务器**
   ```bash
   # 使用scp上传
   scp -r ./sms-verification-ui user@your-server-ip:/home/user/
   
   # 或使用git克隆
   git clone <your-repo-url> /home/user/sms-verification-ui
   ```

2. **进入项目目录**
   ```bash
   cd /home/user/sms-verification-ui
   ```

3. **给脚本执行权限**
   ```bash
   chmod +x deploy-linux.sh
   chmod +x setup-firewall.sh
   ```

4. **运行部署脚本**
   ```bash
   ./deploy-linux.sh
   ```

5. **配置防火墙（可选）**
   ```bash
   sudo ./setup-firewall.sh
   ```

### 方法2：手动部署

#### 步骤1：安装Node.js
```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# CentOS/RHEL
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# 验证安装
node --version
npm --version
```

#### 步骤2：安装PM2
```bash
sudo npm install -g pm2
```

#### 步骤3：部署应用
```bash
# 进入项目目录
cd /path/to/sms-verification-ui

# 安装依赖
npm install

# 构建项目
npm run build

# 启动应用
pm2 start server.js --name "sms-verification"

# 保存配置
pm2 save

# 设置开机自启
pm2 startup
```

---

## 🌐 配置Nginx反向代理

### 安装Nginx
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nginx

# CentOS/RHEL
sudo yum install nginx
```

### 配置Nginx
1. **复制配置文件**
   ```bash
   sudo cp nginx.conf /etc/nginx/sites-available/sms-verification
   ```

2. **修改配置文件**
   ```bash
   sudo nano /etc/nginx/sites-available/sms-verification
   ```
   
   将 `your-domain.com` 替换为您的域名或IP地址

3. **启用站点**
   ```bash
   sudo ln -s /etc/nginx/sites-available/sms-verification /etc/nginx/sites-enabled/
   ```

4. **测试配置**
   ```bash
   sudo nginx -t
   ```

5. **重启Nginx**
   ```bash
   sudo systemctl restart nginx
   sudo systemctl enable nginx
   ```

---

## 🔒 安全配置

### 防火墙设置
```bash
# 使用UFW (Ubuntu)
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable

# 使用iptables (CentOS)
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo service iptables save
```

### SSL证书配置（推荐）
```bash
# 安装Certbot
sudo apt install certbot python3-certbot-nginx

# 获取SSL证书
sudo certbot --nginx -d your-domain.com

# 自动续期
sudo crontab -e
# 添加: 0 12 * * * /usr/bin/certbot renew --quiet
```

---

## 📊 监控和维护

### PM2管理命令
```bash
# 查看应用状态
pm2 status

# 查看日志
pm2 logs sms-verification

# 重启应用
pm2 restart sms-verification

# 停止应用
pm2 stop sms-verification

# 删除应用
pm2 delete sms-verification

# 监控面板
pm2 monit
```

### 系统监控
```bash
# 查看系统资源
htop
df -h
free -h

# 查看端口占用
netstat -tulpn | grep :3000

# 查看Nginx状态
sudo systemctl status nginx
```

### 日志查看
```bash
# PM2日志
pm2 logs sms-verification --lines 100

# Nginx日志
sudo tail -f /var/log/nginx/sms-verification.access.log
sudo tail -f /var/log/nginx/sms-verification.error.log

# 系统日志
sudo journalctl -u nginx -f
```

---

## 🔧 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 查看端口占用
   sudo netstat -tulpn | grep :3000
   
   # 杀死进程
   sudo kill -9 <PID>
   ```

2. **权限问题**
   ```bash
   # 修改文件权限
   sudo chown -R $USER:$USER /path/to/project
   sudo chmod +x deploy-linux.sh
   ```

3. **内存不足**
   ```bash
   # 增加Node.js内存限制
   pm2 start server.js --name "sms-verification" --node-args="--max-old-space-size=4096"
   ```

4. **Nginx配置错误**
   ```bash
   # 测试配置
   sudo nginx -t
   
   # 查看错误日志
   sudo tail -f /var/log/nginx/error.log
   ```

5. **防火墙阻止**
   ```bash
   # 检查防火墙状态
   sudo ufw status
   sudo iptables -L
   ```

---

## 📈 性能优化

### Node.js优化
```bash
# 增加内存限制
pm2 start server.js --name "sms-verification" --node-args="--max-old-space-size=4096"

# 集群模式（多核CPU）
pm2 start server.js --name "sms-verification" -i max
```

### Nginx优化
```nginx
# 在nginx.conf中添加
worker_processes auto;
worker_connections 1024;

# 启用gzip压缩
gzip on;
gzip_types text/plain text/css application/json application/javascript;
```

### 系统优化
```bash
# 增加文件描述符限制
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf
```

---

## 🔄 更新部署

### 自动更新脚本
```bash
#!/bin/bash
cd /path/to/sms-verification-ui
git pull
npm install
npm run build
pm2 restart sms-verification
```

### 手动更新
```bash
# 停止应用
pm2 stop sms-verification

# 更新代码
git pull

# 安装依赖
npm install

# 重新构建
npm run build

# 启动应用
pm2 start sms-verification
```

---

## 📞 技术支持

### 检查清单
- [ ] Node.js版本 >= 18.0
- [ ] npm版本 >= 8.0
- [ ] PM2已安装并运行
- [ ] 防火墙配置正确
- [ ] Nginx配置正确（如果使用）
- [ ] SSL证书有效（如果使用）
- [ ] 域名解析正确
- [ ] API密钥有效

### 联系信息
如遇到问题，请检查：
1. 服务器日志
2. 应用日志
3. 网络连接
4. 防火墙设置
5. 域名解析

---

## 🎉 部署完成

部署成功后，您可以通过以下地址访问：
- **直接访问**: `http://your-server-ip:3000`
- **Nginx代理**: `http://your-domain.com`
- **HTTPS**: `https://your-domain.com`（如果配置了SSL）

恭喜！您的短信验证码接收平台已成功部署到Linux服务器！🎊 