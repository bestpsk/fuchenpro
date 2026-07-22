<template>
  <view class="form-container">
    <view class="form-section">
      <view class="section-title">基本信息</view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="file-text" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.cardItemName" placeholder="* 卡项名称" placeholder-class="field-placeholder" :disabled="mode === 'view'" :disabledColor="'#fff'" @input="onNameInput" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="grid" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.cardItemCode" placeholder="* 卡项编码" placeholder-class="field-placeholder" :disabled="mode === 'view'" :disabledColor="'#fff'" />
        </view>
      </view>

      <view class="form-field" @click="mode !== 'view' && (showCategoryPicker = true)">
        <view class="field-input-box">
          <u-icon name="list" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="categoryLabel" placeholder="* 类别" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-row">
        <view class="form-field half-width">
          <view class="field-input-box">
            <u-icon name="minus-circle" size="16" color="#86909C"></u-icon>
            <input class="field-input" type="number" v-model.number="form.defaultQuantity" placeholder="* 默认次数" placeholder-class="field-placeholder" :disabled="mode === 'view'" :disabledColor="'#fff'" @input="calcPrices" />
          </view>
        </view>
        <view class="form-field half-width">
          <view class="field-input-box">
            <u-icon name="rmb-circle" size="16" color="#86909C"></u-icon>
            <input class="field-input" type="digit" :value="formatAmount(form.suggestedPrice)" placeholder="建议成交价" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          </view>
        </view>
      </view>

      <view class="form-row">
        <view class="form-field half-width">
          <view class="field-input-box">
            <u-icon name="rmb-circle" size="16" color="#86909C"></u-icon>
            <input class="field-input" type="digit" :value="formatAmount(form.defaultUnitPrice)" placeholder="默认单次价" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          </view>
        </view>
      </view>

      <view class="form-field status-field">
        <view class="status-options">
          <view
            class="status-item"
            :class="{ active: form.status === '0', disabled: mode === 'view' }"
            @click="mode !== 'view' && (form.status = '0')"
          >
            <view class="status-radio" :class="{ checked: form.status === '0' }"></view>
            <text>正常</text>
          </view>
          <view
            class="status-item"
            :class="{ active: form.status === '1', disabled: mode === 'view' }"
            @click="mode !== 'view' && (form.status = '1')"
          >
            <view class="status-radio" :class="{ checked: form.status === '1' }"></view>
            <text>停用</text>
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
        <view class="section-title">关联货品</view>
        <view v-if="mode !== 'view'" class="add-item-btn" @click="openProductPicker">
          <u-icon name="plus" size="14" color="#3D6DF7"></u-icon>
          <text>添加货品</text>
        </view>
      </view>

      <view v-if="form.products.length > 0" class="items-list">
        <view v-for="(item, index) in form.products" :key="index" class="item-card">
          <view class="item-header">
            <text class="item-name">{{ item.productName || '未选择货品' }}</text>
            <view v-if="mode !== 'view'" class="item-actions">
              <view class="action-btn" @click="removeProduct(index)"><u-icon name="trash" size="14" color="#F53F3F"></u-icon></view>
            </view>
          </view>
          <view class="item-body">
            <view class="item-info-row">
              <text class="item-label">单位类型</text>
              <view v-if="mode !== 'view'" class="unit-type-switch" @click="toggleUnitType(item)">
                <text class="unit-type-text">{{ item.unitType === '1' ? '主单位-整' : '副单位-拆' }}</text>
                <u-icon name="arrow-right" size="12" color="#3D6DF7"></u-icon>
              </view>
              <text v-else class="item-value">{{ item.unitType === '1' ? '主单位-整' : '副单位-拆' }}</text>
            </view>
            <view class="item-info-row">
              <text class="item-label">数量</text>
              <input v-if="mode !== 'view'" class="item-quantity-input" type="number" v-model.number="item.quantity" :min="1" @input="onProductQuantityChange(item)" />
              <text v-else class="item-value">{{ item.quantity || 0 }}</text>
              <text class="item-label" style="margin-left: 20rpx;">单价</text>
              <text class="item-value price">¥{{ formatAmount(item.unitPrice) }}</text>
            </view>
            <view class="item-info-row">
              <text class="item-label">金额</text>
              <text class="item-value price">¥{{ formatAmount(item.totalPrice) }}</text>
            </view>
          </view>
        </view>
      </view>
      <view v-else class="empty-items">
        <text class="empty-text">暂无关联货品</text>
      </view>
    </view>

    <u-picker
      :show="showCategoryPicker"
      :columns="[categoryOptions]"
      keyName="dictLabel"
      title="选择类别"
      @confirm="onCategoryConfirm"
      @cancel="showCategoryPicker = false"
      @close="showCategoryPicker = false"
    ></u-picker>

    <u-popup :show="showProductPopup" mode="bottom" round="16" @close="showProductPopup = false">
      <view class="picker-content">
        <view class="picker-header">
          <text class="picker-title">选择货品</text>
          <view class="picker-close" @click="showProductPopup = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <view class="picker-search">
          <u-icon name="search" size="14" color="#86909C"></u-icon>
          <input class="picker-search-input" type="text" v-model="productKeyword" placeholder="搜索货品名称/编码" placeholder-class="search-placeholder" @input="onProductSearch" />
        </view>
        <scroll-view scroll-y class="picker-list" :style="{ height: '500rpx' }">
          <view v-for="p in productSearchResults" :key="p.productId" class="picker-product-item" :class="{ selected: isProductSelected(p.productId) }" @click="toggleProductSelect(p)">
            <view class="product-checkbox">
              <view class="checkbox-box" :class="{ checked: isProductSelected(p.productId) }">
                <u-icon v-if="isProductSelected(p.productId)" name="checkmark" size="12" color="#fff"></u-icon>
              </view>
            </view>
            <view class="product-info">
              <view class="product-name-row">
                <text class="product-name">{{ p.productName }}</text>
                <text class="product-code">{{ p.productCode }}</text>
              </view>
              <view class="product-detail-row">
                <text class="product-supplier">{{ p.supplierName || '-' }}</text>
                <text class="product-pack">包装: {{ p.packQty || 1 }}</text>
              </view>
              <view class="product-price-row">
                <text class="product-price">主: ¥{{ formatAmount(p.salePrice) }}</text>
                <text class="product-price">副: ¥{{ formatAmount(p.salePriceSpec) }}</text>
              </view>
            </view>
          </view>
          <u-empty v-if="productSearchResults.length === 0" mode="search" text="未找到货品" :marginTop="40"></u-empty>
        </scroll-view>
        <view class="picker-actions">
          <u-button type="info" plain text="取消" @click="showProductPopup = false"></u-button>
          <u-button type="primary" text="确定({{ selectedProducts.length }})" @click="confirmProductSelect"></u-button>
        </view>
      </view>
    </u-popup>

    <view class="form-actions" v-if="mode !== 'view'">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>

    <view class="form-actions" v-else>
      <u-button v-if="checkPermi('business:cardItem:edit')" type="primary" plain text="编辑" @click="goEdit"></u-button>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 卡项表单页 - 新增/编辑/查看卡项
 * @description 支持三种模式（add/edit/view），包含卡项名称、编码、类别、默认次数、
 * 建议成交价、默认单次价等字段，以及关联货品管理，提交时区分新增和修改
 */
