<template>
  <view class="select-plan-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.keyword"
          placeholder="搜索方案/企业名称"
          placeholder-class="search-placeholder"
          confirm-type="search"
          @input="onSearchInput"
          @confirm="handleSearch"
        />
        <view v-if="queryParams.keyword" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
        <view class="filter-btn" @click="showFilter = !showFilter">
          <text>筛选</text>
          <u-icon name="arrow-down" size="12" color="#3D6DF7" :class="{ 'icon-rotate': showFilter }"></u-icon>
        </view>
      </view>
      <view v-if="hasActiveFilters" class="active-filters">
        <view v-if="filterParams.enterpriseName" class="filter-tag active" @click="clearFilter('enterpriseName')">
          <text>企业: {{ filterParams.enterpriseName }}</text>
          <u-icon name="close" size="12" color="#3D6DF7"></u-icon>
        </view>
        <view v-if="filterParams.planName" class="filter-tag active" @click="clearFilter('planName')">
          <text>方案: {{ filterParams.planName }}</text>
          <u-icon name="close" size="12" color="#3D6DF7"></u-icon>
        </view>
      </view>
    </view>

    <scroll-view scroll-y class="plan-list" @scrolltolower="loadMore">
      <view
        v-for="item in list"
        :key="item.planId"
        class="plan-card"
        @click="goPrepare(item)"
      >
        <view class="card-header">
          <text class="plan-name">{{ item.planName }}</text>
          <text class="plan-amount">¥{{ item.giftAmount || '0.00' }}</text>
        </view>
        <view class="card-body">
          <view class="info-row">
            <text class="label">企业</text>
            <text class="value">{{ item.enterpriseName || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="label">编号</text>
            <text class="value">{{ item.planNo || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="label">状态</text>
            <text class="status-tag prepared">已审核</text>
          </view>
        </view>
      </view>
      <u-loadmore :status="loadStatus" />
      <view v-if="list.length === 0 && !loading" class="empty-tip">
        <u-empty text="暂无可备货方案" mode="data"></u-empty>
      </view>
    </scroll-view>

    <u-popup :show="showFilter" mode="top" round="16" @close="showFilter = false">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <text class="form-label">企业名称</text>
          <input class="form-input" type="text" v-model="filterParams.enterpriseName" placeholder="请输入企业名称" placeholder-class="form-placeholder" />
        </view>
        <view class="form-item">
          <text class="form-label">方案名称</text>
          <input class="form-input" type="text" v-model="filterParams.planName" placeholder="请输入方案名称" placeholder-class="form-placeholder" />
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
      </view>
    </u-popup>
  </view>
</template>

<script setup>
/**
 * @description 选择方案备货页 - 从已审核方案列表中选择一个方案进行备货
 * @description 单搜索框（keyword 搜方案名+企业名）+ 筛选按钮（企业名/方案名精确筛选）
 */
import { ref, reactive, computed, onMounted } from 'vue'
import { listPlan } from '@/api/business/plan'

const list = ref([])
const loading = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: '',
  auditStatus: '2'
})

const filterParams = reactive({
  enterpriseName: '',
  planName: ''
})

const hasActiveFilters = computed(() => {
  return !!(filterParams.enterpriseName || filterParams.planName)
})

let searchTimer = null

onMounted(() => {
  getList(true)
})

async function getList(isRefresh = false) {
  if (loading.value) return

  loading.value = true
  if (isRefresh) {
    queryParams.pageNum = 1
    loadStatus.value = 'loadmore'
  }

  try {
    const params = { ...queryParams }
    if (filterParams.enterpriseName) params.enterpriseName = filterParams.enterpriseName
    if (filterParams.planName) params.planName = filterParams.planName
    const response = await listPlan(params)
    const data = response.data || response
    const rows = data.rows || []
    const total = data.total || 0

    if (isRefresh) {
      list.value = rows
    } else {
      list.value = [...list.value, ...rows]
    }

    if (list.value.length >= total) {
      loadStatus.value = 'nomore'
    } else {
      loadStatus.value = 'loadmore'
    }
  } catch (e) {
    console.error('获取可备货方案列表失败:', e)
    loadStatus.value = 'error'
  } finally {
    loading.value = false
  }
}

function onSearchInput() {
  if (searchTimer) clearTimeout(searchTimer)
  searchTimer = setTimeout(() => getList(true), 500)
}

function handleSearch() {
  getList(true)
}

function clearKeyword() {
  queryParams.keyword = ''
  getList(true)
}

function clearFilter(field) {
  filterParams[field] = ''
  getList(true)
}

function resetFilter() {
  filterParams.enterpriseName = ''
  filterParams.planName = ''
  getList(true)
}

function confirmFilter() {
  showFilter.value = false
  getList(true)
}

function loadMore() {
  if (loadStatus.value === 'nomore' || loading.value) return
  queryParams.pageNum++
  getList(false)
}

function goPrepare(item) {
  uni.navigateTo({
    url: `/pages/business/plan/prepare?planId=${item.planId}`
  })
}
</script>

<style lang="scss" scoped>
.select-plan-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: #f5f6f7;
}

.search-section {
  flex-shrink: 0;
  padding: 20rpx 24rpx;
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
  height: 100%;
}

.search-placeholder {
  color: #86909C;
  font-size: 28rpx;
}

.clear-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 8rpx;
}

