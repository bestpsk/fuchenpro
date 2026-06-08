<template>
  <view class="form-container">
    <view class="form-section">
      <view class="section-title">方案信息</view>
      <view class="form-field">
        <view class="field-input-box field-readonly">
          <u-icon name="file-text" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.planName" placeholder="关联方案" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
        </view>
      </view>
      <view class="form-row">
        <view class="form-field half-width">
          <view class="field-input-box field-readonly">
            <u-icon name="home-fill" size="16" color="#86909C"></u-icon>
            <input class="field-input" :value="form.enterpriseName" placeholder="企业" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          </view>
        </view>
        <view class="form-field half-width">
          <view class="field-input-box field-readonly">
            <u-icon name="share" size="16" color="#86909C"></u-icon>
            <input class="field-input" :value="form.commissionRate" placeholder="回款比例" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          </view>
        </view>
      </view>
    </view>

    <view class="form-section">
      <view class="section-title">收货信息</view>
      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="man" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.contactPerson" placeholder="* 收货人" placeholder-class="field-placeholder" />
        </view>
      </view>
      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="phone" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="tel" v-model="form.contactPhone" placeholder="收货电话" placeholder-class="field-placeholder" />
        </view>
      </view>
      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="map" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.shippingAddress" placeholder="收货地址" placeholder-class="field-placeholder" />
        </view>
      </view>
    </view>

    <view class="form-section">
      <view class="section-header">
        <view class="section-title">出货明细</view>
        <view class="add-item-btn" @click="addCustomProduct">
          <u-icon name="plus" size="14" color="#3D6DF7"></u-icon>
          <text>添加货品</text>
        </view>
      </view>

      <view v-if="form.items.length > 0" class="items-list">
        <view v-for="(item, index) in form.items" :key="index" class="item-card">
          <view class="item-header">
            <text class="item-name">{{ item.productName || '未选择货品' }}</text>
            <view class="item-actions">
              <view v-if="!item.planItemId" class="action-btn" @click="editCustomItem(index)"><u-icon name="edit-pen" size="14" color="#3D6DF7"></u-icon></view>
              <view class="action-btn" @click="removeItem(index)"><u-icon name="trash" size="14" color="#F53F3F"></u-icon></view>
            </view>
          </view>
          <view class="item-body">
            <view class="item-info-row">
              <text class="item-label">供货商</text>
              <text class="item-value">{{ item.supplierName || '-' }}</text>
              <text class="item-label" style="margin-left: 20rpx;">单位</text>
              <text class="item-value">{{ getUnitTypeLabel(item) }}</text>
            </view>
            <view class="item-info-row item-row-between">
              <view class="item-left">
                <text class="item-label">数量</text>
                <view class="quantity-control">
                  <view class="qty-btn" @click="changeQuantity(index, -1)"><u-icon name="minus" size="12" color="#86909C"></u-icon></view>
                  <input class="qty-input" type="number" v-model.number="item.quantity" @input="onItemChange(index)" />
                  <view class="qty-btn" @click="changeQuantity(index, 1)"><u-icon name="plus" size="12" color="#86909C"></u-icon></view>
                </view>
                <text v-if="item.planItemId" class="item-max">最多{{ item.maxQuantity }}</text>
              </view>
              <view class="item-right">
                <text class="item-label">单价</text>
                <text class="item-value price">¥{{ formatAmount(item.salePrice) }}</text>
              </view>
            </view>
            <view class="item-info-row item-row-between amount-row">
              <view class="item-left">
                <text class="item-label">折扣单价</text>
                <input class="discount-input" type="digit" v-model="item.discountPrice" @input="onItemChange(index)" />
              </view>
              <view class="item-right">
                <text class="item-label">总金额</text>
                <input class="amount-input" type="digit" v-model="item.amount" @input="onAmountChange(index)" />
              </view>
            </view>
          </view>
        </view>
      </view>
      <view v-else class="empty-items">
        <text class="empty-text">暂无出货明细</text>
      </view>

      <view class="summary-row">
        <text class="summary-label">出货总金额</text>
        <text class="summary-amount">¥{{ totalAmount }}</text>
      </view>
      <view class="summary-row sub">
        <text class="summary-label">方案剩余金额</text>
        <text class="summary-value">¥{{ formatAmount(form.remainingAmount) }}</text>
      </view>
    </view>

    <view class="form-section">
      <view class="section-title">备注</view>
      <view class="form-field">
        <view class="field-textarea-box">
          <textarea class="field-textarea" v-model="form.remark" placeholder="请输入备注信息" placeholder-class="field-placeholder" :maxlength="500" auto-height></textarea>
        </view>
      </view>
    </view>

    <u-popup :show="showItemForm" mode="bottom" round="16" @close="showItemForm = false">
      <view class="picker-content">
        <view class="picker-header">
          <text class="picker-title">添加货品</text>
          <view class="picker-close" @click="showItemForm = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <view class="item-form-content">
          <view class="form-field" @click="searchProductKeyword = ''; showProductPicker = true">
            <view class="field-input-box">
              <u-icon name="list" size="18" color="#86909C"></u-icon>
              <input class="field-input" :value="itemForm.productName" placeholder="* 选择货品" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
              <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
            </view>
          </view>
          <view class="form-field" @click="showUnitTypePicker = true">
            <view class="field-input-box">
              <u-icon name="grid" size="18" color="#86909C"></u-icon>
              <input class="field-input" :value="getUnitTypeLabel(itemForm)" placeholder="单位类型" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
              <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
            </view>
          </view>
          <view class="form-row">
            <view class="form-field half-width">
              <view class="field-input-box">
                <u-icon name="minus-circle" size="16" color="#86909C"></u-icon>
                <input class="field-input" type="number" v-model.number="itemForm.quantity" placeholder="数量" placeholder-class="field-placeholder" @input="calcItemFormAmount" />
              </view>
            </view>
            <view class="form-field half-width">
              <view class="field-input-box">
                <u-icon name="rmb-circle" size="16" color="#86909C"></u-icon>
                <input class="field-input" type="digit" v-model="itemForm.discountPrice" placeholder="折扣单价" placeholder-class="field-placeholder" @input="calcItemFormAmount" />
              </view>
            </view>
          </view>
          <view class="item-amount-row">
            <text class="item-amount-label">总金额</text>
            <input class="item-amount-input" type="digit" v-model="itemForm.amount" @input="onItemFormAmountChange" />
          </view>
        </view>
        <view class="picker-actions">
          <u-button type="info" plain text="取消" @click="showItemForm = false"></u-button>
          <u-button type="primary" text="确定" @click="confirmCustomItem"></u-button>
        </view>
      </view>
    </u-popup>

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
          <view v-for="p in productOptions" :key="p.productId" class="picker-item" :class="{ active: itemForm.productId === p.productId }" @click="selectProduct(p)">
            <text class="picker-item-text">{{ p.productName }}</text>
            <text class="picker-item-price">¥{{ formatAmount(p.salePrice) }}</text>
          </view>
          <u-empty v-if="productOptions.length === 0" mode="search" text="未找到货品" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <u-picker :show="showUnitTypePicker" :columns="unitTypeColumns" keyName="label" title="选择单位类型" @confirm="onUnitTypeConfirm" @cancel="showUnitTypePicker = false" @close="showUnitTypePicker = false"></u-picker>

    <view class="form-actions">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button v-if="checkPermi('business:stockPrepare:createStockOut')" type="primary" text="提交" :loading="submitting" @click="submitForm"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getPlan } from '@/api/business/plan'
