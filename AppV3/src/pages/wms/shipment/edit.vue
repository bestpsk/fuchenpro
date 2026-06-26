<template>
  <view class="form-container">
    <view class="form-section">
      <view class="section-title">
        <u-icon name="list" size="16" color="#3D6DF7"></u-icon>
        <text>出库信息</text>
      </view>

      <view class="form-field" @click="showTypePicker = true">
        <view class="field-label"><text class="required">*</text> 出库类型</view>
        <view class="field-input-box picker-field">
          <input class="field-input" :value="getStockOutTypeLabel(form.stockOutType)" placeholder="请选择出库类型" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="showWarehousePicker = true">
        <view class="field-label"><text class="required">*</text> 仓库</view>
        <view class="field-input-box picker-field">
          <input class="field-input" :value="form.warehouseName" placeholder="请选择仓库" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="showTargetTypePicker = true">
        <view class="field-label"><text class="required">*</text> 对象类型</view>
        <view class="field-input-box picker-field">
          <input class="field-input" :value="getOutTargetTypeLabel(form.outTargetType)" placeholder="请选择对象类型" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" v-if="form.outTargetType === '1'" @click="openEnterprisePicker">
        <view class="field-label"><text class="required">*</text> 企业</view>
        <view class="field-input-box picker-field">
          <input class="field-input" :value="form.enterpriseName" placeholder="请选择企业" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" v-if="form.outTargetType === '2'" @click="openEmployeePicker">
        <view class="field-label"><text class="required">*</text> 员工</view>
        <view class="field-input-box picker-field">
          <input class="field-input" :value="form.responsibleName" placeholder="请选择员工" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" v-if="form.outTargetType === '1'" @click="openContactEmployeePicker">
        <view class="field-label">对接员工</view>
        <view class="field-input-box picker-field">
          <input class="field-input" :value="form.contactEmployeeName" placeholder="请选择对接员工" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="showShipTypePicker = true">
        <view class="field-label"><text class="required">*</text> 发货方式</view>
        <view class="field-input-box picker-field">
          <input class="field-input" :value="getShipTypeLabel(form.shipType)" placeholder="请选择发货方式" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="stockOutDatePickerModel = Date.now(); showStockOutDatePicker = true">
        <view class="field-label"><text class="required">*</text> 出库日期</view>
        <view class="field-input-box picker-field">
          <input class="field-input" :value="form.stockOutDate" placeholder="请选择出库日期" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
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
        <view class="section-title">
          <u-icon name="arrow-up" size="16" color="#3D6DF7"></u-icon>
          <text>出库明细</text>
        </view>
        <view class="add-item-btn" @click="addItem">
          <u-icon name="plus" size="14" color="#3D6DF7"></u-icon>
          <text>添加明细</text>
        </view>
      </view>

      <view v-if="form.items.length > 0" class="items-list">
        <view v-for="(item, index) in form.items" :key="index" class="item-card">
          <view class="item-header" @click="openProductPicker(index)">
            <text class="item-index">{{ index + 1 }}.</text>
            <text class="item-name">{{ item.productName || '点击选择货品' }}</text>
            <u-icon v-if="!item.productId" name="arrow-right" size="14" color="#C9CDD4" style="margin-right: 8rpx;"></u-icon>
            <view class="item-delete" @click.stop="removeItem(index)">
              <u-icon name="trash" size="14" color="#F53F3F"></u-icon>
            </view>
          </view>
          <view class="item-body">
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
                <view class="field-label">销售单价</view>
                <view class="field-input-box mini">
                  <input class="field-input" type="digit" v-model="item.salePrice" placeholder="0.00" placeholder-class="field-placeholder" @input="calcItemAmount(index)" />
                </view>
              </view>
            </view>
          </view>
        </view>
      </view>
      <view v-else class="empty-items">
        <text class="empty-text">暂无出库明细，请点击添加</text>
      </view>

      <view class="summary-row">
        <text class="summary-label">出库总金额</text>
        <text class="summary-amount">¥{{ totalAmount }}</text>
      </view>
    </view>

    <u-picker :show="showTypePicker" :columns="typeColumns" keyName="label" title="选择出库类型" @confirm="onTypeConfirm" @cancel="showTypePicker = false" @close="showTypePicker = false"></u-picker>

    <u-picker :show="showWarehousePicker" :columns="warehouseColumns" keyName="label" title="选择仓库" @confirm="onWarehouseConfirm" @cancel="showWarehousePicker = false" @close="showWarehousePicker = false"></u-picker>

    <u-picker :show="showTargetTypePicker" :columns="targetTypeColumns" keyName="label" title="选择对象类型" @confirm="onTargetTypeConfirm" @cancel="showTargetTypePicker = false" @close="showTargetTypePicker = false"></u-picker>

    <u-picker :show="showShipTypePicker" :columns="shipTypeColumns" keyName="label" title="选择发货方式" @confirm="onShipTypeConfirm" @cancel="showShipTypePicker = false" @close="showShipTypePicker = false"></u-picker>

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

    <u-popup :show="showEnterprisePopup" mode="bottom" round="16" @close="showEnterprisePopup = false">
      <view class="picker-content">
        <view class="picker-header">
          <text class="picker-title">选择企业</text>
          <view class="picker-close" @click="showEnterprisePopup = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <view class="picker-search">
          <u-icon name="search" size="14" color="#86909C"></u-icon>
          <input class="picker-search-input" type="text" v-model="enterpriseKeyword" placeholder="搜索企业名称" placeholder-class="search-placeholder" @input="onEnterpriseSearch" />
        </view>
        <scroll-view scroll-y class="picker-list" :style="{ height: '400rpx' }">
          <view v-for="e in enterpriseOptions" :key="e.enterpriseId" class="picker-item" :class="{ active: form.enterpriseId === e.enterpriseId }" @click="selectEnterprise(e)">
            <text class="picker-item-text">{{ e.enterpriseName }}</text>
          </view>
          <u-empty v-if="enterpriseOptions.length === 0" mode="search" text="未找到企业" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <u-popup :show="showEmployeePopup" mode="bottom" round="16" @close="showEmployeePopup = false">
      <view class="picker-content">
        <view class="picker-header">
          <text class="picker-title">选择员工</text>
          <view class="picker-close" @click="showEmployeePopup = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <view class="picker-search">
          <u-icon name="search" size="14" color="#86909C"></u-icon>
          <input class="picker-search-input" type="text" v-model="employeeKeyword" placeholder="搜索员工姓名" placeholder-class="search-placeholder" @input="onEmployeeSearch" />
        </view>
        <scroll-view scroll-y class="picker-list" :style="{ height: '400rpx' }">
          <view v-for="u in employeeOptions" :key="u.userId" class="picker-item" :class="{ active: employeePickerTarget === 'responsible' && form.responsibleId === u.userId || employeePickerTarget === 'contact' && form.contactEmployeeId === u.userId }" @click="selectEmployee(u)">
            <text class="picker-item-text">{{ u.nickName || u.userName }}</text>
          </view>
          <u-empty v-if="employeeOptions.length === 0" mode="search" text="未找到员工" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <u-datetime-picker :show="showStockOutDatePicker" mode="date" v-model="stockOutDatePickerModel" @confirm="onStockOutDateConfirm" @cancel="showStockOutDatePicker = false" @close="showStockOutDatePicker = false"></u-datetime-picker>

    <view class="form-actions">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getStockOut, updateStockOut } from '@/api/wms/stockOut'
