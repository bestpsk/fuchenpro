<template>
  <view class="detail-container">
    <view class="prepare-info">
      <view class="info-header">
        <text class="prepare-no">{{ prepareInfo.prepareNo || '-' }}</text>
        <view class="status-tag" :class="getStatusClass(prepareInfo.status)">
          {{ getStatusName(prepareInfo.status) }}
        </view>
      </view>

      <view class="info-body">
        <view class="info-row">
          <u-icon name="home" size="20" color="#86909C" />
          <text class="label">企业</text>
          <text class="value">{{ prepareInfo.enterpriseName || '-' }}</text>
        </view>
        <view class="info-row">
          <u-icon name="map" size="20" color="#86909C" />
          <text class="label">门店</text>
          <text class="value">{{ prepareInfo.storeName || '-' }}</text>
        </view>
        <view class="info-row">
          <u-icon name="list" size="20" color="#86909C" />
          <text class="label">货品种类</text>
          <text class="value highlight">{{ prepareInfo.productCount || 0 }}种</text>
        </view>
        <view class="info-row">
          <u-icon name="rmb-circle" size="20" color="#86909C" />
          <text class="label">总金额</text>
          <text class="value amount">¥{{ prepareInfo.totalAmount || '0.00' }}</text>
        </view>
        <view class="info-row">
          <u-icon name="checkmark-circle" size="20" color="#86909C" />
          <text class="label">已出库</text>
          <text class="value shipped">{{ formatPrepareQty(prepareInfo.shippedQuantity) }} / ¥{{ prepareInfo.shippedAmount || '0' }}</text>
        </view>
        <view class="info-row">
          <u-icon name="clock" size="20" color="#86909C" />
          <text class="label">待出库</text>
          <text class="value pending">{{ formatPrepareQty(prepareInfo.pendingQuantity) }} / ¥{{ prepareInfo.pendingAmount || '0' }}</text>
        </view>
        <view class="info-row">
          <u-icon name="calendar" size="20" color="#86909C" />
          <text class="label">创建时间</text>
          <text class="value">{{ formatTime(prepareInfo.createTime) }}</text>
        </view>
      </view>
    </view>

    <view class="tabs-section">
      <view class="tabs-header">
        <view
          class="tab-item"
          :class="{ active: activeTab === 'items' }"
          @click="activeTab = 'items'"
        >
          <text>库存明细</text>
        </view>
        <view
          class="tab-item"
          :class="{ active: activeTab === 'orders' }"
          @click="activeTab = 'orders'"
        >
          <text>关联订单</text>
        </view>
      </view>

      <view v-if="activeTab === 'items'" class="tab-content">
        <view v-if="itemList.length > 0" class="item-list">
          <view v-for="(item, idx) in itemList" :key="item.prepareItemId" class="item-card">
            <view class="item-header">
              <view class="item-left">
                <text class="item-index">{{ idx + 1 }}.</text>
                <text class="item-name">{{ item.productName || '-' }}</text>
              </view>
              <view class="item-right">
                <text class="item-code">{{ item.productCode || '' }}</text>
              </view>
            </view>

            <view class="item-body">
              <view class="info-line">
                <view class="info-left">
                  <text class="info-label">单位</text>
                  <text class="info-value">{{ item.unitLabel || '-' }}</text>
                </view>
                <view class="info-right">
                  <text class="info-label">规格</text>
                  <text class="info-value">{{ item.specLabel || '-' }}</text>
                </view>
              </view>
              <view v-if="item.packQty > 1" class="info-line">
                <view class="info-left">
                  <text class="info-label">换算</text>
                  <text class="info-value convert">1{{ item.unitLabel }}={{ item.packQty }}{{ item.specLabel }}</text>
                </view>
              </view>
              <view class="info-line">
                <view class="info-left">
                  <text class="info-label">总数量</text>
                  <text class="info-value">{{ formatItemQty(item.totalQuantity, item.packQty, item.unitLabel, item.specLabel) }}</text>
                </view>
                <view class="info-right">
                  <text class="info-label">出货价</text>
                  <text class="info-value price">¥{{ item.unitType === '1' ? item.mainSalePrice : item.salePriceSpec }}/{{ item.unitType === '1' ? item.unitLabel : item.specLabel }}</text>
                </view>
              </view>
              <view class="info-line">
                <view class="info-left">
                  <text class="info-label">已出库</text>
                  <text class="info-value shipped">{{ item.shippedQuantity }}{{ item.specLabel }}</text>
                </view>
                <view class="info-right">
                  <text class="info-label">待出库</text>
                  <text class="info-value pending">{{ item.pendingQuantity }}{{ item.specLabel }}</text>
                </view>
              </view>
            </view>
          </view>
        </view>
        <u-empty v-else mode="data" text="暂无库存明细" :marginTop="40"></u-empty>
      </view>

      <view v-if="activeTab === 'orders'" class="tab-content">
        <view v-if="orderList.length > 0" class="order-list">
          <view v-for="(order, idx) in orderList" :key="order.orderId" class="order-card">
            <view class="order-header">
              <text class="order-no">{{ order.orderNo || '-' }}</text>
              <view class="order-status-tag" :class="getOrderStatusClass(order.orderStatus)">
                {{ getOrderStatusName(order.orderStatus) }}
              </view>
            </view>
            <view class="order-body">
              <view class="info-line">
                <view class="info-left">
                  <text class="info-label">客户</text>
                  <text class="info-value">{{ order.customerName || '-' }}</text>
                </view>
                <view class="info-right">
                  <text class="info-label">金额</text>
                  <text class="info-value amount">¥{{ order.dealAmount || '0' }}</text>
                </view>
              </view>
            </view>
          </view>
        </view>
        <u-empty v-else mode="data" text="暂无关联订单" :marginTop="40"></u-empty>
      </view>
    </view>

    <!-- 底部操作按钮 -->
    <view v-if="canStockOut || canCancel" class="bottom-bar">
      <u-button v-if="canCancel" type="error" text="取消备货" @click="handleCancel" style="flex: 1"></u-button>
      <u-button v-if="canStockOut && checkPermi('business:stockPrepare:createStockOut')" type="primary" text="出库" @click="openStockOutPopup" style="flex: 1"></u-button>
    </view>

    <!-- 出库弹窗 -->
    <u-popup :show="stockOutOpen" mode="bottom" round="16" @close="stockOutOpen = false">
      <view class="stock-out-popup">
        <view class="popup-title-bar">
          <text class="popup-title">出库</text>
          <u-icon name="close" size="20" @click="stockOutOpen = false"></u-icon>
        </view>

        <view class="warehouse-selector-bar" @click="showWarehousePicker = true">
          <text class="warehouse-label">出库仓库</text>
          <view class="warehouse-value-wrap">
            <text v-if="warehouseList.length === 0" class="warehouse-placeholder">您没有仓库权限，请联系管理员</text>
            <text v-else-if="!currentWarehouseId" class="warehouse-placeholder">请选择仓库</text>
            <text v-else class="warehouse-name">{{ currentWarehouse?.warehouseName || '-' }}</text>
            <u-icon name="arrow-right" size="14" color="#86909C"></u-icon>
          </view>
        </view>

        <scroll-view scroll-y class="stock-out-scroll">
          <view class="stock-out-scroll-inner">
          <view v-for="(item, idx) in stockOutItems" :key="item.prepareItemId" class="stock-out-item">
            <view class="stock-out-header">
              <text class="stock-out-name">{{ item.productName }}</text>
              <view class="stock-out-pending">待出库: {{ item.pendingQuantity }}{{ item.specLabel }}</view>
            </view>

            <view v-if="item.packQty > 1" class="stock-out-convert">
              1{{ item.unitLabel }}={{ item.packQty }}{{ item.specLabel }}
            </view>

            <view class="stock-out-form">
              <view class="form-row">
                <text class="form-label">单位类型</text>
                <view class="unit-type-btns">
                  <view
                    class="unit-btn"
                    :class="{ active: item.unitType === '1' }"
                    @click="onUnitTypeChange(idx, '1')"
                  >主单位(整)</view>
                  <view
                    class="unit-btn"
                    :class="{ active: item.unitType === '2' }"
                    @click="onUnitTypeChange(idx, '2')"
                  >副单位(拆)</view>
                </view>
              </view>
              <view class="form-row">
                <text class="form-label">数量</text>
                <view class="qty-input-wrap">
                  <u-number-box
                    v-model="item.outQuantity"
                    :min="0"
                    :max="getStockOutMaxQty(item)"
                    inputWidth="100"
                    buttonSize="28"
                    @change="onQuantityChange(idx, $event)"
                  ></u-number-box>
                  <text class="qty-unit">{{ item.unitType === '1' ? item.unitLabel : item.specLabel }}</text>
                </view>
              </view>
              <view class="form-row">
                <text class="form-label">单价</text>
                <view class="price-input-wrap">
                  <u-number-box
                    v-model="item.outPrice"
                    :min="0"
                    :step="0.01"
                    :decimalLength="2"
                    inputWidth="100"
                    buttonSize="28"
                    @change="onPriceChange(idx, $event)"
                  ></u-number-box>
                  <text class="qty-unit">元</text>
                </view>
              </view>
              <view class="form-row">
                <text class="form-label">金额</text>
                <text class="form-value amount">¥{{ item.outAmount }}</text>
              </view>
            </view>
          </view>
          </view>
        </scroll-view>

        <view class="stock-out-summary">
          <text>出库总数量：<text class="summary-value">{{ stockOutTotalDisplayQty }}</text></text>
          <text style="margin-left: 24rpx;">出库总金额：<text class="summary-value">¥{{ stockOutTotalAmount }}</text></text>
        </view>

        <view class="stock-out-actions">
          <u-button type="info" plain text="取消" @click="stockOutOpen = false"></u-button>
          <u-button type="primary" text="确认出库" @click="submitStockOut"></u-button>
        </view>
      </view>
    </u-popup>

    <!-- 仓库选择器 -->
    <u-picker
      :show="showWarehousePicker"
      :columns="[warehouseList.map(w => ({ label: w.warehouseName, value: w.warehouseId }))]"
      keyName="label"
      @confirm="onWarehouseConfirm"
      @cancel="showWarehousePicker = false"
      @close="showWarehousePicker = false"
    ></u-picker>
  </view>