import { ref, reactive, computed, onMounted } from 'vue'
import { getCardItem, addCardItem, updateCardItem } from '@/api/business/cardItem'
import { searchProduct } from '@/api/wms/product'
import { getDicts } from '@/api/system/dictData'
import { generateProductCode } from '@/utils/pinyin'
import { checkPermi } from '@/utils/permission'

const submitting = ref(false)
const showCategoryPicker = ref(false)
const showProductPopup = ref(false)
/** 页面模式：add/edit/view */
const mode = ref('add')
const cardItemId = ref(null)

const categoryOptions = ref([])
const productKeyword = ref('')
const productSearchResults = ref([])
const selectedProducts = ref([])
let productSearchTimer = null

const form = reactive({
  cardItemId: undefined,
  cardItemName: '',
  cardItemCode: '',
  category: '',
  defaultQuantity: 1,
  suggestedPrice: 0,
  defaultUnitPrice: 0,
  status: '0',
  remark: '',
  products: []
})

const categoryLabel = computed(() => {
  if (!form.category) return ''
  const item = categoryOptions.value.find(c => c.dictValue === String(form.category))
  return item ? item.dictLabel : ''
})

function formatAmount(val) {
  const num = parseFloat(val)
  if (isNaN(num)) return '0.00'
  return num.toFixed(2)
}

/** 卡项名称输入时自动生成编码 */
function onNameInput() {
  if (mode.value === 'add' && form.cardItemName) {
    form.cardItemCode = generateProductCode(form.cardItemName)
  }
}

