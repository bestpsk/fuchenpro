<template>
  <view class="form-container">
    <view class="form-section">
      <view class="section-title">基本信息</view>

      <view class="form-field" @click="mode !== 'view' && (showEnterprisePicker = true)">
        <view class="field-input-box" :class="{ 'field-readonly': mode === 'view' }">
          <u-icon name="home-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.enterpriseName" placeholder="* 选择企业" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon v-if="mode !== 'view' && !form.enterpriseId" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="file-text" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.planName" placeholder="* 方案名称" placeholder-class="field-placeholder" :disabled="mode === 'view'" :disabledColor="'#fff'" />
        </view>
      </view>

      <view class="form-row">
        <view class="form-field half-width">
          <view class="field-input-box">
            <u-icon name="share" size="16" color="#86909C"></u-icon>
            <input class="field-input" type="digit" v-model="form.commissionRate" placeholder="分成比例(%)" placeholder-class="field-placeholder" :disabled="mode === 'view'" :disabledColor="'#fff'" />
          </view>
        </view>
        <view class="form-field half-width">
          <view class="field-input-box">
            <u-icon name="rmb-circle" size="16" color="#86909C"></u-icon>
            <input class="field-input" type="digit" v-model="form.planAmount" placeholder="* 方案金额" placeholder-class="field-placeholder" :disabled="mode === 'view'" :disabledColor="'#fff'" />
          </view>
        </view>
      </view>

      <view class="form-row">
        <view class="form-field half-width">
          <view class="field-input-box">
            <u-icon name="gift" size="16" color="#86909C"></u-icon>
            <input class="field-input" type="digit" v-model="form.giftAmount" placeholder="* 配赠金额" placeholder-class="field-placeholder" :disabled="mode === 'view'" :disabledColor="'#fff'" @input="onGiftAmountChange" />
          </view>
        </view>
        <view class="form-field half-width">
          <view class="field-input-box">
            <u-icon name="bag" size="16" color="#86909C"></u-icon>
            <input class="field-input" :value="'剩余: ' + formatAmount(form.remainingAmount)" placeholder="剩余金额" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          </view>
        </view>
      </view>

      <view class="form-row">
        <view class="form-field half-width" @click="mode !== 'view' && (showEffectivePicker = true)">
          <view class="field-input-box">
            <u-icon name="calendar" size="16" color="#86909C"></u-icon>
            <input class="field-input" :value="form.effectiveDate" placeholder="生效日期" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
            <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>
        <view class="form-field half-width" @click="mode !== 'view' && (showExpiryPicker = true)">
          <view class="field-input-box">
            <u-icon name="calendar" size="16" color="#86909C"></u-icon>
            <input class="field-input" :value="form.expiryDate" placeholder="失效日期" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
            <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>
      </view>

      <view class="form-field">
        <view class="field-textarea-box">
          <view class="textarea-prefix"><u-icon name="edit-pen" size="18" color="#86909C"></u-icon><text class="prefix-text">备注</text></view>
          <textarea class="field-textarea" v-model="form.remark" placeholder="请输入备注信息" placeholder-class="field-placeholder" :maxlength="500" auto-height :disabled="mode === 'view'"></textarea>
        </view>
      </view>
    </view>

    <view class="form-section">
      <view class="section-header">
        <view class="section-title">配赠明细</view>
        <view v-if="mode !== 'view'" class="add-item-btn" @click="addItem">
          <u-icon name="plus" size="14" color="#3D6DF7"></u-icon>
          <text>添加</text>
        </view>
      </view>

      <view v-if="form.items.length > 0" class="items-list">
        <view v-for="(item, index) in form.items" :key="index" class="item-card">
          <view class="item-header">
            <text class="item-name">{{ item.productName || '未选择货品' }}</text>
            <view v-if="mode !== 'view'" class="item-actions">
              <view class="action-btn" @click="editItem(index)"><u-icon name="edit-pen" size="14" color="#3D6DF7"></u-icon></view>
              <view class="action-btn" @click="removeItem(index)"><u-icon name="trash" size="14" color="#F53F3F"></u-icon></view>
            </view>
          </view>
          <view class="item-body">
            <view class="item-info-row">
              <text class="item-label">供货商</text>
              <text class="item-value">{{ item.supplierName || '-' }}</text>
            </view>
            <view class="item-info-row">
              <text class="item-label">单位</text>
              <text class="item-value">{{ item.unitType === '1' ? '主单位整' : '副单位拆' }}</text>
              <text class="item-label" style="margin-left: 20rpx;">数量</text>
              <text class="item-value">{{ item.quantity || 0 }}</text>
            </view>
            <view class="item-info-row">
              <text class="item-label">单价</text>
              <text class="item-value price">¥{{ formatAmount(item.salePrice) }}</text>
              <text class="item-label" style="margin-left: 20rpx;">金额</text>
              <text class="item-value price">¥{{ formatAmount(item.amount) }}</text>
            </view>
          </view>
        </view>
      </view>
      <view v-else class="empty-items">
        <text class="empty-text">暂无配赠明细</text>
      </view>
    </view>

    <u-popup :show="showEnterprisePicker" mode="bottom" round="16" @close="showEnterprisePicker = false">
      <view class="picker-content">
        <view class="picker-header">
          <text class="picker-title">选择企业</text>
          <view class="picker-close" @click="showEnterprisePicker = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <view class="picker-search">
          <u-icon name="search" size="14" color="#86909C"></u-icon>
          <input class="picker-search-input" type="text" v-model="enterpriseKeyword" placeholder="搜索企业名称" placeholder-class="search-placeholder" @input="onEnterpriseSearch" />
        </view>
        <scroll-view scroll-y class="picker-list" :style="{ height: '400rpx' }">
          <view v-for="item in filteredEnterprises" :key="item.enterpriseId" class="picker-item" :class="{ active: form.enterpriseId === item.enterpriseId }" @click="selectEnterprise(item)">
            <text class="picker-item-text">{{ item.enterpriseName }}</text>
            <view class="picker-item-status" :class="item.status === '0' ? 'active' : ''">{{ item.status === '0' ? '合作中' : '已停止' }}</view>
          </view>
          <u-empty v-if="filteredEnterprises.length === 0" mode="search" text="未找到企业" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <u-popup :show="showItemForm" mode="bottom" round="16" @close="showItemForm = false">
      <view class="picker-content">
        <view class="picker-header">
          <text class="picker-title">{{ editingItemIndex >= 0 ? '编辑明细' : '添加明细' }}</text>
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
              <input class="field-input" :value="itemForm.unitType === '1' ? '主单位整' : '副单位拆'" placeholder="单位类型" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
              <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
            </view>
          </view>
          <view class="form-row">
            <view class="form-field half-width">
              <view class="field-input-box">
                <u-icon name="minus-circle" size="16" color="#86909C"></u-icon>
                <input class="field-input" type="number" v-model.number="itemForm.quantity" placeholder="数量" placeholder-class="field-placeholder" @input="calcItemAmount" />
              </view>
            </view>
            <view class="form-field half-width">
              <view class="field-input-box">
                <u-icon name="rmb-circle" size="16" color="#86909C"></u-icon>
                <input class="field-input" type="digit" v-model="itemForm.salePrice" placeholder="单价" placeholder-class="field-placeholder" @input="calcItemAmount" />
              </view>
            </view>
          </view>
          <view class="item-amount-row">
            <text class="item-amount-label">总金额</text>
            <text class="item-amount-value">¥{{ formatAmount(itemForm.amount) }}</text>
          </view>
        </view>
        <view class="picker-actions">
          <u-button type="info" plain text="取消" @click="showItemForm = false"></u-button>
          <u-button type="primary" text="确定" @click="confirmItem"></u-button>
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

    <u-picker :show="showUnitTypePicker" :columns="[[{ label: '主单位整', value: '1' }, { label: '副单位拆', value: '2' }]]" keyName="label" title="选择单位类型" @confirm="onUnitTypeConfirm" @cancel="showUnitTypePicker = false" @close="showUnitTypePicker = false"></u-picker>

    <u-datetime-picker :show="showEffectivePicker" mode="date" @confirm="onEffectiveDateConfirm" @cancel="showEffectivePicker = false" @close="showEffectivePicker = false"></u-datetime-picker>
    <u-datetime-picker :show="showExpiryPicker" mode="date" @confirm="onExpiryDateConfirm" @cancel="showExpiryPicker = false" @close="showExpiryPicker = false"></u-datetime-picker>

    <view class="form-actions" v-if="mode !== 'view'">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>

    <view class="form-actions" v-else>
      <u-button v-if="checkPermi('business:plan:edit')" type="primary" plain text="编辑" @click="goEdit"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { listPlan, listEnterprise, getPlan, addPlan, updatePlan } from '@/api/business/plan'
