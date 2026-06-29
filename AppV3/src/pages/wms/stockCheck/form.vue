<template>
  <view class="form-container">
    <view class="form-section">
      <view class="form-field" @click="showWarehousePicker = true">
        <view class="field-label"><text class="required">*</text> 仓库</view>
        <view class="field-input-box picker-field">
          <input class="field-input" :value="currentWarehouseName" placeholder="请选择仓库" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="openCheckDatePicker">
        <view class="field-label"><text class="required">*</text> 盘点日期</view>
        <view class="field-input-box picker-field">
          <input class="field-input" :value="form.checkDate" placeholder="请选择盘点日期" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
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

    <view class="form-section detail-section">
      <view class="section-header">
        <view class="card-title">
          <u-icon name="checkmark-circle" size="16" color="#3D6DF7"></u-icon>
          <text>盘点明细</text>
        </view>
        <text class="item-count">{{ filteredItems.length }}项</text>
      </view>
      <view class="detail-search">
        <u-icon name="search" size="14" color="#86909C"></u-icon>
        <input class="detail-search-input" type="text" v-model="detailKeyword" placeholder="搜索品名/编码" placeholder-class="search-placeholder" />
        <view v-if="detailKeyword" class="clear-btn" @click="detailKeyword = ''">
          <u-icon name="close-circle-fill" size="12" color="#C9CDD4"></u-icon>
        </view>
      </view>
      <view v-if="filteredItems.length > 0" class="detail-list">
        <view v-for="(item, idx) in filteredItems" :key="idx" class="detail-item">
          <view class="detail-item-header">
            <text class="detail-item-name">{{ item.productName || '-' }}</text>
            <text class="detail-item-code">{{ item.productCode || '-' }}</text>
          </view>
          <view class="detail-item-body">
            <view class="detail-row">
              <view class="detail-field">
                <text class="detail-label">系统库存</text>
                <text class="detail-value">{{ displaySystemQty(item) }}</text>
              </view>
              <view class="detail-field">
                <text class="detail-label">实际数量</text>
                <view class="detail-input-box">
                  <input class="detail-input" type="digit" v-model="item.actualQuantity" placeholder="0" placeholder-class="field-placeholder" @input="onActualChange(item)" />
                </view>
              </view>
              <view class="detail-field">
                <text class="detail-label">差异</text>
                <text v-if="item.diffQuantity > 0" class="detail-value diff-positive">+{{ displayDiffQty(item) }}</text>
                <text v-else-if="item.diffQuantity < 0" class="detail-value diff-negative">{{ displayDiffQty(item) }}</text>
                <text v-else class="detail-value diff-zero">0</text>
              </view>
            </view>
            <view class="detail-unit-row">
              <view class="unit-type-btns">
                <view class="unit-btn" :class="{ active: item.unitType === '1' }" @click="onUnitTypeChange(item, '1')">主单位(整)</view>
                <view class="unit-btn" :class="{ active: item.unitType === '2' }" @click="onUnitTypeChange(item, '2')">副单位(拆)</view>
              </view>
              <text v-if="item.packQty > 1" class="unit-convert-tip">1主单位={{ item.packQty }}副单位</text>
            </view>
            <view class="item-row">
              <view class="form-field mini half" @click="openDatePicker(idx, 'productionDate')">
                <view class="field-label">生产日期</view>
                <view class="field-input-box picker-field mini">
                  <input class="field-input" :value="item.productionDate" placeholder="选择日期" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
                  <u-icon name="arrow-right" size="12" color="#C9CDD4"></u-icon>
                </view>
              </view>
              <view class="form-field mini half" @click="openDatePicker(idx, 'expiryDate')">
                <view class="field-label">到期日期</view>
                <view class="field-input-box picker-field mini">
                  <input class="field-input" :value="item.expiryDate" placeholder="选择日期" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
                  <u-icon name="arrow-right" size="12" color="#C9CDD4"></u-icon>
                </view>
              </view>
            </view>
          </view>
        </view>
      </view>
      <u-empty v-else mode="data" text="暂无明细数据" :marginTop="40"></u-empty>
    </view>

    <u-datetime-picker :show="showDatePicker" mode="date" @confirm="onDateConfirm" @cancel="showDatePicker = false" @close="showDatePicker = false"></u-datetime-picker>

    <u-picker :show="showWarehousePicker" :columns="warehouseColumns" keyName="warehouseName" @confirm="onWarehouseConfirm" @cancel="showWarehousePicker = false" @close="showWarehousePicker = false"></u-picker>

    <view class="form-actions">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getStockCheck, addStockCheck, updateStockCheck, loadInventoryData } from '@/api/wms/stockCheck'
