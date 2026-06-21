<template>
  <view class="plan-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="queryParams.keyword" placeholder="搜索方案/企业名称" placeholder-class="search-placeholder" confirm-type="search" @input="onSearchInput" @confirm="handleSearch" />
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
          <view v-if="queryParams.enterpriseName !== ''" class="filter-tag active" @click="clearFilter('enterpriseName')">
            <text>企业: {{ queryParams.enterpriseName }}</text><u-icon name="close" size="12"></u-icon>
          </view>
          <view v-if="queryParams.planName !== ''" class="filter-tag active" @click="clearFilter('planName')">
            <text>方案: {{ queryParams.planName }}</text><u-icon name="close" size="12"></u-icon>
          </view>
          <view v-if="queryParams.auditStatus !== '' && queryParams.auditStatus !== undefined" class="filter-tag active" @click="clearFilter('auditStatus')">
            <text>{{ getAuditStatusLabel(queryParams.auditStatus) }}</text><u-icon name="close" size="12"></u-icon>
          </view>
        </view>
      </scroll-view>
    </view>

    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <view class="form-label">企业名称</view>
          <input class="form-input" type="text" v-model="filterForm.enterpriseName" placeholder="请输入企业名称" placeholder-class="form-placeholder" />
        </view>
        <view class="form-item">
          <view class="form-label">方案名称</view>
          <input class="form-input" type="text" v-model="filterForm.planName" placeholder="请输入方案名称" placeholder-class="form-placeholder" />
        </view>
        <view class="form-item">
          <view class="form-label">审核状态</view>
          <view class="form-options">
            <view v-for="item in auditStatusOptions" :key="item.value" class="option-tag" :class="{ active: filterForm.auditStatus === item.value }" @click="filterForm.auditStatus = filterForm.auditStatus === item.value ? '' : item.value">{{ item.label }}</view>
          </view>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
      </view>
    </u-popup>

    <scroll-view scroll-y class="list-scroll" @scrolltolower="loadMore" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onPullDownRefresh">
      <view v-if="planList.length > 0" class="card-list">
        <view v-for="item in planList" :key="item.planId" class="plan-card" @click="goDetail(item)">
          <view class="card-header">
            <view class="header-left">
              <text class="plan-no">{{ item.planNo || '-' }}</text>
            </view>
            <view class="status-tag" :class="'status-' + item.auditStatus">{{ getAuditStatusLabel(item.auditStatus) }}</view>
          </view>
          <view class="card-body">
            <view class="info-row">
              <view class="info-item"><text class="label">企业</text><text class="value">{{ item.enterpriseName || '-' }}</text></view>
              <view class="info-item"><text class="label">方案</text><text class="value">{{ item.planName || '-' }}</text></view>
            </view>
            <view class="info-row">
              <view class="info-item"><text class="label">方案金额</text><text class="value amount">¥{{ formatAmount(item.planAmount) }}</text></view>
              <view class="info-item"><text class="label">配赠</text><text class="value">¥{{ formatAmount(item.giftAmount) }}</text></view>
            </view>
            <view class="info-row">
              <view class="info-item"><text class="label">剩余</text><text class="value" :class="{ 'amount-warning': parseFloat(item.remainingAmount) <= 0 }">¥{{ formatAmount(item.remainingAmount) }}</text></view>
              <view class="info-item"><text class="label">分成</text><text class="value">{{ item.commissionRate || 0 }}%</text></view>
            </view>
            <view class="info-row">
              <view class="info-item"><text class="label">有效期</text><text class="value">{{ formatDateRange(item.effectiveDate, item.expiryDate) }}</text></view>
            </view>
          </view>
          <view class="card-footer" v-if="item.auditStatus === '0' || item.auditStatus === '4'">
            <view class="delete-btn" @click.stop="handleDelete(item)">
              <u-icon name="trash" size="14" color="#F53F3F"></u-icon>
              <text style="font-size: 24rpx; color: #F53F3F;">删除</text>
            </view>
          </view>
        </view>
      </view>
      <u-empty v-else-if="!loading" mode="data" text="暂无方案数据" :marginTop="100"></u-empty>
      <u-loadmore :status="loadStatus" :loading-text="'加载中...'" :loadmore-text="'上拉加载更多'" :nomore-text="'没有更多了'" :marginTop="20" />
    </scroll-view>

    <view class="fab-btn" v-if="checkPermi('business:plan:add')" @click="handleAdd">
      <u-icon name="plus" size="28" color="#fff"></u-icon>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, computed, onUnmounted } from 'vue'
