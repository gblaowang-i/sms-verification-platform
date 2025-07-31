<template>
  <div id="app">
    <el-container>
      <el-header>
        <h1>📱 短信验证码接收平台</h1>
      </el-header>
      
      <el-main>
        <!-- 配置区域 -->
        <el-card class="config-card">
          <template #header>
            <div class="card-header">
              <span>🔧 平台配置</span>
            </div>
          </template>
          
          <el-form :model="config" label-width="120px" :rules="rules" ref="configForm">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="用户名" prop="name">
                  <el-input v-model="config.name" placeholder="请输入用户名" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="API密钥" prop="apiKey">
                  <el-input v-model="config.apiKey" placeholder="请输入API密钥" show-password />
                </el-form-item>
              </el-col>
            </el-row>
            
            <el-row :gutter="20">
              <el-col :span="8">
                <el-form-item label="项目ID" prop="pid">
                  <el-input v-model="config.pid" placeholder="请输入项目ID" />
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="获取数量" prop="num">
                  <el-input-number v-model="config.num" :min="1" :max="10" />
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="国家代码">
                  <el-input v-model="config.cuy" placeholder="如：bo,us,cn" />
                </el-form-item>
              </el-col>
            </el-row>
            
            <el-row :gutter="20">
              <el-col :span="8">
                <el-form-item label="过滤黑名单">
                  <el-select v-model="config.noblack">
                    <el-option label="只过滤自己的黑名单" :value="0" />
                    <el-option label="过滤所有用户黑名单" :value="1" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="获取方式">
                  <el-select v-model="config.serial">
                    <el-option label="单条" :value="2" />
                    <el-option label="多条" :value="1" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="API版本">
                  <el-select v-model="config.apiVersion">
                    <el-option label="版本1 (直接返回手机号)" value="v1" />
                    <el-option label="版本2 (返回手机号+区号)" value="v2" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>
          </el-form>
          
          <div class="button-group">
            <el-button type="primary" @click="getUserInfo" :loading="loading.userInfo">
              <el-icon><User /></el-icon>
              获取用户信息
            </el-button>
            <el-button type="success" @click="getCountryPhoneNum" :loading="loading.countryNum">
              <el-icon><Globe /></el-icon>
              查询国家号码数量
            </el-button>
          </div>
        </el-card>

        <!-- 操作区域 -->
        <el-card class="operation-card">
          <template #header>
            <div class="card-header">
              <span>🚀 批量操作</span>
            </div>
          </template>
          
          <div class="button-group">
            <el-button type="primary" @click="getMobileNumbers" :loading="loading.getMobile">
              <el-icon><Phone /></el-icon>
              获取手机号码
            </el-button>
            <el-button type="warning" @click="getVerificationCodes" :loading="loading.getMsg">
              <el-icon><Message /></el-icon>
              获取验证码
            </el-button>
            <el-button type="danger" @click="addToBlacklist" :loading="loading.addBlack">
              <el-icon><Delete /></el-icon>
              加入黑名单
            </el-button>
            <el-button type="info" @click="releaseNumbers" :loading="loading.passMobile">
              <el-icon><Refresh /></el-icon>
              释放号码
            </el-button>
          </div>
        </el-card>

        <!-- 结果显示区域 -->
        <el-card class="result-card">
          <template #header>
            <div class="card-header">
              <span>📊 结果展示</span>
              <el-button type="text" @click="clearResults">清空结果</el-button>
            </div>
          </template>
          
          <el-tabs v-model="activeTab">
            <el-tab-pane label="手机号码" name="phones">
              <div class="result-content">
                <el-table :data="phoneNumbers" style="width: 100%">
                  <el-table-column prop="phone" label="手机号码" />
                  <el-table-column prop="country" label="国家区号" />
                  <el-table-column prop="status" label="状态">
                    <template #default="scope">
                      <el-tag :type="getStatusType(scope.row.status)">
                        {{ scope.row.status }}
                      </el-tag>
                    </template>
                  </el-table-column>
                  <el-table-column prop="verificationCode" label="验证码" />
                  <el-table-column label="操作">
                    <template #default="scope">
                      <el-button size="small" @click="getSingleCode(scope.row)">
                        获取验证码
                      </el-button>
                      <el-button size="small" type="danger" @click="addSingleToBlacklist(scope.row)">
                        加入黑名单
                      </el-button>
                    </template>
                  </el-table-column>
                </el-table>
              </div>
            </el-tab-pane>
            
            <el-tab-pane label="用户信息" name="userInfo">
              <div class="result-content" v-if="userInfo">
                <el-descriptions :column="2" border>
                  <el-descriptions-item label="用户名">{{ userInfo.username }}</el-descriptions-item>
                  <el-descriptions-item label="积分">{{ userInfo.score }}</el-descriptions-item>
                  <el-descriptions-item label="创建时间">{{ userInfo.create_date }}</el-descriptions-item>
                </el-descriptions>
              </div>
            </el-tab-pane>
            
            <el-tab-pane label="国家号码统计" name="countryStats">
              <div class="result-content" v-if="countryStats">
                <el-descriptions :column="3" border>
                  <el-descriptions-item v-for="(count, country) in countryStats" :key="country" :label="country">
                    {{ count }}
                  </el-descriptions-item>
                </el-descriptions>
              </div>
            </el-tab-pane>
          </el-tabs>
        </el-card>
      </el-main>
    </el-container>
  </div>
