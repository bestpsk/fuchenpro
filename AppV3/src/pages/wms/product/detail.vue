<template>
  <view class="detail-container">
    <view class="info-card">
      <view class="card-header-row">
        <text class="product-name">{{ info.productName || '-' }}</text>
        <view class="status-badge" :class="'status-' + info.status">{{ info.status === '0' ? '正常' : '停用' }}</view>
      </view>
      <view class="info-body">
        <view class="info-row">
          <text class="info-label">货品编码</text>
          <text class="info-value">{{ info.productCode || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">供货商</text>
          <text class="info-value">{{ info.supplierName || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">类别</text>
          <text class="info-value">{{ info.category || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">单位(整)</text>
          <text class="info-value">{{ info.unit || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">规格(拆)</text>
          <text class="info-value">{{ info.spec || '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">包装数量</text>
          <text class="info-value">{{ info.packQty ?? '-' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">进货价</text>
          <text class="info-value price">¥{{ formatAmount(info.purchasePrice) }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">出货价(整)</text>
          <text class="info-value price">¥{{ formatAmount(info.sellingPrice) }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">出货价(拆)</text>
          <text class="info-value price">¥{{ formatAmount(info.splitPrice) }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">预警数量</text>
          <text class="info-value">{{ info.warnQty ?? '-' }}</text>
        </view>
        <view v-if="info.remark" class="info-row">
          <text class="info-label">备注</text>
          <text class="info-value remark-text">{{ info.remark }}</text>
        </view>
      </view>
    </view>

    <view class="info-card" v-if="info.createBy || info.updateBy">
      <view class="card-title">
        <u-icon name="clock" size="16" color="#3D6DF7"></u-icon>
        <text>操作记录</text>
      </view>
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
        <u-button v-if="checkPermi('wms:product:edit')" type="primary" plain text="编辑" @click="goEdit"></u-button>
        <u-button v-if="checkPermi('wms:product:remove')" type="error" plain text="删除" @click="handleDelete"></u-button>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getProduct, delProduct } from '@/api/wms/product'
import { checkPermi } from '@/utils/permission'

const info = ref({})
const productId = ref(null)

function formatAmount(val) {
  const num = parseFloat(val)
  if (isNaN(num)) return '0.00'
  return num.toFixed(2)
}

function formatTime(time) {
  if (!time) return ''
  return String(time).substring(0, 16)
}

async function loadDetail() {
  if (!productId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getProduct(productId.value)
    info.value = response.data || response
  } catch (e) {
    console.error('加载货品详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

function goEdit() {
  uni.navigateTo({ url: `/pages/wms/product/form?mode=edit&id=${productId.value}` })
}

function handleDelete() {
  uni.showModal({
    title: '提示',
    content: '确认删除该货品？删除后不可恢复。',
    success: async (res) => {
      if (res.confirm) {
        try {
          await delProduct(productId.value)
          uni.showToast({ title: '删除成功', icon: 'success' })
          setTimeout(() => {
            const pages = getCurrentPages()
            if (pages.length > 1) uni.navigateBack()
            else uni.redirectTo({ url: '/pages/wms/product/index' })
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
  productId.value = options.id ? parseInt(options.id) : null
  loadDetail()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.detail-container { min-height: 100vh; padding: 24rpx; padding-bottom: 160rpx; }

.info-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; margin-bottom: 20rpx; }
.card-header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24rpx; padding-bottom: 20rpx; border-bottom: 1rpx solid #F2F3F5; }
.product-name { font-size: 32rpx; font-weight: 600; color: #1D2129; flex: 1; margin-right: 16rpx; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #e8f0fe; color: #3D6DF7; }
  &.status-1 { background: #F2F3F5; color: #86909C; }
}

.card-title { display: flex; align-items: center; gap: 8rpx; font-size: 28rpx; font-weight: 600; color: #1D2129; margin-bottom: 20rpx; }

.info-body { display: flex; flex-direction: column; gap: 16rpx; }
.info-row { display: flex; align-items: center; gap: 12rpx; }
.info-label { font-size: 26rpx; color: #86909C; min-width: 140rpx; flex-shrink: 0; }
.info-value { font-size: 28rpx; color: #1D2129; flex: 1;
  &.price { color: #FF6B35; font-weight: 600; }
  &.remark-text { word-break: break-all; line-height: 1.6; }
}
.info-time { font-size: 24rpx; color: #86909C; flex-shrink: 0; }

.action-section { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; background: #fff; border-radius: 16rpx; padding: 20rpx; box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.06); z-index: 100; }
.action-btns { display: flex; gap: 16rpx;
  .u-button { flex: 1; }
}
</style>
