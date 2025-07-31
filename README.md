# 📱 短信验证码接收平台

基于Vue 3 + Element Plus的短信验证码接收平台UI，支持多种API操作。

## ✨ 功能特性

- 🔐 **用户信息管理**: 获取用户信息、积分查询
- 📱 **手机号管理**: 获取手机号、批量操作、状态查询
- 🔑 **验证码处理**: 获取验证码、状态查询
- ⚫ **黑名单管理**: 加入黑名单、查询黑名单状态
- 📊 **统计分析**: 国家号码统计、使用情况分析
- 🎨 **现代化UI**: 基于Element Plus的美观界面
- 📱 **响应式设计**: 支持桌面和移动端

## 🚀 快速开始

### 环境要求
- Node.js 18.0+
- npm 8.0+

### 安装依赖
```bash
npm install
```

### 开发模式
```bash
npm run dev
```

### 生产构建
```bash
npm run build
```

### 生产部署
```bash
npm run deploy
```

## 📋 API接口

### 用户信息
- `getUserInfo` - 获取用户信息
- `getCountryPhoneNum` - 查询国家号码统计

### 手机号管理
- `getMobile` - 获取手机号（版本1）
- `getMobileCode` - 获取手机号（版本2）
- `passMobile` - 释放手机号
- `getStatus` - 查询号码状态

### 验证码处理
- `getMsg` - 获取验证码

### 黑名单管理
- `addBlack` - 加入黑名单
- `getBlack` - 查询黑名单状态

## 🏗️ 项目结构

```
sms-verification-ui/
├── src/
│   ├── App.vue          # 主应用组件
│   ├── main.js          # 应用入口
│   └── api.js           # API接口封装
├── dist/                # 构建输出目录
├── server.js            # 生产服务器
├── package.json         # 项目配置
└── README.md           # 项目文档
```

## 🔧 配置说明

### API配置
在 `src/api.js` 中配置API基础地址：
```javascript
const BASE_URL = 'https://api.durianrcs.com/out/ext_api'
```

### 环境变量
创建 `.env` 文件：
```env
# 服务器端口
PORT=3000

# 生产环境
NODE_ENV=production
```

## 🌐 部署选项

### 静态部署
```bash
npm run build
# 将 dist/ 文件夹部署到静态服务器
```

### 完整部署
```bash
npm run deploy
# 启动包含静态文件服务的Node.js服务器
```

### 使用PM2管理
```bash
npm install -g pm2
pm2 start server.js --name "sms-verification"
pm2 startup
pm2 save
```

## 📊 技术栈

- **前端框架**: Vue 3
- **UI组件库**: Element Plus
- **构建工具**: Vite
- **HTTP客户端**: Axios
- **服务器**: Express.js
- **样式**: CSS3 + Element Plus主题

## 🔒 安全说明

- 所有API请求使用HTTPS
- 支持CORS跨域请求
- 生产环境建议配置防火墙
- 定期更新依赖包

## 📞 技术支持

如有问题，请检查：
1. Node.js版本是否符合要求
2. 网络连接是否正常
3. API密钥是否有效
4. 服务器防火墙设置

## 📄 许可证

MIT License

---

**注意**: 本项目使用真实API接口，请确保您有有效的API密钥和访问权限。 