/** 类别选择确认 */
function onCategoryConfirm(e) {
  const item = e.value[0]
  form.category = item.dictValue
  showCategoryPicker.value = false
}

/** 计算建议成交价和默认单次价 */
function calcPrices() {
  let total = 0
  form.products.forEach(item => {
    total += (parseFloat(item.totalPrice) || 0)
  })
  form.suggestedPrice = Math.round(total * 100) / 100
  const qty = parseInt(form.defaultQuantity) || 0
  form.defaultUnitPrice = qty > 0 ? Math.round((form.suggestedPrice / qty) * 100) / 100 : 0
}

/** 切换货品单位类型 */
function toggleUnitType(item) {
  const oldType = item.unitType
  if (oldType === '1') {
    item.unitType = '2'
    item.unitPrice = item.salePriceSpec || 0
    item.specLabel = item._specLabel || ''
    if (item.packQty > 1) {
      item.quantity = (parseInt(item.quantity) || 1) * item.packQty
    }
  } else {
    item.unitType = '1'
    item.unitPrice = item.salePrice || 0
    item.specLabel = item._unitLabel || ''
  }
  item.totalPrice = Math.round((parseFloat(item.unitPrice) || 0) * (parseInt(item.quantity) || 0) * 100) / 100
  calcPrices()
}

/** 货品数量变化时重新计算 */
function onProductQuantityChange(item) {
  item.totalPrice = Math.round((parseFloat(item.unitPrice) || 0) * (parseInt(item.quantity) || 0) * 100) / 100
  calcPrices()
}

/** 打开货品选择弹窗 */
function openProductPicker() {
  productKeyword.value = ''
  selectedProducts.value = []
  showProductPopup.value = true
  onProductSearch()
}

/** 货品搜索 */
function onProductSearch() {
  if (productSearchTimer) clearTimeout(productSearchTimer)
  productSearchTimer = setTimeout(() => {
    searchProduct(productKeyword.value).then(res => {
      productSearchResults.value = res.data || []
    }).catch(e => {
      console.error('搜索货品失败:', e)
      productSearchResults.value = []
    })
  }, 400)
}

/** 判断货品是否已选中（含已添加到列表的） */
function isProductSelected(productId) {
  return selectedProducts.value.some(p => p.productId === productId) ||
    form.products.some(p => p.productId === productId)
}

/** 切换货品选中状态 */
function toggleProductSelect(p) {
  const idx = selectedProducts.value.findIndex(item => item.productId === p.productId)
  if (idx >= 0) {
    selectedProducts.value.splice(idx, 1)
  } else {
    if (!form.products.some(item => item.productId === p.productId)) {
      selectedProducts.value.push(p)
    }
  }
}

/** 确认货品选择 */
function confirmProductSelect() {
  selectedProducts.value.forEach(p => {
    const unitMap = { '1': '箱', '2': '件', '3': '套', '4': '罐', '5': '盒', '6': '袋', '7': '包' }
    const specMap = { '1': '支', '2': '瓶', '3': '件', '4': '套', '5': '片', '6': '个' }
    const unitLabel = unitMap[p.unit] || ''
    const specLabel = specMap[p.spec] || ''

    form.products.push({
      productId: p.productId,
      productName: p.productName,
      productCode: p.productCode,
      supplierName: p.supplierName || '',
      unitType: '1',
      packQty: p.packQty || 1,
      quantity: 1,
      salePrice: p.salePrice || 0,
      salePriceSpec: p.salePriceSpec || 0,
      unitPrice: p.salePrice || 0,
      totalPrice: p.salePrice || 0,
      _unitLabel: unitLabel,
      _specLabel: specLabel,
      specLabel: unitLabel
    })
  })
  selectedProducts.value = []
  showProductPopup.value = false
  calcPrices()
}

/** 删除关联货品 */
function removeProduct(index) {
  uni.showModal({
    title: '提示',
    content: '确认删除该货品?',
    success: (res) => {
      if (res.confirm) {
        form.products.splice(index, 1)
        calcPrices()
      }
    }
  })
}