import { listProduct } from '@/api/wms/product'
import { checkPermi } from '@/utils/permission'

const submitting = ref(false)
const mode = ref('add')
const planId = ref(null)

const showEnterprisePicker = ref(false)
const showItemForm = ref(false)
const showProductPicker = ref(false)
const showUnitTypePicker = ref(false)
const showEffectivePicker = ref(false)
const showExpiryPicker = ref(false)

const enterpriseList = ref([])
const enterpriseKeyword = ref('')
const productOptions = ref([])
const searchProductKeyword = ref('')
const editingItemIndex = ref(-1)

let productSearchTimer = null

const form = reactive({
  planId: undefined,
  enterpriseId: undefined,
  enterpriseName: '',
  planName: '',
  commissionRate: '',
  planAmount: '',
  giftAmount: '',
  remainingAmount: 0,
  effectiveDate: '',
  expiryDate: '',
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
  amount: 0,
  _mainPrice: null,
  unitLabel: '',
  specLabel: ''
})

const filteredEnterprises = computed(() => {
  if (!enterpriseKeyword.value) return enterpriseList.value
  const kw = enterpriseKeyword.value.toLowerCase()
  return enterpriseList.value.filter(e => (e.enterpriseName || '').toLowerCase().includes(kw))
})

function formatAmount(val) {
  const num = parseFloat(val)
  if (isNaN(num)) return '0.00'
  return num.toFixed(2)
}