</template>

<script setup>
/**
 * @description 备货详情页 - 备货明细与出库操作
 * @description 展示备货基本信息、库存明细和关联订单两个Tab，
 * 支持出库操作（选择货品、设置单位类型/数量/价格）
 */
import { ref, computed, onMounted } from 'vue'
import { getStockPrepare, createStockOutFromPrepare, cancelPrepare } from '@/api/business/stockPrepare'
import { useWarehouse } from '@/composables/useWarehouse'
import { checkPermi } from '@/utils/permission'

const { currentWarehouseId, warehouseList, currentWarehouse, loadWarehouses, setCurrentWarehouse } = useWarehouse()
const prepareId = ref(null)
const prepareInfo = ref({})
const itemList = ref([])
const orderList = ref([])
const activeTab = ref('items')
const stockOutOpen = ref(false)
const stockOutItems = ref([])
const showWarehousePicker = ref(false)

/** 是否可出库：状态为待出库或部分出库 */
const canStockOut = computed(() => {
  const status = prepareInfo.value.status
  return status === '0' || status === '1'
})

const canCancel = computed(() => {
  return prepareInfo.value.status === '0'
})

/** 出库总数量展示 */
const stockOutTotalDisplayQty = computed(() => {
  return stockOutItems.value
    .filter(item => item.outQuantity > 0)
    .map(item => {
      const label = item.unitType === '1' ? item.unitLabel : item.specLabel
      return (item.outQuantity || 0) + label
    })
    .join(' + ') || '0'
})

