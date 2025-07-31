import axios from 'axios'

const BASE_URL = '/api'

// 创建axios实例
const api = axios.create({
  baseURL: BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8'
  },
  withCredentials: false
})

// 响应拦截器
api.interceptors.response.use(
  response => response.data,
  error => {
    console.error('API请求错误:', error)
    return Promise.reject(error)
  }
)

export default {
  // 获取用户信息
  getUserInfo(name, apiKey) {
    return api.get('/getUserInfo', {
      params: { name, ApiKey: apiKey }
    })
  },

  // 获取手机号
  getMobile(params) {
    return api.get('/getMobile', { params })
  },

  // 获取手机号（版本2）
  getMobileCode(params) {
    return api.get('/getMobileCode', { params })
  },

  // 获取验证码
  getMsg(params) {
    return api.get('/getMsg', { params })
  },

  // 释放手机号
  passMobile(params) {
    return api.get('/passMobile', { params })
  },

  // 加黑名单
  addBlack(params) {
    return api.get('/addBlack', { params })
  },

  // 查询号码状态
  getStatus(params) {
    return api.get('/getStatus', { params })
  },

  // 查询黑名单
  getBlack(params) {
    return api.get('/getBlack', { params })
  },

  // 查询国家手机号数量
  getCountryPhoneNum(params) {
    return api.get('/getCountryPhoneNum', { params })
  }
} 