</template>

<script>
import api from './api.js'
import { ElMessage, ElMessageBox } from 'element-plus'

export default {
  name: 'App',
  data() {
    return {
      config: {
        name: '',
        apiKey: '',
        pid: '',
        num: 5,
        cuy: '',
        noblack: 0,
        serial: 2,
        apiVersion: 'v1'
      },
      rules: {
        name: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
        apiKey: [{ required: true, message: '请输入API密钥', trigger: 'blur' }],
        pid: [{ required: true, message: '请输入项目ID', trigger: 'blur' }]
      },
      loading: {
        userInfo: false,
        countryNum: false,
        getMobile: false,
        getMsg: false,
        addBlack: false,
        passMobile: false
      },
      phoneNumbers: [],
      userInfo: null,
      countryStats: null,
      activeTab: 'phones'
    }
  },
  methods: {
    async getUserInfo() {
      if (!this.config.name || !this.config.apiKey) {
        ElMessage.error('请先填写用户名和API密钥')
        return
      }
      
      this.loading.userInfo = true
      try {
        const response = await api.getUserInfo(this.config.name, this.config.apiKey)
        if (response.code === 200) {
          this.userInfo = response.data
          this.activeTab = 'userInfo'
          ElMessage.success('获取用户信息成功')
        } else {
          ElMessage.error(response.msg || '获取用户信息失败')
        }
      } catch (error) {
        ElMessage.error('获取用户信息失败')
      } finally {
        this.loading.userInfo = false
      }
    },

    async getCountryPhoneNum() {
      if (!this.config.name || !this.config.apiKey) {
        ElMessage.error('请先填写用户名和API密钥')
        return
      }
      
      this.loading.countryNum = true
      try {
        const response = await api.getCountryPhoneNum({
          name: this.config.name,
          ApiKey: this.config.apiKey,
          pid: this.config.pid || null
        })
        if (response.code === 200) {
          this.countryStats = response.data
          this.activeTab = 'countryStats'
          ElMessage.success('获取国家号码统计成功')
        } else {
          ElMessage.error(response.msg || '获取国家号码统计失败')
        }
      } catch (error) {
        ElMessage.error('获取国家号码统计失败')
      } finally {
        this.loading.countryNum = false
      }
    },

    async getMobileNumbers() {
      if (!this.validateConfig()) return
      
      this.loading.getMobile = true
      try {
        const params = {
          name: this.config.name,
          ApiKey: this.config.apiKey,
          pid: this.config.pid,
          num: this.config.num,
          noblack: this.config.noblack,
          serial: this.config.serial
        }
        
        if (this.config.cuy) params.cuy = this.config.cuy
        
        const apiMethod = this.config.apiVersion === 'v2' ? api.getMobileCode : api.getMobile
        const response = await apiMethod(params)
        
        if (response.code === 200) {
          const phones = Array.isArray(response.data) ? response.data : [response.data]
          this.phoneNumbers = phones.map(phone => {
            if (this.config.apiVersion === 'v2') {
              const [phoneNumber, countryCode] = phone.split(',')
              return {
                phone: phoneNumber,
                country: countryCode,
                status: '已获取',
                verificationCode: ''
              }
            } else {
              return {
                phone: phone,
                country: '',
                status: '已获取',
                verificationCode: ''
              }
            }
          })
          this.activeTab = 'phones'
          ElMessage.success(`成功获取 ${this.phoneNumbers.length} 个手机号码`)
        } else {
          ElMessage.error(response.msg || '获取手机号码失败')
        }
      } catch (error) {
        ElMessage.error('获取手机号码失败')
      } finally {
        this.loading.getMobile = false
      }
    },

    async getVerificationCodes() {
      if (this.phoneNumbers.length === 0) {
        ElMessage.warning('请先获取手机号码')
        return
      }
      
      this.loading.getMsg = true
      try {
        const promises = this.phoneNumbers.map(async (phone) => {
          try {
            const response = await api.getMsg({
              name: this.config.name,
              ApiKey: this.config.apiKey,
              pid: this.config.pid,
              pn: phone.phone,
              serial: this.config.serial
            })
            
            if (response.code === 200) {
              phone.verificationCode = response.data
              phone.status = '验证码已获取'
            } else if (response.code === 407) {
              // 多条数据格式
              const codes = response.data.split(';').filter(code => code)
              codes.forEach(code => {
                const [project, verificationCode] = code.split(':')
                const targetPhone = this.phoneNumbers.find(p => p.phone.includes(project))
                if (targetPhone) {
                  targetPhone.verificationCode = verificationCode
                  targetPhone.status = '验证码已获取'
                }
              })
            } else {
              phone.status = '获取失败'
            }
          } catch (error) {
            phone.status = '获取失败'
          }
        })
        
        await Promise.all(promises)
        ElMessage.success('验证码获取完成')
      } catch (error) {
        ElMessage.error('获取验证码失败')
      } finally {
        this.loading.getMsg = false
      }
    },

    async getSingleCode(phone) {
      try {
        const response = await api.getMsg({
          name: this.config.name,
          ApiKey: this.config.apiKey,
          pid: this.config.pid,
          pn: phone.phone,
          serial: this.config.serial
        })
        
        if (response.code === 200) {
          phone.verificationCode = response.data
          phone.status = '验证码已获取'
          ElMessage.success('获取验证码成功')
        } else {
          ElMessage.error(response.msg || '获取验证码失败')
        }
      } catch (error) {
        ElMessage.error('获取验证码失败')
      }
    },

    async addToBlacklist() {
      if (this.phoneNumbers.length === 0) {
        ElMessage.warning('请先获取手机号码')
        return
      }
      
      try {
        await ElMessageBox.confirm('确定要将所有号码加入黑名单吗？', '确认操作', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })
        
        this.loading.addBlack = true
        const promises = this.phoneNumbers.map(async (phone) => {
          try {
            const response = await api.addBlack({
              name: this.config.name,
              ApiKey: this.config.apiKey,
              pid: this.config.pid,
              pn: phone.phone
            })
            
            if (response.code === 200) {
              phone.status = '已加入黑名单'
            }
          } catch (error) {
            console.error('加入黑名单失败:', error)
          }
        })
        
        await Promise.all(promises)
        ElMessage.success('批量加入黑名单完成')
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('加入黑名单失败')
        }
      } finally {
        this.loading.addBlack = false
      }
    },

    async addSingleToBlacklist(phone) {
      try {
        const response = await api.addBlack({
          name: this.config.name,
          ApiKey: this.config.apiKey,
          pid: this.config.pid,
          pn: phone.phone
        })
        
        if (response.code === 200) {
          phone.status = '已加入黑名单'
          ElMessage.success('加入黑名单成功')
        } else {
          ElMessage.error(response.msg || '加入黑名单失败')
        }
      } catch (error) {
        ElMessage.error('加入黑名单失败')
      }
    },

    async releaseNumbers() {
      if (this.phoneNumbers.length === 0) {
        ElMessage.warning('请先获取手机号码')
        return
      }
      
      try {
        await ElMessageBox.confirm('确定要释放所有号码吗？', '确认操作', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })
        
        this.loading.passMobile = true
        const promises = this.phoneNumbers.map(async (phone) => {
          try {
            const response = await api.passMobile({
              name: this.config.name,
              ApiKey: this.config.apiKey,
              pid: this.config.pid,
              pn: phone.phone,
              serial: this.config.serial
            })
            
            if (response.code === 200) {
              phone.status = '已释放'
            }
          } catch (error) {
            console.error('释放号码失败:', error)
          }
        })
        
        await Promise.all(promises)
        ElMessage.success('批量释放号码完成')
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('释放号码失败')
        }
      } finally {
        this.loading.passMobile = false
      }
    },

    validateConfig() {
      if (!this.config.name || !this.config.apiKey || !this.config.pid) {
        ElMessage.error('请填写完整的配置信息')
        return false
      }
      return true
    },

    getStatusType(status) {
      const statusMap = {
        '已获取': 'success',
        '验证码已获取': 'success',
        '已加入黑名单': 'danger',
        '已释放': 'info',
        '获取失败': 'warning'
      }
      return statusMap[status] || 'info'
    },

    clearResults() {
      this.phoneNumbers = []
      this.userInfo = null
      this.countryStats = null
      ElMessage.success('结果已清空')
    }
  }
}
</script>

<style scoped>
#app {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.el-header {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 24px;
  font-weight: bold;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.el-main {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.config-card,
.operation-card,
.result-card {
  margin-bottom: 20px;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
  background: rgba(255, 255, 255, 0.95);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
  font-size: 16px;
}

.button-group {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  margin-top: 20px;
}

.result-content {
  min-height: 200px;
}

.el-table {
  border-radius: 8px;
  overflow: hidden;
}

.el-descriptions {
  margin-top: 10px;
}

@media (max-width: 768px) {
  .button-group {
    flex-direction: column;
  }
  
  .el-form-item {
    margin-bottom: 15px;
  }
}
</style> 