/** 出库总金额 */
const stockOutTotalAmount = computed(() => {
  return stockOutItems.value
    .reduce((sum, item) => sum + parseFloat(item.outAmount || 0), 0)
    .toFixed(2)
})

/** 状态编码映射为中文名称 */
function getStatusName(value) {
  const map = { '0': '待出库', '1': '部分出库', '2': '已完成', '3': '已取消' }
  return map[value] || '-'
}

/** 状态编码映射为样式类名 */
function getStatusClass(value) {
  const map = { '0': 'status-pending', '1': 'status-partial', '2': 'status-done' }
  return map[value] || 'status-pending'
}

/** 订单状态编码映射为中文名称 */
function getOrderStatusName(value) {
  const map = { '0': '待确认', '1': '企业已审', '2': '财务已审', '3': '已完成', '4': '已取消' }
  return map[value] || '-'
}

/** 订单状态编码映射为样式类名 */
function getOrderStatusClass(value) {
  const map = { '0': 'status-0', '1': 'status-1', '2': 'status-2', '3': 'status-3', '4': 'status-3' }
  return map[value] || 'status-0'
}

function formatTime(time) {
  if (!time) return ''
  return String(time).substring(0, 16)
}

/**
 * 将最小单位数量转为可读格式
 * @param {number} qty - 最小单位数量
 * @param {number} packQty - 换算比（1主单位=packQty副单位）
 * @param {string} unitLabel - 主单位标签，如"箱"
 * @param {string} specLabel - 副单位标签，如"个"
 * @returns {string} 格式化后的数量字符串，如"1箱（10个）"、"5箱"、"10个"
 */
