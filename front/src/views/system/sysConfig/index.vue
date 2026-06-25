<template>
   <div class="app-container">
      <el-tabs v-model="activeTab" type="border-card">
         <!-- 参数配置 Tab -->
         <el-tab-pane label="参数配置" name="system">
            <el-form label-width="140px" v-loading="loading">
               <!-- 登录过期配置 -->
               <el-divider content-position="left">登录过期配置</el-divider>
               <el-form-item label="Token有效期">
                  <el-input-number
                     v-model="systemForm.expireTime"
                     :min="1"
                     :max="1440"
                     :step="1"
                     controls-position="right"
                  />
                  <span style="margin-left: 10px">分钟</span>
                  <div style="color: #909399; font-size: 12px; line-height: 1.5; margin-top: 4px;">
                     修改后将影响Web端和APP端的新登录用户
                  </div>
               </el-form-item>

               <!-- 对象存储配置 -->
               <el-divider content-position="left">对象存储配置</el-divider>
               <el-form-item label="启用腾讯云COS">
                  <el-switch v-model="systemForm.cosEnabled" />
               </el-form-item>
               <el-form-item label="SecretId">
                  <el-input v-model="systemForm.cosSecretId" placeholder="请输入腾讯云SecretId" style="max-width: 400px" />
               </el-form-item>
               <el-form-item label="SecretKey">
                  <el-input v-model="systemForm.cosSecretKey" placeholder="请输入腾讯云SecretKey" show-password style="max-width: 400px" />
               </el-form-item>
               <el-form-item label="Bucket">
                  <el-input v-model="systemForm.cosBucket" placeholder="请输入COS存储桶名称" style="max-width: 400px" />
               </el-form-item>
               <el-form-item label="Region">
                  <el-select v-model="systemForm.cosRegion" placeholder="请选择COS地域" style="max-width: 400px">
                     <el-option label="华东-上海 (ap-shanghai)" value="ap-shanghai" />
                     <el-option label="华北-北京 (ap-beijing)" value="ap-beijing" />
                     <el-option label="华南-广州 (ap-guangzhou)" value="ap-guangzhou" />
                     <el-option label="西南-成都 (ap-chengdu)" value="ap-chengdu" />
                     <el-option label="华东-南京 (ap-nanjing)" value="ap-nanjing" />
                     <el-option label="西南-重庆 (ap-chongqing)" value="ap-chongqing" />
                  </el-select>
               </el-form-item>
               <el-form-item label="自定义域名">
                  <el-input v-model="systemForm.cosDomain" placeholder="请输入COS自定义域名" style="max-width: 400px" />
               </el-form-item>

               <!-- 安全策略配置 -->
               <el-divider content-position="left">安全策略配置</el-divider>
               <el-form-item label="启用验证码">
                  <el-switch v-model="systemForm.captchaEnabled" />
                  <div class="form-tip">开启后登录页将显示验证码</div>
               </el-form-item>
               <el-form-item label="是否允许注册">
                  <el-switch v-model="systemForm.registerUser" />
                  <div class="form-tip">关闭后 APP 登录页将隐藏"立即注册"入口</div>
               </el-form-item>
               <el-form-item label="验证码有效期">
                  <el-input-number v-model="systemForm.captchaExpire" :min="1" :max="60" controls-position="right" />
                  <span class="unit">分钟</span>
               </el-form-item>
               <el-form-item label="密码最大错误次数">
                  <el-input-number v-model="systemForm.maxRetryCount" :min="1" :max="10" controls-position="right" />
                  <span class="unit">次</span>
               </el-form-item>
               <el-form-item label="密码锁定时间">
                  <el-input-number v-model="systemForm.lockTime" :min="1" :max="1440" controls-position="right" />
                  <span class="unit">分钟</span>
               </el-form-item>
               <el-form-item label="密码字符范围">
                  <el-select v-model="systemForm.chrtype" placeholder="请选择密码字符范围" style="max-width: 400px">
                     <el-option label="不限" :value="0" />
                     <el-option label="数字（0-9）" :value="1" />
                     <el-option label="英文字母（a-z, A-Z）" :value="2" />
                     <el-option label="字母和数字" :value="3" />
                     <el-option label="字母数字和特殊字符" :value="4" />
                  </el-select>
               </el-form-item>
               <el-form-item label="初始密码修改策略">
                  <el-switch v-model="systemForm.initPasswordModify" :active-value="1" :inactive-value="0" />
                  <div class="form-tip">新用户首次登录或重置密码后是否提醒修改密码</div>
               </el-form-item>
               <el-form-item label="密码更新周期">
                  <el-input-number v-model="systemForm.passwordValidateDays" :min="0" :max="365" controls-position="right" />
                  <span class="unit">天（0表示不限制）</span>
                  <div class="form-tip">超过此天数未修改密码将提醒用户更新</div>
               </el-form-item>
               <el-form-item label="用户初始密码">
                  <el-input v-model="systemForm.initPassword" placeholder="请输入初始密码" style="max-width: 400px" />
                  <div class="form-tip">新建用户和重置密码时的默认密码</div>
               </el-form-item>
               <el-form-item label="登录IP黑名单">
                  <el-input
                     v-model="systemForm.blackIPList"
                     type="textarea"
                     :rows="3"
                     placeholder="多个IP以分号(;)分隔，如：192.168.1.1;10.0.0.1"
                     style="max-width: 500px"
                  />
                  <div class="form-tip">黑名单中的IP将无法登录系统，多个IP以分号(;)分隔</div>
               </el-form-item>

               <!-- 高德地图配置 -->
               <el-divider content-position="left">高德地图配置</el-divider>
               <el-form-item label="Web服务Key">
                  <el-input v-model="systemForm.amapWebServiceKey" placeholder="请输入Web服务Key" style="max-width: 500px" />
                  <div class="form-tip">用于APP端逆地理编码和IP定位，修改后立即生效</div>
               </el-form-item>
               <el-form-item label="JS API Key">
                  <el-input v-model="systemForm.amapJsApiKey" placeholder="请输入JS API Key" style="max-width: 500px" />
                  <div class="form-tip">用于Web端地图组件加载，修改后刷新页面生效</div>
               </el-form-item>
               <el-form-item label="安全密钥">
                  <el-input v-model="systemForm.amapSecurityJsCode" placeholder="请输入安全密钥" show-password style="max-width: 500px" />
                  <div class="form-tip">JS API安全密钥，与JS API Key配合使用</div>
               </el-form-item>

               <el-form-item>
                  <el-button type="primary" @click="saveSystemConfig">保 存</el-button>
               </el-form-item>
            </el-form>
         </el-tab-pane>

         <!-- 业务配置 Tab -->
         <el-tab-pane label="业务配置" name="business">
            <el-form label-width="180px" v-loading="loading">
               <el-divider content-position="left">销售开单配置</el-divider>
               <el-form-item label="允许修改套餐次数">
                  <el-switch v-model="bizForm.packageQuantityEditable" />
                  <div style="color: #909399; font-size: 12px; line-height: 1.5; margin-top: 4px;">
                     修改后将影响Web端和APP端
                  </div>
               </el-form-item>
               <el-form-item label="允许修改套餐成交金额">
                  <el-switch v-model="bizForm.packageDealAmountEditable" />
                  <div style="color: #909399; font-size: 12px; line-height: 1.5; margin-top: 4px;">
                     修改后将影响Web端和APP端
                  </div>
               </el-form-item>
               <el-form-item label="允许修改套餐实付金额">
                  <el-switch v-model="bizForm.packagePaidAmountEditable" />
                  <div style="color: #909399; font-size: 12px; line-height: 1.5; margin-top: 4px;">
                     修改后将影响Web端和APP端
                  </div>
               </el-form-item>

               <el-divider content-position="left">考勤配置</el-divider>
               <el-form-item label="允许手动输入打卡地址">
                  <el-switch v-model="bizForm.allowManualAddress" />
                  <div style="color: #909399; font-size: 12px; line-height: 1.5; margin-top: 4px;">
                     关闭后，APP端考勤打卡定位失败时无法手动输入地址
                  </div>
               </el-form-item>

               <el-form-item>
                  <el-button type="primary" @click="saveBizConfig">保 存</el-button>
               </el-form-item>
            </el-form>
         </el-tab-pane>
      </el-tabs>
   </div>
