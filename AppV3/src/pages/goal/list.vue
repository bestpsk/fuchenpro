<template>
  <view class="goal-list-container">
    <!-- 搜索栏 -->
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="queryParams.goalName" placeholder="搜索目标名称" placeholder-class="search-placeholder" confirm-type="search" @confirm="handleSearch" />
        <view v-if="queryParams.goalName" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
        <view class="filter-btn" @click="toggleFilter">
          <text>筛选</text>
          <u-icon name="arrow-down" size="12" :class="{ 'icon-rotate': showFilter }"></u-icon>
        </view>
      </view>
    </view>

    <!-- 活动筛选标签 -->
    <view v-if="hasActiveFilters" class="active-filters">
      <scroll-view scroll-x class="filter-scroll">
        <view class="filter-tags">
          <view v-if="queryParams.ownerType" class="filter-tag active" @click="clearFilter('ownerType')">
            <text>{{ getOwnerTypeLabel(queryParams.ownerType) }}</text><u-icon name="close" size="12"></u-icon>
          </view>
          <view v-if="queryParams.periodType" class="filter-tag active" @click="clearFilter('periodType')">
            <text>{{ getPeriodTypeLabel(queryParams.periodType) }}</text><u-icon name="close" size="12"></u-icon>
          </view>
          <view v-if="queryParams.metricType" class="filter-tag active" @click="clearFilter('metricType')">
            <text>{{ getMetricTypeLabel(queryParams.metricType) }}</text><u-icon name="close" size="12"></u-icon>
          </view>
          <view v-if="queryParams.status !== '' && queryParams.status !== undefined && queryParams.status !== null" class="filter-tag active" @click="clearFilter('status')">
            <text>{{ queryParams.status === '0' ? '启用' : '停用' }}</text><u-icon name="close" size="12"></u-icon>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- 筛选弹窗 -->
    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>

        <view class="form-item">
          <view class="form-label">归属层级</view>
          <view class="form-options">
            <view v-for="item in ownerTypeOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.ownerType === item.value }" @click="setFilter('ownerType', item.value)">{{ item.label }}</view>
          </view>
        </view>

        <view class="form-item">
          <view class="form-label">周期类型</view>
          <view class="form-options">
            <view v-for="item in periodTypeOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.periodType === item.value }" @click="setFilter('periodType', item.value)">{{ item.label }}</view>
          </view>
        </view>

        <view class="form-item">
          <view class="form-label">口径类型</view>
          <view class="form-options">
            <view v-for="item in metricTypeOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.metricType === item.value }" @click="setFilter('metricType', item.value)">{{ item.label }}</view>
          </view>
        </view>

        <view class="form-item">
          <view class="form-label">状态</view>
          <view class="form-options">
            <view class="option-tag" :class="{ active: queryParams.status === '0' }" @click="setFilter('status', '0')">启用</view>
            <view class="option-tag" :class="{ active: queryParams.status === '1' }" @click="setFilter('status', '1')">停用</view>
          </view>
        </view>

        <view class="popup-btns">
          <view class="popup-btn reset" @click="resetFilter">重置</view>
          <view class="popup-btn confirm" @click="confirmFilter">确定</view>
        </view>
      </view>
    </u-popup>

    <!-- 列表 -->
    <view class="list-wrap">
      <view v-if="list.length > 0">
        <view v-for="(item, index) in list" :key="item.goalId" class="goal-card" @click="handleDetail(item)">
          <view class="card-top">
            <text class="goal-name">{{ item.goalName }}</text>
            <view class="status-tag" :class="item.status === '0' ? 'status-active' : 'status-inactive'">
              <text>{{ item.status === '0' ? '启用' : '停用' }}</text>
            </view>
          </view>
          <view class="card-tags">
            <view class="tag tag-owner">{{ getOwnerTypeLabel(item.ownerType) }}</view>
            <view class="tag tag-metric">{{ getMetricTypeLabel(item.metricType) }}</view>
            <view class="tag tag-period">{{ getPeriodTypeLabel(item.periodType) }}</view>
          </view>
          <view class="card-info">
            <view class="info-item">
              <text class="info-label">归属</text>
              <text class="info-value">{{ item.ownerName || '-' }}</text>
            </view>
            <view class="info-item">
              <text class="info-label">周期名称</text>
              <text class="info-value">{{ item.periodName || '-' }}</text>
            </view>
          </view>
          <view class="card-target">
            <view class="target-block">
              <text class="target-label">目标值</text>
              <view class="target-value-row">
                <text class="target-value">{{ formatNumber(item.targetValue) }}</text>
                <text class="target-unit">{{ item.unit }}</text>
              </view>
            </view>
            <view class="date-block">
              <text class="date-text">{{ item.startDate }} ~ {{ item.endDate }}</text>
            </view>
          </view>
          <!-- 卡片底部操作按钮 -->
          <view class="card-footer">
            <text class="footer-time">{{ item.startDate }} ~ {{ item.endDate }}</text>
            <view class="action-btns">
              <view class="action-btn edit" @click.stop="handleEdit(item)">
                <u-icon name="edit-pen" size="14" color="#3D6DF7"></u-icon>
                <text>编辑</text>
              </view>
              <view class="action-btn delete" @click.stop="handleDelete(item)">
                <u-icon name="trash" size="14" color="#F53F3F"></u-icon>
                <text>删除</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <!-- 空状态 -->
      <view v-else-if="!loading" class="empty-state">
        <u-icon name="empty-data" size="80" color="#C9CDD4"></u-icon>
        <text class="empty-text">暂无目标数据</text>
      </view>

      <!-- 加载状态 -->
      <view v-if="loading" class="loading-more">
        <u-icon name="loading" size="16" color="#3D6DF7"></u-icon>
        <text class="loading-text">加载中...</text>
      </view>
      <view v-else-if="list.length > 0 && !hasMore" class="no-more">
        <text>没有更多了</text>
      </view>
    </view>

    <!-- 底部浮动新增按钮 -->
    <view class="fab-btn" @click="handleAdd">
      <u-icon name="plus" size="24" color="#fff"></u-icon>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 目标列表页 - 展示目标管理列表，支持搜索/筛选/新增/编辑/删除
 */
