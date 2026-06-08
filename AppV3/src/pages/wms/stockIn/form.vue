<template>
  <view class="form-container">
    <view class="form-section">
      <view class="section-title">入库信息</view>

      <view class="form-field" @click="showTypePicker = true">
        <view class="field-label"><text class="required">*</text> 入库类型</view>
        <view class="field-input-box picker-field">
          <input class="field-input" :value="getStockInTypeLabel(form.stockInType)" placeholder="请选择入库类型" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="openSupplierPicker">
        <view class="field-label">供货商</view>
        <view class="field-input-box picker-field">
          <input class="field-input" :value="form.supplierName" placeholder="请选择供货商" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field">
        <view class="field-label">备注</view>
        <view class="field-textarea-box">
          <textarea class="field-textarea" v-model="form.remark" placeholder="请输入备注信息" placeholder-class="field-placeholder" :maxlength="500" auto-height></textarea>
        </view>
      </view>
    </view>

    <view class="form-section">
      <view class="section-header">
        <view class="section-title">入库明细</view>
        <view class="add-item-btn" @click="addItem">
          <u-icon name="plus" size="14" color="#3D6DF7"></u-icon>
          <text>添加明细</text>
        </view>
      </view>

      <view v-if="form.items.length > 0" class="items-list">
        <view v-for="(item, index) in form.items" :key="index" class="item-card">
          <view class="item-header">
            <text class="item-index">{{ index + 1 }}.</text>
            <text class="item-name">{{ item.productName || '未选择货品' }}</text>
            <view class="item-delete" @click="removeItem(index)">
              <u-icon name="trash" size="14" color="#F53F3F"></u-icon>
            </view>
          </view>
          <view class="item-body">
            <view class="form-field mini" @click="openProductPicker(index)">
              <view class="field-label">货品</view>
              <view class="field-input-box picker-field mini">
                <input class="field-input" :value="item.productName" placeholder="搜索选择货品" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
                <u-icon name="arrow-right" size="12" color="#C9CDD4"></u-icon>
              </view>
            </view>
            <view class="item-row">
              <view class="form-field mini half">
                <view class="field-label">单位类型</view>
                <view class="unit-type-switch">
                  <view class="unit-type-btn" :class="{ active: item.unitType === '1' }" @click="changeUnitType(index, '1')">主单位(整)</view>
                  <view class="unit-type-btn" :class="{ active: item.unitType === '2' }" @click="changeUnitType(index, '2')">副单位(拆)</view>
                </view>
              </view>
              <view class="form-field mini half" v-if="item.packQty > 1">
                <view class="field-label">换算</view>
                <view class="field-input-box mini readonly">
                  <text class="conversion-text">1主={{ item.packQty }}副</text>
                </view>
              </view>
            </view>
            <view class="item-row">
              <view class="form-field mini half">
                <view class="field-label">数量</view>
                <view class="field-input-box mini">
                  <input class="field-input" type="number" v-model.number="item.quantity" placeholder="0" placeholder-class="field-placeholder" @input="calcItemAmount(index)" />
                </view>
              </view>
              <view class="form-field mini half">
                <view class="field-label">进货单价</view>
                <view class="field-input-box mini">
                  <input class="field-input" type="digit" v-model="item.price" placeholder="0.00" placeholder-class="field-placeholder" @input="calcItemAmount(index)" />
                </view>
              </view>
            </view>
            <view class="item-row">
              <view class="form-field mini half">
                <view class="field-label">金额</view>
                <view class="field-input-box mini readonly">
                  <input class="field-input amount-value" :value="formatAmount(item.amount)" disabled :disabledColor="'transparent'" />
                </view>
              </view>
              <view class="form-field mini half" @click="openDatePicker(index, 'productionDate')">
                <view class="field-label">生产日期</view>
                <view class="field-input-box picker-field mini">
                  <input class="field-input" :value="item.productionDate" placeholder="选择日期" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
                  <u-icon name="arrow-right" size="12" color="#C9CDD4"></u-icon>
                </view>
              </view>
            </view>
            <view class="item-row">
              <view class="form-field mini half" @click="openDatePicker(index, 'expiryDate')">
                <view class="field-label">有效期至</view>
                <view class="field-input-box picker-field mini">
                  <input class="field-input" :value="item.expiryDate" placeholder="选择日期" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
                  <u-icon name="arrow-right" size="12" color="#C9CDD4"></u-icon>
                </view>
              </view>
            </view>
          </view>
        </view>
      </view>
      <view v-else class="empty-items">
        <text class="empty-text">暂无入库明细，请点击添加</text>
      </view>

      <view class="summary-row">
        <text class="summary-label">入库总金额</text>
        <text class="summary-amount">¥{{ totalAmount }}</text>
      </view>
    </view>

    <u-picker :show="showTypePicker" :columns="typeColumns" keyName="label" title="选择入库类型" @confirm="onTypeConfirm" @cancel="showTypePicker = false" @close="showTypePicker = false"></u-picker>

    <u-popup :show="showSupplierPicker" mode="bottom" round="16" @close="showSupplierPicker = false">
      <view class="picker-content">
        <view class="picker-header">
          <text class="picker-title">选择供货商</text>
          <view class="picker-close" @click="showSupplierPicker = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <view class="picker-search">
          <u-icon name="search" size="14" color="#86909C"></u-icon>
          <input class="picker-search-input" type="text" v-model="supplierKeyword" placeholder="搜索供货商名称" placeholder-class="search-placeholder" @input="onSupplierSearch" />
        </view>
        <scroll-view scroll-y class="picker-list" :style="{ height: '400rpx' }">
          <view v-for="s in supplierOptions" :key="s.supplierId" class="picker-item" :class="{ active: form.supplierId === s.supplierId }" @click="selectSupplier(s)">
            <text class="picker-item-text">{{ s.supplierName }}</text>
          </view>
          <u-empty v-if="supplierOptions.length === 0" mode="search" text="未找到供货商" :marginTop="40"></u-empty>
        </scroll-view>
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
          <input class="picker-search-input" type="text" v-model="productKeyword" placeholder="搜索货品名称" placeholder-class="search-placeholder" @input="onProductSearch" />
        </view>
        <scroll-view scroll-y class="picker-list" :style="{ height: '400rpx' }">
          <view v-for="p in productOptions" :key="p.productId" class="picker-item" :class="{ active: currentEditIndex >= 0 && form.items[currentEditIndex]?.productId === p.productId }" @click="selectProduct(p)">
            <text class="picker-item-text">{{ p.productName }}</text>
            <text class="picker-item-spec">{{ p.spec || '' }}</text>
          </view>
          <u-empty v-if="productOptions.length === 0" mode="search" text="未找到货品" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <u-datetime-picker :show="showDatePicker" mode="date" @confirm="onDateConfirm" @cancel="showDatePicker = false" @close="showDatePicker = false"></u-datetime-picker>

    <view class="form-actions">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getStockIn, addStockIn, updateStockIn } from '@/api/wms/stockIn'