function onGiftAmountChange() {
  if (!form.planId) {
    form.remainingAmount = parseFloat(form.giftAmount) || 0
  }
}

async function loadEnterprises() {
  try {
    const response = await listEnterprise({ pageNum: 1, pageSize: 100 })
    const data = response.data || response
    enterpriseList.value = data.rows || []
  } catch (e) { console.error('加载企业列表失败:', e) }
}

function selectEnterprise(item) {
  form.enterpriseId = item.enterpriseId
  form.enterpriseName = item.enterpriseName
  if (!form.planName) {
    form.planName = item.enterpriseName + ' 方案'
  }
  showEnterprisePicker.value = false
}

function onEnterpriseSearch() {}

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
  const unitMap = { '1': '箱', '2': '件', '3': '套', '4': '罐', '5': '盒', '6': '袋', '7': '包' }
  const specMap = { '1': '支', '2': '瓶', '3': '件', '4': '套', '5': '片', '6': '个' }
  itemForm.unitLabel = unitMap[p.unit] || ''
  itemForm.specLabel = specMap[p.spec] || ''
  itemForm.spec = itemForm.unitLabel || ''
  calcItemAmount()
  showProductPicker.value = false
}

function onUnitTypeConfirm(e) {
  const item = e.value[0]
  itemForm.unitType = item.value
  if (itemForm.unitType === '1') {
    if (itemForm._mainPrice) itemForm.salePrice = itemForm._mainPrice
    itemForm.spec = itemForm.unitLabel || ''
  } else {
    if (itemForm._mainPrice && itemForm.packQty > 0) {
      itemForm.salePrice = Math.round((itemForm._mainPrice / itemForm.packQty) * 100) / 100
    }
    itemForm.spec = itemForm.specLabel || ''
  }
  calcItemAmount()
  showUnitTypePicker.value = false
}