import { ref, reactive, computed } from 'vue'
import { onShow, onReachBottom } from '@dcloudio/uni-app'
import { listGoal, delGoal } from '@/api/goal'

// 字段常量
const ownerTypeOptions = [
  { value: '1', label: '公司' },
  { value: '2', label: '部门' },
  { value: '3', label: '门店' },
  { value: '4', label: '个人' }
]
const periodTypeOptions = [
  { value: '1', label: '年度' },
  { value: '2', label: '季度' },
  { value: '3', label: '月度' },
  { value: '4', label: '自定义' }
]
const metricTypeOptions = [
  { value: '1', label: '实收业绩' },
  { value: '2', label: '消耗业绩' },
  { value: '3', label: '出货金额' },
  { value: '4', label: '品项件数' },
  { value: '5', label: '品项金额' },
  { value: '6', label: '到店客次' },
  { value: '7', label: '新客数' },
  { value: '8', label: '活跃门店数' }
]

const list = ref([])
const loading = ref(false)
const hasMore = ref(true)
const showFilter = ref(false)

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  goalName: '',
  ownerType: '',
  periodType: '',
  metricType: '',
  status: ''
})

const hasActiveFilters = computed(() => {
  return !!(queryParams.ownerType || queryParams.periodType || queryParams.metricType ||
    (queryParams.status !== '' && queryParams.status !== undefined && queryParams.status !== null))
})

function getOwnerTypeLabel(val) {
  const item = ownerTypeOptions.find(o => o.value === String(val))
  return item ? item.label : '-'
}
function getPeriodTypeLabel(val) {
  const item = periodTypeOptions.find(o => o.value === String(val))
  return item ? item.label : '-'
}
function getMetricTypeLabel(val) {
  const item = metricTypeOptions.find(o => o.value === String(val))
  return item ? item.label : '-'
}