import { searchProduct } from '@/api/wms/product'
import { searchSupplier } from '@/api/wms/supplier'

const submitting = ref(false)
const mode = ref('add')
const stockInId = ref(null)

const showTypePicker = ref(false)
const showSupplierPicker = ref(false)
const showProductPicker = ref(false)
const showDatePicker = ref(false)

const supplierOptions = ref([])
const supplierKeyword = ref('')
const productOptions = ref([])
const productKeyword = ref('')
const currentEditIndex = ref(-1)
const currentDateField = ref('')

let supplierSearchTimer = null
let productSearchTimer = null

const form = reactive({
  stockInType: '',
  supplierId: undefined,
  supplierName: '',
  remark: '',
  items: []
})

const totalAmount = computed(() => {
  return (form.items || []).reduce((sum, item) => sum + (parseFloat(item.amount) || 0), 0).toFixed(2)
})

const typeColumns = computed(() => [[
  { label: '采购入库', value: '1' },
  { label: '退货入库', value: '2' },
  { label: '其他入库', value: '3' }
]])

function getStockInTypeLabel(stockInType) {
  const map = { '1': '采购入库', '2': '退货入库', '3': '其他入库' }
  return map[String(stockInType)] || ''
}

function formatAmount(val) {
  const num = parseFloat(val)
  if (isNaN(num)) return '0.00'
  return num.toFixed(2)
}

function onTypeConfirm(e) {
  const item = e.value[0]
  form.stockInType = item.value
  showTypePicker.value = false
}

function openSupplierPicker() {
  supplierKeyword.value = ''
  showSupplierPicker.value = true
  loadSuppliers('')
}