/** 加载卡项详情数据并填充到表单，用于编辑和查看模式 */
async function loadDetail() {
  if (!cardItemId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getCardItem(cardItemId.value)
    const data = response.data || response
    Object.assign(form, {
      cardItemId: data.cardItemId,
      cardItemName: data.cardItemName || '',
      cardItemCode: data.cardItemCode || '',
      category: String(data.category || ''),
      defaultQuantity: data.defaultQuantity || 1,
      suggestedPrice: data.suggestedPrice || 0,
      defaultUnitPrice: data.defaultUnitPrice || 0,
      status: String(data.status ?? '0'),
      remark: data.remark || '',
      products: (data.products || []).map(item => {
        const product = item.product || item || {}
        const unitType = String(item.unitType || '1')
        const packQty = item.packQty || product.packQty || 1
        const salePrice = product.salePrice || 0
        const salePriceSpec = product.salePriceSpec || 0
        const unitPrice = unitType === '1' ? salePrice : salePriceSpec
        const quantity = item.quantity || 1
        const totalPrice = Math.round(unitPrice * quantity * 100) / 100

        const unitMap = { '1': '箱', '2': '件', '3': '套', '4': '罐', '5': '盒', '6': '袋', '7': '包' }
        const specMap = { '1': '支', '2': '瓶', '3': '件', '4': '套', '5': '片', '6': '个' }
        const unitLabel = unitMap[product.unit] || ''
        const specLabel = specMap[product.spec] || ''

        return {
          productId: item.productId || product.productId,
          productName: product.productName || item.productName || '',
          productCode: product.productCode || '',
          supplierName: product.supplierName || '',
          unitType,
          packQty,
          quantity,
          salePrice,
          salePriceSpec,
          unitPrice,
          totalPrice,
          _unitLabel: unitLabel,
          _specLabel: specLabel,
          specLabel: unitType === '1' ? unitLabel : specLabel
        }
      })
    })
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

/** 提交卡项表单，校验必填项后根据是否有ID区分新增和修改 */
async function submitForm() {
  if (!form.cardItemName) { uni.showToast({ title: '请输入卡项名称', icon: 'none' }); return }
  if (!form.cardItemCode) { uni.showToast({ title: '请输入卡项编码', icon: 'none' }); return }
  if (!form.category) { uni.showToast({ title: '请选择类别', icon: 'none' }); return }
  if (!form.defaultQuantity || form.defaultQuantity < 1) { uni.showToast({ title: '默认次数不能小于1', icon: 'none' }); return }

  submitting.value = true
  try {
    const formData = {
      cardItemId: form.cardItemId || undefined,
      cardItemName: form.cardItemName,
      cardItemCode: form.cardItemCode,
      category: form.category || null,
      defaultQuantity: parseInt(form.defaultQuantity) || 1,
      suggestedPrice: form.suggestedPrice || 0,
      defaultUnitPrice: form.defaultUnitPrice || 0,
      status: form.status,
      remark: form.remark || null,
      products: form.products.map(item => ({
        productId: item.productId,
        unitType: item.unitType,
        packQty: item.packQty,
        quantity: item.quantity
      }))
    }

    if (formData.cardItemId) {
      await updateCardItem(formData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      delete formData.cardItemId
      await addCardItem(formData)
      uni.showToast({ title: '新增成功', icon: 'success' })
    }
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('提交失败:', e)
    const msg = e?.msg || e?.message || '操作失败，请重试'
    uni.showToast({ title: msg, icon: 'none', duration: 2000 })
  } finally { submitting.value = false }
}

function goEdit() { mode.value = 'edit'; uni.setNavigationBarTitle({ title: '编辑卡项' }) }

function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.redirectTo({ url: '/pages/business/cardItem/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  mode.value = options.mode || 'add'
  cardItemId.value = options.id ? parseInt(options.id) : null

  getDicts('biz_card_item_category').then(res => { categoryOptions.value = res.data || [] })

  if (mode.value === 'view') { uni.setNavigationBarTitle({ title: '卡项详情' }); loadDetail() }
  else if (mode.value === 'edit') { uni.setNavigationBarTitle({ title: '编辑卡项' }); loadDetail() }
  else { uni.setNavigationBarTitle({ title: '新增卡项' }) }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }

.form-container { min-height: 100vh; padding-bottom: 140rpx; }

.form-section {
  margin: 24rpx;
  background: #fff;
  border-radius: 20rpx;
  padding: 32rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05);
}

.section-title { font-size: 30rpx; font-weight: 600; color: #1D2129; margin-bottom: 24rpx; }
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24rpx; }

.add-item-btn { display: flex; align-items: center; gap: 6rpx; padding: 8rpx 20rpx; background: #E8F0FE; border-radius: 24rpx;
  text { font-size: 24rpx; color: #3D6DF7; font-weight: 500; }
}

.form-field { margin-bottom: 20rpx; &:last-child { margin-bottom: 0; } }

.field-input-box {
  display: flex;
  align-items: center;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 0 20rpx;
  height: 88rpx;
  gap: 16rpx;
  border: 2rpx solid transparent;
  transition: all 0.2s;

  &:active { background: #EFF0F1; }
}

.field-input {
  flex: 1;
  font-size: 30rpx;
  color: #1D2129;
  height: 88rpx;
  line-height: 88rpx;
}

.field-placeholder { color: #C9CDD4; font-size: 30rpx; }

.field-textarea-box {
  display: flex;
  flex-direction: column;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 16rpx 20rpx;
  gap: 8rpx;
  border: 2rpx solid transparent;
}

.textarea-prefix {
  display: flex;
  align-items: center;
  gap: 10rpx;
}

.prefix-text {
  font-size: 26rpx;
  color: #86909C;
  font-weight: 500;
}

.field-textarea {
  width: 100%;
  min-height: 120rpx;
  font-size: 28rpx;
  color: #1D2129;
  line-height: 1.6;
}

.form-row { display: flex; gap: 20rpx; }

.half-width { flex: 1; min-width: 0;
  .field-input-box { height: 80rpx; }
  .field-input { height: 80rpx; line-height: 80rpx; font-size: 28rpx; }
}

.status-field { margin-top: 8rpx; margin-bottom: 24rpx; }

.status-options {
  display: flex;
  gap: 48rpx;
  padding: 8rpx 4rpx;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 12rpx;
  font-size: 28rpx;
  color: #4E5969;

  &.active { color: #1D2129; font-weight: 500; }
  &.disabled { opacity: 0.5; }
}

.status-radio {
  width: 36rpx;
  height: 36rpx;
  border-radius: 50%;
  border: 3rpx solid #C9CDD4;
  transition: all 0.2s;

  &.checked {
    background: #3D6DF7;
    border-color: #3D6DF7;
    position: relative;

    &::after {
      content: '';
      position: absolute;
      top: 50%; left: 50%;
      transform: translate(-50%, -50%);
      width: 14rpx;
      height: 14rpx;
      border-radius: 50%;
      background: #fff;
    }
  }
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

.unit-type-switch {
  display: flex;
  align-items: center;
  gap: 4rpx;
  padding: 4rpx 12rpx;
  background: #E8F0FE;
  border-radius: 8rpx;
}

.unit-type-text { font-size: 24rpx; color: #3D6DF7; font-weight: 500; }

.item-quantity-input {
  width: 100rpx;
  height: 48rpx;
  font-size: 24rpx;
  color: #1D2129;
  background: #fff;
  border-radius: 8rpx;
  padding: 0 12rpx;
  border: 1rpx solid #E5E6EB;
  text-align: center;
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

.picker-product-item {
  display: flex;
  align-items: flex-start;
  padding: 20rpx 16rpx;
  border-bottom: 1rpx solid #F2F3F5;
  gap: 16rpx;

  &.selected { background: #E8F0FE; }
  &:active { background: #F5F7FA; }
}

.product-checkbox { padding-top: 4rpx; }

.checkbox-box {
  width: 36rpx;
  height: 36rpx;
  border-radius: 6rpx;
  border: 3rpx solid #C9CDD4;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;

  &.checked {
    background: #3D6DF7;
    border-color: #3D6DF7;
  }
}

.product-info { flex: 1; min-width: 0; }
.product-name-row { display: flex; align-items: center; gap: 12rpx; margin-bottom: 6rpx; }
.product-name { font-size: 28rpx; color: #1D2129; font-weight: 500; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.product-code { font-size: 22rpx; color: #86909C; }
.product-detail-row { display: flex; gap: 20rpx; margin-bottom: 6rpx; }
.product-supplier { font-size: 24rpx; color: #86909C; }
.product-pack { font-size: 24rpx; color: #86909C; }
.product-price-row { display: flex; gap: 20rpx; }
.product-price { font-size: 24rpx; color: #FF6B35; font-weight: 500; }

.picker-actions { display: flex; gap: 20rpx; padding-top: 20rpx; border-top: 1rpx solid #E5E6EB;
  .u-button { flex: 1; }
}

.form-actions {
  position: fixed;
  left: 24rpx;
  right: 24rpx;
  bottom: 40rpx;
  display: flex;
  gap: 20rpx;
  z-index: 100;

  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
