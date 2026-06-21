<template>
  <view class="form-container">
    <view class="form-section">
      <view class="section-title"><view class="title-bar"></view>调拨信息</view>

      <view class="form-field" @click="openWarehousePicker('source')">
        <view class="field-label"><text class="required">*</text> 源仓库</view>
        <view class="field-input-box picker-field">
          <u-icon name="home" size="16" color="#3D6DF7" style="margin-right:12rpx"></u-icon>
          <input class="field-input" :value="form.fromWarehouseName" placeholder="请选择源仓库" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="openWarehousePicker('target')">
        <view class="field-label"><text class="required">*</text> 目标仓库</view>
        <view class="field-input-box picker-field">
          <u-icon name="map" size="16" color="#00B42A" style="margin-right:12rpx"></u-icon>
          <input class="field-input" :value="form.toWarehouseName" placeholder="请选择目标仓库" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="transferDatePickerModel = Date.now(); showTransferDatePicker = true">
        <view class="field-label"><text class="required">*</text> 调拨日期</view>
        <view class="field-input-box picker-field">
          <u-icon name="calendar" size="16" color="#86909C" style="margin-right:12rpx"></u-icon>
          <input class="field-input" :value="form.transferDate" placeholder="请选择调拨日期" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
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
        <view class="section-title"><view class="title-bar"></view>调拨明细</view>
        <view class="add-item-btn" @click="addItem">
          <u-icon name="plus" size="14" color="#3D6DF7"></u-icon>
          <text>添加明细</text>
        </view>
      </view>

      <view v-if="form.items.length > 0" class="items-list">
        <view v-for="(item, index) in form.items" :key="index" class="item-card">
          <view class="item-header" @click="openProductPicker(index)">
            <text class="item-index">{{ index + 1 }}.</text>
            <text class="item-name">{{ item.productName || '点击选择产品' }}</text>
            <u-icon v-if="item.productId" name="checkmark-circle-fill" size="18" color="#00B42A"></u-icon>
            <u-icon v-if="!item.productId" name="arrow-right" size="14" color="#C9CDD4" style="margin-right: 8rpx;"></u-icon>
            <view class="item-delete" @click.stop="removeItem(index)">
              <u-icon name="trash" size="14" color="#F53F3F"></u-icon>
            </view>
          </view>
          <view class="item-body">
            <view v-if="item.stockInfo" class="stock-info-badge">
              <text class="stock-label">库存：</text>
              <text class="stock-value">{{ item.stockInfo }}</text>
            </view>
            <view class="item-row">
              <view class="form-field mini half">
                <view class="field-label">单位类型</view>
                <view class="unit-type-box">
                  <view class="unit-type-tag" :class="{ active: item.unitType === '1' }" @click="item.unitType = '1'; onUnitTypeChange(index)">主单位(整)</view>
                  <view class="unit-type-tag" :class="{ active: item.unitType === '2' }" @click="item.unitType = '2'; onUnitTypeChange(index)">副单位(拆)</view>
                </view>
              </view>
              <view class="form-field mini half">
                <view class="field-label">换算</view>
                <view class="field-input-box mini readonly-box">
                  <text v-if="item.packQty && item.packQty > 1" class="convert-text">1{{ getUnitLabel(item.unit) }}={{ item.packQty }}{{ getSpecLabel(item.spec) }}</text>
                  <text v-else class="convert-text placeholder">-</text>
                </view>
              </view>
            </view>
            <view class="item-row">
              <view class="form-field mini half">
                <view class="field-label">数量</view>
                <view class="field-input-box mini">
                  <input class="field-input" type="number" v-model.number="item.quantity" placeholder="0" placeholder-class="field-placeholder" @blur="onQuantityChange(index)" />
                </view>
              </view>
              <view class="form-field mini half">
                <view class="field-label">规格</view>
                <view class="field-input-box mini readonly-box">
                  <text class="spec-text">{{ item.unitType === '1' ? (getUnitLabel(item.unit) || '-') : (getSpecLabel(item.spec) || '-') }}</text>
                </view>
              </view>
            </view>
          </view>
        </view>
      </view>
      <view v-else class="empty-items">
        <text class="empty-text">暂无调拨明细，请点击添加</text>
      </view>

      <view class="summary-row">
        <text class="summary-label">总数量</text>
        <text class="summary-amount">{{ totalQuantity }}</text>
      </view>
    </view>

    <u-popup :show="showWarehousePicker" mode="bottom" round="16" @close="showWarehousePicker = false">
      <view class="picker-content">
        <view class="picker-header">
          <text class="picker-title">{{ warehousePickerTitle }}</text>
          <view class="picker-close" @click="showWarehousePicker = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <scroll-view scroll-y class="picker-list" :style="{ height: '500rpx' }">
          <view v-for="w in warehouseOptions" :key="w.warehouseId" class="picker-item" :class="{ active: isWarehouseSelected(w.warehouseId), disabled: isWarehouseDisabled(w.warehouseId) }" @click="selectWarehouse(w)">
            <text class="picker-item-text">{{ w.warehouseName }}</text>
            <u-icon v-if="isWarehouseSelected(w.warehouseId)" name="checkmark" size="16" color="#3D6DF7"></u-icon>
          </view>
          <u-empty v-if="warehouseOptions.length === 0" mode="data" text="暂无仓库" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <u-popup :show="showProductPicker" mode="bottom" round="16" @close="showProductPicker = false">
      <view class="picker-content">
        <view class="picker-header">
          <text class="picker-title">选择产品</text>
          <view class="picker-close" @click="showProductPicker = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <view class="picker-search">
          <u-icon name="search" size="14" color="#86909C"></u-icon>
          <input class="picker-search-input" type="text" v-model="productKeyword" placeholder="搜索产品名称" placeholder-class="search-placeholder" @input="onProductSearch" />
        </view>
        <scroll-view scroll-y class="picker-list" :style="{ height: '400rpx' }">
          <view v-for="p in productOptions" :key="p.productId" class="picker-item" :class="{ active: currentEditIndex >= 0 && form.items[currentEditIndex]?.productId === p.productId }" @click="selectProduct(p)">
            <text class="picker-item-text">{{ p.productName }}</text>
            <text class="picker-item-spec">{{ p.spec || p.unit || '' }}</text>
          </view>
          <u-empty v-if="productOptions.length === 0" mode="search" text="未找到产品" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <u-datetime-picker :show="showTransferDatePicker" mode="date" v-model="transferDatePickerModel" @confirm="onTransferDateConfirm" @cancel="showTransferDatePicker = false" @close="showTransferDatePicker = false"></u-datetime-picker>

    <view class="form-actions">
      <u-button type="info" plain text="取消" icon="close" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" icon="checkmark" @click="submitForm"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { addStockTransfer } from '@/api/wms/stockTransfer'