function formatItemQty(qty, packQty, unitLabel, specLabel) {
  if (qty === 0 || qty === null || qty === undefined) return '0'
  qty = Number(qty)
  packQty = Number(packQty) || 1
  if (packQty > 1 && specLabel) {
    const mainQty = Math.floor(qty / packQty)
    const subQty = qty % packQty
    let result = ''
    if (mainQty > 0) {
      result = mainQty + unitLabel
    }
    if (subQty > 0) {
      if (mainQty > 0) {
        result += '（' + subQty + specLabel + '）'
      } else {
        result = subQty + specLabel
      }
    } else if (mainQty > 0) {
      result += '（' + qty + specLabel + '）'
    }
    return result || '0'
  }
  if (unitLabel && packQty <= 1) {
    return qty + unitLabel
  }
  return String(qty)
}

/**
 * 格式化备货主表的数量（最小单位），利用明细列表的单位信息进行转换
 * 如果所有明细共用同一个副单位标签，则显示为"X主单位（Y副单位）"格式
 * 否则直接显示数字
 */
function formatPrepareQty(qty) {
  if (qty === 0 || qty === null || qty === undefined) return '0'
  const items = itemList.value
  if (!items || items.length === 0) return String(qty)
  // 取第一个明细的单位信息作为参考
  const firstItem = items[0]
  const packQty = Number(firstItem.packQty) || 1
  const unitLabel = firstItem.unitLabel || ''
  const specLabel = firstItem.specLabel || ''
  return formatItemQty(qty, packQty, unitLabel, specLabel)
}

