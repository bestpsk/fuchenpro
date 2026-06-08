<template>
  <view class="sales-container">
    <view class="search-section">
      <view class="selector-row">
        <view class="selector-item" @click="showEnterprisePicker = true">
          <text class="selector-label">企业</text>
          <text class="selector-value">{{ currentEnterpriseName || '请选择' }}</text>
          <u-icon name="arrow-down" size="12" color="#fff"></u-icon>
        </view>
        <view class="selector-item" @click="showStorePicker = true" :style="{ opacity: currentEnterpriseId ? 1 : 0.5 }">
          <text class="selector-label">门店</text>
          <text class="selector-value">{{ currentStoreName || '请选择' }}</text>
          <u-icon name="arrow-down" size="12" color="#fff"></u-icon>
        </view>
      </view>
      <view class="search-box" v-if="currentStoreId">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="customerKeyword" placeholder="搜索客户" placeholder-class="search-placeholder" @input="onCustomerSearch" />
      </view>
    </view>

    <u-popup :show="showEnterprisePicker" mode="bottom" round="16" @close="showEnterprisePicker = false">
      <view class="picker-popup">
        <view class="popup-header">
          <text class="popup-title">选择企业</text>
          <view class="popup-close" @click="showEnterprisePicker = false">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <view class="popup-search">
          <u-icon name="search" size="16" color="#86909C"></u-icon>
          <input class="popup-input" type="text" v-model="enterpriseSearchKeyword" placeholder="搜索企业名称" placeholder-class="popup-placeholder" />
        </view>
        <scroll-view scroll-y class="popup-list">
          <view v-for="item in filteredEnterpriseList" :key="item.enterpriseId" class="popup-item" :class="{ active: item.enterpriseId === currentEnterpriseId }" @click="onEnterpriseSelect(item)">
            <text class="item-name">{{ item.enterpriseName }}</text>
            <u-icon v-if="item.enterpriseId === currentEnterpriseId" name="checkmark" size="18" color="#3D6DF7"></u-icon>
          </view>
          <u-empty v-if="filteredEnterpriseList.length === 0" mode="search" text="未找到匹配企业" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <u-popup :show="showStorePicker" mode="bottom" round="16" @close="showStorePicker = false">
      <view class="picker-popup">
        <view class="popup-header">
          <text class="popup-title">选择门店</text>
          <view class="popup-close" @click="showStorePicker = false">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <view class="popup-search">
          <u-icon name="search" size="16" color="#86909C"></u-icon>
          <input class="popup-input" type="text" v-model="storeSearchKeyword" placeholder="搜索门店名称" placeholder-class="popup-placeholder" />
        </view>
        <scroll-view scroll-y class="popup-list">
          <view v-for="item in filteredStoreList" :key="item.storeId" class="popup-item" :class="{ active: item.storeId === currentStoreId }" @click="onStoreSelect(item)">
            <text class="item-name">{{ item.storeName }}</text>
            <u-icon v-if="item.storeId === currentStoreId" name="checkmark" size="18" color="#3D6DF7"></u-icon>
          </view>
          <u-empty v-if="filteredStoreList.length === 0" mode="search" text="未找到匹配门店" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <scroll-view scroll-y class="list-scroll" v-if="currentStoreId">
      <view v-if="customerList.length > 0" class="card-list">
        <view v-for="item in customerList" :key="item.customerId" class="customer-card" @click="goCustomerDetail(item)">
          <view class="card-header">
            <u-avatar v-if="item.avatar" :src="getAvatarUrl(item.avatar)" size="40" mode="aspectFill" />
            <u-avatar v-else :text="item.customerName ? item.customerName.charAt(0) : ''" size="40" :bg-color="item.gender === '1' ? '#FF6B9D' : '#3D6DF7'" color="#fff" fontSize="18" />
            <view class="customer-info-area">
              <view class="customer-name">
                <text class="name-text">{{ item.customerName }}</text>
                <text class="gender-text" :class="item.gender === '1' ? 'female' : 'male'">{{ item.gender === '1' ? '女' : '男' }}</text>
                <text class="age-text" v-if="item.age">{{ item.age }}岁</text>
              </view>
            </view>
          </view>
          <view class="card-body">
            <view class="info-row">
              <view class="tag-list" v-if="item.tag">
                <text class="customer-tag" v-for="(tag, idx) in item.tag.split(',')" :key="idx">{{ getTagLabel(tag) }}</text>
              </view>
              <text class="no-tag" v-else>暂无标签</text>
            </view>
          </view>
          <view class="card-actions">
            <view class="action-btn order" @click.stop="goCreateOrder(item)"><u-icon name="edit-pen" size="14"></u-icon><text>开单</text></view>
            <view class="action-btn op" @click.stop="goCreateOperation(item)"><u-icon name="grid" size="14"></u-icon><text>操作</text></view>
            <view class="action-btn archive" @click.stop="goArchive(item)"><u-icon name="folder" size="14"></u-icon><text>档案</text></view>
          </view>
        </view>
      </view>
      <u-empty v-else mode="data" text="暂无客户数据" :marginTop="100"></u-empty>
    </scroll-view>

    <view v-else class="empty-store">
      <u-icon name="shop" size="60" color="#C9CDD4"></u-icon>
      <text class="empty-text">请先选择企业和门店</text>
    </view>

    <view class="fab-btn" @click="goAddCustomer" v-if="currentStoreId && checkPermi('business:customer:add')">
      <u-icon name="plus" size="24" color="#fff"></u-icon>
    </view>

    <!-- 新增客户弹窗 -->
    <u-popup :show="showAddCustomerPopup" mode="bottom" round="16" :closeOnClickOverlay="false">
      <view class="add-customer-drawer">
        <!-- 标题栏 -->
        <view class="popup-header">
          <text class="popup-title">新增客户</text>
          <view class="popup-close" @click="closeAddCustomerPopup">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>

        <!-- 表单内容 -->
        <scroll-view scroll-y class="form-scroll">
          <!-- 头像 -->
          <view class="form-item avatar-form-item">
            <view class="form-label">头像</view>
            <view class="avatar-upload-area" @click="chooseCustomerAvatar">
              <u-avatar v-if="customerAvatarPreview" :src="customerAvatarPreview" size="64" mode="aspectFill" />
              <u-avatar v-else :text="customerForm.customerName ? customerForm.customerName.charAt(0) : '头'" size="64" :bg-color="customerForm.gender === '1' ? '#FF6B9D' : '#3D6DF7'" color="#fff" fontSize="28" />
              <view class="avatar-upload-hint">
                <u-icon name="camera" size="16" color="#86909C"></u-icon>
                <text>点击上传</text>
              </view>
            </view>
          </view>

          <!-- 姓名 -->
          <view class="form-item">
            <view class="form-label">姓名 <text class="required">*</text></view>
            <input
              class="form-input"
              type="text"
              v-model="customerForm.customerName"
              placeholder="请输入客户姓名"
              placeholder-class="form-placeholder"
              :class="{ error: formErrors.customerName }"
            />
          </view>

          <!-- 性别 -->
          <view class="form-item">
            <view class="form-label">性别</view>
            <view class="gender-selector">
              <view
                v-for="option in genderOptions"
                :key="option.value"
                class="gender-option"
                :class="{ active: customerForm.gender === option.value }"
                :style="{ borderColor: customerForm.gender === option.value ? option.color : '#E5E6EB' }"
                @click="customerForm.gender = option.value"
              >
                <u-icon :name="option.icon" size="18" :color="customerForm.gender === option.value ? option.color : '#86909C'"></u-icon>
                <text class="option-text" :style="{ color: customerForm.gender === option.value ? option.color : '#4E5969' }">{{ option.label }}</text>
              </view>
            </view>
          </view>

          <!-- 年龄 -->
          <view class="form-item">
            <view class="form-label">年龄</view>
            <input
              class="form-input"
              type="number"
              v-model="customerForm.age"
              placeholder="请输入年龄"
              placeholder-class="form-placeholder"
            />
          </view>

          <!-- 客户标签 -->
          <view class="form-item">
            <view class="form-label">客户标签</view>
            <view class="tag-selector">
              <view class="tag-option" v-for="d in customerTagDict" :key="d.value" :class="{ active: customerForm.tag.includes(d.value) }" @click="toggleTag(d.value)">{{ d.label }}</view>
            </view>
          </view>

          <!-- 备注 -->
          <view class="form-item">
            <view class="form-label">备注</view>
            <textarea
              class="form-textarea"
              v-model="customerForm.remark"
              placeholder="请输入备注信息（选填）"
              placeholder-class="form-placeholder"
              :maxlength="200"
              auto-height
            ></textarea>
            <text class="textarea-count">{{ customerForm.remark.length }}/200</text>
          </view>
        </scroll-view>

        <!-- 操作按钮 -->
        <view class="form-actions">
          <button class="btn-cancel" @click="closeAddCustomerPopup">取消</button>
          <button class="btn-confirm" @click="submitAddCustomer">确定</button>
        </view>
      </view>
    </u-popup>


  </view>
