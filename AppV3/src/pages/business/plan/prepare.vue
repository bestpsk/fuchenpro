<template>
  <view class="form-container">
    <view class="form-section">
      <view class="section-title">方案信息</view>
      <view class="info-row">
        <text class="info-label">方案编号</text>
        <text class="info-value">{{ planInfo.planNo || '-' }}</text>
      </view>
      <view class="info-row">
        <text class="info-label">企业名称</text>
        <text class="info-value">{{ planInfo.enterpriseName || (planInfo.enterprise && planInfo.enterprise.enterpriseName) || '-' }}</text>
      </view>
      <view class="info-row">
        <text class="info-label">配赠金额</text>
        <text class="info-value amount">¥{{ formatAmount(planInfo.giftAmount) }}</text>
      </view>
      <view class="info-row">
        <text class="info-label">已出库金额</text>
        <text class="info-value">¥{{ formatAmount(planInfo.shippedAmount) }}</text>
      </view>
      <view class="info-row">
        <text class="info-label">备货中金额</text>
        <text class="info-value">¥{{ formatAmount(activePreparedAmount) }}</text>
      </view>
      <view class="info-row">
        <text class="info-label">剩余可备货</text>
        <text class="info-value" :class="{ 'amount-warning': parseFloat(remainingAvailable) <= 0 }">¥{{ formatAmount(remainingAvailable) }}</text>
      </view>
    </view>

    <view class="form-section">
      <view class="section-header">
        <view class="section-title">备货明细</view>
        <view class="add-item-btn" @click="openAddProduct">
          <u-icon name="plus" size="14" color="#3D6DF7"></u-icon>
          <text>添加货品</text>
        </view>
      </view>

      <view v-if="form.items.length > 0" class="items-list">
        <view v-for="(item, index) in form.items" :key="index" class="item-card">
          <view class="item-header">
            <text class="item-name">{{ item.productName || '未选择货品' }}</text>
            <view class="item-actions">
              <view class="action-btn" @click="removeItem(index)"><u-icon name="trash" size="14" color="#F53F3F"></u-icon></view>
            </view>
          </view>
          <view class="item-body">
            <view class="item-info-row">
              <view class="unit-type-switch">
                <view class="unit-type-btn" :class="{ active: item.unitType === '1' }" @click="changeUnitType(index, '1')">主单位(整)</view>
                <view class="unit-type-btn" :class="{ active: item.unitType === '2' }" @click="changeUnitType(index, '2')">副单位(拆)</view>
              </view>
              <text v-if="item.packQty > 1" class="conversion-text" style="margin-left: 20rpx;">1主={{ item.packQty }}副</text>
            </view>
            <view class="item-info-row item-row-between">
              <view class="item-left">
                <text class="item-label">出货价</text>
                <text class="item-value price">¥{{ formatAmount(item.salePrice) }}</text>
              </view>
              <view class="item-right">
                <text class="item-label">方案剩余</text>
                <text class="item-value">{{ formatRemainingQuantity(item) }}</text>
              </view>
            </view>
            <view class="item-info-row item-row-between">
              <view class="item-left">
                <text class="item-label">数量({{ getCurrentUnitName(item) }})</text>
                <view class="quantity-control">
                  <view class="qty-btn" @click="changeQuantity(index, -1)"><u-icon name="minus" size="12" color="#86909C"></u-icon></view>
                  <input class="qty-input" type="number" v-model.number="item.quantity" @input="onItemChange(index)" />
                  <view class="qty-btn" @click="changeQuantity(index, 1)"><u-icon name="plus" size="12" color="#86909C"></u-icon></view>
                </view>
              </view>
              <view class="item-right">
                <text class="item-label">金额</text>
                <text class="item-value price">¥{{ formatAmount(item.amount) }}</text>
              </view>
            </view>
          </view>
        </view>
      </view>
      <view v-else class="empty-items">
        <text class="empty-text">暂无备货明细，请添加货品</text>
      </view>
    </view>

    <u-popup :show="showProductPicker" mode="bottom" round="16" @close="showProductPicker = false">
      <view class="picker-content">
        <view class="picker-header">
          <text class="picker-title">选择货品</text>
          <view class="picker-close" @click="showProductPicker = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <view class="picker-search">
          <u-icon name="search" size="14" color="#86909C"></u-icon>
          <input class="picker-search-input" type="text" v-model="searchProductKeyword" placeholder="搜索货品名称" placeholder-class="search-placeholder" @input="onProductSearch" />
        </view>
        <scroll-view scroll-y class="picker-list" :style="{ height: '400rpx' }">
          <view v-for="p in productOptions" :key="p.productId" class="picker-item" @click="selectProduct(p)">
            <view class="picker-item-info">
              <text class="picker-item-text">{{ p.productName }}</text>
              <text class="picker-item-spec">{{ formatProductConversion(p) }}</text>
            </view>
            <text class="picker-item-price">¥{{ formatAmount(p.salePrice) }}</text>
          </view>
          <u-empty v-if="productOptions.length === 0" mode="search" text="未找到货品" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <view class="bottom-bar">
      <view class="bottom-info">
        <view class="bottom-row">
          <text class="bottom-label">本次备货总金额</text>
          <text class="bottom-amount">¥{{ totalAmount }}</text>
        </view>
        <view class="bottom-row sub">
          <text class="bottom-label">方案剩余可用金额</text>
          <text class="bottom-value" :class="{ 'amount-warning': parseFloat(remainingAvailable) <= 0 }">¥{{ formatAmount(remainingAvailable) }}</text>
        </view>
      </view>
      <view class="bottom-actions">
        <u-button type="primary" text="提交备货" :loading="submitting" @click="submitForm"></u-button>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getPlan } from '@/api/business/plan'