/** 加载备货详情 */
async function loadDetail() {
  if (!prepareId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getStockPrepare(prepareId.value)
    const data = response.data || response
    prepareInfo.value = data
    itemList.value = data.items || []
    orderList.value = data.orders || []
  } catch (e) {
    console.error('加载备货详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

/** 取消备货 */
async function handleCancel() {
  uni.showModal({
    title: '确认取消',
    content: '取消后可重新备货，确认取消该备货单吗？',
    success: async (res) => {
      if (!res.confirm) return
      try {
        uni.showLoading({ title: '取消中...' })
        await cancelPrepare(prepareId.value)
        uni.showToast({ title: '取消成功', icon: 'success' })
        setTimeout(() => {
          uni.navigateBack()
        }, 1000)
      } catch (e) {
        uni.showToast({ title: e.message || '取消失败', icon: 'none' })
      } finally {
        uni.hideLoading()
      }
    }
  })
}

/** 打开出库弹窗，初始化出库数据 */
function openStockOutPopup() {
  stockOutItems.value = itemList.value.map(item => {
    const packQty = item.packQty || 1
    const maxQty = packQty > 1 ? Math.floor((item.pendingQuantity || 0) / packQty) : (item.pendingQuantity || 0)
    const outPrice = item.mainSalePrice || 0
    return {
      prepareItemId: item.prepareItemId,
      itemId: item.prepareItemId,  // 后端需要 item_id
      productId: item.productId,
      productName: item.productName,
      unitLabel: item.unitLabel,
      specLabel: item.specLabel,
      packQty: packQty,
      pendingQuantity: item.pendingQuantity || 0,
      salePrice: item.salePrice || 0,
      salePriceSpec: item.salePriceSpec || 0,
      mainSalePrice: outPrice,
      unitType: '1',
      outQuantity: maxQty,
      outPrice: outPrice,  // 主单位出货价
      _mainPrice: outPrice,
      outAmount: (maxQty * outPrice).toFixed(2)
    }
  })
  stockOutOpen.value = true
}

/** 切换单位类型，重新计算单价和金额 */
function onUnitTypeChange(idx, type) {
  const item = stockOutItems.value[idx]
  item.unitType = type
  if (type === '1') {
    item.outPrice = item._mainPrice || 0
  } else {
    item.outPrice = item.salePriceSpec || 0
  }
  item.outQuantity = 0
  calcStockOutAmount(idx)
}

/** 获取出库最大数量 */
function getStockOutMaxQty(item) {
  if (item.unitType === '1' && item.packQty > 1) {
    return Math.floor(item.pendingQuantity / item.packQty)
  }
  return item.pendingQuantity || 0
}

/** 计算出库金额 */
function calcStockOutAmount(idx) {
  const item = stockOutItems.value[idx]
  if (!item) return
  item.outAmount = (item.outQuantity * item.outPrice).toFixed(2)
}

/** 数量变化时重算金额（使用事件参数中的value，避免v-model异步更新导致读取旧值） */
function onQuantityChange(idx, e) {
  const item = stockOutItems.value[idx]
  if (!item) return
  const qty = Number(e?.value ?? item.outQuantity) || 0
  item.outAmount = (qty * item.outPrice).toFixed(2)
}

/** 单价变化时重算金额 */
function onPriceChange(idx, e) {
  const item = stockOutItems.value[idx]
  if (!item) return
  const price = Number(e?.value ?? item.outPrice) || 0
  item.outAmount = (item.outQuantity * price).toFixed(2)
}

/** 提交出库 */
async function submitStockOut() {
  if (warehouseList.value.length === 0) {
    uni.showToast({ title: '您没有仓库权限，请联系管理员', icon: 'none' })
    return
  }
  if (!currentWarehouseId.value) {
    uni.showToast({ title: '请选择出库仓库', icon: 'none' })
    return
  }

  const items = stockOutItems.value
    .filter(item => item.outQuantity > 0)
    .map(item => ({
      item_id: item.itemId,           // 备货明细ID
      unit_type: item.unitType,       // 单位类型
      original_quantity: item.outQuantity  // 原始数量
    }))

  if (items.length === 0) {
    uni.showToast({ title: '请至少填写一项出库数量', icon: 'none' })
    return
  }

  // 先关闭抽屉，避免uni.showModal被抽屉遮挡
  stockOutOpen.value = false

  uni.showModal({
    title: '提示',
    content: '确认提交出库？',
    success: async (res) => {
      if (res.confirm) {
        try {
          uni.showLoading({ title: '提交中...' })
          await createStockOutFromPrepare({ prepareId: prepareId.value, items, warehouseId: currentWarehouseId.value })
          uni.showToast({ title: '出库成功', icon: 'success' })
          loadDetail()
        } catch (e) {
          console.error('出库失败:', e)
          uni.showToast({ title: '出库失败', icon: 'none' })
          // 出库失败，重新打开抽屉让用户修改
          stockOutOpen.value = true
        } finally {
          uni.hideLoading()
        }
      } else {
        // 取消确认，重新打开抽屉
        stockOutOpen.value = true
      }
    }
  })
}

/** 仓库选择确认 */
function onWarehouseConfirm(e) {
  const selected = e.value?.[0]
  if (selected && selected.value) {
    setCurrentWarehouse(selected.value)
  }
  showWarehousePicker.value = false
}

onMounted(() => {
  const pages = getCurrentPages()
  const options = pages[pages.length - 1].options || {}
  loadWarehouses()
  prepareId.value = options.id ? parseInt(options.id) : null

  uni.setNavigationBarTitle({ title: '备货详情' })

  loadDetail()
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
}

.detail-container {
  min-height: 100vh;
  padding: 24rpx;
  padding-bottom: 140rpx;
}

/* ========== 备货基本信息卡片 ========== */
.prepare-info {
  background: #fff;
  border-radius: 12rpx;
  padding: 28rpx;
  margin-bottom: 24rpx;
}

.info-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
  padding-bottom: 20rpx;
  border-bottom: 1rpx solid #F2F3F5;
}

.prepare-no {
  font-size: 30rpx;
  font-weight: 600;
  color: #1D2129;
}

.status-tag {
  padding: 6rpx 18rpx;
  border-radius: 6rpx;
  font-size: 23rpx;
  font-weight: 500;

  &.status-pending { background: #FFF7E8; color: #FF7D00; }
  &.status-partial { background: #E8F0FE; color: #3D6DF7; }
  &.status-done { background: #E8FFEA; color: #00B42A; }
}

.info-body {
  display: flex;
  flex-direction: column;
  gap: 10rpx;
}

.info-row {
  display: flex;
  align-items: center;
  gap: 10rpx;

  .u-icon {
    flex-shrink: 0;
  }
}

.label {
  font-size: 26rpx;
  color: #86909C;
  min-width: 80rpx;
}

.value {
  font-size: 27rpx;
  color: #1D2129;
  flex: 1;

  &.amount {
    color: #1D2129;
    font-weight: 600;
    font-size: 30rpx;
  }

  &.highlight {
    color: #FF6B35;
    font-weight: 500;
  }

  &.shipped {
    color: #3D6DF7;
  }

  &.pending {
    color: #FF7D00;
  }
}

/* ========== Tab区域 ========== */
.tabs-section {
  background: #fff;
  border-radius: 12rpx;
  padding: 28rpx;
}

.tabs-header {
  display: flex;
  margin-bottom: 24rpx;
  border-bottom: 1rpx solid #F2F3F5;
}

.tab-item {
  flex: 1;
  text-align: center;
  padding-bottom: 16rpx;
  font-size: 28rpx;
  color: #86909C;
  position: relative;

  &.active {
    color: #3D6DF7;
    font-weight: 600;

    &::after {
      content: '';
      position: absolute;
      bottom: 0;
      left: 50%;
      transform: translateX(-50%);
      width: 48rpx;
      height: 4rpx;
      background: #3D6DF7;
      border-radius: 2rpx;
    }
  }
}

.tab-content {
  min-height: 200rpx;
}

/* ========== 库存明细 ========== */
.item-list {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.item-card {
  padding: 20rpx 0;
  border-bottom: 1rpx solid #F2F3F5;

  &:last-child {
    border-bottom: none;
  }
}

.item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16rpx;

  .item-left {
    display: flex;
    align-items: baseline;
    gap: 12rpx;
    flex: 1;
  }

  .item-index {
    font-size: 26rpx;
    color: #86909C;
    font-weight: 500;
  }

  .item-name {
    font-size: 27rpx;
    color: #1D2129;
    font-weight: 500;
  }

  .item-code {
    font-size: 22rpx;
    color: #C9CDD4;
  }
}

.item-body {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.info-line {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 25rpx;
  line-height: 1.6;

  .info-left {
    display: flex;
    align-items: center;
    gap: 8rpx;
    flex: 1;
  }

  .info-right {
    display: flex;
    align-items: center;
    gap: 8rpx;
    flex-shrink: 0;
    margin-left: auto;
  }

  .info-label {
    color: #86909C;
    white-space: nowrap;
    font-size: 24rpx;
  }

  .info-value {
    color: #4E5969;
    font-size: 25rpx;

    &.price {
      color: #1D2129;
      font-weight: 500;
    }

    &.amount {
      color: #FF6B35;
      font-weight: 600;
    }

    &.shipped {
      color: #3D6DF7;
      font-weight: 500;
    }

    &.pending {
      color: #FF7D00;
      font-weight: 500;
    }

    &.convert {
      color: #86909C;
      font-size: 23rpx;
    }
  }
}

/* ========== 关联订单 ========== */
.order-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.order-card {
  padding: 20rpx;
  background: #F5F7FA;
  border-radius: 8rpx;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12rpx;

  .order-no {
    font-size: 27rpx;
    color: #1D2129;
    font-weight: 500;
  }
}

.order-status-tag {
  padding: 4rpx 14rpx;
  border-radius: 4rpx;
  font-size: 22rpx;
  font-weight: 500;

  &.status-0 { background: #FFF7E8; color: #FF7D00; }
  &.status-1 { background: #E8F0FE; color: #3D6DF7; }
  &.status-2 { background: #E8FFEA; color: #00B42A; }
  &.status-3 { background: #F2F3F5; color: #86909C; }
}

.order-body {
  .info-line {
    .info-value.amount {
      color: #FF6B35;
      font-weight: 600;
    }
  }
}

/* ========== 底部出库按钮 ========== */
.bottom-bar {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  padding: 20rpx 32rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  background: #fff;
  box-shadow: 0 -2rpx 12rpx rgba(0, 0, 0, 0.06);
  z-index: 10;

  .u-button {
    width: 100%;
  }
}

/* ========== 出库弹窗 ========== */
.stock-out-popup {
  height: 80vh;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
}

.popup-title-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28rpx 44rpx 20rpx;

  .popup-title {
    font-size: 32rpx;
    font-weight: 600;
    color: #1D2129;
  }
}

.warehouse-selector-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 44rpx;
  border-bottom: 1rpx solid #f0f0f0;

  .warehouse-label {
    font-size: 28rpx;
    font-weight: 500;
    color: #1D2129;
    flex-shrink: 0;
  }

  .warehouse-value-wrap {
    display: flex;
    align-items: center;
    gap: 8rpx;
  }

  .warehouse-name {
    font-size: 28rpx;
    color: #3D6DF7;
  }

  .warehouse-placeholder {
    font-size: 28rpx;
    color: #C9CDD4;
  }
}

.stock-out-scroll {
  flex: 1;
  min-height: 0;
  overflow: hidden;
  padding: 0;
}

.stock-out-scroll-inner {
  padding: 0 32rpx;
}

.stock-out-item {
  background: #FAFBFC;
  border-radius: 12rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  flex-shrink: 0;

  &:last-child {
    margin-bottom: 0;
  }
}

.stock-out-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8rpx;

  .stock-out-name {
    font-size: 28rpx;
    font-weight: 500;
    color: #1D2129;
    flex: 1;
    min-width: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    word-break: break-all;
  }

  .stock-out-pending {
    font-size: 24rpx;
    color: #00B42A;
    flex-shrink: 0;
    margin-left: 16rpx;
    white-space: nowrap;
    background: #E8FFEA;
    padding: 4rpx 12rpx;
    border-radius: 4rpx;
  }
}

.stock-out-convert {
  font-size: 23rpx;
  color: #86909C;
  margin-bottom: 16rpx;
}

.stock-out-form {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.form-row {
  display: flex;
  align-items: center;
  gap: 16rpx;
  min-width: 0;

  .form-label {
    font-size: 26rpx;
    color: #86909C;
    min-width: 100rpx;
    flex-shrink: 0;
  }

  .form-value {
    font-size: 26rpx;
    color: #1D2129;
    min-width: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;

    &.amount {
      color: #FF6B35;
      font-weight: 600;
    }
  }
}

.unit-type-btns {
  display: flex;
  gap: 12rpx;
  flex-wrap: wrap;
}

.unit-btn {
  padding: 10rpx 20rpx;
  background: #F5F7FA;
  border-radius: 6rpx;
  font-size: 24rpx;
  color: #4E5969;
  border: 2rpx solid transparent;

  &.active {
    background: #E8F0FE;
    color: #3D6DF7;
    border-color: #3D6DF7;
  }
}

.qty-input-wrap,
.price-input-wrap {
  display: flex;
  align-items: center;
  gap: 8rpx;
  flex: 1;
  min-width: 0;

  .qty-unit {
    font-size: 24rpx;
    color: #86909C;
    flex-shrink: 0;
  }
}

.stock-out-summary {
  padding: 20rpx 44rpx;
  font-size: 26rpx;
  color: #4E5969;
  border-top: 1rpx solid #F2F3F5;

  .summary-value {
    font-weight: 600;
    color: #1D2129;
  }
}

.stock-out-actions {
  display: flex;
  gap: 20rpx;
  padding: 20rpx 44rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));

  .u-button {
    flex: 1;
  }
}
</style>