import { searchProduct } from '@/api/wms/product'
import { searchEnterprise } from '@/api/business/enterprise'
import { listUser } from '@/api/system/user'
import { useWarehouse } from '@/composables/useWarehouse'

const { currentWarehouseId, warehouseList, loadWarehouses } = useWarehouse()

const submitting = ref(false)
const stockOutId = ref(null)

const showTypePicker = ref(false)
const showWarehousePicker = ref(false)
const showTargetTypePicker = ref(false)
const showShipTypePicker = ref(false)
const showProductPicker = ref(false)
const showEnterprisePopup = ref(false)
const showEmployeePopup = ref(false)
const showStockOutDatePicker = ref(false)

const productOptions = ref([])
const productKeyword = ref('')
const currentEditIndex = ref(-1)

const enterpriseOptions = ref([])
const enterpriseKeyword = ref('')

const employeeOptions = ref([])
const employeeKeyword = ref('')
const employeePickerTarget = ref('responsible') // 'responsible' or 'contact'

let productSearchTimer = null
let enterpriseSearchTimer = null
let employeeSearchTimer = null

const stockOutDatePickerModel = ref(Date.now())

const form = reactive({
  stockOutType: '',
  warehouseId: undefined,
  warehouseName: '',
  outTargetType: '',
  enterpriseId: undefined,
  enterpriseName: '',
  responsibleId: undefined,
  responsibleName: '',
  contactEmployeeId: undefined,
  contactEmployeeName: '',
  shipType: '',
  stockOutDate: '',
  remark: '',
  items: []
})