function formatNumber(val) {
  if (val === null || val === undefined || val === '') return '0'
  const num = Number(val)
  if (isNaN(num)) return '0'
  return num.toLocaleString('zh-CN')
}

async function loadList(reset = false) {
  if (loading.value) return
  if (reset) {
    queryParams.pageNum = 1
    hasMore.value = true
  }
  if (!hasMore.value) return
  loading.value = true
  try {
    const res = await listGoal(queryParams)
    const rows = res.rows || []
    if (reset) {
      list.value = rows
    } else {
      list.value = [...list.value, ...rows]
    }
    const total = res.total || 0
    hasMore.value = list.value.length < total
  } catch (e) {
    console.error('加载目标列表失败', e)
    if (reset) list.value = []
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  loadList(true)
}

function clearKeyword() {
  queryParams.goalName = ''
  loadList(true)
}

function toggleFilter() {
  showFilter.value = !showFilter.value
}

function setFilter(key, value) {
  if (queryParams[key] === value) {
    queryParams[key] = ''
  } else {
    queryParams[key] = value
  }
}

function clearFilter(key) {
  queryParams[key] = ''
  loadList(true)
}

function resetFilter() {
  queryParams.ownerType = ''
  queryParams.periodType = ''
  queryParams.metricType = ''
  queryParams.status = ''
}

function confirmFilter() {
  showFilter.value = false
  loadList(true)
}

function handleDetail(item) {
  uni.navigateTo({ url: '/pages/goal/detail?goalId=' + item.goalId })
}

function handleAdd() {
  uni.navigateTo({ url: '/pages/goal/form' })
}

function handleEdit(item) {
  uni.navigateTo({ url: '/pages/goal/form?goalId=' + item.goalId })
}

function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: '是否确认删除目标"' + item.goalName + '"？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await delGoal(item.goalId)
          uni.showToast({ title: '删除成功', icon: 'success' })
          loadList(true)
        } catch (e) {
          console.error('删除失败', e)
        }
      }
    }
  })
}

onShow(() => {
  loadList(true)
})

onReachBottom(() => {
  if (hasMore.value && !loading.value) {
    queryParams.pageNum++
    loadList()
  }
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
}

.goal-list-container {
  min-height: 100vh;
  padding-bottom: 120rpx;
}

/* 搜索栏 */
.search-section {
  padding: 16rpx 24rpx;
  background: #fff;
  position: sticky;
  top: 0;
  z-index: 10;
}

.search-box {
  display: flex;
  align-items: center;
  background: #F5F7FA;
  border-radius: 32rpx;
  padding: 12rpx 24rpx;
  gap: 12rpx;
}

.search-input {
  flex: 1;
  font-size: 26rpx;
  color: #1D2129;
}

.search-placeholder {
  color: #C9CDD4;
  font-size: 26rpx;
}

.clear-btn {
  display: flex;
  align-items: center;
}

.filter-btn {
  display: flex;
  align-items: center;
  gap: 4rpx;
  font-size: 24rpx;
  color: #3D6DF7;
  padding-left: 16rpx;
  border-left: 1rpx solid #E5E6EB;
}

.icon-rotate {
  transform: rotate(180deg);
  transition: transform 0.2s;
}

/* 活动筛选标签 */
.active-filters {
  padding: 12rpx 24rpx;
  background: #fff;
}

.filter-scroll {
  white-space: nowrap;
}

.filter-tags {
  display: inline-flex;
  gap: 12rpx;
}

.filter-tag {
  display: inline-flex;
  align-items: center;
  gap: 6rpx;
  background: #E8F0FE;
  color: #3D6DF7;
  font-size: 22rpx;
  padding: 6rpx 16rpx;
  border-radius: 20rpx;
}

/* 筛选弹窗 */
.popup-content {
  padding: 32rpx 24rpx;
  max-height: 70vh;
  overflow-y: auto;
}

.popup-title {
  font-size: 30rpx;
  font-weight: 700;
  color: #1D2129;
  margin-bottom: 24rpx;
}

.form-item {
  margin-bottom: 28rpx;
}

.form-label {
  font-size: 26rpx;
  color: #4E5969;
  margin-bottom: 12rpx;
}

.form-options {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.option-tag {
  font-size: 24rpx;
  color: #4E5969;
  background: #F5F7FA;
  padding: 10rpx 24rpx;
  border-radius: 8rpx;
  border: 1rpx solid transparent;

  &.active {
    color: #3D6DF7;
    background: #E8F0FE;
    border-color: #3D6DF7;
  }
}

.popup-btns {
  display: flex;
  gap: 24rpx;
  margin-top: 32rpx;
}

.popup-btn {
  flex: 1;
  text-align: center;
  padding: 20rpx 0;
  border-radius: 12rpx;
  font-size: 28rpx;

  &.reset {
    background: #F5F7FA;
    color: #4E5969;
  }

  &.confirm {
    background: #3D6DF7;
    color: #fff;
  }
}

/* 列表 */
.list-wrap {
  padding: 16rpx 24rpx;
}

.goal-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.card-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16rpx;
  gap: 12rpx;
}

.goal-name {
  flex: 1;
  font-size: 30rpx;
  font-weight: 600;
  color: #1D2129;
  line-height: 1.4;
}

.status-tag {
  padding: 4rpx 12rpx;
  border-radius: 6rpx;
  font-size: 22rpx;
  flex-shrink: 0;

  &.status-active {
    background: rgba(82, 196, 26, 0.1);
    color: #52c41a;
  }

  &.status-inactive {
    background: rgba(193, 197, 204, 0.2);
    color: #909399;
  }
}

.card-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8rpx;
  margin-bottom: 16rpx;
}