import { addStockOut } from '@/api/wms/stockOut'
import { listProduct } from '@/api/wms/product'
import { checkPermi } from '@/utils/permission'

const submitting = ref(false)
const planId = ref(null)

const showItemForm = ref(false)
const showProductPicker = ref(false)
const showUnitTypePicker = ref(false)
const productOptions = ref([])
const searchProductKeyword = ref('')
const editingItemIndex = ref(-1)

let productSearchTimer = null

const form = reactive({
  planId: undefined,
  planName: '',
  enterpriseId: undefined,
  enterpriseName: '',
  commissionRate: '',
  contactPerson: '',
  contactPhone: '',
  shippingAddress: '',
  remainingAmount: 0,
  remark: '',
  items: []
})

const itemForm = reactive({
  productId: undefined,
  productName: '',
  supplierId: undefined,
  supplierName: '',
  unitType: '1',
  packQty: 1,
  quantity: 1,
  spec: '',
  salePrice: 0,
  discountPrice: 0,
  amount: 0,
  _mainPrice: null,
  unitLabel: '',
  specLabel: ''
})

const totalAmount = computed(() => {
  return (form.items || []).reduce((sum, item) => sum + (parseFloat(item.amount) || 0), 0).toFixed(2)
})

function formatAmount(val) {
  const num = parseFloat(val)
  if (isNaN(num)) return '0.00'
  return num.toFixed(2)
}

