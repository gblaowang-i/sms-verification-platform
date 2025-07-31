# 🚀 部署目录

本目录包含Linux服务器部署相关的所有文件和配置。

## 📁 文件说明

### 📋 部署文档
- **linux-deploy.md** - Linux服务器详细部署指南
- **README.md** - 本说明文件

### 🔧 部署脚本
- **deploy.sh** - Linux服务器一键部署脚本（自动检测并安装环境）

### ⚙️ 配置文件
- **.env.production** - 生产环境配置文件
- **server.js** - Express服务器文件（用于生产环境）

## 🚀 快速部署

```bash
# 给脚本执行权限
chmod +x deploy.sh

# 运行部署脚本
./deploy.sh
```

脚本会自动检测并安装所需环境：
- ✅ 自动安装 curl、git
- ✅ 自动安装 Node.js 18.x
- ✅ 自动安装 PM2
- ✅ 自动修复文件权限
- ✅ 自动安装项目依赖
- ✅ 自动构建并启动应用

## 🔧 自动化功能

### 环境检测与安装
- ✅ 自动检测并安装 curl、git
- ✅ 自动检测并安装 Node.js 18.x
- ✅ 自动检测并安装 PM2
- ✅ 自动修复文件权限

### 部署流程
1. **环境检测**：检查并安装缺失的系统工具和运行环境
2. **权限修复**：自动修复项目目录和文件权限
3. **依赖安装**：清理旧依赖并安装项目依赖
4. **项目构建**：清理旧构建文件并重新构建
5. **应用启动**：停止旧进程并启动新应用
6. **部署验证**：检查进程状态和端口监听

## 📖 详细说明

请查看 [linux-deploy.md](./linux-deploy.md) 获取完整的部署指南。

## 🆘 故障排除

### 查看部署状态
```bash
# 查看PM2进程状态
pm2 status

# 查看应用日志
pm2 logs sms-verification

# 重启应用
pm2 restart sms-verification

# 停止应用
pm2 stop sms-verification

# 删除应用
pm2 delete sms-verification
```

### 重新部署
```bash
# 重新运行部署脚本
./deploy.sh
``` 