async function loadSuppliers(keyword) {
  try {
    const response = await searchSupplier(keyword)
    const data = response.data || response
    supplierOptions.value = Array.isArray(data) ? data : (data.rows || data.items || [])
  } catch (e) { console.error('搜索供货商失败:', e) }
}

function onSupplierSearch() {
  if (supplierSearchTimer) clearTimeout(supplierSearchTimer)
  supplierSearchTimer = setTimeout(() => loadSuppliers(supplierKeyword.value), 400)
}

function selectSupplier(s) {
  form.supplierId = s.supplierId
  form.supplierName = s.supplierName || ''
  showSupplierPicker.value = false
}

function openProductPicker(index) {
  currentEditIndex.value = index
  productKeyword.value = ''
  showProductPicker.value = true
  loadProducts('')
}

async function loadProducts(keyword) {
  try {
    const response = await searchProduct(keyword)
    const data = response.data || response
    productOptions.value = Array.isArray(data) ? data : (data.rows || data.items || [])
  } catch (e) { console.error('搜索货品失败:', e) }
}

function onProductSearch() {
  if (productSearchTimer) clearTimeout(productSearchTimer)
  productSearchTimer = setTimeout(() => loadProducts(productKeyword.value), 400)
}

function selectProduct(p) {
  const index = currentEditIndex.value
  if (index < 0 || index >= form.items.length) return
  const item = form.items[index]
  item.productId = p.productId
  item.productName = p.productName || ''
  item.spec = p.spec || ''
  item.unit = p.unit || ''
  item.packQty = p.packQty || 1
  item.price = p.purchasePrice || p.sellingPrice || 0
  item._mainPrice = p.purchasePrice || 0
  item.unitType = '1'
  item._prevUnitType = '1'
  item._prevQuantity = undefined
  item._prevPrice = undefined
  calcItemAmount(index)
  showProductPicker.value = false
}

function addItem() {
  form.items.push({
    productId: undefined,
    productName: '',
    spec: '',
    unit: '',
    packQty: 1,
    unitType: '1',
    quantity: 1,
    price: 0,
    amount: 0,
    _mainPrice: 0,
    _prevUnitType: '1',
    _prevQuantity: undefined,
    _prevPrice: undefined,
    productionDate: '',
    expiryDate: ''
  })
}

function removeItem(index) {
  uni.showModal({
    title: '提示',
    content: '确认删除该明细？',
    success: (res) => { if (res.confirm) form.items.splice(index, 1) }
  })
}

function changeUnitType(index, type) {
  const item = form.items[index]
  if (item.unitType === type) return
  item.unitType = type
  onUnitTypeChange(index)
}

function onUnitTypeChange(index) {
  const item = form.items[index]
  const packQty = item.packQty || 1
  const newType = item.unitType
  const oldType = item._prevUnitType

  if (!oldType || newType === oldType) {
    item._prevUnitType = newType
    return
  }

  const currentQty = Number(item.quantity) || 0
  const currentPrice = Number(item.price) || 0

  // If switching back to a type where we have backup, restore exact values
  if (item._prevQuantity !== undefined && item._prevPrice !== undefined) {
    // Save current values temporarily
    const tempQty = currentQty
    const tempPrice = currentPrice
    // Restore from backup
    item.quantity = item._prevQuantity
    item.price = item._prevPrice
    // Update backup with the values we're leaving
    item._prevQuantity = tempQty
    item._prevPrice = tempPrice
  } else {
    // No backup, need to convert
    if (newType === '1') {
      // Sub → Main: quantity / packQty, price * packQty
      item.quantity = packQty > 0 ? Math.round(currentQty / packQty * 10000) / 10000 : 0
      item.price = Math.round(currentPrice * packQty * 100) / 100
    } else {
      // Main → Sub: quantity * packQty, price / packQty
      item.quantity = Math.round(currentQty * packQty * 10000) / 10000
      item.price = packQty > 0 ? Math.round(currentPrice / packQty * 100) / 100 : 0
    }
    // Save backup
    item._prevQuantity = currentQty
    item._prevPrice = currentPrice
  }

  item._prevUnitType = newType
  calcItemAmount(index)
}

function calcItemAmount(index) {
  const item = form.items[index]
  const qty = parseFloat(item.quantity) || 0
  const price = parseFloat(item.price) || 0
  item.amount = Math.round(qty * price * 100) / 100
}

