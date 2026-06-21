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

               <el-form-item label="令牌续期阈值">
                  <el-input-number v-model="systemForm.tokenRefreshThreshold" :min="1" :max="1440" :step="1" controls-position="right" />
                  <span style="margin-left: 10px">分钟</span>
                  <div style="color: #909399; font-size: 12px; line-height: 1.5; margin-top: 4px;">
                     令牌剩余有效期低于此值时自动续期
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
               <el-form-item label="验证码有效期">
                  <el-input-number v-model="systemForm.captchaExpire" :min="1" :max="30" :step="1" controls-position="right" />
                  <span style="margin-left: 10px">分钟</span>
               </el-form-item>
               <el-form-item label="密码最大错误次数">
                  <el-input-number v-model="systemForm.pwdErrMaxCount" :min="1" :max="20" :step="1" controls-position="right" />
                  <span style="margin-left: 10px">次</span>
               </el-form-item>
               <el-form-item label="密码锁定时间">
                  <el-input-number v-model="systemForm.pwdErrLockTime" :min="1" :max="1440" :step="1" controls-position="right" />
                  <span style="margin-left: 10px">分钟</span>
               </el-form-item>
               <el-form-item label="用户初始密码">
                  <el-input v-model="systemForm.initPassword" placeholder="请输入用户初始密码" show-password style="max-width: 400px" />
                  <div style="color: #909399; font-size: 12px; line-height: 1.5; margin-top: 4px;">
                     新建用户和重置密码时的默认密码
                  </div>
               </el-form-item>

               <!-- 高德地图配置 -->
               <el-divider content-position="left">高德地图配置</el-divider>
               <el-form-item label="Web服务Key">
                  <el-input v-model="systemForm.amapWebServiceKey" placeholder="请输入高德Web服务Key" style="max-width: 400px" />
                  <div style="color: #909399; font-size: 12px; line-height: 1.5; margin-top: 4px;">
                     用于APP端逆地理编码和IP定位，修改后立即生效
                  </div>
               </el-form-item>
               <el-form-item label="JS API Key">
                  <el-input v-model="systemForm.amapJsKey" placeholder="请输入高德JS API Key" style="max-width: 400px" />
                  <div style="color: #909399; font-size: 12px; line-height: 1.5; margin-top: 4px;">
                     用于Web端地图组件加载，修改后刷新页面生效
                  </div>
               </el-form-item>
               <el-form-item label="安全密钥">
                  <el-input v-model="systemForm.amapSecurityJsCode" placeholder="请输入高德安全密钥" show-password style="max-width: 400px" />
                  <div style="color: #909399; font-size: 12px; line-height: 1.5; margin-top: 4px;">
                     JS API安全密钥，与JS API Key配合使用
                  </div>
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
import { listConfig, getConfig, addConfig, updateConfig, refreshCache } from "@/api/system/config"

const { proxy } = getCurrentInstance()

const activeTab = ref("system")
const loading = ref(false)

// 配置项原始数据（包含configId等完整信息）
const configMap = ref({})

// 参数配置表单
const systemForm = reactive({
   expireTime: 300,
   tokenRefreshThreshold: 20,
   cosEnabled: false,
   cosSecretId: '',
   cosSecretKey: '',
   cosBucket: '',
   cosRegion: 'ap-shanghai',
   cosDomain: '',
   captchaExpire: 2,
   pwdErrMaxCount: 5,
   pwdErrLockTime: 10,
   initPassword: '123456',
   amapWebServiceKey: '',
   amapJsKey: '',
   amapSecurityJsCode: ''
})

// 业务配置表单
const bizForm = reactive({
   packageQuantityEditable: true,
   packageDealAmountEditable: true,
   packagePaidAmountEditable: true,
   allowManualAddress: true
})

// 配置键名与表单字段的映射关系
const systemKeyMap = {
   'sys.login.expireTime': { field: 'expireTime', type: 'number', configName: 'Token有效期', remark: 'Token有效时长（分钟）' },
   'sys.login.tokenRefreshThreshold': { field: 'tokenRefreshThreshold', type: 'number', configName: '令牌续期阈值', remark: '令牌剩余有效期低于此值时自动续期（分钟）' },
   'sys.cos.enabled': { field: 'cosEnabled', type: 'boolean', configName: '启用腾讯云COS', remark: '是否启用腾讯云对象存储' },
   'sys.cos.secretId': { field: 'cosSecretId', type: 'string', configName: 'COS SecretId', remark: '腾讯云SecretId' },
   'sys.cos.secretKey': { field: 'cosSecretKey', type: 'string', configName: 'COS SecretKey', remark: '腾讯云SecretKey' },
   'sys.cos.bucket': { field: 'cosBucket', type: 'string', configName: 'COS Bucket', remark: 'COS存储桶名称' },
   'sys.cos.region': { field: 'cosRegion', type: 'string', configName: 'COS Region', remark: 'COS地域' },
   'sys.cos.domain': { field: 'cosDomain', type: 'string', configName: 'COS自定义域名', remark: 'COS自定义访问域名' },
   'sys.security.captchaExpire': { field: 'captchaExpire', type: 'number', configName: '验证码有效期', remark: '验证码有效时长（分钟）' },
   'sys.security.pwdErrMaxCount': { field: 'pwdErrMaxCount', type: 'number', configName: '密码最大错误次数', remark: '密码错误达到此次数后锁定账号' },
   'sys.security.pwdErrLockTime': { field: 'pwdErrLockTime', type: 'number', configName: '密码锁定时间', remark: '密码错误锁定时长（分钟）' },
   'sys.security.initPassword': { field: 'initPassword', type: 'string', configName: '用户初始密码', remark: '新建用户和重置密码时的默认密码' },
   'sys.amap.webServiceKey': { field: 'amapWebServiceKey', type: 'string', configName: '高德Web服务Key', remark: '用于APP端逆地理编码和IP定位' },
   'sys.amap.jsKey': { field: 'amapJsKey', type: 'string', configName: '高德JS API Key', remark: '用于Web端地图组件加载' },
   'sys.amap.securityJsCode': { field: 'amapSecurityJsCode', type: 'string', configName: '高德安全密钥', remark: 'JS API安全密钥，与JS API Key配合使用' }
}

const bizKeyMap = {
   'biz.sales.packageQuantityEditable': { field: 'packageQuantityEditable', type: 'boolean', configName: '允许修改套餐次数', remark: '销售开单时是否允许修改套餐次数' },
   'biz.sales.packageDealAmountEditable': { field: 'packageDealAmountEditable', type: 'boolean', configName: '允许修改套餐成交金额', remark: '销售开单时是否允许修改套餐成交金额' },
   'biz.sales.packagePaidAmountEditable': { field: 'packagePaidAmountEditable', type: 'boolean', configName: '允许修改套餐实付金额', remark: '销售开单时是否允许修改套餐实付金额' },
   'biz.attendance.allowManualAddress': { field: 'allowManualAddress', type: 'boolean', configName: '允许手动输入打卡地址', remark: '关闭后APP端考勤打卡定位失败时无法手动输入地址' }
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
      const configValue = stringifyValue(form[mapping.field], mapping.type)
      if (config) {
         const updateData = {
            configId: config.configId,
            configName: config.configName,
            configKey: config.configKey,
            configValue,
            configType: config.configType,
            remark: config.remark
         }
         promises.push(updateConfig(updateData))
      } else {
         // 配置项不存在，自动创建
         const addData = {
            configName: mapping.configName,
            configKey: key,
            configValue,
            configType: 'Y',
            remark: mapping.remark
         }
         promises.push(addConfig(addData))
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