import { createFromPlan, getActivePreparedAmount } from '@/api/business/stockPrepare'
import { listProduct } from '@/api/wms/product'

// 单位字典映射（与 form.vue 保持一致）
const unitMap = { '1': '箱', '2': '件', '3': '套', '4': '罐', '5': '盒', '6': '袋', '7': '包' }
const specMap = { '1': '支', '2': '瓶', '3': '件', '4': '套', '5': '片', '6': '个' }

const submitting = ref(false)
const planId = ref(null)
const planInfo = ref({})
const activePreparedAmount = ref(0)
const showProductPicker = ref(false)
const productOptions = ref([])
const searchProductKeyword = ref('')

let productSearchTimer = null

const form = reactive({
  items: []
})

const totalAmount = computed(() => {
  return (form.items || []).reduce((sum, item) => sum + (parseFloat(item.amount) || 0), 0).toFixed(2)
})

const remainingAvailable = computed(() => {
  const giftAmount = parseFloat(planInfo.value.giftAmount) || 0
  const prepared = parseFloat(activePreparedAmount.value) || 0
  const shipped = parseFloat(planInfo.value.shippedAmount) || 0
  return (giftAmount - prepared - shipped).toFixed(2)
})

const planItems = computed(() => planInfo.value.items || [])

const hasPlanItems = computed(() => planItems.value.length > 0)

function formatAmount(val) {
  const num = parseFloat(val)
  if (isNaN(num)) return '0.00'
  return num.toFixed(2)
}

// 格式化货品换算规则：1盒=10支
function formatProductConversion(p) {
  const packQty = Number(p.packQty) || 1
  const mainUnit = unitMap[p.unit] || ''
  const subUnit = specMap[p.spec] || ''
  if (packQty > 1 && mainUnit && subUnit) {
    return '1' + mainUnit + '=' + packQty + subUnit
  }
  return mainUnit || subUnit || '-'
}

// 获取当前单位类型对应的单位名称（用于数量标签显示）
function getCurrentUnitName(item) {
  return String(item.unitType) === '1' ? getMainUnitName(item) : getSecondaryUnitName(item)
}

// 计算明细金额
function calcItemAmount(index) {
  const item = form.items[index]
  const qty = parseFloat(item.quantity) || 0
  const price = parseFloat(item.salePrice) || 0
  item.amount = Math.round(qty * price * 100) / 100
}

// 切换单位类型
function changeUnitType(index, type) {
  const item = form.items[index]
  if (String(item.unitType) === String(type)) return
  item.unitType = String(type)
  onUnitTypeChange(index)
}