const totalAmount = computed(() => {
  return (form.items || []).reduce((sum, item) => sum + (parseFloat(item.amount) || 0), 0).toFixed(2)
})

const typeColumns = computed(() => [[
  { label: '销售出库', value: '1' },
  { label: '领用出库', value: '2' },
  { label: '其他', value: '3' }
]])

const warehouseColumns = computed(() => [
  warehouseList.value.map(w => ({ label: w.warehouseName, value: w.warehouseId }))
])

const targetTypeColumns = computed(() => [[
  { label: '企业出库', value: '1' },
  { label: '员工领用', value: '2' }
]])

const shipTypeColumns = computed(() => [[
  { label: '无需发货', value: '0' },
  { label: '自提', value: '1' },
  { label: '物流', value: '2' }
]])

function getStockOutTypeLabel(val) {
  const map = { '1': '销售出库', '2': '领用出库', '3': '其他' }
  return map[String(val)] || ''
}

function getOutTargetTypeLabel(val) {
  const map = { '1': '企业出库', '2': '员工领用' }
  return map[String(val)] || ''
}

function getShipTypeLabel(val) {
  const map = { '0': '无需发货', '1': '自提', '2': '物流' }
  return map[String(val)] || ''
}

function onTypeConfirm(e) {
  form.stockOutType = e.value[0].value
  showTypePicker.value = false
}

function onWarehouseConfirm(e) {
  const item = e.value[0]
  form.warehouseId = item.value
  form.warehouseName = item.label
  showWarehousePicker.value = false
}

function onTargetTypeConfirm(e) {
  const newType = e.value[0].value
  if (form.outTargetType !== newType) {
    form.outTargetType = newType
    // Clear target fields when switching type
    form.enterpriseId = undefined
    form.enterpriseName = ''
    form.responsibleId = undefined
    form.responsibleName = ''
    form.contactEmployeeId = undefined
    form.contactEmployeeName = ''
  }
  showTargetTypePicker.value = false
}

function onShipTypeConfirm(e) {
  form.shipType = e.value[0].value
  showShipTypePicker.value = false
}

function onStockOutDateConfirm(e) {
  const timestamp = Number(e.value) || e.value
  const date = new Date(timestamp)
  form.stockOutDate = date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0')
  showStockOutDatePicker.value = false
}

// --- Product picker ---
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
  item.supplierId = p.supplierId || p.supplier_id || null
  item.supplierName = p.supplierName || p.supplier_name || null
  item.packQty = p.packQty || 1
  item.salePrice = p.sellingPrice || 0
  item._mainPrice = p.sellingPrice || 0
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
    supplierId: null,
    supplierName: null,
    packQty: 1,
    unitType: '1',
    quantity: 1,
    salePrice: 0,
    amount: 0,
    _mainPrice: 0,
    _prevUnitType: '1',
    _prevQuantity: undefined,
    _prevPrice: undefined
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
  const currentPrice = Number(item.salePrice) || 0

  if (item._prevQuantity !== undefined && item._prevPrice !== undefined) {
    const tempQty = currentQty
    const tempPrice = currentPrice
    item.quantity = item._prevQuantity
    item.salePrice = item._prevPrice
    item._prevQuantity = tempQty
    item._prevPrice = tempPrice
  } else {
    if (newType === '1') {
      item.quantity = packQty > 0 ? Math.round(currentQty / packQty * 10000) / 10000 : 0
      item.salePrice = Math.round(currentPrice * packQty * 100) / 100
    } else {
      item.quantity = Math.round(currentQty * packQty * 10000) / 10000
      item.salePrice = packQty > 0 ? Math.round(currentPrice / packQty * 100) / 100 : 0
    }
    item._prevQuantity = currentQty
    item._prevPrice = currentPrice
  }

  item._prevUnitType = newType
  calcItemAmount(index)
}

