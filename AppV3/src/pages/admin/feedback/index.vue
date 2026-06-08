<template>
  <view class="feedback-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="queryParams.keyword" placeholder="搜索反馈标题" placeholder-class="search-placeholder" confirm-type="search" @input="onSearchInput" @confirm="handleSearch" />
        <view v-if="queryParams.keyword" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
        <view class="filter-btn" :class="{ active: hasActiveFilters }" @click="toggleFilter">
          <u-icon name="list" size="12" :color="hasActiveFilters ? '#3D6DF7' : '#4E5969'"></u-icon>
          <text>筛选</text>
        </view>
      </view>
    </view>

    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <view class="form-label">反馈类型</view>
          <view class="form-options">
            <view v-for="item in typeOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.feedbackType === item.value }" @click="queryParams.feedbackType = queryParams.feedbackType === item.value ? '' : item.value">{{ item.label }}</view>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">处理状态</view>
          <view class="form-options">
            <view v-for="item in statusOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.status === item.value }" @click="queryParams.status = queryParams.status === item.value ? '' : item.value">{{ item.label }}</view>
          </view>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
      </view>
    </u-popup>

    <scroll-view scroll-y class="list-scroll" @scrolltolower="loadMore" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onPullDownRefresh">
      <view v-if="feedbackList.length > 0" class="card-list">
        <view v-for="item in feedbackList" :key="item.feedbackId" class="feedback-card" @click="goDetail(item)">
          <view class="card-header">
            <text class="feedback-title">{{ item.title || '-' }}</text>
            <view class="status-badge" :class="'status-' + String(item.status)">{{ getStatusLabel(item.status) }}</view>
          </view>
          <view class="card-body">
            <text class="feedback-content">{{ item.content ? item.content.substring(0, 60) + (item.content.length > 60 ? '...' : '') : '-' }}</text>
          </view>
          <view class="card-footer">
            <view class="footer-left">
              <view class="type-tag" :class="'type-' + String(item.feedbackType)">{{ getTypeLabel(item.feedbackType) }}</view>
              <text class="feedback-time">{{ formatTime(item.createTime) }}</text>
            </view>
            <view class="action-btns">
              <view v-if="checkPermi('admin:feedback:edit')" class="action-btn edit" @click.stop="goEdit(item)">
                <u-icon name="edit-pen" size="14"></u-icon>
                <text>编辑</text>
              </view>
              <view v-if="checkPermi('admin:feedback:remove')" class="action-btn delete" @click.stop="handleDelete(item)">
                <u-icon name="trash" size="14"></u-icon>
                <text>删除</text>
              </view>
            </view>
          </view>
        </view>
      </view>
      <u-empty v-else-if="!loading" mode="data" text="暂无反馈数据" :marginTop="100"></u-empty>
      <u-loadmore :status="loadStatus" :loading-text="'加载中...'" :loadmore-text="'上拉加载更多'" :nomore-text="'没有更多了'" :marginTop="20" />
    </scroll-view>

    <view class="fab-btn" @click="handleAdd">
      <u-icon name="plus" size="28" color="#fff"></u-icon>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { listFeedback, delFeedback } from '@/api/admin/feedback'
import { getDicts } from '@/api/system/dictData'
import { checkPermi } from '@/utils/permission'

const feedbackList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)

let searchTimer = null

const hasActiveFilters = computed(() => (queryParams.feedbackType !== '' && queryParams.feedbackType !== undefined) || (queryParams.status !== '' && queryParams.status !== undefined))

const queryParams = reactive({ pageNum: 1, pageSize: 10, keyword: '', feedbackType: '', status: '' })

const typeOptions = ref([])
const statusOptions = ref([])

async function loadDicts() {
  try {
    const [typeRes, statusRes] = await Promise.all([
      getDicts('biz_feedback_type'),
      getDicts('biz_feedback_status')
    ])
    typeOptions.value = (typeRes.data || []).map(item => ({ label: item.dictLabel, value: item.dictValue }))
    statusOptions.value = (statusRes.data || []).map(item => ({ label: item.dictLabel, value: item.dictValue }))
  } catch (e) { console.error('获取字典失败:', e) }
}

function getTypeLabel(type) {
  const item = typeOptions.value.find(o => o.value === String(type))
  return item ? item.label : '其他'
}

function getStatusLabel(status) {
  const item = statusOptions.value.find(o => o.value === String(status))
  return item ? item.label : '未知'
}

function formatTime(time) {
  if (!time) return ''
  return String(time).substring(0, 16)
}

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) { queryParams.pageNum = 1; loadStatus.value = 'loadmore' }
  try {
    const params = { pageNum: queryParams.pageNum, pageSize: queryParams.pageSize }
    if (queryParams.feedbackType !== '' && queryParams.feedbackType !== undefined) params.feedbackType = queryParams.feedbackType
    if (queryParams.status !== '' && queryParams.status !== undefined) params.status = queryParams.status
    if (queryParams.keyword) params.title = queryParams.keyword
    const response = await listFeedback(params)
    const data = response.data || response
    const list = data.rows || data.items || []
    const total = data.total || 0
    feedbackList.value = isRefresh ? list : [...feedbackList.value, ...list]
    loadStatus.value = feedbackList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) { console.error('获取反馈列表失败:', e); loadStatus.value = 'error' }
  finally { loading.value = false; refreshing.value = false }
}

