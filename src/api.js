import axios from 'axios'
import { ElMessage } from 'element-plus'

const BASE_URL = '/api'

// 创建axios实例
const api = axios.create({
  baseURL: BASE_URL,
  timeout: 15000, // 增加超时时间
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8'
  },
  withCredentials: false
})

// 请求拦截器
api.interceptors.request.use(
  config => {
    // 添加请求时间戳
    config.metadata = { startTime: new Date() }
    return config
  },
  error => {
    console.error('请求拦截器错误:', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
api.interceptors.response.use(
  response => {
    // 计算请求耗时
    const endTime = new Date()
    const startTime = response.config.metadata.startTime
    const duration = endTime - startTime
    
    console.log(`API请求完成: ${response.config.url} (${duration}ms)`)
    
    // 检查响应状态
    if (response.data && response.data.code !== undefined) {
      if (response.data.code !== 200) {
        // API返回错误
        const errorMsg = response.data.msg || '请求失败'
        ElMessage.error(errorMsg)
        return Promise.reject(new Error(errorMsg))
      }
    }
    
    return response.data
  },
  error => {
    console.error('API请求错误:', error)
    
    let errorMessage = '网络请求失败'
    
    if (error.response) {
      // 服务器响应了错误状态码
      const status = error.response.status
      switch (status) {
        case 400:
          errorMessage = '请求参数错误'
          break
        case 401:
          errorMessage = '未授权，请检查API密钥'
          break
        case 403:
          errorMessage = '访问被拒绝'
          break
        case 404:
          errorMessage = '请求的资源不存在'
          break
        case 500:
          errorMessage = '服务器内部错误'
          break
        case 502:
          errorMessage = '网关错误'
          break
        case 503:
          errorMessage = '服务不可用'
          break
        default:
          errorMessage = `请求失败 (${status})`
      }
    } else if (error.request) {
      // 请求已发出但没有收到响应
      errorMessage = '网络连接超时，请检查网络连接'
    } else {
      // 请求配置出错
      errorMessage = '请求配置错误'
    }
    
    ElMessage.error(errorMessage)
    return Promise.reject(error)
  }
)

// 重试机制
const retryRequest = async (requestFn, maxRetries = 3, delay = 1000) => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await requestFn()
    } catch (error) {
      if (i === maxRetries - 1) {
        throw error
      }
      console.log(`请求失败，${delay}ms后重试 (${i + 1}/${maxRetries})`)
      await new Promise(resolve => setTimeout(resolve, delay))
      delay *= 2 // 指数退避
    }
  }
}

export default {
  // 获取用户信息
  getUserInfo(name, apiKey) {
    return retryRequest(() => api.get('/getUserInfo', {
      params: { name, ApiKey: apiKey }
    }))
  },

  // 获取手机号
  getMobile(params) {
    return retryRequest(() => api.get('/getMobile', { params }))
  },

  // 获取手机号（版本2）
  getMobileCode(params) {
    return retryRequest(() => api.get('/getMobileCode', { params }))
  },

  // 获取验证码
  getMsg(params) {
    return retryRequest(() => api.get('/getMsg', { params }))
  },

  // 释放手机号
  passMobile(params) {
    return retryRequest(() => api.get('/passMobile', { params }))
  },

  // 加黑名单
  addBlack(params) {
    return retryRequest(() => api.get('/addBlack', { params }))
  },

  // 查询号码状态
  getStatus(params) {
    return retryRequest(() => api.get('/getStatus', { params }))
  },

  // 查询黑名单
  getBlack(params) {
    return retryRequest(() => api.get('/getBlack', { params }))
  },

  // 查询国家手机号数量
  getCountryPhoneNum(params) {
    return retryRequest(() => api.get('/getCountryPhoneNum', { params }))
  }
} 