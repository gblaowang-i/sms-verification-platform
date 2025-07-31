const express = require('express');
const path = require('path');
const cors = require('cors');

const app = express();

// 启用CORS
app.use(cors());

// 静态文件服务
app.use(express.static(path.join(__dirname, 'dist')));

// 所有其他请求返回Vue应用
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 生产服务器运行在 http://localhost:${PORT}`);
  console.log('📱 短信验证码接收平台已部署');
  console.log('🌐 使用真实API: https://api.durianrcs.com/out/ext_api');
}); 