</template>

<script setup>
/**
 * @description 销售开单页 - 客户选择与业务入口
 * @description 按企业→门店→客户三级筛选，支持企业/门店选择持久化（刷新不丢失），
 * 提供客户搜索、新增客户弹窗、开单/操作/档案快捷跳转功能
 */
import { ref, computed, onMounted, reactive } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import config from '@/config'
import { getDicts } from '@/api/system/dict/data'
import { listEnterprise } from '@/api/business/enterprise'
import { searchStore } from '@/api/business/store'
import { searchCustomer, addCustomer } from '@/api/business/customer'
import { checkPermi } from '@/utils/permission'


/** 本地存储键名，用于持久化企业和门店选择 */
const STORAGE_KEYS = {
  enterprise: 'sales_selected_enterprise',
  store: 'sales_selected_store'
}

const customerTagDict = ref([])

async function loadCustomerTagDict() {
  try {
    const res = await getDicts('biz_customer_tag')
    customerTagDict.value = (res.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
  } catch (e) {
    console.error(e)
  }
}

function toggleTag(value) {
  const idx = customerForm.tag.indexOf(value)
  if (idx === -1) {
    customerForm.tag.push(value)
  } else {
    customerForm.tag.splice(idx, 1)
  }
}

function getTagLabel(value) {
  const item = customerTagDict.value.find(d => d.value === value)
  return item ? item.label : value
}

function getAvatarUrl(avatar) {
  if (!avatar || avatar === '') return ''
  if (avatar.startsWith('http://') || avatar.startsWith('https://')) return avatar
  return config.baseUrl + avatar
}

/** 将当前选中的企业和门店信息保存到本地存储，刷新后可恢复 */
function saveSelectionToStorage() {
  const enterpriseData = currentEnterpriseId.value ? {
    enterpriseId: currentEnterpriseId.value,
    enterpriseName: currentEnterpriseName.value
  } : null
  const storeData = currentStoreId.value ? {
    storeId: currentStoreId.value,
    storeName: currentStoreName.value
  } : null

  if (enterpriseData) {
    uni.setStorageSync(STORAGE_KEYS.enterprise, enterpriseData)
  } else {
    uni.removeStorageSync(STORAGE_KEYS.enterprise)
  }

  if (storeData) {
    uni.setStorageSync(STORAGE_KEYS.store, storeData)
  } else {
    uni.removeStorageSync(STORAGE_KEYS.store)
  }
}

/** 从本地存储恢复企业和门店选择，校验数据有效性后自动加载客户列表 */
async function loadSelectionFromStorage() {
  try {
    const cachedEnterprise = uni.getStorageSync(STORAGE_KEYS.enterprise)
    const cachedStore = uni.getStorageSync(STORAGE_KEYS.store)

    if (cachedEnterprise && cachedEnterprise.enterpriseId) {
      const exists = enterpriseColumns.value.some(item => item.enterpriseId === cachedEnterprise.enterpriseId)
      if (exists) {
        currentEnterpriseId.value = cachedEnterprise.enterpriseId
        currentEnterpriseName.value = cachedEnterprise.enterpriseName

        if (cachedStore && cachedStore.storeId) {
          try {
            const response = await searchStore('', cachedEnterprise.enterpriseId)
            const data = response.data || response
            storeColumns.value = data.rows || data || []

            const storeExists = storeColumns.value.some(item => item.storeId === cachedStore.storeId)
            if (storeExists) {
              currentStoreId.value = cachedStore.storeId
              currentStoreName.value = cachedStore.storeName
              loadCustomerList()
            }
          } catch (e) {
            console.error('加载门店列表失败:', e)
          }
        }
      } else {
        uni.removeStorageSync(STORAGE_KEYS.enterprise)
        uni.removeStorageSync(STORAGE_KEYS.store)
      }
    }
  } catch (e) {
    console.error('加载缓存选择失败:', e)
  }
}

const enterpriseColumns = ref([])
const storeColumns = ref([])
const customerList = ref([])
const currentEnterpriseId = ref('')
const currentEnterpriseName = ref('')
const currentStoreId = ref('')
const currentStoreName = ref('')
const customerKeyword = ref('')
const showEnterprisePicker = ref(false)
const showStorePicker = ref(false)
const enterpriseSearchKeyword = ref('')
const storeSearchKeyword = ref('')


const showAddCustomerPopup = ref(false)
const customerAvatarPreview = ref('')
/** 新增客户表单数据 */
const customerForm = reactive({
  customerName: '',
  gender: '1',
  age: '',
  tag: [],
  remark: ''
})
/** 表单校验错误状态 */
const formErrors = reactive({
  customerName: false
})
/** 性别选项配置 */
const genderOptions = [
  { label: '女', value: '1', icon: 'woman', color: '#FF6B9D' },
  { label: '男', value: '0', icon: 'man', color: '#3D6DF7' }
]

/** 搜索防抖定时器 */
let searchTimer = null

/** 根据搜索关键词过滤企业列表 */
const filteredEnterpriseList = computed(() => {
  if (!enterpriseSearchKeyword.value) return enterpriseColumns.value
  const kw = enterpriseSearchKeyword.value.toLowerCase()
  return enterpriseColumns.value.filter(item =>
    (item.enterpriseName || '').toLowerCase().includes(kw)
  )
})

/** 根据搜索关键词过滤门店列表 */
const filteredStoreList = computed(() => {
  if (!storeSearchKeyword.value) return storeColumns.value
  const kw = storeSearchKeyword.value.toLowerCase()
  return storeColumns.value.filter(item =>
    (item.storeName || '').toLowerCase().includes(kw)
  )
})

/** 加载企业列表，仅获取状态为正常的企业 */
async function loadEnterpriseOptions() {
  try {
    const response = await listEnterprise({ pageNum: 1, pageSize: 1000, status: '0' })
    const data = response.data || response
    enterpriseColumns.value = data.rows || []
  } catch (e) { console.error('加载企业列表失败:', e) }
}

/** 选择企业后清空门店和客户，加载该企业下的门店列表并持久化选择 */
async function onEnterpriseSelect(item) {
  currentEnterpriseId.value = item.enterpriseId
  currentEnterpriseName.value = item.enterpriseName
  currentStoreId.value = ''
  currentStoreName.value = ''
  storeColumns.value = []
  customerList.value = []
  enterpriseSearchKeyword.value = ''
  showEnterprisePicker.value = false
  saveSelectionToStorage()
  try {
    const response = await searchStore('', item.enterpriseId)
    const data = response.data || response
    storeColumns.value = data.rows || data || []
  } catch (e) { console.error('加载门店列表失败:', e) }
}

/** 选择门店后持久化选择并加载该门店下的客户列表 */
async function onStoreSelect(item) {
  currentStoreId.value = item.storeId
  currentStoreName.value = item.storeName
  storeSearchKeyword.value = ''
  showStorePicker.value = false
  saveSelectionToStorage()
  loadCustomerList()
}

/** 根据关键词和企业/门店ID加载客户列表 */
const isLoadingCustomers = ref(false)
const isFirstShow = ref(true)

async function loadCustomerList() {
  if (!currentStoreId.value) return
  if (isLoadingCustomers.value) return
  isLoadingCustomers.value = true
  try {
    const response = await searchCustomer(customerKeyword.value, currentEnterpriseId.value, currentStoreId.value)
    const data = response.data || response
    customerList.value = data.rows || data || []
  } catch (e) { console.error('加载客户列表失败:', e) }
  finally { isLoadingCustomers.value = false }
}

/** 客户搜索防抖处理，500ms后触发搜索 */
function onCustomerSearch() {
  if (searchTimer) clearTimeout(searchTimer)
  searchTimer = setTimeout(() => loadCustomerList(), 500)
}

/** 跳转客户详情（订单页，不带storeId则只查看） */
function goCustomerDetail(item) {
  uni.navigateTo({ url: `/pages/business/customer/detail?customerId=${item.customerId}` })
}

/** 跳转客户开单页，携带门店信息 */
function goCreateOrder(item) {
  uni.navigateTo({ url: `/pages/business/sales/order?customerId=${item.customerId}&storeId=${currentStoreId.value}&storeName=${currentStoreName.value}&enterpriseName=${currentEnterpriseName.value}` })
}

/** 跳转客户操作页，携带企业和门店信息 */
function goCreateOperation(item) {
  uni.navigateTo({ url: `/pages/business/sales/operation?customerId=${item.customerId}&customerName=${encodeURIComponent(item.customerName)}&storeId=${currentStoreId.value}&storeName=${encodeURIComponent(currentStoreName.value)}&enterpriseId=${currentEnterpriseId.value}&enterpriseName=${encodeURIComponent(currentEnterpriseName.value)}` })
}

/** 跳转客户档案页 */
function goArchive(item) {
  uni.navigateTo({ url: `/pages/business/sales/archive?customerId=${item.customerId}&customerName=${encodeURIComponent(item.customerName)}&storeId=${currentStoreId.value}&storeName=${encodeURIComponent(currentStoreName.value)}&enterpriseId=${currentEnterpriseId.value}&enterpriseName=${encodeURIComponent(currentEnterpriseName.value)}` })
}

/** 打开新增客户弹窗并重置表单 */
function openAddCustomerPopup() {
  resetCustomerForm()
  showAddCustomerPopup.value = true
}

/** 关闭新增客户弹窗，延迟重置表单避免闪烁 */
function closeAddCustomerPopup() {
  showAddCustomerPopup.value = false
  setTimeout(() => resetCustomerForm(), 300)
}

/** 重置新增客户表单所有字段和校验状态 */
function resetCustomerForm() {
  customerForm.customerName = ''
  customerForm.gender = '1'
  customerForm.age = ''
  customerForm.tag = []
  customerForm.remark = ''
  customerAvatarPreview.value = ''
  formErrors.customerName = false
}

/** 校验新增客户表单，目前仅校验姓名必填 */
function validateCustomerForm() {
  let isValid = true
  formErrors.customerName = !customerForm.customerName.trim()
  if (formErrors.customerName) isValid = false
  return isValid
}

function chooseCustomerAvatar() {
  uni.chooseImage({
    count: 1,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera'],
    success: (res) => {
      customerAvatarPreview.value = res.tempFilePaths[0]
    }
  })
}

async function uploadCustomerAvatar(customerId, tempFilePath) {
  const baseUrl = '/prod-api'
  const token = uni.getStorageSync('App-Token')
  return new Promise((resolve) => {
    uni.uploadFile({
      url: baseUrl + '/business/customer/avatar',
      filePath: tempFilePath,
      name: 'avatarfile',
      formData: { customer_id: customerId },
      header: { 'Authorization': 'Bearer ' + token },
      success: (res) => {
        try {
          const data = JSON.parse(res.data)
          if (data.code === 200) resolve(data)
          else resolve(null)
        } catch { resolve(null) }
      },
      fail: () => resolve(null)
    })
  })
}

/** 提交新增客户，校验通过后组装数据（含可选的性别/年龄/标签/备注）调用接口，成功后刷新列表 */
async function submitAddCustomer() {
  if (!validateCustomerForm()) {
    uni.showToast({ title: '请填写必填项', icon: 'none' })
    return
  }

  try {
    const data = {
      customerName: customerForm.customerName.trim(),
      enterpriseId: currentEnterpriseId.value,
      storeId: currentStoreId.value,
      status: '0'
    }

    if (customerForm.gender) data.gender = customerForm.gender
    if (customerForm.age) data.age = parseInt(customerForm.age)
    if (customerForm.tag.length > 0) data.tag = customerForm.tag.join(',')
    if (customerForm.remark.trim()) data.remark = customerForm.remark.trim()

    const res = await addCustomer(data)
    const newCustomerId = res?.customerId || res?.data?.customerId || res?.data?.customer_id

    if (newCustomerId && customerAvatarPreview.value) {
      await uploadCustomerAvatar(newCustomerId, customerAvatarPreview.value)
    }

    uni.showToast({ title: '新增成功', icon: 'success' })
    closeAddCustomerPopup()
    loadCustomerList()
  } catch (e) {
    console.error('新增客户失败:', e)
    uni.showToast({ title: '新增失败', icon: 'error' })
  }
}

/** 悬浮按钮点击，校验已选企业和门店后打开新增客户弹窗 */
function goAddCustomer() {
  if (!currentEnterpriseId.value || !currentStoreId.value) {
    uni.showToast({ title: '请先选择企业和门店', icon: 'none' })
    return
  }
  openAddCustomerPopup()
}

onMounted(async () => {
  await loadEnterpriseOptions()
  loadSelectionFromStorage()
  loadCustomerTagDict()
})

onShow(() => {
  if (isFirstShow.value) {
    isFirstShow.value = false
    return
  }
  if (currentStoreId.value) loadCustomerList()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.sales-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx; box-sizing: border-box;
  :deep(.u-popup) { flex: none !important; }
}

.search-section { flex-shrink: 0; padding: 20rpx 24rpx; margin-left: -24rpx; margin-right: -24rpx; background: linear-gradient(180deg, #3D6DF7 0%, #4A7AEF 100%); }
.selector-row { display: flex; gap: 16rpx; margin-bottom: 16rpx; }
.selector-item { flex: 1; display: flex; align-items: center; gap: 8rpx; background: rgba(255,255,255,0.15); border-radius: 12rpx; padding: 16rpx 20rpx; }
.selector-label { font-size: 24rpx; color: rgba(255,255,255,0.7); white-space: nowrap; }
.selector-value { flex: 1; font-size: 28rpx; color: #fff; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

.search-box { display: flex; align-items: center; background: #fff; border-radius: 36rpx; padding: 0 24rpx; height: 72rpx; gap: 12rpx; }
.search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; }
.search-placeholder { color: #86909C; font-size: 28rpx; }

.list-scroll { flex: 1; overflow: hidden; padding: 20rpx 0; }
.card-list { display: flex; flex-direction: column; gap: 20rpx; }

.customer-card { background: #fff; border-radius: 16rpx; padding: 28rpx; box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
  &:active { transform: scale(0.98); opacity: 0.9; }
}
.card-header { display: flex; align-items: center; gap: 16rpx; margin-bottom: 16rpx; }
.customer-info-area { flex: 1; }
.customer-name { display: flex; align-items: center; gap: 12rpx;
  .name-text { font-size: 30rpx; font-weight: 600; color: #1D2129; }
}
.gender-text { font-size: 22rpx; padding: 2rpx 10rpx; border-radius: 4rpx;
  &.male { color: #3D6DF7; background: #E8F0FE; }
  &.female { color: #FF6B9D; background: #FFF0F5; }
}
.age-text { font-size: 24rpx; color: #86909C; }
.tag-list { display: flex; gap: 8rpx; flex-wrap: wrap; }
.customer-tag { padding: 4rpx 12rpx; background: #E8F0FE; color: #3D6DF7; border-radius: 4rpx; font-size: 22rpx; }
.no-tag { font-size: 24rpx; color: #C9CDD4; }

.card-body { padding: 16rpx 0; border-top: 1rpx solid #F2F3F5; }
.info-row { display: flex; }
.info-item { flex: 1; display: flex; align-items: center; gap: 12rpx;
  .label { font-size: 24rpx; color: #86909C; min-width: 60rpx; }
  .value { font-size: 26rpx; color: #1D2129; }
}

.card-actions { display: flex; gap: 20rpx; margin-top: 16rpx; padding-top: 16rpx; border-top: 1rpx solid #F2F3F5; }
.action-btn { flex: 1; display: flex; align-items: center; justify-content: center; gap: 8rpx; padding: 16rpx; border-radius: 12rpx; font-size: 28rpx; font-weight: 500;
  &.order { color: #3D6DF7; background: #E8F0FE; }
  &.op { color: #FF6B35; background: #FFF3ED; }
  &.archive { color: #722ED1; background: #F5E8FF; }
}

.empty-store { display: flex; flex-direction: column; align-items: center; justify-content: center; padding-top: 200rpx; }
.empty-text { font-size: 28rpx; color: #86909C; margin-top: 20rpx; }

.fab-btn { position: fixed; right: 32rpx; bottom: 120rpx; width: 100rpx; height: 100rpx; border-radius: 50%; background: linear-gradient(135deg, #FF6B35, #FF8F5E); display: flex; align-items: center; justify-content: center; box-shadow: 0 8rpx 24rpx rgba(255,107,53,0.4);
  &:active { transform: scale(0.95); opacity: 0.9; }
}

.picker-popup { background: #fff; border-radius: 24rpx 24rpx 0 0; max-height: 80vh; display: flex; flex-direction: column; }
.popup-header { display: flex; justify-content: space-between; align-items: center; padding: 28rpx 32rpx; border-bottom: 1rpx solid #F2F3F5; }
.popup-title { font-size: 30rpx; font-weight: 600; color: #1D2129; }
.popup-close { padding: 8rpx; }
.popup-search { display: flex; align-items: center; margin: 20rpx 24rpx; padding: 0 24rpx; height: 72rpx; background: #F7F8FA; border-radius: 12rpx; gap: 12rpx; }
.popup-input { flex: 1; height: 72rpx; font-size: 27rpx; color: #1D2129; }
.popup-placeholder { color: #C9CDD4; font-size: 27rpx; }
.popup-list { max-height: 50vh; padding: 0 8rpx; padding-bottom: env(safe-area-inset-bottom); }
.popup-item { display: flex; justify-content: space-between; align-items: center; padding: 24rpx 20rpx; border-bottom: 1rpx solid #F5F6F7;
  &:active { background: #F7F8FA; }
  &.active { background: #EEF2FF; }
  .item-name { font-size: 28rpx; color: #1D2129; }
  &.active .item-name { color: #3D6DF7; font-weight: 500; }
}

/* 新增客户弹窗样式 */
.add-customer-drawer {
  width: 100%;
  max-height: 85vh;
  background: #fff;
  border-radius: 24rpx 24rpx 0 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  padding: 0 32rpx;
  box-sizing: border-box;
}

.popup-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 32rpx 32rpx;
  margin-left: -32rpx;
  margin-right: -32rpx;
  border-bottom: 1rpx solid #F2F3F5;
}

.popup-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #1D2129;
}

.popup-close {
  padding: 8rpx;
}

.form-scroll {
  max-height: 60vh;
  padding: 24rpx 0;
}

.form-item {
  margin-bottom: 28rpx;

  &:last-child {
    margin-bottom: 0;
  }
}

.avatar-form-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.avatar-upload-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  position: relative;
}

.avatar-upload-hint {
  display: flex;
  align-items: center;
  gap: 4rpx;
  font-size: 22rpx;
  color: #86909C;
}

.form-label {
  font-size: 26rpx;
  color: #4E5969;
  margin-bottom: 12rpx;
  font-weight: 500;

  .required {
    color: #F53F3F;
    margin-left: 4rpx;
  }
}

.form-input {
  width: 100%;
  height: 80rpx;
  background: #F7F8FA;
  border: 2rpx solid transparent;
  border-radius: 12rpx;
  padding: 0 24rpx;
  font-size: 28rpx;
  color: #1D2129;
  box-sizing: border-box;
  transition: all 0.3s;

  &:focus {
    background: #fff;
    border-color: #3D6DF7;
  }

  &.error {
    border-color: #F53F3F;
    background: #FFF2F0;
  }
}

.form-placeholder {
  color: #C9CDD4;
  font-size: 28rpx;
}

.tag-selector {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.tag-option {
  font-size: 26rpx;
  padding: 10rpx 24rpx;
  border-radius: 8rpx;
  background: #F2F3F5;
  color: #86909C;
}

.tag-option.active {
  background: #E8F3FF;
  color: #165DFF;
}

.gender-selector {
  display: flex;
  gap: 20rpx;
}

.gender-option {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
  height: 80rpx;
  background: #F7F8FA;
  border: 2rpx solid #E5E6EB;
  border-radius: 12rpx;
  transition: all 0.3s;

  &:active {
    transform: scale(0.98);
  }

  &.active {
    background: #EEF2FF;
  }

  .option-text {
    font-size: 28rpx;
    font-weight: 500;
  }
}

.form-textarea {
  width: 100%;
  min-height: 140rpx;
  max-height: 240rpx;
  background: #F7F8FA;
  border: 2rpx solid transparent;
  border-radius: 12rpx;
  padding: 20rpx 24rpx;
  font-size: 28rpx;
  color: #1D2129;
  box-sizing: border-box;
  line-height: 1.5;
  transition: all 0.3s;

  &:focus {
    background: #fff;
    border-color: #3D6DF7;
  }
}

.textarea-count {
  display: block;
  text-align: right;
  font-size: 22rpx;
  color: #C9CDD4;
  margin-top: 8rpx;
}

.form-actions {
  display: flex;
  gap: 20rpx;
  padding: 24rpx 32rpx 32rpx;
  margin-left: -32rpx;
  margin-right: -32rpx;
  border-top: 1rpx solid #F2F3F5;
}

.btn-cancel,
.btn-confirm {
  flex: 1;
  height: 80rpx;
  border-radius: 12rpx;
  font-size: 30rpx;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;

  &::after {
    border: none;
  }
}

.btn-cancel {
  background: #F2F3F5;
  color: #4E5969;

  &:active {
    background: #E5E6EB;
  }
}

.btn-confirm {
  background: linear-gradient(135deg, #3D6DF7, #4A7AEF);
  color: #fff;

  &:active {
    opacity: 0.9;
  }
}


</style>