import { listPlan, listEnterprise, delPlan } from '@/api/business/plan'
import { checkPermi } from '@/utils/permission'


const planList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)

let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const hasActiveFilters = computed(() => (queryParams.auditStatus !== '' && queryParams.auditStatus !== undefined) || queryParams.enterpriseName !== '' || queryParams.planName !== '')

const filterForm = reactive({
  enterpriseName: '',
  planName: '',
  auditStatus: ''
})

const queryParams = reactive({ pageNum: 1, pageSize: 10, keyword: '', auditStatus: '', enterpriseName: '', planName: '' })

const auditStatusOptions = ref([
  { label: '草稿', value: '0' },
  { label: '待审核', value: '1' },
  { label: '已审核', value: '2' },
  { label: '已完成', value: '3' },
  { label: '已驳回', value: '4' }
])

function getAuditStatusLabel(status) {
  const map = { '0': '草稿', '1': '待审核', '2': '已审核', '3': '已完成', '4': '已驳回' }
  return map[String(status)] || '未知'
}

function formatAmount(val) {
  const num = parseFloat(val)
  if (isNaN(num)) return '0.00'
  return num.toFixed(2)
}

function formatDateRange(start, end) {
  if (!start && !end) return '-'
  const s = start ? start.substring(0, 10) : ''
  const e = end ? end.substring(0, 10) : ''
  if (s && e) return s + ' ~ ' + e
  return s || e
}

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) { queryParams.pageNum = 1; loadStatus.value = 'loadmore' }
  try {
    const params = { pageNum: queryParams.pageNum, pageSize: queryParams.pageSize }
    if (queryParams.auditStatus !== '' && queryParams.auditStatus !== undefined) params.auditStatus = queryParams.auditStatus
    if (queryParams.enterpriseName) params.enterpriseName = queryParams.enterpriseName
    if (queryParams.planName) params.planName = queryParams.planName
    if (queryParams.keyword) { params.keyword = queryParams.keyword }
    const response = await listPlan(params)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0
    planList.value = isRefresh ? list : [...planList.value, ...list]
    loadStatus.value = planList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) { console.error('获取方案列表失败:', e); loadStatus.value = 'error' }
  finally { loading.value = false; refreshing.value = false }
}

function loadMore() { if (loading.value || loadStatus.value === 'nomore') return; loadStatus.value = 'loading'; queryParams.pageNum++; getList() }
function onPullDownRefresh() { refreshing.value = true; getList(true) }
function handleSearch() { getList(true) }
function onSearchInput() { if (searchTimer) clearTimeout(searchTimer); searchTimer = setTimeout(() => handleSearch(), 500) }
function clearKeyword() { queryParams.keyword = ''; handleSearch() }
function toggleFilter() { showFilter.value = !showFilter.value }
function resetFilter() { filterForm.enterpriseName = ''; filterForm.planName = ''; filterForm.auditStatus = '' }
function confirmFilter() { queryParams.enterpriseName = filterForm.enterpriseName; queryParams.planName = filterForm.planName; queryParams.auditStatus = filterForm.auditStatus; showFilter.value = false; getList(true) }
function clearFilter(field) { queryParams[field] = ''; if (field === 'enterpriseName') filterForm.enterpriseName = ''; if (field === 'planName') filterForm.planName = ''; if (field === 'auditStatus') filterForm.auditStatus = ''; getList(true) }

function goDetail(item) {
  uni.navigateTo({ url: `/pages/business/plan/detail?id=${item.planId}` })
}

function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: `确认删除方案"${item.planName || item.planNo}"？`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delPlan(item.planId)
          uni.showToast({ title: '删除成功', icon: 'success' })
          getList(true)
        } catch (e) {
          uni.showToast({ title: '删除失败', icon: 'none' })
        }
      }
    }
  })
}

function handleAdd() {
  uni.navigateTo({ url: '/pages/business/plan/form?mode=add' })
}

onMounted(() => { getList(true) })
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.plan-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx;
  :deep(.u-popup) { flex: none !important; }
}