function getUnitTypeLabel(item) {
  if (item.unitType === '1') {
    const label = item.unitLabel || ''
    return label ? label + '（主单位整）' : '主单位整'
  } else {
    const label = item.specLabel || ''
    return label ? label + '（副单位拆）' : '副单位拆'
  }
}

const unitTypeColumns = computed(() => {
  const mainLabel = itemForm.unitLabel || ''
  const subLabel = itemForm.specLabel || ''
  return [[
    { label: mainLabel ? mainLabel + '（主单位整）' : '主单位整', value: '1' },
    { label: subLabel ? subLabel + '（副单位拆）' : '副单位拆', value: '2' }
  ]]
})

function onItemChange(index) {
  const item = form.items[index]
  const qty = parseInt(item.quantity) || 0
  if (item.planItemId && item.maxQuantity && qty > item.maxQuantity) {
    item.quantity = item.maxQuantity
  }
  if (qty < 1) item.quantity = 1
  item.amount = (parseFloat(item.discountPrice) || 0) * (parseInt(item.quantity) || 0)
}

function onAmountChange(index) {
  const item = form.items[index]
  const qty = parseInt(item.quantity) || 0
  if (qty > 0) {
    item.discountPrice = Math.round((parseFloat(item.amount) / qty) * 100) / 100
  }
}

function changeQuantity(index, delta) {
  const item = form.items[index]
  let qty = (parseInt(item.quantity) || 0) + delta
  if (qty < 1) qty = 1
  if (item.planItemId && item.maxQuantity && qty > item.maxQuantity) qty = item.maxQuantity
  item.quantity = qty
  onItemChange(index)
}

function removeItem(index) {
  uni.showModal({
    title: '提示',
    content: '确认删除该明细?',
    success: (res) => { if (res.confirm) form.items.splice(index, 1) }
  })
}

function addCustomProduct() {
  editingItemIndex.value = -1
  Object.assign(itemForm, {
    productId: undefined, productName: '', supplierId: undefined, supplierName: '',
    unitType: '1', packQty: 1, quantity: 1, spec: '', salePrice: 0, discountPrice: 0, amount: 0,
    _mainPrice: null, unitLabel: '', specLabel: ''
  })
  showItemForm.value = true
  loadProducts('')
}

function editCustomItem(index) {
  editingItemIndex.value = index
  const item = form.items[index]
  Object.assign(itemForm, { ...item })
  showItemForm.value = true
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
  itemForm.productId = p.productId
  itemForm.productName = p.productName
  itemForm.supplierId = p.supplierId
  itemForm.supplierName = p.supplierName || ''
  itemForm.packQty = p.packQty || 1
  itemForm.unitType = '1'
  itemForm._mainPrice = p.salePrice || 0
  itemForm.salePrice = p.salePrice || 0
  itemForm.discountPrice = p.salePrice || 0
  const unitMap = { '1': '箱', '2': '件', '3': '套', '4': '罐', '5': '盒', '6': '袋', '7': '包' }
  const specMap = { '1': '支', '2': '瓶', '3': '件', '4': '套', '5': '片', '6': '个' }
  itemForm.unitLabel = unitMap[p.unit] || ''
  itemForm.specLabel = specMap[p.spec] || ''
  itemForm.spec = itemForm.unitLabel || ''
  calcItemFormAmount()
  showProductPicker.value = false
}

function onUnitTypeConfirm(e) {
  const item = e.value[0]
  itemForm.unitType = item.value
  if (itemForm.unitType === '1') {
    if (itemForm._mainPrice) {
      itemForm.salePrice = itemForm._mainPrice
      itemForm.discountPrice = itemForm._mainPrice
    }
    itemForm.spec = itemForm.unitLabel || ''
  } else {
    if (itemForm._mainPrice && itemForm.packQty > 0) {
      itemForm.salePrice = Math.round((itemForm._mainPrice / itemForm.packQty) * 100) / 100
      itemForm.discountPrice = Math.round((itemForm._mainPrice / itemForm.packQty) * 100) / 100
    }
    itemForm.spec = itemForm.specLabel || ''
  }
  calcItemFormAmount()
  showUnitTypePicker.value = false
}

function calcItemFormAmount() {
  itemForm.amount = (parseFloat(itemForm.discountPrice) || 0) * (parseInt(itemForm.quantity) || 0)
}

function onItemFormAmountChange() {
  const qty = parseInt(itemForm.quantity) || 0
  if (qty > 0) {
    itemForm.discountPrice = Math.round((parseFloat(itemForm.amount) / qty) * 100) / 100
  }
}