.tag {
  font-size: 20rpx;
  padding: 4rpx 12rpx;
  border-radius: 4rpx;

  &.tag-owner {
    background: rgba(61, 109, 247, 0.08);
    color: #3D6DF7;
  }

  &.tag-metric {
    background: rgba(230, 162, 60, 0.1);
    color: #e6a23c;
  }

  &.tag-period {
    background: rgba(103, 194, 58, 0.1);
    color: #67c23a;
  }
}

.card-info {
  display: flex;
  gap: 32rpx;
  margin-bottom: 16rpx;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.info-label {
  font-size: 22rpx;
  color: #86909C;
}

.info-value {
  font-size: 26rpx;
  color: #4E5969;
  max-width: 200rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.card-target {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  padding-top: 16rpx;
  border-top: 1rpx solid #F0F0F0;
}

.target-block {
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.target-label {
  font-size: 22rpx;
  color: #86909C;
}

.target-value-row {
  display: flex;
  align-items: baseline;
  gap: 4rpx;
}

.target-value {
  font-size: 34rpx;
  font-weight: 700;
  color: #3D6DF7;
}

.target-unit {
  font-size: 22rpx;
  color: #86909C;
}

.date-block {
  text-align: right;
}

.date-text {
  font-size: 22rpx;
  color: #86909C;
}

/* 卡片底部操作按钮 */
.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16rpx;
  padding-top: 16rpx;
  border-top: 1rpx solid #F0F0F0;
}

.footer-time {
  font-size: 22rpx;
  color: #C9CDD4;
}

.action-btns {
  display: flex;
  gap: 16rpx;
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

/* 空状态 */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 120rpx 0;
  gap: 16rpx;
}

.empty-text {
  font-size: 28rpx;
  color: #86909C;
}

/* 加载状态 */
.loading-more,
.no-more {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 24rpx;
  gap: 8rpx;
  font-size: 24rpx;
  color: #86909C;
}

/* 浮动新增按钮 */
.fab-btn {
  position: fixed;
  right: 40rpx;
  bottom: 60rpx;
  width: 100rpx;
  height: 100rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, #3D6DF7 0%, #5B8FF9 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 24rpx rgba(61, 109, 247, 0.4);
  z-index: 100;
}
</style>