.search-section { flex-shrink: 0; padding: 20rpx 24rpx; margin-left: -24rpx; margin-right: -24rpx; background: linear-gradient(180deg, #3D6DF7 0%, #4A7AEF 100%); }
.search-box { display: flex; align-items: center; background: #fff; border-radius: 36rpx; padding: 0 8rpx 0 28rpx; height: 72rpx; gap: 12rpx; box-sizing: border-box; }
.search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; min-width: 0; }
.search-placeholder { color: #86909C; font-size: 28rpx; }
.clear-btn { flex-shrink: 0; padding: 8rpx; display: flex; align-items: center; }
.filter-btn { flex-shrink: 0; display: flex; align-items: center; justify-content: center; gap: 4rpx; height: 56rpx; padding: 0 22rpx; background: #E8F0FE; border-radius: 28rpx;
  text { font-size: 26rpx; color: #3D6DF7; font-weight: 500; white-space: nowrap; }
  .icon-rotate { transform: rotate(180deg); transition: transform 0.3s ease; }
}

.active-filters { flex-shrink: 0; padding: 12rpx 24rpx 16rpx; margin-left: -24rpx; margin-right: -24rpx; background: linear-gradient(180deg, #4A7AEF 0%, #F5F7FA 100%); }
.filter-scroll { white-space: nowrap; }
.filter-tags { display: inline-flex; gap: 16rpx; padding: 16rpx 0; }
.filter-tag { display: inline-flex; align-items: center; gap: 8rpx; padding: 10rpx 20rpx; background: rgba(255,255,255,0.2); border-radius: 28rpx; font-size: 24rpx; color: #fff;
  &.active { background: #fff; color: #3D6DF7; }
}

.popup-content { padding: 30rpx; background: #fff; }
.popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; margin-bottom: 30rpx; }
.form-item { margin-bottom: 30rpx; }
.form-label { font-size: 28rpx; color: #1D2129; font-weight: 500; margin-bottom: 16rpx; }
.form-options { display: flex; flex-wrap: wrap; gap: 16rpx; }
.form-input { width: 100%; height: 72rpx; background: #F5F7FA; border-radius: 8rpx; padding: 0 20rpx; font-size: 28rpx; color: #1D2129; box-sizing: border-box; }
.form-placeholder { color: #C9CDD4; font-size: 28rpx; }
.option-tag { padding: 14rpx 28rpx; background: #F5F7FA; border-radius: 8rpx; font-size: 26rpx; color: #4E5969; border: 2rpx solid transparent;
  &.active { background: #E8F0FE; color: #3D6DF7; border-color: #3D6DF7; }
}
.popup-actions { display: flex; gap: 20rpx; margin-top: 40rpx; padding-top: 30rpx; border-top: 1rpx solid #E5E6EB; .u-button { flex: 1; } }

.list-scroll { flex: 1; overflow: hidden; padding: 20rpx 0; }
.card-list { display: flex; flex-direction: column; gap: 20rpx; }

.plan-card { background: #fff; border-radius: 16rpx; padding: 28rpx; box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
  &:active { transform: scale(0.98); opacity: 0.9; }
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.header-left { display: flex; align-items: center; gap: 12rpx; flex: 1; min-width: 0;
  .plan-no { font-size: 28rpx; font-weight: 600; color: #1D2129; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
}
.status-tag { padding: 6rpx 16rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #F2F3F5; color: #86909C; }
  &.status-1 { background: #E8F0FE; color: #3D6DF7; }
  &.status-2 { background: #E8FFEA; color: #00B42A; }
  &.status-3 { background: #F0E8FF; color: #8B5CF6; }
  &.status-4 { background: #FFECE8; color: #F53F3F; }
}

.card-body { padding: 20rpx 0; border-top: 1rpx solid #F2F3F5; }
.card-footer { display: flex; justify-content: flex-end; padding-top: 16rpx; margin-top: 12rpx; border-top: 1rpx solid #F2F3F5; }
.delete-btn { display: flex; align-items: center; gap: 6rpx; padding: 8rpx 20rpx; }
.info-row { display: flex; margin-bottom: 16rpx; &:last-child { margin-bottom: 0; } }
.info-item { flex: 1; display: flex; align-items: center; gap: 12rpx;
  .label { font-size: 24rpx; color: #86909C; min-width: 60rpx; }
  .value { font-size: 26rpx; color: #1D2129; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
    &.amount { color: #FF6B35; font-weight: 600; font-size: 30rpx; }
    &.amount-warning { color: #F53F3F; font-weight: 600; }
  }
}

.fab-btn { position: fixed; right: 40rpx; bottom: 80rpx; width: 100rpx; height: 100rpx; border-radius: 50%; background: #FF6B35; display: flex; align-items: center; justify-content: center; box-shadow: 0 8rpx 24rpx rgba(255,107,53,0.4); z-index: 100;
  &:active { transform: scale(0.92); }
}
</style>