function loadMore() { if (loading.value || loadStatus.value === 'nomore') return; loadStatus.value = 'loading'; queryParams.pageNum++; getList() }
function onPullDownRefresh() { refreshing.value = true; getList(true) }
function handleSearch() { getList(true) }
function onSearchInput() { if (searchTimer) clearTimeout(searchTimer); searchTimer = setTimeout(() => handleSearch(), 500) }
function clearKeyword() { queryParams.keyword = ''; handleSearch() }
function toggleFilter() { showFilter.value = !showFilter.value }
function resetFilter() { queryParams.feedbackType = ''; queryParams.status = '' }
function confirmFilter() { showFilter.value = false; getList(true) }

function goDetail(item) {
  uni.navigateTo({ url: `/pages/admin/feedback/detail?id=${item.feedbackId}` })
}

function goEdit(item) {
  uni.navigateTo({ url: `/pages/admin/feedback/form?mode=edit&id=${item.feedbackId}` })
}

function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: `是否确认删除反馈"${item.title}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delFeedback(item.feedbackId)
          uni.showToast({ title: '删除成功', icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('删除失败:', e)
        }
      }
    }
  })
}

function handleAdd() {
  uni.navigateTo({ url: '/pages/admin/feedback/form?mode=add' })
}

onMounted(() => { loadDicts(); getList(true) })
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.feedback-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx;
  :deep(.u-popup) { flex: none !important; }
}

.search-section { flex-shrink: 0; padding: 20rpx 0; }
.search-box { display: flex; align-items: center; background: #fff; border-radius: 36rpx; padding: 0 8rpx 0 28rpx; height: 72rpx; gap: 12rpx; box-sizing: border-box; box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.04); }
.search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; min-width: 0; }
.search-placeholder { color: #86909C; font-size: 28rpx; }
.clear-btn { flex-shrink: 0; padding: 8rpx; display: flex; align-items: center; }
.filter-btn { flex-shrink: 0; display: flex; align-items: center; justify-content: center; gap: 6rpx; height: 56rpx; padding: 0 22rpx; background: #F5F7FA; border-radius: 28rpx; transition: all 0.2s;
  text { font-size: 26rpx; color: #4E5969; font-weight: 500; white-space: nowrap; }
  &.active { background: #e8f0fe;
    text { color: #3D6DF7; }
  }
}

.popup-content { padding: 30rpx; background: #fff; }
.popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; margin-bottom: 30rpx; }
.form-item { margin-bottom: 30rpx; }
.form-label { font-size: 28rpx; color: #1D2129; font-weight: 500; margin-bottom: 16rpx; }
.form-options { display: flex; flex-wrap: wrap; gap: 16rpx; }
.option-tag { padding: 14rpx 28rpx; background: #F5F7FA; border-radius: 8rpx; font-size: 26rpx; color: #4E5969; border: 2rpx solid transparent; transition: all 0.2s;
  &.active { background: #e8f0fe; color: #3D6DF7; border-color: #3D6DF7; }
}
.popup-actions { display: flex; gap: 20rpx; margin-top: 40rpx; padding-top: 30rpx; border-top: 1rpx solid #E5E6EB; .u-button { flex: 1; } }

.list-scroll { flex: 1; overflow: hidden; padding: 12rpx 0; }
.card-list { display: flex; flex-direction: column; gap: 16rpx; }

.feedback-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; transition: all 0.15s;
  &:active { transform: scale(0.985); background: #FAFBFC; }
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12rpx; }
.feedback-title { font-size: 28rpx; font-weight: 600; color: #1D2129; flex: 1; margin-right: 16rpx; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #FFF7E8; color: #FF7D00; }
  &.status-1 { background: #e8f0fe; color: #3D6DF7; }
  &.status-2 { background: #f6ffed; color: #52c41a; }
  &.status-3 { background: #F2F3F5; color: #86909C; }
}

.card-body { margin-bottom: 12rpx; }
.feedback-content { font-size: 26rpx; color: #4E5969; line-height: 1.6; }

.card-footer { display: flex; justify-content: space-between; align-items: center; }
.footer-left { display: flex; align-items: center; gap: 12rpx; }
.type-tag { padding: 2rpx 12rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500;
  &.type-0 { background: #FFECE8; color: #F53F3F; }
  &.type-1 { background: #fff7e6; color: #fa8c16; }
  &.type-2 { background: #F2F3F5; color: #86909C; }
}
.feedback-time { font-size: 24rpx; color: #86909C; }
.action-btns { display: flex; gap: 12rpx; }
.action-btn {
  display: flex; align-items: center; gap: 4rpx; font-size: 22rpx;
  padding: 6rpx 12rpx; border-radius: 8rpx;
  &.edit { color: #3D6DF7; background: #E8F0FE; }
  &.delete { color: #F53F3F; background: #FFF1F0; }
}

.fab-btn { position: fixed; right: 40rpx; bottom: 80rpx; width: 100rpx; height: 100rpx; border-radius: 50%; background: #3D6DF7; display: flex; align-items: center; justify-content: center; box-shadow: 0 8rpx 24rpx rgba(61,109,247,0.35); z-index: 100;
  &:active { transform: scale(0.92); }
}
</style>