import { useWarehouse } from '@/composables/useWarehouse'

const { currentWarehouseId, warehouseList, loadWarehouses } = useWarehouse()

const submitting = ref(false)
const mode = ref('add')
const stockCheckId = ref(null)
const showDatePicker = ref(false)
const showWarehousePicker = ref(false)
const detailKeyword = ref('')
const currentEditIndex = ref(-1)
const currentDateField = ref('')
const datePickerModel = ref(Date.now())

const warehouseColumns = computed(() => [warehouseList.value])
const currentWarehouseName = computed(() => {
  const w = warehouseList.value.find(w => w.warehouseId === form.warehouseId)
  return w ? w.warehouseName : ''
})

const form = reactive({
  stockCheckId: undefined,
  checkDate: '',
  remark: '',
  warehouseId: undefined,
  items: []
})

const filteredItems = computed(() => {
  if (!detailKeyword.value) return form.items
  const kw = detailKeyword.value.toLowerCase()
  return form.items.filter(item =>
    (item.productName && item.productName.toLowerCase().includes(kw)) ||
    (item.productCode && item.productCode.toLowerCase().includes(kw))
  )
})

function getToday() {
  const d = new Date()
  return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0')
}

function openCheckDatePicker() {
  currentEditIndex.value = -1
  datePickerModel.value = Date.now()
  showDatePicker.value = true
}

function openDatePicker(index, field) {
  currentEditIndex.value = index
  currentDateField.value = field
  datePickerModel.value = Date.now()
  showDatePicker.value = true
}

function onDateConfirm(e) {
  const timestamp = Number(e.value) || e.value
  const date = new Date(timestamp)
  const dateStr = date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0')
  const index = currentEditIndex.value
  if (index >= 0 && index < form.items.length) {
    form.items[index][currentDateField.value] = dateStr
  } else {
    form.checkDate = dateStr
  }
  showDatePicker.value = false
}

function onWarehouseConfirm(e) {
  const warehouse = e.value[0]
  if (warehouse && warehouse.warehouseId !== form.warehouseId) {
    form.warehouseId = warehouse.warehouseId
    currentWarehouseId.value = warehouse.warehouseId
    showWarehousePicker.value = false
    // 切换仓库后重新加载库存数据
    loadInventory()
  } else {
    showWarehousePicker.value = false
  }
}

function onActualChange(item) {
  const systemQty = Number(item.systemQuantity) || 0
  const actualQty = Number(item.actualQuantity) || 0
  // diffQuantity 始终以副单位存储
  const actualQtySub = item.unitType === '1' ? actualQty * (Number(item.packQty) || 1) : actualQty
  item.diffQuantity = actualQtySub - systemQty
}

/** 显示系统库存（根据单位类型换算） */
function displaySystemQty(item) {
  const systemQty = Number(item.systemQuantity) || 0
  const packQty = Number(item.packQty) || 1
  if (item.unitType === '1' && packQty > 1) {
    const val = systemQty / packQty
    return Number.isInteger(val) ? val : val.toFixed(2)
  }
  return systemQty
}

/** 显示差异数量（根据单位类型换算） */
function displayDiffQty(item) {
  const diffQty = Number(item.diffQuantity) || 0
  const packQty = Number(item.packQty) || 1
  if (item.unitType === '1' && packQty > 1) {
    const val = diffQty / packQty
    return Number.isInteger(val) ? val : val.toFixed(2)
  }
  return diffQty
}