</template>

<script setup name="SysConfig">
/**
 * @description 系统配置页面 - 参数配置与业务配置管理
 * @description 提供登录过期时间、对象存储、销售开单等配置项的查看与修改
 */
import { listConfig, updateConfig, refreshCache } from "@/api/system/config"

const { proxy } = getCurrentInstance()

const activeTab = ref("system")
const loading = ref(false)

// 配置项原始数据（包含configId等完整信息）
const configMap = ref({})

// 参数配置表单
const systemForm = reactive({
   expireTime: 300,
   cosEnabled: false,
   cosSecretId: '',
   cosSecretKey: '',
   cosBucket: '',
   cosRegion: 'ap-shanghai',
   cosDomain: '',
   // 安全策略
   captchaEnabled: true,
   registerUser: false,
   captchaExpire: 5,
   maxRetryCount: 5,
   lockTime: 10,
   chrtype: 0,
   initPasswordModify: 1,
   passwordValidateDays: 0,
   initPassword: '123456',
   blackIPList: '',
   // 高德地图
   amapWebServiceKey: '',
   amapJsApiKey: '',
   amapSecurityJsCode: ''
})

// 业务配置表单
const bizForm = reactive({
   packageQuantityEditable: false,
   packageDealAmountEditable: false,
   packagePaidAmountEditable: false,
   allowManualAddress: false
})