import { listWarehouse } from '@/api/wms/warehouse'
import { listProduct } from '@/api/wms/product'
import { getInventory } from '@/api/wms/inventory'
import { getDicts } from '@/api/system/dictData'

const submitting = ref(false)

const showWarehousePicker = ref(false)
const showProductPicker = ref(false)
const showTransferDatePicker = ref(false)

const warehouseOptions = ref([])
const productOptions = ref([])
const productKeyword = ref('')
const currentEditIndex = ref(-1)
const currentWarehouseField = ref('')

const unitOptions = ref([])
const specOptions = ref([])

let productSearchTimer = null

const transferDatePickerModel = ref(Date.now())

const form = reactive({
  fromWarehouseId: undefined,
  fromWarehouseName: '',
  toWarehouseId: undefined,
  toWarehouseName: '',
  transferDate: '',
  remark: '',
  items: []
})

const totalQuantity = computed(() => {
  return (form.items || []).reduce((sum, item) => sum + (parseFloat(item.quantity) || 0), 0)
})

const warehousePickerTitle = computed(() => {
  return currentWarehouseField.value === 'source' ? '选择源仓库' : '选择目标仓库'
})

function isWarehouseSelected(warehouseId) {
  if (currentWarehouseField.value === 'source') return form.fromWarehouseId === warehouseId
  if (currentWarehouseField.value === 'target') return form.toWarehouseId === warehouseId
  return false
}

function isWarehouseDisabled(warehouseId) {
  if (currentWarehouseField.value === 'source') return form.toWarehouseId === warehouseId
  if (currentWarehouseField.value === 'target') return form.fromWarehouseId === warehouseId
  return false
}

function openWarehousePicker(field) {
  currentWarehouseField.value = field
  showWarehousePicker.value = true
}

