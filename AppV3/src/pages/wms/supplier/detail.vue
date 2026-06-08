<template>
  <view class="detail-container">
    <view class="info-card">
      <view class="card-header-row">
        <text class="supplier-name">{{ info.supplierName || '-' }}</text>
        <view class="status-badge" :class="'status-' + info.status">{{ info.status === '0' ? '正常' : '停用' }}</view>
      </view>
      <view class="info-body">
        <view class="info-row">
          <text class="info-label">联系人</text>
          <text class="info-value">{{ info.contactPerson || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">联系电话</text>
          <text class="info-value phone-link" v-if="info.contactPhone" @click="callPhone">{{ info.contactPhone }}</text>
          <text class="info-value" v-else>-</text>
        </view>
        <view class="info-row">
          <text class="info-label">地址</text>
          <text class="info-value">{{ info.address || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">合作日期</text>
          <text class="info-value">{{ info.cooperationStartDate || '-' }}</text>
        </view>
        <view v-if="info.remark" class="info-row">
          <text class="info-label">备注</text>
          <text class="info-value remark-text">{{ info.remark }}</text>
        </view>
      </view>
    </view>

    <view class="info-card" v-if="info.createBy || info.updateBy">
      <view class="card-title">操作记录</view>
      <view class="info-body">
        <view v-if="info.createBy" class="info-row">
          <text class="info-label">创建人</text>
          <text class="info-value">{{ info.createBy }}</text>
          <text class="info-time">{{ formatTime(info.createTime) }}</text>
        </view>
        <view v-if="info.updateBy" class="info-row">
          <text class="info-label">更新人</text>
          <text class="info-value">{{ info.updateBy }}</text>
          <text class="info-time">{{ formatTime(info.updateTime) }}</text>
        </view>
      </view>
    </view>

    <view class="action-section">
      <view class="action-btns">
        <u-button v-if="checkPermi('wms:supplier:edit')" type="primary" plain text="编辑" @click="goEdit"></u-button>
        <u-button v-if="checkPermi('wms:supplier:remove')" type="error" plain text="删除" @click="handleDelete"></u-button>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getSupplier, delSupplier } from '@/api/wms/supplier'

const info = ref({})
const supplierId = ref(null)

function formatTime(time) {
  if (!time) return ''
  return String(time).substring(0, 16)
}

async function loadDetail() {
  if (!supplierId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getSupplier(supplierId.value)
    info.value = response.data || response
  } catch (e) {
    console.error('加载供货商详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

function callPhone() {
  if (info.value.contactPhone) uni.makePhoneCall({ phoneNumber: info.value.contactPhone })
}

function goEdit() {
  uni.navigateTo({ url: `/pages/wms/supplier/form?mode=edit&id=${supplierId.value}` })
}

function handleDelete() {
  uni.showModal({
    title: '提示',
    content: '确认删除该供货商？删除后不可恢复。',
    success: async (res) => {
      if (res.confirm) {
        try {
          await delSupplier(supplierId.value)
          uni.showToast({ title: '删除成功', icon: 'success' })
          setTimeout(() => {
            const pages = getCurrentPages()
            if (pages.length > 1) uni.navigateBack()
            else uni.redirectTo({ url: '/pages/wms/supplier/index' })
          }, 1500)
        } catch (e) {
          console.error('删除失败:', e)
        }
      }
    }
  })
}

onMounted(() => {
  const pages = getCurrentPages()
  const options = pages[pages.length - 1].options || {}
  supplierId.value = options.id ? parseInt(options.id) : null
  loadDetail()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.detail-container { min-height: 100vh; padding: 24rpx; padding-bottom: 160rpx; }

.info-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; margin-bottom: 20rpx; }
.card-header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24rpx; padding-bottom: 20rpx; border-bottom: 1rpx solid #F2F3F5; }
.supplier-name { font-size: 32rpx; font-weight: 600; color: #1D2129; flex: 1; margin-right: 16rpx; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #e8f0fe; color: #3D6DF7; }
  &.status-1 { background: #F2F3F5; color: #86909C; }
}

.card-title { font-size: 28rpx; font-weight: 600; color: #1D2129; margin-bottom: 20rpx; }

.info-body { display: flex; flex-direction: column; gap: 16rpx; }
.info-row { display: flex; align-items: center; gap: 12rpx; }
.info-label { font-size: 26rpx; color: #86909C; min-width: 100rpx; flex-shrink: 0; }
.info-value { font-size: 28rpx; color: #1D2129; flex: 1;
  &.phone-link { color: #3D6DF7; }
  &.remark-text { word-break: break-all; line-height: 1.6; }
}
.info-time { font-size: 24rpx; color: #86909C; flex-shrink: 0; }

.action-section { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; background: #fff; border-radius: 16rpx; padding: 20rpx; box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.06); z-index: 100; }
.action-btns { display: flex; gap: 16rpx;
  .u-button { flex: 1; }
}
</style>