function calcItemAmount() {
  itemForm.amount = (parseFloat(itemForm.salePrice) || 0) * (parseInt(itemForm.quantity) || 0)
}

function addItem() {
  editingItemIndex.value = -1
  Object.assign(itemForm, {
    productId: undefined, productName: '', supplierId: undefined, supplierName: '',
    unitType: '1', packQty: 1, quantity: 1, spec: '', salePrice: 0, amount: 0,
    _mainPrice: null, unitLabel: '', specLabel: ''
  })
  showItemForm.value = true
  loadProducts('')
}

function editItem(index) {
  editingItemIndex.value = index
  const item = form.items[index]
  Object.assign(itemForm, { ...item })
  showItemForm.value = true
  loadProducts('')
}

function removeItem(index) {
  uni.showModal({
    title: '提示',
    content: '确认删除该明细?',
    success: (res) => { if (res.confirm) form.items.splice(index, 1) }
  })
}

function confirmItem() {
  if (!itemForm.productId) { uni.showToast({ title: '请选择货品', icon: 'none' }); return }
  if (!itemForm.quantity || itemForm.quantity < 1) { uni.showToast({ title: '请输入数量', icon: 'none' }); return }
  const itemData = { ...itemForm }
  delete itemData._mainPrice
  if (editingItemIndex.value >= 0) {
    form.items[editingItemIndex.value] = itemData
  } else {
    form.items.push(itemData)
  }
  showItemForm.value = false
}

function onEffectiveDateConfirm(e) {
  const date = new Date(e.value)
  form.effectiveDate = date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0')
  showEffectivePicker.value = false
}

function onExpiryDateConfirm(e) {
  const date = new Date(e.value)
  form.expiryDate = date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0')
  showExpiryPicker.value = false
}

