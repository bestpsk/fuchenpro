<template>
  <view class="detail-container">
    <view v-if="loading" class="loading-wrap">
      <u-icon name="loading" size="24" color="#3D6DF7"></u-icon>
      <text class="loading-text">加载中...</text>
    </view>
    <view v-else-if="detail" class="detail-content">
      <view class="detail-card">
        <view class="card-title">
          <u-icon name="file-text" size="16" color="#3D6DF7"></u-icon>
          <text>基本信息</text>
        </view>
        <view class="info-body">
          <view class="info-row">
            <text class="info-label">操作模块</text>
            <text class="info-value">{{ detail.title || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">业务类型</text>
            <text class="info-value">{{ getOperTypeLabel(String(detail.businessType)) }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">请求方式</text>
            <text class="info-value">{{ detail.requestMethod || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">操作时间</text>
            <text class="info-value">{{ detail.operTime || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">执行状态</text>
            <view class="status-tag" :class="String(detail.status) === '0' ? 'status-success' : 'status-fail'">
              {{ String(detail.status) === '0' ? '成功' : '失败' }}
            </view>
          </view>
        </view>
      </view>

      <view class="detail-card">
        <view class="card-title">
          <u-icon name="account" size="16" color="#3D6DF7"></u-icon>
          <text>操作人员</text>
        </view>
        <view class="info-body">
          <view class="info-row">
            <text class="info-label">操作人员</text>
            <text class="info-value">{{ detail.operName || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">所属部门</text>
            <text class="info-value">{{ detail.deptName || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">操作地址</text>
            <text class="info-value">{{ detail.operIp || '-' }}</text>
          </view>
        </view>
      </view>

      <view class="detail-card">
        <view class="card-title">
          <u-icon name="server" size="16" color="#3D6DF7"></u-icon>
          <text>请求信息</text>
        </view>
        <view class="info-body">
          <view class="info-row">
            <text class="info-label">请求URL</text>
            <text class="info-value url-text">{{ detail.operUrl || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">操作方法</text>
            <text class="info-value method-text">{{ detail.method || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">消耗时间</text>
            <text class="info-value">{{ detail.costTime != null ? detail.costTime + 'ms' : '-' }}</text>
          </view>
        </view>
      </view>

      <view class="detail-card">
        <view class="card-title">
          <u-icon name="list" size="16" color="#3D6DF7"></u-icon>
          <text>请求参数</text>
        </view>
        <view class="json-content">
          <text class="json-text">{{ formatJson(detail.operParam) }}</text>
        </view>
      </view>

      <view class="detail-card">
        <view class="card-title">
          <u-icon name="checkmark-circle" size="16" color="#3D6DF7"></u-icon>
          <text>返回参数</text>
        </view>
        <view class="json-content">
          <text class="json-text">{{ formatJson(detail.jsonResult) }}</text>
        </view>
      </view>

      <view v-if="String(detail.status) === '1' && detail.errorMsg" class="detail-card error-card">
        <view class="card-title">
          <u-icon name="warning" size="16" color="#F53F3F"></u-icon>
          <text>异常信息</text>
        </view>
        <view class="json-content">
          <text class="json-text error-text">{{ detail.errorMsg }}</text>
        </view>
      </view>
    </view>

    <u-empty v-else-if="!hasPermission" mode="permission" icon="lock" text="没有权限访问操作日志" :marginTop="120"></u-empty>
    <u-empty v-else-if="!loading" mode="data" text="日志不存在" :marginTop="100"></u-empty>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { listOperlog } from '@/api/monitor/operlog'
import { getDicts } from '@/api/system/dictData'
import { checkPermi } from '@/utils/permission'

const detail = ref(null)
const loading = ref(false)
const operTypeOptions = ref([])
const hasPermission = checkPermi('monitor:operlog:list')

async function loadDicts() {
  try {
    const res = await getDicts('sys_oper_type')
    operTypeOptions.value = res.data || []
  } catch (e) {
    console.error('获取字典失败:', e)
  }
}

function getOperTypeLabel(value) {
  const item = operTypeOptions.value.find(o => o.dictValue === String(value))
  return item ? item.dictLabel : '其他'
}

function formatJson(str) {
  if (!str) return '-'
  try {
    return JSON.stringify(JSON.parse(str), null, 2)
  } catch {
    return str
  }
}

async function loadDetail(operId) {
  loading.value = true
  try {
    const response = await listOperlog({ operId, pageNum: 1, pageSize: 1 })
    const data = response.data || response
    const list = data.rows || []
    detail.value = list.length > 0 ? list[0] : null
  } catch (e) {
    console.error('获取操作日志详情失败:', e)
    detail.value = null
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  if (!hasPermission) return
  loadDicts()
  const pages = getCurrentPages()
  const page = pages[pages.length - 1]
  const operId = page.options?.operId || page.$page?.options?.operId
  if (operId) loadDetail(operId)
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.detail-container { min-height: 100vh; padding: 24rpx; }

.loading-wrap { display: flex; flex-direction: column; align-items: center; justify-content: center; padding-top: 200rpx; gap: 16rpx; }
.loading-text { font-size: 28rpx; color: #86909C; }

.detail-content { display: flex; flex-direction: column; gap: 20rpx; }

.detail-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04); }
.error-card { border-left: 6rpx solid #F53F3F; }

.card-title {
  display: flex; align-items: center; gap: 10rpx;
  font-size: 28rpx; font-weight: 600; color: #1D2129; margin-bottom: 24rpx;
  padding-bottom: 16rpx; border-bottom: 1rpx solid #F2F3F5;
}

.info-body { display: flex; flex-direction: column; gap: 16rpx; }
.info-row { display: flex; align-items: flex-start; gap: 12rpx; }
.info-label { font-size: 26rpx; color: #86909C; min-width: 120rpx; flex-shrink: 0; }
.info-value { font-size: 28rpx; color: #1D2129; flex: 1; word-break: break-all; }
.url-text { color: #3D6DF7; font-size: 26rpx; }
.method-text { font-size: 26rpx; font-family: monospace; }

.status-tag {
  display: inline-block; padding: 6rpx 16rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500;
  &.status-success { background: #E8FFEA; color: #00B42A; }
  &.status-fail { background: #FFF1F0; color: #F53F3F; }
}

.json-content { background: #F5F7FA; border-radius: 12rpx; padding: 20rpx 24rpx; max-height: 400rpx; overflow-y: auto; }
.json-text { font-size: 24rpx; color: #4E5969; line-height: 1.6; word-break: break-all; white-space: pre-wrap; }
.error-text { color: #F53F3F; }
</style>