// 配置键名与表单字段的映射关系
const systemKeyMap = {
   'sys.login.expireTime': { field: 'expireTime', type: 'number' },
   'sys.cos.enabled': { field: 'cosEnabled', type: 'boolean' },
   'sys.cos.secretId': { field: 'cosSecretId', type: 'string' },
   'sys.cos.secretKey': { field: 'cosSecretKey', type: 'string' },
   'sys.cos.bucket': { field: 'cosBucket', type: 'string' },
   'sys.cos.region': { field: 'cosRegion', type: 'string' },
   'sys.cos.domain': { field: 'cosDomain', type: 'string' },
   // 安全策略
   'sys.account.captchaEnabled': { field: 'captchaEnabled', type: 'boolean' },
   'sys.account.registerUser': { field: 'registerUser', type: 'boolean' },
   'sys.account.captchaExpire': { field: 'captchaExpire', type: 'number' },
   'sys.account.maxRetryCount': { field: 'maxRetryCount', type: 'number' },
   'sys.account.lockTime': { field: 'lockTime', type: 'number' },
   'sys.account.chrtype': { field: 'chrtype', type: 'number' },
   'sys.account.initPasswordModify': { field: 'initPasswordModify', type: 'number' },
   'sys.account.passwordValidateDays': { field: 'passwordValidateDays', type: 'number' },
   'sys.user.initPassword': { field: 'initPassword', type: 'string' },
   'sys.login.blackIPList': { field: 'blackIPList', type: 'string' },
   // 高德地图
   'sys.amap.webServiceKey': { field: 'amapWebServiceKey', type: 'string' },
   'sys.amap.jsApiKey': { field: 'amapJsApiKey', type: 'string' },
   'sys.amap.securityJsCode': { field: 'amapSecurityJsCode', type: 'string' }
}

const bizKeyMap = {
   'biz.sales.packageQuantityEditable': { field: 'packageQuantityEditable', type: 'boolean' },
   'biz.sales.packageDealAmountEditable': { field: 'packageDealAmountEditable', type: 'boolean' },
   'biz.sales.packagePaidAmountEditable': { field: 'packagePaidAmountEditable', type: 'boolean' },
   'biz.attendance.allowManualAddress': { field: 'allowManualAddress', type: 'boolean' }
}

/** 将配置值转换为表单字段类型 */
function parseValue(value, type) {
   if (type === 'boolean') return value === 'true'
   if (type === 'number') return Number(value)
   return value || ''
}

/** 将表单字段值转换为配置值字符串 */
function stringifyValue(value, type) {
   if (type === 'boolean') return value ? 'true' : 'false'
   if (type === 'number') return String(value)
   return value || ''
}

/** 加载所有配置项 */
function loadConfig() {
   loading.value = true
   listConfig({ pageNum: 1, pageSize: 100 }).then(response => {
      const rows = response.rows || []
      configMap.value = {}
      rows.forEach(item => {
         configMap.value[item.configKey] = item
      })
      // 填充参数配置表单
      for (const [key, mapping] of Object.entries(systemKeyMap)) {
         const config = configMap.value[key]
         if (config) {
            systemForm[mapping.field] = parseValue(config.configValue, mapping.type)
         }
      }
      // 填充业务配置表单
      for (const [key, mapping] of Object.entries(bizKeyMap)) {
         const config = configMap.value[key]
         if (config) {
            bizForm[mapping.field] = parseValue(config.configValue, mapping.type)
         }
      }
   }).finally(() => {
      loading.value = false
   })
}

/** 保存配置项 */
async function saveConfigs(keyMap, form) {
   const promises = []
   for (const [key, mapping] of Object.entries(keyMap)) {
      const config = configMap.value[key]
      if (config) {
         const updateData = {
            configId: config.configId,
            configName: config.configName,
            configKey: config.configKey,
            configValue: stringifyValue(form[mapping.field], mapping.type),
            configType: config.configType,
            remark: config.remark
         }
         promises.push(updateConfig(updateData))
      }
   }
   await Promise.all(promises)
   await refreshCache()
}

/** 保存参数配置 */
function saveSystemConfig() {
   proxy.$modal.confirm('是否确认保存参数配置？').then(() => {
      saveConfigs(systemKeyMap, systemForm).then(() => {
         proxy.$modal.msgSuccess("保存成功")
         loadConfig()
      })
   }).catch(() => {})
}

/** 保存业务配置 */
function saveBizConfig() {
   proxy.$modal.confirm('是否确认保存业务配置？').then(() => {
      saveConfigs(bizKeyMap, bizForm).then(() => {
         proxy.$modal.msgSuccess("保存成功")
         loadConfig()
      })
   }).catch(() => {})
}

loadConfig()
</script>

<style scoped>
.form-tip {
  color: #909399;
  font-size: 12px;
  line-height: 1.5;
  margin-top: 4px;
}
.unit {
  margin-left: 10px;
  color: #606266;
}
</style>