function selectWarehouse(w) {
  if (isWarehouseDisabled(w.warehouseId)) {
    uni.showToast({ title: '源仓库与目标仓库不能相同', icon: 'none' })
    return
  }
  if (currentWarehouseField.value === 'source') {
    form.fromWarehouseId = w.warehouseId
    form.fromWarehouseName = w.warehouseName
  } else if (currentWarehouseField.value === 'target') {
    form.toWarehouseId = w.warehouseId
    form.toWarehouseName = w.warehouseName
  }
  showWarehousePicker.value = false
}

function getUnitLabel(value) {
  if (value === undefined || value === null || value === '') return ''
  const item = unitOptions.value.find(d => String(d.dictValue) === String(value))
  return item ? item.dictLabel : String(value)
}

function getSpecLabel(value) {
  if (value === undefined || value === null || value === '') return ''
  const item = specOptions.value.find(d => String(d.dictValue) === String(value))
  return item ? item.dictLabel : String(value)
}

async function loadDicts() {
  try {
    const [unitRes, specRes] = await Promise.all([
      getDicts('biz_product_unit'),
      getDicts('biz_product_spec')
    ])
    unitOptions.value = (unitRes.data || unitRes) || []
    specOptions.value = (specRes.data || specRes) || []
  } catch (e) { console.error('加载字典失败:', e) }
}

async function loadWarehouses() {
  try {
    const response = await listWarehouse({ pageNum: 1, pageSize: 1000 })
    const data = response.data || response
    warehouseOptions.value = data.rows || data.items || []
  } catch (e) { console.error('加载仓库列表失败:', e) }
}

function openProductPicker(index) {
  currentEditIndex.value = index
  productKeyword.value = ''
  showProductPicker.value = true
  loadProducts('')
}

async function loadProducts(keyword) {
  try {
    const params = { pageNum: 1, pageSize: 50 }
    if (keyword) params.productName = keyword
    const response = await listProduct(params)
    const data = response.data || response
    productOptions.value = data.rows || data.items || []
  } catch (e) { console.error('搜索产品失败:', e) }
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
  item.unitType = '1'
  item.quantity = 1
  showProductPicker.value = false
  // 加载源仓库库存信息
  if (form.fromWarehouseId) {
    loadStockInfo(index, p.productId)
  }
}

async function loadStockInfo(index, productId) {
  try {
    const res = await getInventory(productId, { warehouse_id: form.fromWarehouseId })
    const data = res.data || res
    if (data && data.quantity !== undefined) {
      const item = form.items[index]
      const totalQty = Number(data.quantity) || 0
      item.stockQuantity = totalQty
      refreshStockDisplay(index)
    } else {
      form.items[index].stockInfo = '库存为0'
      form.items[index].stockQuantity = 0
    }
  } catch (e) {
    form.items[index].stockInfo = ''
    form.items[index].stockQuantity = 0
  }
}

function refreshStockDisplay(index) {
  const item = form.items[index]
  const totalQty = item.stockQuantity || 0
  const unitLabel = getUnitLabel(item.unit)
  const specLabel = getSpecLabel(item.spec)
  if (item.unitType === '1' && item.packQty > 1) {
    const mainQty = Math.floor(totalQty / item.packQty)
    item.stockInfo = `主单位${mainQty}${unitLabel}（共${totalQty}${specLabel}）`
  } else {
    item.stockInfo = `${totalQty}${specLabel}`
  }
}

function onUnitTypeChange(index) {
  const item = form.items[index]
  item.quantity = 1
  if (item.productId && form.fromWarehouseId) {
    refreshStockDisplay(index)
  }
}

function onQuantityChange(index) {
  const item = form.items[index]
  if (!item.productId || item.stockQuantity < 0) return
  const needQty = item.unitType === '1' && item.packQty > 1
    ? item.quantity * item.packQty
    : item.quantity
  if (needQty > item.stockQuantity) {
    uni.showToast({ title: '数量超出源仓库库存', icon: 'none', duration: 1500 })
  }
}

function addItem() {
  form.items.push({
    productId: undefined,
    productName: '',
    spec: undefined,
    unit: undefined,
    packQty: 1,
    unitType: '1',
    quantity: 1,
    stockInfo: '',
    stockQuantity: -1,
    originalQuantity: undefined
  })
}