// 单位类型切换处理：转换数量与出货价
function onUnitTypeChange(index) {
  const item = form.items[index]
  const packQty = Number(item.packQty) || 1
  const newType = String(item.unitType)
  const oldType = item._prevUnitType

  if (!oldType || newType === oldType) {
    item._prevUnitType = newType
    return
  }

  const currentQty = Number(item.quantity) || 0
  const currentSalePrice = Number(item.salePrice) || 0

  // 若已有备份（切换回原单位），直接还原
  if (item._prevQuantity !== undefined && item._prevSalePrice !== undefined) {
    const tempQty = currentQty
    const tempSalePrice = currentSalePrice
    item.quantity = item._prevQuantity
    item.salePrice = item._prevSalePrice
    item._prevQuantity = tempQty
    item._prevSalePrice = tempSalePrice
  } else {
    // 首次切换，按 packQty 转换
    if (newType === '1') {
      // 副 → 主: quantity / packQty, salePrice * packQty
      item.quantity = packQty > 0 ? Math.round(currentQty / packQty * 10000) / 10000 : 0
      item.salePrice = Math.round(currentSalePrice * packQty * 100) / 100
    } else {
      // 主 → 副: quantity * packQty, salePrice / packQty
      item.quantity = Math.round(currentQty * packQty * 10000) / 10000
      item.salePrice = packQty > 0 ? Math.round(currentSalePrice / packQty * 100) / 100 : 0
    }
    item._prevQuantity = currentQty
    item._prevSalePrice = currentSalePrice
  }

  // 同步更新 displayMaxQuantity（用于数量校验上限）
  item.displayMaxQuantity = newType === '1'
    ? (packQty > 0 ? Math.round((item.maxQuantity || 0) / packQty * 10000) / 10000 : 0)
    : (item.maxQuantity || 0)

  // 同步更新 spec 显示
  item.spec = newType === '1' ? getMainUnitName(item) : getSecondaryUnitName(item)

  item._prevUnitType = newType
  calcItemAmount(index)
}

// 获取主单位名称（如"盒"）
function getMainUnitName(item) {
  // 优先用 product.unit 字典 key 解析
  if (item.productUnit) {
    return unitMap[item.productUnit] || item.productUnit
  }
  // 兜底：unitType='1' 时 item.spec 即主单位名
  if (String(item.unitType) === '1') {
    return item.spec || ''
  }
  return ''
}

// 获取副单位名称（如"支"）
function getSecondaryUnitName(item) {
  // 优先用 product.spec 字典 key 解析
  if (item.productSpec) {
    return specMap[item.productSpec] || item.productSpec
  }
  // 兜底：unitType='2' 时 item.spec 即副单位名
  if (String(item.unitType) === '2') {
    return item.spec || ''
  }
  return ''
}

// 格式化方案剩余数量：主单位时显示 "2盒（20支）"，副单位时显示 "20支"
function formatRemainingQuantity(item) {
  const qty = Number(item.maxQuantity) || 0
  const packQty = Number(item.packQty) || 1
  const unitType = String(item.unitType)
  const mainUnit = getMainUnitName(item)
  const secondaryUnit = getSecondaryUnitName(item)

  // 无换算或无副单位名：仅显示数量+当前单位
  if (packQty <= 1 || !mainUnit || !secondaryUnit) {
    const unit = unitType === '1' ? mainUnit : secondaryUnit
    return qty + (unit ? unit : '')
  }

  // 主单位（整）：显示 "主数量+主单位（副数量+副单位）"
  if (unitType === '1') {
    const mainQty = qty / packQty
    const mainQtyStr = Number.isInteger(mainQty) ? mainQty : mainQty.toFixed(2)
    return `${mainQtyStr}${mainUnit}（${qty}${secondaryUnit}）`
  }

  // 副单位（拆）：显示 "副数量+副单位"
  return `${qty}${secondaryUnit}`
}

function onItemChange(index) {
  const item = form.items[index]
  let qty = parseFloat(item.quantity) || 0
  if (qty < 0) qty = 0
  const maxQty = Number(item.displayMaxQuantity) || 0
  if (maxQty > 0 && qty > maxQty) qty = maxQty
  item.quantity = qty
  calcItemAmount(index)
}

function changeQuantity(index, delta) {
  const item = form.items[index]
  let qty = (parseFloat(item.quantity) || 0) + delta
  if (qty < 0) qty = 0
  const maxQty = Number(item.displayMaxQuantity) || 0
  if (maxQty > 0 && qty > maxQty) qty = maxQty
  item.quantity = qty
  calcItemAmount(index)
}

function removeItem(index) {
  uni.showModal({
    title: '提示',
    content: '确认删除该明细?',
    success: (res) => { if (res.confirm) form.items.splice(index, 1) }
  })
}

function openAddProduct() {
  searchProductKeyword.value = ''
  showProductPicker.value = true
  loadProducts('')
}

async function loadProducts(keyword) {
  try {
    const response = await listProduct({ productName: keyword || '', status: '0', pageNum: 1, pageSize: 20 })
    const data = response.data || response
    productOptions.value = data.rows || []
  } catch (e) { console.error('加载货品列表失败:', e) }
}

function onProductSearch() {
  if (productSearchTimer) clearTimeout(productSearchTimer)
  productSearchTimer = setTimeout(() => loadProducts(searchProductKeyword.value), 400)
}

