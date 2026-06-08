<template>
  <view class="operlog-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.keyword"
          placeholder="搜索系统模块/操作人员"
          placeholder-class="search-placeholder"
          confirm-type="search"
          @input="onSearchInput"
          @confirm="handleSearch"
        />
        <view v-if="queryParams.keyword" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
        <view class="filter-btn" :class="{ active: hasActiveFilters }" @click="toggleFilter">
          <u-icon name="list" size="12" :color="hasActiveFilters ? '#3D6DF7' : '#4E5969'"></u-icon>
          <text>筛选</text>
        </view>
      </view>
    </view>

    <view v-if="hasActiveFilters" class="active-filters">
      <scroll-view scroll-x class="filter-scroll">
        <view class="filter-tags">
          <view
            v-if="queryParams.businessType !== '' && queryParams.businessType !== undefined"
            class="filter-tag active"
            @click="clearFilter('businessType')"
          >
            <text>{{ getOperTypeLabel(queryParams.businessType) }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
          <view
            v-if="queryParams.status !== '' && queryParams.status !== undefined"
            class="filter-tag active"
            @click="clearFilter('status')"
          >
            <text>{{ queryParams.status === '0' ? '成功' : '失败' }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
          <view
            v-if="queryParams.beginTime"
            class="filter-tag active"
            @click="clearFilter('date')"
          >
            <text>{{ queryParams.beginTime }} ~ {{ queryParams.endTime }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
        </view>
      </scroll-view>
    </view>

    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <view class="form-label">操作类型</view>
          <view class="form-options">
            <view
              v-for="item in operTypeOptions"
              :key="item.dictValue"
              class="option-tag"
              :class="{ active: queryParams.businessType === item.dictValue }"
              @click="queryParams.businessType = queryParams.businessType === item.dictValue ? '' : item.dictValue"
            >{{ item.dictLabel }}</view>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">操作状态</view>
          <view class="form-options">
            <view
              class="option-tag"
              :class="{ active: queryParams.status === '0' }"
              @click="queryParams.status = queryParams.status === '0' ? '' : '0'"
            >成功</view>
            <view
              class="option-tag"
              :class="{ active: queryParams.status === '1' }"
              @click="queryParams.status = queryParams.status === '1' ? '' : '1'"
            >失败</view>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">操作日期</view>
          <view class="date-range">
            <view class="date-input" @click="showStartDatePicker = true">
              <text :class="{ 'date-placeholder': !queryParams.beginTime }">{{ queryParams.beginTime || '开始日期' }}</text>
            </view>
            <text class="date-separator">~</text>
            <view class="date-input" @click="showEndDatePicker = true">
              <text :class="{ 'date-placeholder': !queryParams.endTime }">{{ queryParams.endTime || '结束日期' }}</text>
            </view>
          </view>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
      </view>
    </u-popup>

    <u-datetime-picker
      :show="showStartDatePicker"
      mode="date"
      @confirm="onStartDateConfirm"
      @cancel="showStartDatePicker = false"
    ></u-datetime-picker>
    <u-datetime-picker
      :show="showEndDatePicker"
      mode="date"
      @confirm="onEndDateConfirm"
      @cancel="showEndDatePicker = false"
    ></u-datetime-picker>

    <scroll-view
      scroll-y
      class="list-scroll"
      @scrolltolower="loadMore"
      refresher-enabled
      :refresher-triggered="refreshing"
      @refresherrefresh="onPullDownRefresh"
    >
      <view v-if="dataList.length > 0" class="card-list">
        <view
          v-for="item in dataList"
          :key="item.operId"
          class="log-card"
          @click="goDetail(item)"
        >
          <view class="card-header">
            <view class="module-name">
              <u-icon name="file-text" size="16" color="#3D6DF7"></u-icon>
              <text class="name-text">{{ item.title || '-' }}</text>
            </view>
            <view class="status-tag" :class="item.status === 0 ? 'status-success' : 'status-fail'">
              {{ item.status === 0 ? '成功' : '失败' }}
            </view>
          </view>

          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="label">操作类型</text>
                <text class="value">{{ getOperTypeLabel(String(item.businessType)) }}</text>
              </view>
              <view class="info-item">
                <text class="label">操作人员</text>
                <text class="value">{{ item.operName || '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">操作地址</text>
                <text class="value">{{ item.operIp || '-' }}</text>
              </view>
              <view class="info-item">
                <text class="label">消耗时间</text>
                <text class="value">{{ item.costTime != null ? item.costTime + 'ms' : '-' }}</text>
              </view>
            </view>
          </view>

          <view class="card-footer">
            <text class="time-text">{{ formatTime(item.operTime) }}</text>
            <view class="action-btns">
              <view v-if="checkPermi('monitor:operlog:remove')" class="action-btn delete" @click.stop="handleDelete(item)">
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
        text="暂无操作日志"
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

    <view v-if="selectedIds.length > 0 && checkPermi('monitor:operlog:remove')" class="batch-bar">
      <text class="batch-text">已选 {{ selectedIds.length }} 项</text>
      <view class="batch-btns">
        <u-button type="error" size="small" text="删除选中" @click="handleBatchDelete" customStyle="height:64rpx; border-radius:32rpx;"></u-button>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { listOperlog, delOperlog, cleanOperlog } from '@/api/monitor/operlog'
import { getDicts } from '@/api/system/dictData'
import { checkPermi } from '@/utils/permission'

const dataList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)
const showStartDatePicker = ref(false)
const showEndDatePicker = ref(false)
const selectedIds = ref([])

let searchTimer = null

const operTypeOptions = ref([])

const hasActiveFilters = computed(() => {
  return (queryParams.businessType !== '' && queryParams.businessType !== undefined) ||
    (queryParams.status !== '' && queryParams.status !== undefined) ||
    queryParams.beginTime
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: '',
  title: '',
  operName: '',
  businessType: '',
  status: '',
  beginTime: '',
  endTime: ''
})

async function loadDicts() {
  try {
    const [operTypeRes] = await Promise.all([
      getDicts('sys_oper_type')
    ])
    operTypeOptions.value = operTypeRes.data || []
  } catch (e) {
    console.error('获取字典失败:', e)
  }
}

function getOperTypeLabel(value) {
  const item = operTypeOptions.value.find(o => o.dictValue === String(value))
  return item ? item.dictLabel : '其他'
}

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
      params.title = params.keyword
      params.operName = params.keyword
    }
    delete params.keyword
    const response = await listOperlog(params)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0
    dataList.value = isRefresh ? list : [...dataList.value, ...list]
    loadStatus.value = dataList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) {
    console.error('获取操作日志列表失败:', e)
    loadStatus.value = 'error'
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

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

function onSearchInput() {
  if (searchTimer) clearTimeout(searchTimer)
  searchTimer = setTimeout(() => handleSearch(), 500)
}

function clearKeyword() {
  queryParams.keyword = ''
  handleSearch()
}

function toggleFilter() {
  showFilter.value = !showFilter.value
}

function resetFilter() {
  queryParams.businessType = ''
  queryParams.status = ''
  queryParams.beginTime = ''
  queryParams.endTime = ''
}

function confirmFilter() {
  showFilter.value = false
  getList(true)
}

function clearFilter(field) {
  if (field === 'businessType') {
    queryParams.businessType = ''
  } else if (field === 'status') {
    queryParams.status = ''
  } else if (field === 'date') {
    queryParams.beginTime = ''
    queryParams.endTime = ''
  }
  getList(true)
}

function onStartDateConfirm(e) {
  const date = new Date(e.value)
  queryParams.beginTime = formatDate(date)
  showStartDatePicker.value = false
}

function onEndDateConfirm(e) {
  const date = new Date(e.value)
  queryParams.endTime = formatDate(date)
  showEndDatePicker.value = false
}

function formatDate(date) {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

function goDetail(item) {
  uni.navigateTo({ url: `/pages/monitor/operlog/detail?operId=${item.operId}` })
}

function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: '是否确认删除该操作日志?',
    success: async (res) => {
      if (res.confirm) {
        try {
          await delOperlog(item.operId)
          uni.showToast({ title: '删除成功', icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('删除失败:', e)
        }
      }
    }
  })
}

function handleBatchDelete() {
  uni.showModal({
    title: '提示',
    content: `是否确认删除选中的${selectedIds.value.length}条操作日志?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delOperlog(selectedIds.value.join(','))
          selectedIds.value = []
          uni.showToast({ title: '删除成功', icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('删除失败:', e)
        }
      }
    }
  })
}

function formatTime(time) {
  if (!time) return ''
  return String(time).substring(0, 16)
}

onMounted(() => {
  loadDicts()
  getList(true)
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.operlog-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx;
  :deep(.u-popup) { flex: none !important; }
}

.search-section {
  flex-shrink: 0;
  padding: 20rpx 24rpx; margin-left: -24rpx; margin-right: -24rpx;
  background: linear-gradient(180deg, #3D6DF7 0%, #4A7AEF 100%);
}
.search-box {
  display: flex; align-items: center; background: #fff; border-radius: 36rpx;
  padding: 0 8rpx 0 28rpx; height: 72rpx; gap: 12rpx; box-sizing: border-box;
}
.search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; min-width: 0; }
.search-placeholder { color: #86909C; font-size: 28rpx; }
.clear-btn { flex-shrink: 0; padding: 8rpx; display: flex; align-items: center; }
.filter-btn {
  flex-shrink: 0; display: flex; align-items: center; justify-content: center;
  gap: 6rpx; height: 56rpx; padding: 0 22rpx; background: #E8F0FE; border-radius: 28rpx;
  transition: all 0.2s;
  text { font-size: 26rpx; color: #3D6DF7; font-weight: 500; white-space: nowrap; }
  &.active { background: #fff;
    text { color: #3D6DF7; }
  }
}

.active-filters {
  flex-shrink: 0;
  padding: 12rpx 24rpx 16rpx; margin-left: -24rpx; margin-right: -24rpx;
  background: linear-gradient(180deg, #4A7AEF 0%, #F5F7FA 100%);
}
.filter-scroll { white-space: nowrap; }
.filter-tags { display: inline-flex; gap: 16rpx; padding: 16rpx 0; }
.filter-tag {
  display: inline-flex; align-items: center; gap: 8rpx; padding: 10rpx 20rpx;
  background: rgba(255, 255, 255, 0.2); border-radius: 28rpx; font-size: 24rpx; color: #fff;
  &.active { background: #fff; color: #3D6DF7; }
}

.popup-content { padding: 30rpx; background: #fff; }
.popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; margin-bottom: 30rpx; }
.form-item { margin-bottom: 30rpx; }
.form-label { font-size: 28rpx; color: #1D2129; font-weight: 500; margin-bottom: 16rpx; }
.form-options { display: flex; flex-wrap: wrap; gap: 16rpx; }
.option-tag {
  padding: 14rpx 28rpx; background: #F5F7FA; border-radius: 8rpx; font-size: 26rpx;
  color: #4E5969; border: 2rpx solid transparent; transition: all 0.2s;
  &.active { background: #E8F0FE; color: #3D6DF7; border-color: #3D6DF7; }
}
.date-range { display: flex; align-items: center; gap: 16rpx; }
.date-input {
  flex: 1; padding: 20rpx 24rpx; background: #F5F7FA; border-radius: 8rpx;
  text { font-size: 26rpx; color: #1D2129; }
  .date-placeholder { color: #C9CDD4; }
}
.date-separator { font-size: 26rpx; color: #86909C; }
.popup-actions {
  display: flex; gap: 20rpx; margin-top: 40rpx; padding-top: 30rpx; border-top: 1rpx solid #E5E6EB;
  .u-button { flex: 1; }
}

.list-scroll { flex: 1; overflow: hidden; padding: 20rpx 0; }
.card-list { display: flex; flex-direction: column; gap: 20rpx; }
.log-card {
  background: #fff; border-radius: 16rpx; padding: 28rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
  &:active { transform: scale(0.98); opacity: 0.9; }
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.module-name {
  display: flex; align-items: center; gap: 12rpx; flex: 1; min-width: 0;
  .name-text { font-size: 30rpx; font-weight: 600; color: #1D2129; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
}
.status-tag {
  padding: 6rpx 16rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-success { background: #E8FFEA; color: #00B42A; }
  &.status-fail { background: #FFF1F0; color: #F53F3F; }
}
.card-body { padding: 20rpx 0; border-top: 1rpx solid #F2F3F5; border-bottom: 1rpx solid #F2F3F5; }
.info-row { display: flex; margin-bottom: 16rpx; &:last-child { margin-bottom: 0; } }
.info-item {
  flex: 1; display: flex; align-items: center; gap: 12rpx;
  .label { font-size: 24rpx; color: #86909C; min-width: 80rpx; }
  .value { font-size: 26rpx; color: #1D2129; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
}
.card-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 20rpx; }
.time-text { font-size: 22rpx; color: #C9CDD4; }
.action-btns { display: flex; gap: 16rpx; }
.action-btn {
  display: flex; align-items: center; gap: 6rpx; font-size: 24rpx;
  padding: 8rpx 14rpx; border-radius: 8rpx;
  &.delete { color: #F53F3F; background: #FFF1F0; }
}

.batch-bar {
  position: fixed; left: 0; right: 0; bottom: 0; display: flex; align-items: center;
  justify-content: space-between; padding: 20rpx 30rpx; background: #fff;
  box-shadow: 0 -4rpx 16rpx rgba(0, 0, 0, 0.08); z-index: 100;
}
.batch-text { font-size: 28rpx; color: #1D2129; }
.batch-btns { display: flex; gap: 16rpx; }
</style>