function confirmCustomItem() {
  if (!itemForm.productId) { uni.showToast({ title: '请选择货品', icon: 'none' }); return }
  if (!itemForm.quantity || itemForm.quantity < 1) { uni.showToast({ title: '请输入数量', icon: 'none' }); return }
  const itemData = { ...itemForm, planItemId: undefined }
  delete itemData._mainPrice
  if (editingItemIndex.value >= 0) {
    form.items[editingItemIndex.value] = itemData
  } else {
    form.items.push(itemData)
  }
  showItemForm.value = false
}

async function loadPlanDetail() {
  if (!planId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getPlan(planId.value)
    const data = response.data || response
    form.planId = data.planId
    form.planName = data.planName || ''
    form.enterpriseId = data.enterpriseId
    form.enterpriseName = data.enterpriseName || (data.enterprise && data.enterprise.enterpriseName) || ''
    form.commissionRate = data.commissionRate ? (data.commissionRate + '%') : ''
    form.contactPerson = data.enterprise?.bossName || ''
    form.contactPhone = data.enterprise?.phone || ''
    form.shippingAddress = data.enterprise?.address || ''
    form.remainingAmount = data.remainingAmount || 0
    form.items = (data.items || []).filter(item => item.remainingQuantity > 0).map(item => {
      const unitMap = { '1': '箱', '2': '件', '3': '套', '4': '罐', '5': '盒', '6': '袋', '7': '包' }
      const specMap = { '1': '支', '2': '瓶', '3': '件', '4': '套', '5': '片', '6': '个' }
      return {
        planItemId: item.itemId,
        productId: item.productId,
        productName: item.productName,
        supplierId: item.supplierId,
        supplierName: item.supplierName,
        unitType: item.unitType,
        packQty: item.packQty,
        quantity: item.remainingQuantity,
        maxQuantity: item.remainingQuantity,
        spec: item.spec,
        salePrice: item.salePrice,
        discountPrice: item.salePrice,
        amount: (parseFloat(item.salePrice) || 0) * item.remainingQuantity,
        unitLabel: unitMap[item.product?.unit] || '',
        specLabel: specMap[item.product?.spec] || ''
      }
    })
  } catch (e) {
    console.error('加载方案详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

async function submitForm() {
  if (!form.contactPerson) { uni.showToast({ title: '请输入收货人', icon: 'none' }); return }
  if (!form.items || form.items.length === 0) { uni.showToast({ title: '请至少添加一条出货明细', icon: 'none' }); return }
  const hasEmptyItem = form.items.some(item => !item.productId)
  if (hasEmptyItem) { uni.showToast({ title: '请先选择完整的货品信息', icon: 'none' }); return }
  if (parseFloat(totalAmount.value) > parseFloat(form.remainingAmount)) {
    uni.showToast({ title: '出货总金额不能大于方案剩余金额', icon: 'none' })
    return
  }

  submitting.value = true
  try {
    const today = new Date().toISOString().slice(0, 10)
    const submitData = {
      stockOutType: 1,
      outTargetType: 1,
      enterpriseId: form.enterpriseId,
      enterpriseName: form.enterpriseName,
      planId: form.planId,
      shipType: '2',
      stockOutDate: today,
      contactPerson: form.contactPerson,
      contactPhone: form.contactPhone,
      shippingAddress: form.shippingAddress,
      remark: form.remark || undefined,
      items: form.items.map(item => ({
        productId: item.productId,
        productName: item.productName,
        productCode: item.productCode || '',
        unitType: item.unitType,
        packQty: item.packQty || 1,
        quantity: parseInt(item.quantity) || 0,
        price: parseFloat(item.discountPrice) || 0,
        amount: parseFloat(item.amount) || 0,
        supplierId: item.supplierId,
        supplierName: item.supplierName || '',
        planItemId: item.planItemId || undefined
      }))
    }
    await addStockOut(submitData)
    uni.showToast({ title: '新建出库单成功', icon: 'success' })
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
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.form-container { min-height: 100vh; padding-bottom: 140rpx; }

.form-section { margin: 24rpx; background: #fff; border-radius: 20rpx; padding: 32rpx; box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05); }
.section-title { font-size: 30rpx; font-weight: 600; color: #1D2129; margin-bottom: 24rpx; }
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24rpx; }

.add-item-btn { display: flex; align-items: center; gap: 6rpx; padding: 8rpx 20rpx; background: #E8F0FE; border-radius: 24rpx;
  text { font-size: 24rpx; color: #3D6DF7; font-weight: 500; }
}

.form-field { margin-bottom: 20rpx; &:last-child { margin-bottom: 0; } }
.field-input-box { display: flex; align-items: center; background: #F7F8FA; border-radius: 12rpx; padding: 0 20rpx; height: 88rpx; gap: 16rpx; border: 2rpx solid transparent; transition: all 0.2s;
  &.field-readonly { opacity: 0.8; }
}
.field-input { flex: 1; font-size: 30rpx; color: #1D2129; height: 88rpx; line-height: 88rpx; }
.field-placeholder { color: #C9CDD4; font-size: 30rpx; }
.field-textarea-box { display: flex; flex-direction: column; background: #F7F8FA; border-radius: 12rpx; padding: 16rpx 20rpx; gap: 8rpx; }
.field-textarea { width: 100%; min-height: 120rpx; font-size: 28rpx; color: #1D2129; line-height: 1.6; }
.form-row { display: flex; gap: 20rpx; }
.half-width { flex: 1; min-width: 0;
  .field-input-box { height: 80rpx; }
  .field-input { height: 80rpx; line-height: 80rpx; font-size: 28rpx; }
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
.item-max { font-size: 22rpx; color: #C9CDD4; margin-left: 8rpx; }
.amount-row { margin-top: 4rpx; padding-top: 8rpx; border-top: 1rpx solid #E5E6EB; }

.quantity-control { display: flex; align-items: center; gap: 4rpx; }
.qty-btn { width: 48rpx; height: 48rpx; display: flex; align-items: center; justify-content: center; background: #F2F3F5; border-radius: 8rpx; }
.qty-input { width: 80rpx; text-align: center; font-size: 26rpx; color: #1D2129; height: 48rpx; line-height: 48rpx; background: #fff; border-radius: 8rpx; }

.discount-input { width: 120rpx; font-size: 26rpx; color: #FF6B35; text-align: right; background: #fff; border-radius: 8rpx; padding: 0 12rpx; height: 48rpx; line-height: 48rpx; }

.amount-input { width: 140rpx; font-size: 26rpx; color: #FF6B35; font-weight: 600; text-align: right; background: #fff; border-radius: 8rpx; padding: 0 12rpx; height: 48rpx; line-height: 48rpx; }

.empty-items { padding: 40rpx 0; text-align: center; }
.empty-text { font-size: 26rpx; color: #C9CDD4; }

.summary-row { display: flex; justify-content: space-between; align-items: center; padding: 16rpx 0;
  &.sub { padding-top: 8rpx; }
}
.summary-label { font-size: 26rpx; color: #86909C; }
.summary-amount { font-size: 32rpx; color: #FF6B35; font-weight: 600; }
.summary-value { font-size: 26rpx; color: #86909C; }

.picker-content { padding: 30rpx; background: #fff; }
.picker-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.picker-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.picker-close { padding: 8rpx; }
.picker-search { display: flex; align-items: center; background: #F7F8FA; border-radius: 36rpx; padding: 0 24rpx; height: 72rpx; gap: 12rpx; margin-bottom: 20rpx; }
.picker-search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; }
.picker-item { display: flex; justify-content: space-between; align-items: center; padding: 24rpx 16rpx; border-bottom: 1rpx solid #F2F3F5;
  &.active { background: #E8F0FE; }
  &:active { background: #F5F7FA; }
}
.picker-item-text { font-size: 28rpx; color: #1D2129; flex: 1; }
.picker-item-price { font-size: 26rpx; color: #FF6B35; font-weight: 500; }

.item-form-content { padding: 0 0 20rpx; }
.item-amount-row { display: flex; justify-content: space-between; align-items: center; padding: 20rpx 0; border-top: 1rpx solid #F2F3F5; margin-top: 8rpx; }
.item-amount-label { font-size: 28rpx; color: #86909C; }
.item-amount-value { font-size: 32rpx; color: #FF6B35; font-weight: 600; }
.item-amount-input { width: 300rpx; font-size: 30rpx; color: #FF6B35; font-weight: 600; text-align: right; background: #F7F8FA; border-radius: 8rpx; padding: 0 16rpx; height: 64rpx; line-height: 64rpx; }

.picker-actions { display: flex; gap: 20rpx; padding-top: 20rpx; border-top: 1rpx solid #E5E6EB; .u-button { flex: 1; } }

.form-actions { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; display: flex; gap: 20rpx; z-index: 100;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
