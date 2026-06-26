<template>
  <view class="customer-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.keyword"
          placeholder="搜索客户姓名/电话"
          placeholder-class="search-placeholder"
          confirm-type="search"
          @input="onSearchInput"
          @confirm="handleSearch"
        />
        <view v-if="queryParams.keyword" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
        <view class="filter-btn" @click="toggleFilter">
          <text>筛选</text>
          <u-icon name="arrow-down" size="12" :class="{ 'icon-rotate': showFilter }"></u-icon>
        </view>
      </view>
    </view>

    <view v-if="hasActiveFilters" class="active-filters">
      <scroll-view scroll-x class="filter-scroll">
        <view class="filter-tags">
          <view
            v-if="queryParams.enterpriseId"
            class="filter-tag active"
            @click="clearFilter('enterpriseId')"
          >
            <text>{{ getEnterpriseName(queryParams.enterpriseId) }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
          <view
            v-if="queryParams.storeId"
            class="filter-tag active"
            @click="clearFilter('storeId')"
          >
            <text>{{ getStoreName(queryParams.storeId) }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
          <view
            v-if="queryParams.tag"
            class="filter-tag active"
            @click="clearFilter('tag')"
          >
            <text>{{ getTagLabel(queryParams.tag) }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
          <view
            v-if="queryParams.status !== '' && queryParams.status !== undefined"
            class="filter-tag active"
            @click="clearFilter('status')"
          >
            <text>{{ queryParams.status === '0' ? '正常' : '停用' }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
        </view>
      </scroll-view>
    </view>

    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <view class="form-label">所属企业</view>
          <view class="picker-value" @click="showEnterprisePicker = true">
            <text :class="{ 'placeholder-text': !queryParams.enterpriseId }">{{ queryParams.enterpriseId ? getEnterpriseName(queryParams.enterpriseId) : '请选择企业' }}</text>
            <u-icon name="arrow-right" size="14" color="#86909C"></u-icon>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">所属门店</view>
          <view class="picker-value" @click="onStorePickerOpen" :style="{ opacity: queryParams.enterpriseId ? 1 : 0.5 }">
            <text :class="{ 'placeholder-text': !queryParams.storeId }">{{ queryParams.storeId ? getStoreName(queryParams.storeId) : '请选择门店' }}</text>
            <u-icon name="arrow-right" size="14" color="#86909C"></u-icon>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">客户标签</view>
          <view class="form-options">
            <view
              v-for="item in tagOptions"
              :key="item.value"
              class="option-tag"
              :class="{ active: queryParams.tag === item.value }"
              @click="queryParams.tag = queryParams.tag === item.value ? '' : item.value"
            >
              {{ item.label }}
            </view>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">状态</view>
          <view class="form-options">
            <view
              class="option-tag"
              :class="{ active: queryParams.status === '0' }"
              @click="queryParams.status = queryParams.status === '0' ? '' : '0'"
            >正常</view>
            <view
              class="option-tag"
              :class="{ active: queryParams.status === '1' }"
              @click="queryParams.status = queryParams.status === '1' ? '' : '1'"
            >停用</view>
          </view>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
      </view>
    </u-popup>

    <u-popup :show="showEnterprisePicker" mode="bottom" round="16" @close="showEnterprisePicker = false">
      <view class="picker-popup">
        <view class="picker-header">
          <text class="picker-title">选择企业</text>
          <view class="picker-close" @click="showEnterprisePicker = false">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <view class="picker-search">
          <u-icon name="search" size="16" color="#86909C"></u-icon>
          <input class="picker-input" type="text" v-model="enterpriseSearchKeyword" placeholder="搜索企业名称" placeholder-class="picker-placeholder" />
        </view>
        <scroll-view scroll-y class="picker-list">
          <view v-for="item in filteredEnterpriseList" :key="item.enterpriseId" class="picker-item" :class="{ active: item.enterpriseId === queryParams.enterpriseId }" @click="onEnterpriseSelect(item)">
            <text class="item-name">{{ item.enterpriseName }}</text>
            <u-icon v-if="item.enterpriseId === queryParams.enterpriseId" name="checkmark" size="18" color="#3D6DF7"></u-icon>
          </view>
          <u-empty v-if="filteredEnterpriseList.length === 0" mode="search" text="未找到匹配企业" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <u-popup :show="showStorePicker" mode="bottom" round="16" @close="showStorePicker = false">
      <view class="picker-popup">
        <view class="picker-header">
          <text class="picker-title">选择门店</text>
          <view class="picker-close" @click="showStorePicker = false">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <view class="picker-search">
          <u-icon name="search" size="16" color="#86909C"></u-icon>
          <input class="picker-input" type="text" v-model="storeSearchKeyword" placeholder="搜索门店名称" placeholder-class="picker-placeholder" />
        </view>
        <scroll-view scroll-y class="picker-list">
          <view v-for="item in filteredStoreList" :key="item.storeId" class="picker-item" :class="{ active: item.storeId === queryParams.storeId }" @click="onStoreSelect(item)">
            <text class="item-name">{{ item.storeName }}</text>
            <u-icon v-if="item.storeId === queryParams.storeId" name="checkmark" size="18" color="#3D6DF7"></u-icon>
          </view>
          <u-empty v-if="filteredStoreList.length === 0" mode="search" text="未找到匹配门店" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <scroll-view
      scroll-y
      class="list-scroll"
      @scrolltolower="loadMore"
      refresher-enabled
      :refresher-triggered="refreshing"
      @refresherrefresh="onPullDownRefresh"
    >
      <view v-if="customerList.length > 0" class="card-list">
        <view
          v-for="(item, index) in customerList"
          :key="item.customerId"
          class="customer-card"
          @click="goDetail(item)"
        >
          <view class="card-header">
            <view class="avatar-wrap">
              <image v-if="item.avatar" class="customer-avatar" :src="getAvatarUrl(item.avatar)" mode="aspectFill" @click.stop="previewAvatar(item)" />
              <view v-else class="avatar-placeholder" :style="{ background: item.gender === '1' ? '#FF6B9D' : '#3D6DF7' }">
                <text class="avatar-text">{{ item.customerName ? item.customerName.charAt(0) : '' }}</text>
              </view>
            </view>
            <view class="header-info">
              <view class="name-row">
                <text class="name-text">{{ item.customerName }}</text>
                <text class="gender-tag" :class="item.gender === '1' ? 'female' : 'male'">{{ item.gender === '1' ? '女' : '男' }}</text>
                <text class="age-tag" v-if="item.age">{{ item.age }}岁</text>
                <view class="status-tag" :class="item.status === '0' ? 'status-normal' : 'status-stop'">
                  {{ item.status === '0' ? '正常' : '停用' }}
                </view>
              </view>
              <view class="tag-list" v-if="item.tag">
                <text class="customer-tag" v-for="(tag, idx) in item.tag.split(',')" :key="idx">{{ getTagLabel(tag) }}</text>
              </view>
            </view>
          </view>

          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="label">满意度</text>
                <view class="star-row">
                  <u-icon v-for="n in 5" :key="n" :name="n <= (item.avgSatisfaction || 0) ? 'star-fill' : 'star'" size="14" :color="n <= (item.avgSatisfaction || 0) ? '#FF9A2E' : '#E5E6EB'"></u-icon>
                </view>
              </view>
              <view class="info-item">
                <text class="label">成交额</text>
                <text class="value highlight">{{ item.dealAmount ? '¥' + item.dealAmount : '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">企业</text>
                <text class="value">{{ getEnterpriseName(item.enterpriseId) || '-' }}</text>
              </view>
              <view class="info-item">
                <text class="label">门店</text>
                <text class="value">{{ getStoreNameById(item.storeId) || '-' }}</text>
              </view>
            </view>
          </view>

          <view class="card-footer">
            <view class="time-text">{{ formatTime(item.createTime) }}</view>
            <view class="action-btns">
              <view v-if="checkPermi('business:customer:edit')" class="action-btn edit" @click.stop="goEdit(item)">
                <u-icon name="edit-pen" size="14"></u-icon>
                <text>编辑</text>
              </view>
              <view v-if="checkPermi('business:customer:remove')" class="action-btn delete" @click.stop="handleDelete(item)">
                <u-icon name="trash" size="14"></u-icon>
                <text>删除</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <u-empty
        v-else-if="!loading"
        mode="data"
        text="暂无客户数据"
        :marginTop="100"
      ></u-empty>

      <u-loadmore
        :status="loadStatus"
        :loading-text="'加载中...'"
        :loadmore-text="'上拉加载更多'"
        :nomore-text="'没有更多了'"
        :marginTop="20"
      />
    </scroll-view>

    <view v-if="checkPermi('business:customer:add')" class="fab-btn" @click="goAdd">
      <u-icon name="plus" size="24" color="#fff"></u-icon>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 客户列表页 - 客户管理入口
 * @description 展示客户列表，支持关键词搜索（客户名/电话）、按企业/门店/标签/状态筛选、
 * 分页加载、下拉刷新、拨打电话、跳转新增/编辑/详情、删除客户
 */
import { ref, reactive, onMounted, computed, onUnmounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import config from '@/config'
import { getDicts } from '@/api/system/dict/data'
import { listEnterprise } from '@/api/business/enterprise'
import { listStore, searchStore } from '@/api/business/store'
import { listCustomer, searchCustomer, delCustomer } from '@/api/business/customer'
import { checkPermi } from '@/utils/permission'

const customerList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)
const showEnterprisePicker = ref(false)
const showStorePicker = ref(false)
const enterpriseSearchKeyword = ref('')
const storeSearchKeyword = ref('')

const enterpriseColumns = ref([])
const storeColumns = ref([])
const allStoreList = ref([])
const tagOptions = ref([])

/** 搜索防抖定时器 */
let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

/** 是否有激活的筛选条件 */
const hasActiveFilters = computed(() => {
  return queryParams.enterpriseId || queryParams.storeId || queryParams.tag ||
         (queryParams.status !== '' && queryParams.status !== undefined)
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: '',
  customerName: '',
  phone: '',
  enterpriseId: '',
  storeId: '',
  tag: '',
  status: ''
})

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

/** 获取企业名称 */
function getEnterpriseName(id) {
  const item = enterpriseColumns.value.find(e => String(e.enterpriseId) === String(id))
  return item ? item.enterpriseName : ''
}

/** 获取门店名称 */
function getStoreName(id) {
  const item = storeColumns.value.find(s => String(s.storeId) === String(id))
  return item ? item.storeName : ''
}

/** 根据门店ID从全量列表获取门店名称 */
function getStoreNameById(id) {
  const item = allStoreList.value.find(s => String(s.storeId) === String(id))
  return item ? item.storeName : ''
}

/** 加载全量门店列表（用于卡片中门店名称映射） */
async function loadAllStores() {
  try {
    const response = await listStore({ pageNum: 1, pageSize: 999 })
    const data = response.data || response
    allStoreList.value = data.rows || []
  } catch (e) {
    console.error('加载全量门店列表失败:', e)
  }
}

/** 标签值映射为中文名称 */
function getTagLabel(value) {
  const item = tagOptions.value.find(t => t.value === value)
  return item ? item.label : value
}

function formatTime(time) {
  if (!time) return ''
  return time.substring(0, 10)
}

function getAvatarUrl(avatar) {
  if (!avatar || avatar === '') return ''
  if (avatar.startsWith('http://') || avatar.startsWith('https://')) return avatar
  return config.baseUrl + avatar
}

/** 点击头像预览大图 */
function previewAvatar(item) {
  const url = getAvatarUrl(item.avatar)
  if (url) {
    uni.previewImage({
      urls: [url],
      current: url
    })
  }
}

/** 加载企业列表 */
async function loadEnterpriseOptions() {
  try {
    const response = await listEnterprise({ pageNum: 1, pageSize: 100, status: '0' })
    const data = response.data || response
    enterpriseColumns.value = data.rows || []
  } catch (e) {
    console.error('加载企业列表失败:', e)
  }
}

/** 加载门店列表（依赖企业选择） */
async function loadStoreOptions(enterpriseId) {
  try {
    const response = await searchStore('', enterpriseId)
    const data = response.data || response
    storeColumns.value = data.rows || data || []
  } catch (e) {
    console.error('加载门店列表失败:', e)
  }
}

/** 加载客户标签字典 */
async function loadTagOptions() {
  try {
    const res = await getDicts('biz_customer_tag')
    tagOptions.value = (res.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
  } catch (e) {
    console.error('加载客户标签失败:', e)
  }
}

/** 选择企业后清空门店，加载该企业下的门店列表 */
async function onEnterpriseSelect(item) {
  queryParams.enterpriseId = item.enterpriseId
  queryParams.storeId = ''
  storeColumns.value = []
  enterpriseSearchKeyword.value = ''
  showEnterprisePicker.value = false
  await loadStoreOptions(item.enterpriseId)
}

/** 选择门店 */
function onStoreSelect(item) {
  queryParams.storeId = item.storeId
  storeSearchKeyword.value = ''
  showStorePicker.value = false
}

/** 打开门店选择器，需先选择企业 */
function onStorePickerOpen() {
  if (!queryParams.enterpriseId) {
    uni.showToast({ title: '请先选择企业', icon: 'none' })
    return
  }
  showStorePicker.value = true
}

/** 加载客户列表，支持分页和关键词搜索 */
async function getList(isRefresh = false) {
  if (loading.value) return

  loading.value = true
  if (isRefresh) {
    queryParams.pageNum = 1
    loadStatus.value = 'loadmore'
  }

  try {
    const params = { ...queryParams }
    if (params.keyword) {
      params.customerName = params.keyword
      params.phone = params.keyword
    }
    delete params.keyword

    const response = await listCustomer(params)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0

    if (isRefresh) {
      customerList.value = list
    } else {
      customerList.value = [...customerList.value, ...list]
    }

    if (customerList.value.length >= total) {
      loadStatus.value = 'nomore'
    } else {
      loadStatus.value = 'loadmore'
    }
  } catch (e) {
    console.error('获取客户列表失败:', e)
    loadStatus.value = 'error'
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

/** 加载更多，翻页并请求下一页数据 */
function loadMore() {
  if (loading.value || loadStatus.value === 'nomore') return
  loadStatus.value = 'loading'
  queryParams.pageNum++
  getList()
}

function onPullDownRefresh() {
  refreshing.value = true
  getList(true)
}

function handleSearch() {
  getList(true)
}

/** 搜索输入防抖处理，500ms后触发搜索 */
function onSearchInput() {
  if (searchTimer) clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    handleSearch()
  }, 500)
}

function clearKeyword() {
  queryParams.keyword = ''
  handleSearch()
}

function toggleFilter() {
  showFilter.value = !showFilter.value
}

function resetFilter() {
  queryParams.enterpriseId = ''
  queryParams.storeId = ''
  queryParams.tag = ''
  queryParams.status = ''
  storeColumns.value = []
}

function confirmFilter() {
  showFilter.value = false
  getList(true)
}

function clearFilter(field) {
  if (field === 'enterpriseId') {
    queryParams.enterpriseId = ''
    queryParams.storeId = ''
    storeColumns.value = []
  } else {
    queryParams[field] = ''
  }
  getList(true)
}

/** 跳转客户详情页（查看模式） */
function goDetail(item) {
  uni.navigateTo({
    url: `/pages/business/customer/detail?customerId=${item.customerId}`
  })
}

/** 跳转客户编辑页 */
function goEdit(item) {
  uni.navigateTo({
    url: `/pages/business/customer/detail?customerId=${item.customerId}&mode=edit`
  })
}

/** 跳转新增客户页 */
function goAdd() {
  uni.navigateTo({
    url: '/pages/business/customer/detail?mode=add'
  })
}

function callPhone(phone) {
  if (!phone) return
  uni.makePhoneCall({ phoneNumber: phone })
}

/** 删除客户，弹出确认框后调用删除接口，成功后刷新列表 */
function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: `是否确认删除客户"${item.customerName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delCustomer(item.customerId)
          uni.showToast({ title: '删除成功', icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('删除失败:', e)
        }
      }
    }
  })
}

onMounted(async () => {
  await loadEnterpriseOptions()
  loadAllStores()
  loadTagOptions()
})

onShow(() => {
  getList(true)
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
  height: 100%;
  overflow: hidden;
}

.customer-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
  padding: 0 24rpx;

  :deep(.u-popup) {
    flex: none !important;
  }
}

.search-section {
  flex-shrink: 0;
  padding: 20rpx 24rpx;
  margin-left: -24rpx;
  margin-right: -24rpx;
  background: linear-gradient(180deg, #3D6DF7 0%, #4A7AEF 100%);
}

.search-box {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 36rpx;
  padding: 0 8rpx 0 28rpx;
  height: 72rpx;
  gap: 12rpx;
  box-sizing: border-box;
}

.search-input {
  flex: 1;
  font-size: 28rpx;
  color: #1D2129;
  height: 72rpx;
  min-width: 0;
}

.search-placeholder {
  color: #86909C;
  font-size: 28rpx;
}

.clear-btn {
  flex-shrink: 0;
  padding: 8rpx;
  display: flex;
  align-items: center;
}

.filter-btn {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4rpx;
  height: 56rpx;
  padding: 0 22rpx;
  background: #E8F0FE;
  border-radius: 28rpx;

  text {
    font-size: 26rpx;
    color: #3D6DF7;
    font-weight: 500;
    white-space: nowrap;
  }

  .icon-rotate {
    transform: rotate(180deg);
    transition: transform 0.3s ease;
  }
}

.active-filters {
  flex-shrink: 0;
  padding: 12rpx 24rpx 16rpx;
  margin-left: -24rpx;
  margin-right: -24rpx;
  background: linear-gradient(180deg, #4A7AEF 0%, #F5F7FA 100%);
}

.filter-scroll {
  white-space: nowrap;
}

.filter-tags {
  display: inline-flex;
  gap: 16rpx;
  padding: 16rpx 0;
}

.filter-tag {
  display: inline-flex;
  align-items: center;
  gap: 8rpx;
  padding: 10rpx 20rpx;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 28rpx;
  font-size: 24rpx;
  color: #fff;

  &.active {
    background: #fff;
    color: #3D6DF7;
  }
}

.popup-content {
  padding: 30rpx;
  background: #fff;
}

.popup-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #1D2129;
  margin-bottom: 30rpx;
}

.form-item {
  margin-bottom: 30rpx;
}

.form-label {
  font-size: 28rpx;
  color: #1D2129;
  font-weight: 500;
  margin-bottom: 16rpx;
}

.form-options {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.option-tag {
  padding: 14rpx 28rpx;
  background: #F5F7FA;
  border-radius: 8rpx;
  font-size: 26rpx;
  color: #4E5969;
  border: 2rpx solid transparent;

  &.active {
    background: #E8F0FE;
    color: #3D6DF7;
    border-color: #3D6DF7;
  }
}

.picker-value {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 24rpx;
  background: #F5F7FA;
  border-radius: 8rpx;

  text {
    font-size: 28rpx;
    color: #1D2129;
  }

  .placeholder-text {
    color: #C9CDD4;
  }
}

.popup-actions {
  display: flex;
  gap: 20rpx;
  margin-top: 40rpx;
  padding-top: 30rpx;
  border-top: 1rpx solid #E5E6EB;

  .u-button {
    flex: 1;
  }
}

.picker-popup {
  background: #fff;
  border-radius: 24rpx 24rpx 0 0;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
}

.picker-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28rpx 32rpx;
  border-bottom: 1rpx solid #F2F3F5;
}

.picker-title {
  font-size: 30rpx;
  font-weight: 600;
  color: #1D2129;
}

.picker-close {
  padding: 8rpx;
}

.picker-search {
  display: flex;
  align-items: center;
  margin: 20rpx 24rpx;
  padding: 0 24rpx;
  height: 72rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
  gap: 12rpx;
}

.picker-input {
  flex: 1;
  height: 72rpx;
  font-size: 27rpx;
  color: #1D2129;
}

.picker-placeholder {
  color: #C9CDD4;
  font-size: 27rpx;
}

.picker-list {
  max-height: 50vh;
  padding: 0 8rpx;
  padding-bottom: env(safe-area-inset-bottom);
}

.picker-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24rpx 20rpx;
  border-bottom: 1rpx solid #F5F6F7;

  &:active {
    background: #F7F8FA;
  }

  &.active {
    background: #EEF2FF;
  }

  .item-name {
    font-size: 28rpx;
    color: #1D2129;
  }

  &.active .item-name {
    color: #3D6DF7;
    font-weight: 500;
  }
}

.list-scroll {
  flex: 1;
  overflow: hidden;
  padding: 20rpx 0;
}

.card-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.customer-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 28rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);

  &:active {
    transform: scale(0.98);
    opacity: 0.9;
  }
}

.card-header {
  display: flex;
  align-items: flex-start;
  gap: 20rpx;
  margin-bottom: 20rpx;
}

.avatar-wrap {
  flex-shrink: 0;
}

.customer-avatar {
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
}

.avatar-placeholder {
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.avatar-text {
  font-size: 32rpx;
  color: #fff;
  font-weight: 500;
}

.header-info {
  flex: 1;
  min-width: 0;
}

.name-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 12rpx;
}

.name-text {
  font-size: 30rpx;
  font-weight: 600;
  color: #1D2129;
}

.gender-tag {
  font-size: 22rpx;
  padding: 2rpx 10rpx;
  border-radius: 4rpx;

  &.male { color: #3D6DF7; background: #E8F0FE; }
  &.female { color: #FF6B9D; background: #FFF0F5; }
}

.age-tag {
  font-size: 24rpx;
  color: #86909C;
}

.status-tag {
  padding: 6rpx 16rpx;
  border-radius: 6rpx;
  font-size: 22rpx;
  font-weight: 500;

  &.status-normal {
    background: #E8FFEA;
    color: #00B42A;
  }

  &.status-stop {
    background: #FFF1F0;
    color: #F53F3F;
  }
}

.tag-list {
  display: flex;
  gap: 8rpx;
  flex-wrap: wrap;
}

.customer-tag {
  padding: 4rpx 12rpx;
  background: #E8F0FE;
  color: #3D6DF7;
  border-radius: 4rpx;
  font-size: 22rpx;
}

.card-body {
  padding: 20rpx 0;
  border-top: 1rpx solid #F2F3F5;
  border-bottom: 1rpx solid #F2F3F5;
}

.info-row {
  display: flex;
  margin-bottom: 16rpx;

  &:last-child {
    margin-bottom: 0;
  }
}

.info-item {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12rpx;

  .label {
    font-size: 24rpx;
    color: #86909C;
    min-width: 80rpx;
  }

  .value {
    font-size: 26rpx;
    color: #1D2129;

    &.highlight {
      color: #FF6B35;
      font-weight: 500;
    }

    &.phone-text {
      color: #3D6DF7;
    }
  }
}

.star-row {
  display: flex;
  gap: 4rpx;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20rpx;
  padding-top: 16rpx;
}

.time-text {
  font-size: 22rpx;
  color: #C9CDD4;
}

.action-btns {
  display: flex;
  gap: 24rpx;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 6rpx;
  font-size: 24rpx;
  padding: 8rpx 16rpx;
  border-radius: 8rpx;

  &.edit {
    color: #3D6DF7;
    background: #E8F0FE;
  }

  &.delete {
    color: #F53F3F;
    background: #FFF1F0;
  }
}

.fab-btn {
  position: fixed;
  right: 32rpx;
  bottom: 120rpx;
  width: 100rpx;
  height: 100rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, #3D6DF7, #5B8DEF);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 24rpx rgba(61, 109, 247, 0.4);

  &:active {
    transform: scale(0.95);
    opacity: 0.9;
  }
}
</style>
