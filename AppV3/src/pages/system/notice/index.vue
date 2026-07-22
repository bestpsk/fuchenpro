<template>
  <view class="notice-container">
    <view class="top-bar">
      <view class="top-bar-inner">
        <view class="search-wrap">
          <u-icon name="search" size="16" color="#86909C"></u-icon>
          <input class="search-input" v-model="queryParams.noticeTitle" placeholder="搜索公告标题" confirm-type="search" @confirm="handleSearch" />
          <u-icon v-if="queryParams.noticeTitle" name="close-circle-fill" size="16" color="#C9CDD4" @click="clearSearch"></u-icon>
        </view>
        <view class="filter-btn" :class="{ active: hasActiveFilters }" @click="showFilter = true">
          <u-icon name="list" size="14" :color="hasActiveFilters ? '#3D6DF7' : '#4E5969'"></u-icon>
          <text>筛选</text>
        </view>
        <view v-if="noticeList.length > 0" class="mark-all-btn" @click="handleMarkAllRead">
          <u-icon name="checkmark" size="14" color="#3D6DF7"></u-icon>
          <text>全部已读</text>
        </view>
      </view>
    </view>

    <view v-if="hasActiveFilters" class="active-filters">
      <scroll-view scroll-x class="filter-scroll">
        <view class="filter-tags">
          <view v-if="queryParams.noticeType" class="filter-tag active" @click="clearFilter('noticeType')">
            <text>{{ getNoticeTypeLabel(queryParams.noticeType) }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
          <view v-if="queryParams.createBy" class="filter-tag active" @click="clearFilter('createBy')">
            <text>{{ queryParams.createBy }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
        </view>
      </scroll-view>
    </view>

    <u-popup :show="showFilter" mode="top" round="16" @close="showFilter = false">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <view class="form-label">公告类型</view>
          <view class="form-options">
            <view
              v-for="item in noticeTypeOptions"
              :key="item.dictValue"
              class="option-tag"
              :class="{ active: queryParams.noticeType === item.dictValue }"
              @click="queryParams.noticeType = queryParams.noticeType === item.dictValue ? '' : item.dictValue"
            >{{ item.dictLabel }}</view>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">操作人员</view>
          <input class="form-input" v-model="queryParams.createBy" placeholder="请输入操作人员" />
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
      </view>
    </u-popup>

    <scroll-view scroll-y class="list-scroll" :style="{ height: scrollHeight + 'px' }" @scrolltolower="loadMore" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onPullDownRefresh">
      <view v-if="noticeList.length > 0" class="card-list">
        <view v-for="item in noticeList" :key="item.noticeId" class="notice-card" :class="{ 'is-read': item.isRead }" @click="goDetail(item)">
          <view class="card-header">
            <view class="type-tag" :class="'type-' + item.noticeType">{{ item.noticeType === '1' ? '通知' : '公告' }}</view>
            <text class="card-time">{{ formatTime(item.createTime) }}</text>
          </view>
          <view class="card-body">
            <text class="card-title">{{ item.noticeTitle }}</text>
          </view>
          <view class="card-footer">
            <view class="status-wrap">
              <text v-if="item.status === '1'" class="status-text status-disabled">已关闭</text>
              <text v-else class="status-text status-normal">正常</text>
            </view>
            <view class="action-btns">
              <view v-if="checkPermi('system:notice:edit')" class="action-btn edit" @click.stop="goEdit(item)">
                <u-icon name="edit-pen" size="14"></u-icon>
                <text>编辑</text>
              </view>
              <view v-if="checkPermi('system:notice:remove')" class="action-btn delete" @click.stop="handleDelete(item)">
                <u-icon name="trash" size="14"></u-icon>
                <text>删除</text>
              </view>
              <view v-if="checkPermi('system:notice:list')" class="action-btn read-users" @click.stop="goReadUsers(item)">
                <u-icon name="account" size="14"></u-icon>
                <text>已读</text>
              </view>
              <view v-if="checkPermi('system:notice:edit')" class="action-btn switch-btn" @click.stop>
                <u-switch v-model="item._statusOn" size="18" activeColor="#3D6DF7" inactiveColor="#C9CDD4" @change="handleStatusChange(item)"></u-switch>
              </view>
            </view>
          </view>
          <view v-if="!item.isRead" class="unread-dot"></view>
        </view>
      </view>
      <u-empty v-else-if="!loading" mode="data" text="暂无通知公告" :marginTop="100"></u-empty>
      <u-loadmore :status="loadStatus" :loading-text="'加载中...'" :loadmore-text="'上拉加载更多'" :nomore-text="'没有更多了'" :marginTop="20" />
    </scroll-view>

    <view v-if="checkPermi('system:notice:add')" class="fab-btn" @click="goAdd">
      <u-icon name="plus" size="24" color="#fff"></u-icon>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listNotice, delNotice, updateNotice, markNoticeReadAll } from '@/api/system/notice'
import { getDicts } from '@/api/system/dictData'
import { checkPermi } from '@/utils/permission'

const noticeList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const scrollHeight = ref(600)
const showFilter = ref(false)
const noticeTypeOptions = ref([])

const queryParams = reactive({ pageNum: 1, pageSize: 10, noticeTitle: '', noticeType: '', createBy: '' })

const hasActiveFilters = computed(() => {
  return !!(queryParams.noticeType || queryParams.createBy)
})

function getNoticeTypeLabel(value) {
  const item = noticeTypeOptions.value.find(d => d.dictValue === value)
  return item ? item.dictLabel : value
}

function clearFilter(field) {
  queryParams[field] = ''
  getList(true)
}

function resetFilter() {
  queryParams.noticeType = ''
  queryParams.createBy = ''
  getList(true)
}

function confirmFilter() {
  showFilter.value = false
  getList(true)
}

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) { queryParams.pageNum = 1; loadStatus.value = 'loadmore' }
  try {
    const response = await listNotice(queryParams)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0
    noticeList.value = isRefresh ? list.map(item => ({ ...item, _statusOn: item.status === '0' })) : [...noticeList.value, ...list.map(item => ({ ...item, _statusOn: item.status === '0' }))]
    loadStatus.value = noticeList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) {
    console.error('获取通知列表失败:', e)
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

function handleMarkAllRead() {
  markNoticeReadAll().then(() => {
    noticeList.value = noticeList.value.map(item => ({ ...item, isRead: true }))
    uni.showToast({ title: '已全部标记为已读', icon: 'success' })
  }).catch(() => {})
}

function handleSearch() {
  getList(true)
}

function clearSearch() {
  queryParams.noticeTitle = ''
  getList(true)
}

function goDetail(item) {
  uni.navigateTo({ url: `/pages/system/notice/detail?noticeId=${item.noticeId}` })
}

function goAdd() {
  uni.navigateTo({ url: '/pages/system/notice/form?mode=add' })
}

function goEdit(item) {
  uni.navigateTo({ url: `/pages/system/notice/form?mode=edit&id=${item.noticeId}` })
}

function goReadUsers(item) {
  uni.navigateTo({ url: `/pages/system/notice/readUsers?noticeId=${item.noticeId}` })
}

function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: `是否确认删除公告"${item.noticeTitle}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delNotice(item.noticeId)
          uni.showToast({ title: '删除成功', icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('删除失败:', e)
        }
      }
    }
  })
}

async function handleStatusChange(item) {
  const newStatus = item._statusOn ? '0' : '1'
  const text = newStatus === '0' ? '启用' : '关闭'
  try {
    await updateNotice({ noticeId: item.noticeId, status: newStatus })
    item.status = newStatus
    uni.showToast({ title: `${text}成功`, icon: 'success' })
  } catch (e) {
    console.error('状态变更失败:', e)
    item._statusOn = !item._statusOn
  }
}

function formatTime(time) {
  if (!time) return ''
  return time.substring(0, 10)
}

function calcScrollHeight() {
  const systemInfo = uni.getSystemInfoSync()
  scrollHeight.value = systemInfo.windowHeight - 60
}

onMounted(() => {
  calcScrollHeight()
  loadDicts()
  getList(true)
})

async function loadDicts() {
  try {
    const res = await getDicts('sys_notice_type')
    noticeTypeOptions.value = res.data || []
  } catch (e) {
    console.error('获取字典失败:', e)
  }
}

onShow(() => {
  getList(true)
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.notice-container { display: flex; flex-direction: column; min-height: 100vh;
  :deep(.u-popup) { flex: none !important; }
}

.top-bar { background: #fff; padding: 20rpx 30rpx; border-bottom: 1rpx solid #F2F3F5; flex-shrink: 0; }
.top-bar-inner { display: flex; justify-content: space-between; align-items: center; }
.search-wrap {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12rpx;
  background: #F2F3F5;
  border-radius: 28rpx;
  padding: 12rpx 24rpx;
  margin-right: 20rpx;
}
.search-input {
  flex: 1;
  font-size: 26rpx;
  color: #1D2129;
  height: 36rpx;
  line-height: 36rpx;
}
.mark-all-btn { display: flex; align-items: center; gap: 6rpx; padding: 10rpx 20rpx; background: #E8F0FE; border-radius: 28rpx; margin-left: 12rpx;
  text { font-size: 24rpx; color: #3D6DF7; font-weight: 500; }
  &:active { opacity: 0.7; }
}
.filter-btn { display: flex; align-items: center; gap: 6rpx; padding: 10rpx 20rpx; background: #F2F3F5; border-radius: 28rpx; flex-shrink: 0;
  text { font-size: 24rpx; color: #4E5969; }
  &.active { background: #E8F0FE;
    text { color: #3D6DF7; }
  }
}

.active-filters { padding: 16rpx 30rpx 0; flex-shrink: 0; }
.filter-scroll { white-space: nowrap; }
.filter-tags { display: inline-flex; gap: 12rpx; }
.filter-tag { display: inline-flex; align-items: center; gap: 6rpx; padding: 8rpx 20rpx; background: #E8F0FE; border-radius: 24rpx; flex-shrink: 0;
  text { font-size: 24rpx; color: #3D6DF7; }
}

.popup-content { padding: 30rpx; }
.popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; margin-bottom: 30rpx; }
.form-item { margin-bottom: 30rpx; }
.form-label { font-size: 28rpx; color: #4E5969; margin-bottom: 16rpx; }
.form-options { display: flex; flex-wrap: wrap; gap: 16rpx; }
.option-tag { padding: 12rpx 32rpx; background: #F2F3F5; border-radius: 8rpx; font-size: 26rpx; color: #4E5969;
  &.active { background: #3D6DF7; color: #fff; }
}
.form-input { width: 100%; height: 80rpx; background: #F5F7FA; border-radius: 12rpx; padding: 0 24rpx; font-size: 28rpx; color: #1D2129; box-sizing: border-box; }
.popup-actions { display: flex; gap: 20rpx; margin-top: 20rpx;
  .u-button { flex: 1; }
}

.list-scroll { padding: 20rpx 30rpx; flex: 1; box-sizing: border-box; }
.card-list { display: flex; flex-direction: column; gap: 20rpx; }

.notice-card { position: relative; background: #fff; border-radius: 16rpx; padding: 28rpx; box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
  &:active { transform: scale(0.98); opacity: 0.9; }
  &.is-read { opacity: 0.6; }
}

.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.type-tag { padding: 6rpx 16rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500;
  &.type-1 { background: #FFF7E8; color: #FF7D00; }
  &.type-2 { background: #E8FFEA; color: #00B42A; }
}
.card-time { font-size: 24rpx; color: #86909C; }

.card-body { padding-top: 4rpx; }
.card-title { font-size: 28rpx; color: #1D2129; font-weight: 500; line-height: 1.5; display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 2; overflow: hidden; }

.card-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 16rpx; padding-top: 16rpx; border-top: 1rpx solid #F2F3F5; }
.status-wrap { flex-shrink: 0; }
.status-text { font-size: 22rpx; padding: 4rpx 12rpx; border-radius: 6rpx; }
.status-normal { background: #E8FFEA; color: #00B42A; }
.status-disabled { background: #F2F3F5; color: #86909C; }
.action-btns { display: flex; align-items: center; gap: 12rpx; }
.action-btn {
  display: flex; align-items: center; gap: 4rpx; font-size: 22rpx;
  padding: 6rpx 12rpx; border-radius: 8rpx;
  &.edit { color: #3D6DF7; background: #E8F0FE; }
  &.delete { color: #F53F3F; background: #FFF1F0; }
  &.read-users { color: #FF7D00; background: #FFF7E8; }
  &.switch-btn { padding: 0; background: transparent; }
}

.unread-dot { position: absolute; top: 24rpx; right: 24rpx; width: 16rpx; height: 16rpx; border-radius: 50%; background: #F53F3F; }

.fab-btn {
  position: fixed; right: 32rpx; bottom: 120rpx; width: 100rpx; height: 100rpx;
  border-radius: 50%; background: linear-gradient(135deg, #3D6DF7, #5B8DEF);
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 8rpx 24rpx rgba(61, 109, 247, 0.4);
  &:active { transform: scale(0.95); opacity: 0.9; }
}
</style>