.filter-btn {
  display: flex;
  align-items: center;
  gap: 6rpx;
  background: #E8F0FE;
  border-radius: 28rpx;
  height: 56rpx;
  padding: 0 22rpx;
  font-size: 26rpx;
  color: #3D6DF7;
  font-weight: 500;
  flex-shrink: 0;
}

.icon-rotate {
  transform: rotate(180deg);
  transition: transform 0.3s ease;
}

.active-filters {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
  margin-top: 16rpx;
}

.filter-tag.active {
  display: flex;
  align-items: center;
  gap: 6rpx;
  background: #fff;
  color: #3D6DF7;
  padding: 10rpx 20rpx;
  border-radius: 28rpx;
  font-size: 24rpx;
}

.plan-list {
  flex: 1;
  padding: 20rpx 24rpx;
  padding-bottom: 40rpx;
}

.plan-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 28rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);

  &:active {
    transform: scale(0.98);
    opacity: 0.9;
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
  padding-bottom: 16rpx;
  border-bottom: 1rpx solid #f0f0f0;
  gap: 12rpx;
}

.plan-name {
  flex: 1;
  font-size: 30rpx;
  font-weight: 600;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.plan-amount {
  font-size: 32rpx;
  font-weight: 600;
  color: #3D6DF7;
  flex-shrink: 0;
}

.card-body {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.info-row {
  display: flex;
  align-items: center;
}

.info-row .label {
  width: 80rpx;
  font-size: 26rpx;
  color: #86909C;
  flex-shrink: 0;
}

.info-row .value {
  flex: 1;
  font-size: 26rpx;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.status-tag {
  font-size: 24rpx;
  padding: 4rpx 16rpx;
  border-radius: 6rpx;
}

.status-tag.prepared {
  color: #00B42A;
  background: #E8FFEA;
}

.empty-tip {
  padding: 80rpx 0;
  display: flex;
  justify-content: center;
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
  text-align: center;
}

.form-item {
  margin-bottom: 30rpx;
}

.form-label {
  display: block;
  font-size: 28rpx;
  font-weight: 500;
  color: #1D2129;
  margin-bottom: 16rpx;
}

.form-input {
  width: 100%;
  height: 80rpx;
  background: #F5F7FA;
  border-radius: 8rpx;
  padding: 0 24rpx;
  font-size: 28rpx;
  color: #1D2129;
  box-sizing: border-box;
}

.form-placeholder {
  color: #C9CDD4;
  font-size: 28rpx;
}

.popup-actions {
  display: flex;
  gap: 20rpx;
  margin-top: 40rpx;
  padding-top: 30rpx;
  border-top: 1rpx solid #E5E6EB;
}
</style>
