# 🚀 部署目录

本目录包含Linux服务器部署相关的所有文件和配置。

## 📁 文件说明

### 📋 部署文档
- **linux-deploy.md** - Linux服务器详细部署指南
- **README.md** - 本说明文件

### 🔧 部署脚本
- **deploy.sh** - Linux服务器一键部署脚本（已优化权限处理）
- **fix-permissions.sh** - 权限修复辅助脚本

### ⚙️ 配置文件
- **.env.production** - 生产环境配置文件
- **server.js** - Express服务器文件（用于生产环境）

## 🚀 快速部署

### 方法1：直接部署（推荐）
```bash
# 给脚本执行权限
chmod +x deploy.sh

# 运行部署脚本
./deploy.sh
```

### 方法2：权限问题修复
如果遇到权限问题，先运行权限修复脚本：
```bash
# 给权限修复脚本执行权限
chmod +x fix-permissions.sh

# 运行权限修复
./fix-permissions.sh

# 然后运行部署脚本
./deploy.sh
```

## 🔧 权限优化说明

### 新增权限检查功能
- ✅ 自动检查sudo权限
- ✅ 检查关键目录写权限
- ✅ 自动修复文件权限
- ✅ 修复npm缓存权限
- ✅ 修复PM2目录权限
- ✅ 设置正确的文件所有者

### 常见权限问题解决
1. **目录权限不足**：脚本会自动修复项目目录和deploy目录权限
2. **npm权限问题**：自动修复npm缓存和全局目录权限
3. **PM2权限问题**：自动修复PM2配置目录权限
4. **脚本执行权限**：自动确保所有脚本有执行权限

## 📖 详细说明

请查看 [linux-deploy.md](./linux-deploy.md) 获取完整的部署指南。

## 🆘 故障排除

### 权限问题
```bash
# 手动修复权限
./fix-permissions.sh
```

### 查看部署状态
```bash
# 查看PM2进程状态
pm2 status

# 查看应用日志
pm2 logs sms-verification

# 重启应用
pm2 restart sms-verification
``` 