function openDatePicker(index, field) {
  currentEditIndex.value = index
  currentDateField.value = field
  showDatePicker.value = true
}

function onDateConfirm(e) {
  const date = new Date(e.value)
  const dateStr = date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0')
  const index = currentEditIndex.value
  if (index >= 0 && index < form.items.length) {
    form.items[index][currentDateField.value] = dateStr
  }
  showDatePicker.value = false
}

async function loadDetail() {
  if (!stockInId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getStockIn(stockInId.value)
    const data = response.data || response
    form.stockInType = String(data.stockInType || '')
    form.supplierId = data.supplierId
    form.supplierName = data.supplierName || ''
    form.remark = data.remark || ''
    form.items = (data.items || []).map(item => {
      const unitType = item.unitType || '1'
      const packQty = item.packQty || 1
      const purchasePrice = item.purchasePrice || item.price || 0
      // Calculate display price based on unitType
      let displayPrice = purchasePrice
      let displayQuantity = item.quantity || 0
      if (unitType === '1' && packQty > 1) {
        // Backend stores in sub unit, convert to main unit for display
        displayPrice = Math.round(purchasePrice * packQty * 100) / 100
        displayQuantity = Math.round(displayQuantity / packQty * 10000) / 10000
      }
      return {
        itemId: item.itemId,
        productId: item.productId,
        productName: item.productName || '',
        spec: item.spec || '',
        unit: item.unit || '',
        packQty: packQty,
        unitType: unitType,
        quantity: displayQuantity,
        price: displayPrice,
        amount: item.amount || 0,
        _mainPrice: unitType === '1' ? purchasePrice : (packQty > 0 ? Math.round(purchasePrice * packQty * 100) / 100 : purchasePrice),
        _prevUnitType: unitType,
        _prevQuantity: undefined,
        _prevPrice: undefined,
        productionDate: item.productionDate || '',
        expiryDate: item.expiryDate || ''
      }
    })
  } catch (e) {
    console.error('加载入库详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

async function submitForm() {
  if (!form.stockInType) { uni.showToast({ title: '请选择入库类型', icon: 'none' }); return }
  if (!form.items || form.items.length === 0) { uni.showToast({ title: '请至少添加一条入库明细', icon: 'none' }); return }
  const hasEmptyProduct = form.items.some(item => !item.productId)
  if (hasEmptyProduct) { uni.showToast({ title: '请为每条明细选择货品', icon: 'none' }); return }
  const hasZeroQty = form.items.some(item => !item.quantity || item.quantity <= 0)
  if (hasZeroQty) { uni.showToast({ title: '明细数量必须大于0', icon: 'none' }); return }

  submitting.value = true
  try {
    const submitData = {
      stockInType: form.stockInType,
      supplierId: form.supplierId || undefined,
      supplierName: form.supplierName || undefined,
      remark: form.remark.trim() || undefined,
      items: form.items.map(item => {
        const packQty = item.packQty || 1
        const unitType = item.unitType || '2'
        const originalQuantity = Number(item.quantity) || 0
        const inputPrice = Number(item.price) || 0
        // Backend stores in sub unit (minimum unit)
        let quantity, purchasePrice
        if (unitType === '1') {
          // Main unit: quantity needs * packQty, price needs / packQty
          quantity = Math.round(originalQuantity * packQty * 10000) / 10000
          purchasePrice = packQty > 0 ? Math.round(inputPrice / packQty * 100) / 100 : inputPrice
        } else {
          // Sub unit: use directly
          quantity = originalQuantity
          purchasePrice = inputPrice
        }
        return {
          itemId: item.itemId || undefined,
          productId: item.productId,
          productName: item.productName,
          spec: item.spec || '',
          unit: item.unit || '',
          packQty: packQty,
          unitType: unitType,
          originalQuantity: originalQuantity,
          quantity: quantity,
          purchasePrice: purchasePrice,
          _mainPrice: item._mainPrice || 0,
          amount: parseFloat(item.amount) || 0,
          productionDate: item.productionDate || undefined,
          expiryDate: item.expiryDate || undefined
        }
      })
    }

    if (mode.value === 'edit' && stockInId.value) {
      submitData.stockInId = stockInId.value
      await updateStockIn(submitData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      await addStockIn(submitData)
      uni.showToast({ title: '新增成功', icon: 'success' })
    }
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
  else uni.redirectTo({ url: '/pages/wms/stockIn/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  mode.value = options.mode || 'add'
  stockInId.value = options.id ? parseInt(options.id) : null

  if (mode.value === 'add') {
    uni.setNavigationBarTitle({ title: '新增入库单' })
  } else if (mode.value === 'edit') {
    uni.setNavigationBarTitle({ title: '编辑入库单' })
    loadDetail()
  }
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

.form-field { margin-bottom: 28rpx; &:last-child { margin-bottom: 0; }
  &.mini { margin-bottom: 16rpx; }
}
.field-label { font-size: 26rpx; color: #4E5969; font-weight: 500; margin-bottom: 12rpx;
  .required { color: #F53F3F; margin-right: 4rpx; }
}
.field-input-box { display: flex; align-items: center; background: #F7F8FA; border-radius: 12rpx; padding: 0 24rpx; height: 84rpx; gap: 12rpx; transition: background 0.2s;
  &:focus-within { background: #EFF0F1; }
  &.picker-field { cursor: pointer; }
  &.mini { height: 72rpx; padding: 0 20rpx; }
  &.readonly { opacity: 0.8; }
}
.field-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 84rpx; line-height: 84rpx; background: transparent;
  .mini & { height: 72rpx; line-height: 72rpx; font-size: 26rpx; }
  &.amount-value { color: #FF6B35; font-weight: 600; }
}
.field-placeholder { color: #C9CDD4; font-size: 28rpx; }

.field-textarea-box { background: #F7F8FA; border-radius: 12rpx; padding: 20rpx 24rpx; }
.field-textarea { width: 100%; min-height: 120rpx; font-size: 28rpx; color: #1D2129; line-height: 1.6; background: transparent; }

.form-row { display: flex; gap: 24rpx; }
.half { flex: 1; min-width: 0; }
.item-row { display: flex; gap: 16rpx; }

.items-list { display: flex; flex-direction: column; gap: 16rpx; }
.item-card { background: #F7F8FA; border-radius: 12rpx; padding: 20rpx; }
.item-header { display: flex; align-items: center; margin-bottom: 12rpx; }
.item-index { font-size: 26rpx; color: #86909C; font-weight: 500; margin-right: 8rpx; }
.item-name { font-size: 28rpx; color: #1D2129; font-weight: 500; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.item-delete { padding: 8rpx; margin-left: 8rpx; }

.item-body { display: flex; flex-direction: column; gap: 4rpx; padding-left: 32rpx; }

.unit-type-switch { display: flex; background: #F2F3F5; border-radius: 12rpx; overflow: hidden; height: 72rpx; }
.unit-type-btn { flex: 1; display: flex; align-items: center; justify-content: center; font-size: 24rpx; color: #86909C; font-weight: 500; transition: all 0.2s;
  &.active { background: #3D6DF7; color: #fff; border-radius: 12rpx; }
}
.conversion-text { font-size: 24rpx; color: #86909C; line-height: 72rpx; }

.empty-items { padding: 40rpx 0; text-align: center; }
.empty-text { font-size: 26rpx; color: #C9CDD4; }

.summary-row { display: flex; justify-content: space-between; align-items: center; padding: 20rpx 0 4rpx; border-top: 1rpx solid #E5E6EB; margin-top: 16rpx; }
.summary-label { font-size: 26rpx; color: #86909C; }
.summary-amount { font-size: 32rpx; color: #FF6B35; font-weight: 600; }

.picker-content { padding: 30rpx; background: #fff; }
.picker-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.picker-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.picker-close { padding: 8rpx; }
.picker-search { display: flex; align-items: center; background: #F7F8FA; border-radius: 36rpx; padding: 0 24rpx; height: 72rpx; gap: 12rpx; margin-bottom: 20rpx; }
.picker-search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; }
.search-placeholder { color: #C9CDD4; font-size: 28rpx; }
.picker-item { display: flex; justify-content: space-between; align-items: center; padding: 24rpx 16rpx; border-bottom: 1rpx solid #F2F3F5;
  &.active { background: #E8F0FE; }
  &:active { background: #F5F7FA; }
}
.picker-item-text { font-size: 28rpx; color: #1D2129; flex: 1; }
.picker-item-spec { font-size: 24rpx; color: #86909C; margin-left: 16rpx; }

.form-actions { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; display: flex; gap: 20rpx; z-index: 100;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
