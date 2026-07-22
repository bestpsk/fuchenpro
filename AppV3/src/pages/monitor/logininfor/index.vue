<template>
  <view class="logininfor-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.keyword"
          placeholder="搜索用户名/IP地址"
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
            v-if="queryParams.status !== '' && queryParams.status !== undefined"
            class="filter-tag active"
            @click="clearFilter('status')"
          >
            <text>{{ queryParams.status === '0' ? '成功' : '失败' }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
          <view
            v-if="queryParams.loginSource"
            class="filter-tag active"
            @click="clearFilter('loginSource')"
          >
            <text>{{ queryParams.loginSource === 'app' ? 'App端' : 'Web端' }}</text>
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
          <view class="form-label">登录状态</view>
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
          <view class="form-label">登录来源</view>
          <view class="form-options">
            <view
              class="option-tag"
              :class="{ active: queryParams.loginSource === 'web' }"
              @click="queryParams.loginSource = queryParams.loginSource === 'web' ? '' : 'web'"
            >Web端</view>
            <view
              class="option-tag"
              :class="{ active: queryParams.loginSource === 'app' }"
              @click="queryParams.loginSource = queryParams.loginSource === 'app' ? '' : 'app'"
            >App端</view>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">登录日期</view>
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
          :key="item.infoId"
          class="log-card"
        >
          <view class="card-header">
            <view class="user-name">
              <u-icon name="account-fill" size="18" color="#3D6DF7"></u-icon>
              <text class="name-text">{{ item.userName || '-' }}</text>
            </view>
            <view class="status-tag" :class="item.status === '0' ? 'status-success' : 'status-fail'">
              {{ item.status === '0' ? '成功' : '失败' }}
            </view>
          </view>

          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="label">登录地址</text>
                <text class="value">{{ item.ipaddr || '-' }}</text>
              </view>
              <view class="info-item">
                <text class="label">登录地点</text>
                <text class="value">{{ item.loginLocation || '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">操作系统</text>
                <text class="value">{{ item.os || '-' }}</text>
              </view>
              <view class="info-item">
                <text class="label">浏览器</text>
                <text class="value">{{ item.browser || '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item full-width">
                <text class="label">描述</text>
                <text class="value">{{ item.msg || '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">登录来源</text>
                <text class="value">{{ item.loginSource === 'app' ? 'App端' : 'Web端' }}</text>
              </view>
            </view>
          </view>

          <view class="card-footer">
            <text class="time-text">{{ formatTime(item.loginTime) }}</text>
            <view class="action-btns">
              <view v-if="checkPermi('monitor:logininfor:remove')" class="action-btn delete" @click.stop="handleDelete(item)">
                <u-icon name="trash" size="14"></u-icon>
                <text>删除</text>
              </view>
              <view v-if="checkPermi('monitor:logininfor:unlock')" class="action-btn unlock" @click.stop="handleUnlock(item)">
                <u-icon name="lock" size="14"></u-icon>
                <text>解锁</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <u-empty
        v-else-if="!loading"
        mode="data"
        text="暂无登录日志"
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
    <view v-if="checkPermi('monitor:logininfor:remove')" class="clean-bar">
      <u-button type="error" plain text="清空日志" @click="handleClean" customStyle="height:72rpx; border-radius:36rpx;"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, computed, onUnmounted } from 'vue'
import { listLogininfor, delLogininfor, cleanLogininfor, unlockLogininfor } from '@/api/monitor/logininfor'
import { checkPermi } from '@/utils/permission'

const dataList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)
const showStartDatePicker = ref(false)
const showEndDatePicker = ref(false)

let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const hasActiveFilters = computed(() => {
  return (queryParams.status !== '' && queryParams.status !== undefined) || queryParams.loginSource || queryParams.beginTime
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: '',
  userName: '',
  ipaddr: '',
  status: '',
  loginSource: '',
  beginTime: '',
  endTime: ''
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
    // keyword 由后端 OR 查询 user_name/ipaddr，无需前端拆分
    delete params.userName
    delete params.ipaddr
    const response = await listLogininfor(params)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0
    dataList.value = isRefresh ? list : [...dataList.value, ...list]
    loadStatus.value = dataList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) {
    console.error('获取登录日志列表失败:', e)
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
  queryParams.status = ''
  queryParams.loginSource = ''
  queryParams.beginTime = ''
  queryParams.endTime = ''
}

function confirmFilter() {
  showFilter.value = false
  getList(true)
}

function clearFilter(field) {
  if (field === 'status') {
    queryParams.status = ''
  } else if (field === 'loginSource') {
    queryParams.loginSource = ''
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

function formatTime(time) {
  if (!time) return ''
  return String(time).substring(0, 16)
}

function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: '是否确认删除该登录日志?',
    success: async (res) => {
      if (res.confirm) {
        try {
          await delLogininfor(item.infoId)
          uni.showToast({ title: '删除成功', icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('删除失败:', e)
        }
      }
    }
  })
}

function handleClean() {
  uni.showModal({
    title: '提示',
    content: '是否确认清空所有登录日志?',
    success: async (res) => {
      if (res.confirm) {
        try {
          await cleanLogininfor()
          uni.showToast({ title: '清空成功', icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('清空失败:', e)
        }
      }
    }
  })
}

function handleUnlock(item) {
  uni.showModal({
    title: '提示',
    content: `是否确认解锁用户"${item.userName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await unlockLogininfor(item.userName)
          uni.showToast({ title: '解锁成功', icon: 'success' })
        } catch (e) {
          console.error('解锁失败:', e)
        }
      }
    }
  })
}

onMounted(() => {
  getList(true)
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.logininfor-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx;
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
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.user-name {
  display: flex; align-items: center; gap: 12rpx;
  .name-text { font-size: 30rpx; font-weight: 600; color: #1D2129; }
}
.status-tag {
  padding: 6rpx 16rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500;
  &.status-success { background: #E8FFEA; color: #00B42A; }
  &.status-fail { background: #FFF1F0; color: #F53F3F; }
}
.card-body { padding: 20rpx 0; border-top: 1rpx solid #F2F3F5; border-bottom: 1rpx solid #F2F3F5; }
.info-row { display: flex; margin-bottom: 16rpx; &:last-child { margin-bottom: 0; } }
.info-item {
  flex: 1; display: flex; align-items: center; gap: 12rpx;
  &.full-width { flex-basis: 100%; }
  .label { font-size: 24rpx; color: #86909C; min-width: 80rpx; }
  .value { font-size: 26rpx; color: #1D2129; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
}
.card-footer { margin-top: 20rpx; display: flex; justify-content: space-between; align-items: center; }
.time-text { font-size: 22rpx; color: #C9CDD4; }
.action-btns { display: flex; gap: 16rpx; }
.action-btn {
  display: flex; align-items: center; gap: 6rpx; font-size: 24rpx;
  padding: 8rpx 14rpx; border-radius: 8rpx;
  &.delete { color: #F53F3F; background: #FFF1F0; }
  &.unlock { color: #3D6DF7; background: #E8F0FE; }
}
.clean-bar {
  flex-shrink: 0; padding: 20rpx 30rpx; background: #fff;
  box-shadow: 0 -4rpx 16rpx rgba(0, 0, 0, 0.08);
}
</style>