function selectProduct(p) {
  const exists = form.items.find(item => item.productId === p.productId)
  if (exists) {
    uni.showToast({ title: '该货品已添加', icon: 'none' })
    return
  }
  const productUnit = p.unit
  const productSpec = p.spec
  const mainUnitName = unitMap[productUnit] || productUnit || ''
  form.items.push({
    productId: p.productId,
    productName: p.productName,
    supplierId: p.supplierId,
    supplierName: p.supplierName || '',
    unitType: '1',
    _prevUnitType: '1',
    _prevQuantity: undefined,
    _prevSalePrice: undefined,
    packQty: p.packQty || 1,
    spec: mainUnitName,
    salePrice: p.salePrice || 0,
    productUnit: productUnit,
    productSpec: productSpec,
    quantity: 0,
    maxQuantity: 0,
    displayMaxQuantity: 0,
    amount: 0,
    planItemId: undefined
  })
  showProductPicker.value = false
}

async function loadPlanDetail() {
  if (!planId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getPlan(planId.value)
    const data = response.data || response
    planInfo.value = data

    if (data.items && data.items.length > 0) {
      form.items = data.items.filter(item => item.remainingQuantity > 0).map(item => {
        const unitType = String(item.unitType || '1')
        const packQty = Number(item.packQty) || 1
        const maxQuantity = Number(item.remainingQuantity) || 0
        // 后端 biz_plan_item.sale_price 恒为副单位价（由 BizPlanService::syncPlanItems 统一归一化）
        const backendSalePrice = Number(item.salePrice) || 0
        // 主单位价：packQty>1 时 = 后端价 * packQty；否则 = 后端价
        const mainPrice = packQty > 1
          ? Math.round(backendSalePrice * packQty * 100) / 100
          : backendSalePrice
        // 按当前单位类型决定显示价
        const displayPrice = unitType === '1' ? mainPrice : backendSalePrice
        // 根据单位类型计算显示用最大数量
        const displayMaxQuantity = unitType === '1' && packQty > 1
          ? Math.round(maxQuantity / packQty * 10000) / 10000
          : maxQuantity
        return {
          planItemId: item.itemId,
          productId: item.productId,
          productName: item.productName,
          supplierId: item.supplierId,
          supplierName: item.supplierName,
          unitType: unitType,
          _prevUnitType: unitType,
          _prevQuantity: undefined,
          _prevSalePrice: undefined,
          packQty: packQty,
          spec: item.spec,
          salePrice: displayPrice,
          productUnit: item.product?.unit,
          productSpec: item.product?.spec,
          quantity: 0,
          maxQuantity: maxQuantity,
          displayMaxQuantity: displayMaxQuantity,
          amount: 0
        }
      })
    }

    await loadActiveAmount()
  } catch (e) {
    console.error('加载方案详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

async function loadActiveAmount() {
  if (!planId.value) return
  try {
    const amountRes = await getActivePreparedAmount(planId.value)
    activePreparedAmount.value = amountRes.data?.activePreparedAmount || 0
  } catch (e) {
    console.error('获取备货中金额失败:', e)
  }
}

async function submitForm() {
  if (!form.items || form.items.length === 0) {
    uni.showToast({ title: '请至少添加一条备货明细', icon: 'none' })
    return
  }
  const hasInvalidQty = form.items.some(item => !item.quantity || item.quantity <= 0)
  if (hasInvalidQty) {
    uni.showToast({ title: '请输入有效的备货数量', icon: 'none' })
    return
  }
  if (parseFloat(totalAmount.value) > parseFloat(remainingAvailable.value)) {
    uni.showToast({ title: `本次备货金额 ${totalAmount.value} 超过剩余可备货金额 ${remainingAvailable.value}`, icon: 'none', duration: 3000 })
    return
  }

  submitting.value = true
  try {
    const items = form.items.map(item => ({
      planItemId: item.planItemId,
      productId: item.productId,
      productName: item.productName,
      spec: item.spec,
      unitType: item.unitType,
      salePrice: parseFloat(item.salePrice) || 0,
      quantity: parseFloat(item.quantity) || 0
    }))
    await createFromPlan(planId.value, items)
    uni.showToast({ title: '备货成功，已自动创建出库单', icon: 'success' })
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('提交失败:', e)
    const msg = e?.msg || e?.message || '操作失败，请重试'
    uni.showToast({ title: msg, icon: 'none', duration: 2000 })
  } finally { submitting.value = false }
}

function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.redirectTo({ url: '/pages/business/plan/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const options = pages[pages.length - 1].options || {}
  planId.value = options.planId ? parseInt(options.planId) : null
  loadPlanDetail()
})

onShow(() => {
  if (planId.value) {
    loadActiveAmount()
  }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.form-container { min-height: 100vh; padding-bottom: 280rpx; }

.form-section { margin: 24rpx; background: #fff; border-radius: 20rpx; padding: 32rpx; box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05); }
.section-title { font-size: 30rpx; font-weight: 600; color: #1D2129; margin-bottom: 24rpx; }
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24rpx; }

.info-row { display: flex; align-items: center; justify-content: space-between; padding: 12rpx 0; border-bottom: 1rpx solid #F7F8FA;
  &:last-child { border-bottom: none; }
}
.info-label { font-size: 26rpx; color: #86909C; }
.info-value { font-size: 27rpx; color: #1D2129;
  &.amount { color: #FF6B35; font-weight: 600; font-size: 30rpx; }
  &.amount-warning { color: #F53F3F; font-weight: 600; }
}

.add-item-btn { display: flex; align-items: center; gap: 6rpx; padding: 8rpx 20rpx; background: #E8F0FE; border-radius: 24rpx;
  text { font-size: 24rpx; color: #3D6DF7; font-weight: 500; }
}

.items-list { display: flex; flex-direction: column; gap: 16rpx; }
.item-card { background: #F7F8FA; border-radius: 12rpx; padding: 20rpx; }
.item-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12rpx; }
.item-name { font-size: 28rpx; font-weight: 500; color: #1D2129; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.item-actions { display: flex; gap: 16rpx; }
.action-btn { padding: 8rpx; }
.item-body { display: flex; flex-direction: column; gap: 10rpx; }
.item-info-row { display: flex; align-items: center; gap: 8rpx; }
.item-row-between { justify-content: space-between; }
.item-left { display: flex; align-items: center; gap: 8rpx; }
.item-right { display: flex; align-items: center; gap: 8rpx; }
.item-label { font-size: 24rpx; color: #86909C; white-space: nowrap; }
.item-value { font-size: 24rpx; color: #4E5969;
  &.price { color: #FF6B35; font-weight: 600; }
}

.quantity-control { display: flex; align-items: center; gap: 4rpx; }
.qty-btn { width: 48rpx; height: 48rpx; display: flex; align-items: center; justify-content: center; background: #F2F3F5; border-radius: 8rpx; }
.qty-input { width: 80rpx; text-align: center; font-size: 26rpx; color: #1D2129; height: 48rpx; line-height: 48rpx; background: #fff; border-radius: 8rpx; }

.unit-type-switch { display: flex; background: #F2F3F5; border-radius: 12rpx; overflow: hidden; height: 60rpx; flex: 1; max-width: 320rpx; }
.unit-type-btn { flex: 1; display: flex; align-items: center; justify-content: center; font-size: 24rpx; color: #86909C; font-weight: 500; transition: all 0.2s;
  &.active { background: #3D6DF7; color: #fff; border-radius: 12rpx; }
}
.conversion-text { font-size: 24rpx; color: #86909C; }

.empty-items { padding: 40rpx 0; text-align: center; }
.empty-text { font-size: 26rpx; color: #C9CDD4; }

.picker-content { padding: 30rpx; background: #fff; }
.picker-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.picker-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.picker-close { padding: 8rpx; }
.picker-search { display: flex; align-items: center; background: #F7F8FA; border-radius: 36rpx; padding: 0 24rpx; height: 72rpx; gap: 12rpx; margin-bottom: 20rpx; }
.picker-search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; }
.picker-item { display: flex; justify-content: space-between; align-items: center; padding: 24rpx 16rpx; border-bottom: 1rpx solid #F2F3F5;
  &:active { background: #F5F7FA; }
}
.picker-item-info { display: flex; flex-direction: column; gap: 4rpx; flex: 1; }
.picker-item-text { font-size: 28rpx; color: #1D2129; }
.picker-item-spec { font-size: 24rpx; color: #86909C; }
.picker-item-price { font-size: 26rpx; color: #FF6B35; font-weight: 500; flex-shrink: 0; }

.bottom-bar { position: fixed; left: 0; right: 0; bottom: 0; background: #fff; padding: 20rpx 32rpx; padding-bottom: calc(20rpx + env(safe-area-inset-bottom)); box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.08); z-index: 100; }
.bottom-info { margin-bottom: 16rpx; }
.bottom-row { display: flex; justify-content: space-between; align-items: center; padding: 6rpx 0;
  &.sub { padding-top: 4rpx; }
}
.bottom-label { font-size: 26rpx; color: #86909C; }
.bottom-amount { font-size: 32rpx; color: #FF6B35; font-weight: 600; }
.bottom-value { font-size: 26rpx; color: #4E5969;
  &.amount-warning { color: #F53F3F; font-weight: 600; }
}
.bottom-actions {
  .u-button { height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