function calcItemAmount(index) {
  const item = form.items[index]
  const qty = parseFloat(item.quantity) || 0
  const price = parseFloat(item.salePrice) || 0
  item.amount = Math.round(qty * price * 100) / 100
}

// --- Enterprise picker ---
function openEnterprisePicker() {
  enterpriseKeyword.value = ''
  showEnterprisePopup.value = true
  loadEnterprises('')
}

async function loadEnterprises(keyword) {
  try {
    const response = await searchEnterprise(keyword)
    const data = response.data || response
    enterpriseOptions.value = Array.isArray(data) ? data : (data.rows || data.items || [])
  } catch (e) { console.error('搜索企业失败:', e) }
}

function onEnterpriseSearch() {
  if (enterpriseSearchTimer) clearTimeout(enterpriseSearchTimer)
  enterpriseSearchTimer = setTimeout(() => loadEnterprises(enterpriseKeyword.value), 400)
}

function selectEnterprise(e) {
  form.enterpriseId = e.enterpriseId
  form.enterpriseName = e.enterpriseName || ''
  showEnterprisePopup.value = false
}

// --- Employee picker ---
function openEmployeePicker() {
  employeePickerTarget.value = 'responsible'
  employeeKeyword.value = ''
  showEmployeePopup.value = true
  loadEmployees('')
}

function openContactEmployeePicker() {
  employeePickerTarget.value = 'contact'
  employeeKeyword.value = ''
  showEmployeePopup.value = true
  loadEmployees('')
}

async function loadEmployees(keyword) {
  try {
    const params = { pageNum: 1, pageSize: 50 }
    if (keyword) params.userName = keyword
    const response = await listUser(params)
    const data = response.data || response
    employeeOptions.value = data.rows || data.items || (Array.isArray(data) ? data : [])
  } catch (e) { console.error('搜索员工失败:', e) }
}

function onEmployeeSearch() {
  if (employeeSearchTimer) clearTimeout(employeeSearchTimer)
  employeeSearchTimer = setTimeout(() => loadEmployees(employeeKeyword.value), 400)
}

function selectEmployee(u) {
  const name = u.nickName || u.userName || ''
  if (employeePickerTarget.value === 'responsible') {
    form.responsibleId = u.userId
    form.responsibleName = name
  } else {
    form.contactEmployeeId = u.userId
    form.contactEmployeeName = name
  }
  showEmployeePopup.value = false
}