function removeItem(index) {
  uni.showModal({
    title: '提示',
    content: '确认删除该明细？',
    success: (res) => { if (res.confirm) form.items.splice(index, 1) }
  })
}

function onTransferDateConfirm(e) {
  const timestamp = Number(e.value) || e.value
  const date = new Date(timestamp)
  form.transferDate = date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0')
  showTransferDatePicker.value = false
}

async function submitForm() {
  if (!form.fromWarehouseId) { uni.showToast({ title: '请选择源仓库', icon: 'none' }); return }
  if (!form.toWarehouseId) { uni.showToast({ title: '请选择目标仓库', icon: 'none' }); return }
  if (form.fromWarehouseId === form.toWarehouseId) { uni.showToast({ title: '源仓库与目标仓库不能相同', icon: 'none' }); return }
  if (!form.transferDate) { uni.showToast({ title: '请选择调拨日期', icon: 'none' }); return }
  if (!form.items || form.items.length === 0) { uni.showToast({ title: '请至少添加一条调拨明细', icon: 'none' }); return }
  const hasEmptyProduct = form.items.some(item => !item.productId)
  if (hasEmptyProduct) { uni.showToast({ title: '请为每条明细选择产品', icon: 'none' }); return }
  const hasZeroQty = form.items.some(item => !item.quantity || item.quantity <= 0)
  if (hasZeroQty) { uni.showToast({ title: '明细数量必须大于0', icon: 'none' }); return }

  // 校验库存是否充足
  const overStockItems = form.items.filter(item => {
    if (!item.productId || item.stockQuantity < 0) return false
    const needQty = item.unitType === '1' && item.packQty > 1
      ? item.quantity * item.packQty
      : item.quantity
    return needQty > item.stockQuantity
  })
  if (overStockItems.length > 0) {
    uni.showToast({ title: '部分货品数量超出源仓库库存', icon: 'none', duration: 2000 })
    return
  }

  submitting.value = true
  try {
    const submitData = {
      fromWarehouseId: form.fromWarehouseId,
      fromWarehouseName: form.fromWarehouseName,
      toWarehouseId: form.toWarehouseId,
      toWarehouseName: form.toWarehouseName,
      transferDate: form.transferDate,
      remark: form.remark.trim() || undefined,
      items: form.items.map(item => ({
        productId: item.productId,
        productName: item.productName,
        spec: item.spec,
        unit: item.unit,
        packQty: item.packQty,
        unitType: item.unitType,
        quantity: Number(item.quantity) || 0
      }))
    }
    await addStockTransfer(submitData)
    uni.showToast({ title: '新增成功', icon: 'success' })
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
  else uni.redirectTo({ url: '/pages/wms/stockTransfer/index' })
}

onLoad(() => {
  uni.setNavigationBarTitle({ title: '新增调拨单' })
  loadWarehouses()
  loadDicts()
  const now = new Date()
  form.transferDate = now.getFullYear() + '-' + String(now.getMonth() + 1).padStart(2, '0') + '-' + String(now.getDate()).padStart(2, '0')
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.form-container { min-height: 100vh; padding-bottom: 140rpx; }

.form-section { margin: 16rpx; background: #fff; border-radius: 16rpx; padding: 24rpx; box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04); }
.section-title { font-size: 30rpx; font-weight: 600; color: #1D2129; margin-bottom: 20rpx; display: flex; align-items: center; }
.title-bar { display: inline-block; width: 6rpx; height: 28rpx; background: #3D6DF7; border-radius: 3rpx; margin-right: 12rpx; vertical-align: middle; }
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }

.add-item-btn { display: flex; align-items: center; gap: 6rpx; padding: 8rpx 20rpx; background: #E8F0FE; border-radius: 24rpx;
  text { font-size: 24rpx; color: #3D6DF7; font-weight: 500; }
}

.form-field { margin-bottom: 24rpx; &:last-child { margin-bottom: 0; }
  &.mini { margin-bottom: 12rpx; }
}
.field-label { font-size: 26rpx; color: #4E5969; font-weight: 500; margin-bottom: 10rpx;
  .required { color: #F53F3F; margin-right: 4rpx; }
}
.field-input-box { display: flex; align-items: center; background: #F7F8FA; border-radius: 12rpx; padding: 0 24rpx; height: 88rpx; gap: 12rpx; border: 2rpx solid transparent; transition: all 0.2s;
  &:focus-within { border-color: #3D6DF7; background: #fff; box-shadow: 0 0 0 4rpx rgba(61,109,247,0.08); }
  &.picker-field { cursor: pointer; }
  &.mini { height: 72rpx; padding: 0 18rpx; }
  &.readonly { opacity: 0.85; }
}
.field-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 88rpx; line-height: 88rpx; background: transparent;
  .mini & { height: 72rpx; line-height: 72rpx; font-size: 28rpx; text-align: center; font-weight: 600; color: #1D2129; }
}
.field-placeholder { color: #A8ABB2; font-size: 28rpx; }

.field-textarea-box { background: #F7F8FA; border-radius: 12rpx; padding: 18rpx 22rpx; }
.field-textarea { width: 100%; min-height: 100rpx; font-size: 28rpx; color: #1D2129; line-height: 1.6; background: transparent; }

.item-row { display: flex; gap: 12rpx; }
.half { flex: 1; min-width: 0; }

.items-list { display: flex; flex-direction: column; gap: 14rpx; }
.item-card { background: #FAFBFC; border-radius: 12rpx; padding: 18rpx 22rpx; border: 1rpx solid #F0F1F3; }
.item-header { display: flex; align-items: center; margin-bottom: 14rpx; }
.item-index { font-size: 26rpx; color: #86909C; font-weight: 500; margin-right: 8rpx; }
.item-name { font-size: 29rpx; color: #1D2129; font-weight: 600; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.item-delete { padding: 8rpx; margin-left: 8rpx; }

.item-body { display: flex; flex-direction: column; gap: 10rpx; }

.stock-info-badge { display: inline-flex; align-items: center; margin-bottom: 8rpx; padding: 6rpx 14rpx; background: #FFFBF0; border-radius: 20rpx; align-self: flex-start; }
.stock-label { font-size: 22rpx; color: #ff9900; }
.stock-value { font-size: 22rpx; color: #ff9900; font-weight: 500; }

.unit-type-box { display: flex; background: #F2F3F5; border-radius: 10rpx; height: 56rpx; overflow: hidden; }
.unit-type-tag { flex: 1; display: flex; align-items: center; justify-content: center; font-size: 23rpx; color: #86909C; transition: all 0.25s; font-weight: 500;
  &.active { background: #fff; color: #3D6DF7; box-shadow: 0 1rpx 4rpx rgba(0,0,0,0.06); }
}
.readonly-box { opacity: 0.85; }
.convert-text { font-size: 24rpx; color: #86909C; line-height: 72rpx;
  &.placeholder { color: #C9CDD4; }
}
.spec-text { display: inline-flex; align-items: center; justify-content: center; height: 72rpx; padding: 0 18rpx; background: #F2F3F5; border-radius: 10rpx; font-size: 25rpx; color: #4E5969; }

.empty-items { padding: 40rpx 0; text-align: center; }
.empty-text { font-size: 26rpx; color: #C9CDD4; }

.summary-row { display: flex; justify-content: space-between; align-items: center; padding: 18rpx 0 6rpx; border-top: 1rpx solid #E5E6EB; margin-top: 12rpx; }
.summary-label { font-size: 26rpx; color: #86909C; }
.summary-amount { font-size: 32rpx; color: #FF6B35; font-weight: 600; }

.picker-content { padding: 30rpx; background: #fff; }
.picker-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.picker-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.picker-close { padding: 8rpx; }
.picker-search { display: flex; align-items: center; background: #F7F8FA; border-radius: 36rpx; padding: 0 24rpx; height: 72rpx; gap: 12rpx; margin-bottom: 20rpx; }
.picker-search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; }
.search-placeholder { color: #C9CDD4; font-size: 28rpx; }
.picker-list { }
.picker-item { display: flex; justify-content: space-between; align-items: center; padding: 24rpx 16rpx; border-bottom: 1rpx solid #F2F3F5;
  &.active { background: #E8F0FE; }
  &.disabled { opacity: 0.4; }
  &:active { background: #F5F7FA; }
}
.picker-item-text { font-size: 28rpx; color: #1D2129; flex: 1; }
.picker-item-spec { font-size: 24rpx; color: #86909C; margin-left: 16rpx; }

.form-actions { position: fixed; left: 24rpx; right: 24rpx; bottom: 32rpx; display: flex; gap: 20rpx; z-index: 100; padding: 0 24rpx;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