/** 切换单位类型，换算实际数量显示 */
function onUnitTypeChange(item, type) {
  const packQty = Number(item.packQty) || 1
  const oldType = item.unitType
  const currentActualQty = Number(item.actualQuantity) || 0

  item.unitType = type

  if (oldType === type) return

  // 换算实际数量显示值
  if (oldType === '2' && type === '1') {
    // 副单位 → 主单位：除以packQty
    const val = currentActualQty / packQty
    item.actualQuantity = Number.isInteger(val) ? val : parseFloat(val.toFixed(2))
  } else if (oldType === '1' && type === '2') {
    // 主单位 → 副单位：乘以packQty
    item.actualQuantity = currentActualQty * packQty
  }

  // 重新计算差异
  onActualChange(item)
}

async function loadInventory() {
  try {
    uni.showLoading({ title: '加载库存数据...' })
    const res = await loadInventoryData({ warehouse_id: currentWarehouseId.value })
    const data = res.data || res
    const list = data.rows || data.items || data || []
    form.items = list.map(item => ({
      productId: item.productId,
      productName: item.productName || '',
      productCode: item.productCode || '',
      systemQuantity: item.quantity || item.systemQuantity || 0,
      actualQuantity: item.quantity || item.systemQuantity || 0,
      diffQuantity: 0,
      packQty: item.packQty || 1,
      unitType: '2',
      unitLabel: item.unitLabel || '',
      specLabel: item.specLabel || '',
      productionDate: '',
      expiryDate: ''
    }))
  } catch (e) {
    console.error('加载库存数据失败:', e)
    uni.showToast({ title: '加载库存数据失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

async function loadDetail() {
  if (!stockCheckId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getStockCheck(stockCheckId.value)
    const data = response.data || response
    Object.assign(form, {
      stockCheckId: data.stockCheckId,
      checkDate: data.checkDate || '',
      remark: data.remark || '',
      warehouseId: data.warehouseId || undefined,
      items: (data.items || []).map(item => {
        const packQty = item.packQty || 1
        const unitType = item.unitType || '2'
        const systemQuantity = item.systemQuantity || 0
        const actualQuantitySub = item.actualQuantity || 0
        // 根据单位类型换算显示数量
        let displayActualQty = actualQuantitySub
        if (unitType === '1' && packQty > 1) {
          displayActualQty = actualQuantitySub / packQty
        }
        return {
          productId: item.productId,
          productName: item.productName || '',
          productCode: item.productCode || '',
          systemQuantity,
          actualQuantity: Number.isInteger(displayActualQty) ? displayActualQty : parseFloat(displayActualQty.toFixed(2)),
          diffQuantity: (Number(actualQuantitySub) || 0) - (Number(systemQuantity) || 0),
          packQty,
          unitType,
          unitLabel: item.unitLabel || '',
          specLabel: item.specLabel || ''
        }
      })
    })
  } catch (e) {
    console.error('加载盘点详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

async function submitForm() {
  if (!form.warehouseId) { uni.showToast({ title: '请选择仓库', icon: 'none' }); return }
  if (!form.checkDate) { uni.showToast({ title: '请选择盘点日期', icon: 'none' }); return }

  submitting.value = true
  try {
    const formData = {
      checkDate: form.checkDate,
      warehouseId: form.warehouseId,
      remark: form.remark.trim() || null,
      items: form.items.map(item => {
        const packQty = Number(item.packQty) || 1
        const inputQty = Number(item.actualQuantity) || 0
        // 主单位时：提交数量 = 用户输入 * packQty（转为副单位存储）
        // 副单位时：提交数量 = 用户输入（直接使用）
        const actualQuantity = item.unitType === '1' ? inputQty * packQty : inputQty
        return {
          productId: item.productId,
          systemQuantity: item.systemQuantity,
          actualQuantity,
          unitType: item.unitType,
          originalQuantity: inputQty,
          productionDate: item.productionDate || undefined,
          expiryDate: item.expiryDate || undefined
        }
      })
    }

    if (form.stockCheckId) {
      formData.stockCheckId = form.stockCheckId
      await updateStockCheck(formData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      await addStockCheck(formData)
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
  else uni.redirectTo({ url: '/pages/wms/stockCheck/index' })
}

onMounted(async () => {
  await loadWarehouses()

  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  mode.value = options.mode || 'add'
  stockCheckId.value = options.id ? parseInt(options.id) : null

  if (mode.value === 'add') {
    uni.setNavigationBarTitle({ title: '新增盘点单' })
    form.checkDate = getToday()
    form.warehouseId = currentWarehouseId.value
    loadInventory()
  } else if (mode.value === 'edit') {
    uni.setNavigationBarTitle({ title: '编辑盘点单' })
    loadDetail()
  }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.form-container { min-height: 100vh; padding-bottom: 140rpx; }

.form-section { margin: 24rpx; background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; margin-bottom: 20rpx; }
.detail-section { padding-bottom: 20rpx; }

.form-field { margin-bottom: 28rpx; &:last-child { margin-bottom: 0; } }
.field-label { font-size: 26rpx; color: #4E5969; font-weight: 500; margin-bottom: 12rpx;
  .required { color: #F53F3F; margin-right: 4rpx; }
}
.field-input-box { display: flex; align-items: center; background: #F7F8FA; border-radius: 12rpx; padding: 0 24rpx; height: 84rpx; gap: 12rpx; transition: background 0.2s;
  &:focus-within { background: #EFF0F1; }
  &.picker-field { cursor: pointer; }
}
.field-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 84rpx; line-height: 84rpx; background: transparent; }
.field-placeholder { color: #C9CDD4; font-size: 28rpx; }

.field-textarea-box { background: #F7F8FA; border-radius: 12rpx; padding: 20rpx 24rpx; }
.field-textarea { width: 100%; min-height: 120rpx; font-size: 28rpx; color: #1D2129; line-height: 1.6; background: transparent; }

.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.card-title { display: flex; align-items: center; gap: 8rpx; font-size: 28rpx; font-weight: 600; color: #1D2129; }
.item-count { font-size: 22rpx; color: #86909C; background: #F5F7FA; padding: 4rpx 16rpx; border-radius: 4rpx; }

.detail-search { display: flex; align-items: center; background: #F7F8FA; border-radius: 36rpx; padding: 0 20rpx; height: 64rpx; gap: 10rpx; margin-bottom: 20rpx; }
.detail-search-input { flex: 1; font-size: 26rpx; color: #1D2129; height: 64rpx; min-width: 0; }
.search-placeholder { color: #C9CDD4; font-size: 26rpx; }
.clear-btn { flex-shrink: 0; padding: 4rpx; display: flex; align-items: center; }

.detail-list { display: flex; flex-direction: column; gap: 0; }
.detail-item { padding: 20rpx 0; border-bottom: 1rpx solid #F2F3F5;
  &:last-child { border-bottom: none; }
}
.detail-item-header { display: flex; align-items: center; gap: 12rpx; margin-bottom: 12rpx; }
.detail-item-name { font-size: 27rpx; color: #1D2129; font-weight: 500; flex: 1; }
.detail-item-code { font-size: 24rpx; color: #86909C; flex-shrink: 0; }

.detail-item-body { padding-left: 0; }
.detail-row { display: flex; align-items: center; gap: 16rpx; }
.detail-field { display: flex; flex-direction: column; align-items: center; gap: 4rpx; flex: 1;
  &:first-child { flex: 0 0 140rpx; }
  &:last-child { flex: 0 0 120rpx; }
}
.detail-label { font-size: 22rpx; color: #86909C; }
.detail-value { font-size: 26rpx; color: #1D2129; font-weight: 500;
  &.diff-positive { color: #00B42A; }
  &.diff-negative { color: #F53F3F; }
  &.diff-zero { color: #C9CDD4; }
}

.detail-input-box { background: #F7F8FA; border-radius: 8rpx; padding: 0 12rpx; width: 100%; box-sizing: border-box; }
.detail-input { width: 100%; font-size: 26rpx; color: #1D2129; height: 64rpx; line-height: 64rpx; text-align: center; background: transparent; }

.detail-unit-row { display: flex; align-items: center; justify-content: space-between; margin-top: 12rpx; }
.unit-type-btns { display: flex; gap: 0; border-radius: 8rpx; overflow: hidden; border: 1rpx solid #E5E6EB; }
.unit-btn { font-size: 22rpx; color: #4E5969; padding: 6rpx 16rpx; background: #fff; transition: all 0.2s;
  &.active { color: #3D6DF7; background: #EFF4FF; font-weight: 500; }
}
.unit-convert-tip { font-size: 20rpx; color: #86909C; }

.form-actions { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; display: flex; gap: 20rpx; z-index: 100;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