// --- Load detail ---
async function loadDetail() {
  if (!stockOutId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getStockOut(stockOutId.value)
    const data = response.data || response
    form.stockOutType = String(data.stockOutType || '')
    form.warehouseId = data.warehouseId
    form.warehouseName = data.warehouseName || ''
    form.outTargetType = String(data.outTargetType || '')
    form.enterpriseId = data.enterpriseId || undefined
    form.enterpriseName = data.enterpriseName || ''
    form.responsibleId = data.responsibleId || undefined
    form.responsibleName = data.responsibleName || ''
    form.contactEmployeeId = data.contactEmployeeId || undefined
    form.contactEmployeeName = data.contactEmployeeName || ''
    form.shipType = String(data.shipType ?? '')
    form.stockOutDate = data.stockOutDate ? String(data.stockOutDate).substring(0, 10) : ''
    form.remark = data.remark || ''
    form.items = (data.items || []).map(item => {
      const unitType = item.unitType || '1'
      const packQty = item.packQty || 1
      const salePrice = item.salePrice || 0
      let displayPrice = salePrice
      let displayQuantity = item.quantity || 0
      if (unitType === '1' && packQty > 1) {
        displayPrice = Math.round(salePrice * packQty * 100) / 100
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
        salePrice: displayPrice,
        amount: item.amount || 0,
        _mainPrice: unitType === '1' ? salePrice : (packQty > 0 ? Math.round(salePrice * packQty * 100) / 100 : salePrice),
        _prevUnitType: unitType,
        _prevQuantity: undefined,
        _prevPrice: undefined
      }
    })
  } catch (e) {
    console.error('加载出库详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

// --- Submit ---
async function submitForm() {
  if (!form.stockOutType) { uni.showToast({ title: '请选择出库类型', icon: 'none' }); return }
  if (!form.warehouseId) { uni.showToast({ title: '请选择仓库', icon: 'none' }); return }
  if (!form.outTargetType) { uni.showToast({ title: '请选择对象类型', icon: 'none' }); return }
  if (form.outTargetType === '1' && !form.enterpriseId) { uni.showToast({ title: '请选择企业', icon: 'none' }); return }
  if (form.outTargetType === '2' && !form.responsibleId) { uni.showToast({ title: '请选择员工', icon: 'none' }); return }
  if (!form.shipType && form.shipType !== '0') { uni.showToast({ title: '请选择发货方式', icon: 'none' }); return }
  if (!form.stockOutDate) { uni.showToast({ title: '请选择出库日期', icon: 'none' }); return }
  if (!form.items || form.items.length === 0) { uni.showToast({ title: '请至少添加一条出库明细', icon: 'none' }); return }
  const hasEmptyProduct = form.items.some(item => !item.productId)
  if (hasEmptyProduct) { uni.showToast({ title: '请为每条明细选择货品', icon: 'none' }); return }
  const hasZeroQty = form.items.some(item => !item.quantity || item.quantity <= 0)
  if (hasZeroQty) { uni.showToast({ title: '明细数量必须大于0', icon: 'none' }); return }

  submitting.value = true
  try {
    const submitData = {
      stockOutId: stockOutId.value,
      stockOutType: form.stockOutType,
      warehouseId: form.warehouseId,
      outTargetType: form.outTargetType,
      enterpriseId: form.outTargetType === '1' ? form.enterpriseId : undefined,
      responsibleId: form.outTargetType === '2' ? form.responsibleId : undefined,
      contactEmployeeId: form.outTargetType === '1' ? form.contactEmployeeId : undefined,
      shipType: form.shipType,
      stockOutDate: form.stockOutDate,
      remark: form.remark.trim() || undefined,
      items: form.items.map(item => {
        const packQty = item.packQty || 1
        const unitType = item.unitType || '2'
        const originalQuantity = Number(item.quantity) || 0
        const inputPrice = Number(item.salePrice) || 0
        return {
          itemId: item.itemId || undefined,
          productId: item.productId,
          productName: item.productName,
          spec: item.spec || '',
          unit: item.unit || '',
          supplierId: item.supplierId || null,
          supplierName: item.supplierName || null,
          packQty: packQty,
          unitType: unitType,
          originalQuantity: originalQuantity,
          quantity: originalQuantity,
          salePrice: inputPrice,
          _mainPrice: item._mainPrice || 0,
          amount: parseFloat(item.amount) || 0
        }
      })
    }

    await updateStockOut(submitData)
    uni.showToast({ title: '修改成功', icon: 'success' })
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
  else uni.redirectTo({ url: '/pages/wms/shipment/index' })
}

onMounted(async () => {
  await loadWarehouses()
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  stockOutId.value = options.id ? parseInt(options.id) : null

  uni.setNavigationBarTitle({ title: '编辑出库单' })
  loadDetail()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.form-container { min-height: 100vh; padding-bottom: 140rpx; }

.form-section { margin: 24rpx; background: #fff; border-radius: 20rpx; padding: 32rpx; box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05); }
.section-title { display: flex; align-items: center; gap: 8rpx; font-size: 30rpx; font-weight: 600; color: #1D2129; margin-bottom: 24rpx; }
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