async function loadDetail() {
  if (!planId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getPlan(planId.value)
    const data = response.data || response
    Object.assign(form, {
      planId: data.planId,
      enterpriseId: data.enterpriseId,
      enterpriseName: data.enterpriseName || (data.enterprise && data.enterprise.enterpriseName) || '',
      planName: data.planName || '',
      commissionRate: data.commissionRate != null ? String(data.commissionRate) : '',
      planAmount: data.planAmount != null ? String(data.planAmount) : '',
      giftAmount: data.giftAmount != null ? String(data.giftAmount) : '',
      remainingAmount: data.remainingAmount || 0,
      effectiveDate: data.effectiveDate || '',
      expiryDate: data.expiryDate || '',
      remark: data.remark || '',
      items: (data.items || []).map(item => ({ ...item }))
    })
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

async function submitForm() {
  if (!form.enterpriseId) { uni.showToast({ title: '请选择企业', icon: 'none' }); return }
  if (!form.planName) { uni.showToast({ title: '请输入方案名称', icon: 'none' }); return }
  if (!form.planAmount || parseFloat(form.planAmount) <= 0) { uni.showToast({ title: '请输入方案金额', icon: 'none' }); return }
  if (!form.giftAmount || parseFloat(form.giftAmount) <= 0) { uni.showToast({ title: '请输入配赠金额', icon: 'none' }); return }

  submitting.value = true
  try {
    const formData = {
      planId: form.planId || undefined,
      enterpriseId: form.enterpriseId,
      planName: form.planName,
      commissionRate: form.commissionRate ? parseFloat(form.commissionRate) : 0,
      planAmount: parseFloat(form.planAmount) || 0,
      giftAmount: parseFloat(form.giftAmount) || 0,
      effectiveDate: form.effectiveDate || null,
      expiryDate: form.expiryDate || null,
      remark: form.remark || null,
      items: form.items.map(item => ({
        itemId: item.itemId || undefined,
        productId: item.productId,
        productName: item.productName,
        supplierId: item.supplierId,
        unitType: item.unitType,
        packQty: item.packQty || 1,
        quantity: parseInt(item.quantity) || 0,
        spec: item.spec || '',
        salePrice: parseFloat(item.salePrice) || 0,
        amount: parseFloat(item.amount) || 0
      }))
    }

    if (formData.planId) {
      await updatePlan(formData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      delete formData.planId
      await addPlan(formData)
      uni.showToast({ title: '新增成功', icon: 'success' })
    }
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('提交失败:', e)
    const msg = e?.msg || e?.message || '操作失败，请重试'
    uni.showToast({ title: msg, icon: 'none', duration: 2000 })
  } finally { submitting.value = false }
}

function goEdit() { mode.value = 'edit'; uni.setNavigationBarTitle({ title: '编辑方案' }) }

function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.redirectTo({ url: '/pages/business/plan/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  mode.value = options.mode || 'add'
  planId.value = options.id ? parseInt(options.id) : null

  if (mode.value === 'add') {
    uni.setNavigationBarTitle({ title: '新增方案' })
    loadEnterprises()
  } else if (mode.value === 'edit') {
    uni.setNavigationBarTitle({ title: '编辑方案' })
    loadDetail()
  } else {
    uni.setNavigationBarTitle({ title: '方案详情' })
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

.form-field { margin-bottom: 20rpx; &:last-child { margin-bottom: 0; } }
.field-input-box { display: flex; align-items: center; background: #F7F8FA; border-radius: 12rpx; padding: 0 20rpx; height: 88rpx; gap: 16rpx; border: 2rpx solid transparent; transition: all 0.2s;
  &:active { background: #EFF0F1; }
  &.field-readonly { opacity: 0.8; }
}
.field-input { flex: 1; font-size: 30rpx; color: #1D2129; height: 88rpx; line-height: 88rpx; }
.field-placeholder { color: #C9CDD4; font-size: 30rpx; }
.field-textarea-box { display: flex; flex-direction: column; background: #F7F8FA; border-radius: 12rpx; padding: 16rpx 20rpx; gap: 8rpx; border: 2rpx solid transparent; }
.textarea-prefix { display: flex; align-items: center; gap: 10rpx; }
.prefix-text { font-size: 26rpx; color: #86909C; font-weight: 500; }
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
.item-body { display: flex; flex-direction: column; gap: 8rpx; }
.item-info-row { display: flex; align-items: center; gap: 8rpx; }
.item-label { font-size: 24rpx; color: #86909C; }
.item-value { font-size: 24rpx; color: #4E5969;
  &.price { color: #FF6B35; font-weight: 500; }
}
.empty-items { padding: 40rpx 0; text-align: center; }
.empty-text { font-size: 26rpx; color: #C9CDD4; }

.picker-content { padding: 30rpx; background: #fff; }
.picker-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.picker-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.picker-close { padding: 8rpx; }
.picker-search { display: flex; align-items: center; background: #F7F8FA; border-radius: 36rpx; padding: 0 24rpx; height: 72rpx; gap: 12rpx; margin-bottom: 20rpx; }
.picker-search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; }
.picker-list { }
.picker-item { display: flex; justify-content: space-between; align-items: center; padding: 24rpx 16rpx; border-bottom: 1rpx solid #F2F3F5;
  &.active { background: #E8F0FE; }
  &:active { background: #F5F7FA; }
}
.picker-item-text { font-size: 28rpx; color: #1D2129; flex: 1; }
.picker-item-status { font-size: 22rpx; padding: 4rpx 12rpx; border-radius: 4rpx; background: #F2F3F5; color: #86909C;
  &.active { background: #E8FFEA; color: #00B42A; }
}
.picker-item-price { font-size: 26rpx; color: #FF6B35; font-weight: 500; }

.item-form-content { padding: 0 0 20rpx; }
.item-amount-row { display: flex; justify-content: space-between; align-items: center; padding: 20rpx 0; border-top: 1rpx solid #F2F3F5; margin-top: 8rpx; }
.item-amount-label { font-size: 28rpx; color: #86909C; }
.item-amount-value { font-size: 32rpx; color: #FF6B35; font-weight: 600; }

.picker-actions { display: flex; gap: 20rpx; padding-top: 20rpx; border-top: 1rpx solid #E5E6EB; .u-button { flex: 1; } }

.form-actions { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; display: flex; gap: 20rpx; z-index: 100;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
