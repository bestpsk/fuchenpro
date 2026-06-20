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
   cosDomain: ''
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
   'sys.login.expireTime': { field: 'expireTime', type: 'number' },
   'sys.cos.enabled': { field: 'cosEnabled', type: 'boolean' },
   'sys.cos.secretId': { field: 'cosSecretId', type: 'string' },
   'sys.cos.secretKey': { field: 'cosSecretKey', type: 'string' },
   'sys.cos.bucket': { field: 'cosBucket', type: 'string' },
   'sys.cos.region': { field: 'cosRegion', type: 'string' },
   'sys.cos.domain': { field: 'cosDomain', type: 'string' }
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
