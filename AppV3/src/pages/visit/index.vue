<template>
  <view class="visit-list-container">
    <!-- 搜索栏 -->
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="queryParams.enterpriseName" placeholder="搜索企业名称" placeholder-class="search-placeholder" confirm-type="search" @confirm="handleSearch" />
        <view v-if="queryParams.enterpriseName" class="clear-btn" @click="clearKeyword">
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
          <view v-if="queryParams.visitType" class="filter-tag active" @click="clearFilter('visitType')">
            <text>{{ getVisitTypeLabel(queryParams.visitType) }}</text><u-icon name="close" size="12"></u-icon>
          </view>
          <view v-if="queryParams.visitMode" class="filter-tag active" @click="clearFilter('visitMode')">
            <text>{{ getVisitModeLabel(queryParams.visitMode) }}</text><u-icon name="close" size="12"></u-icon>
          </view>
          <view v-if="queryParams.visitStatus !== '' && queryParams.visitStatus !== undefined && queryParams.visitStatus !== null" class="filter-tag active" @click="clearFilter('visitStatus')">
            <text>{{ getStatusLabel(queryParams.visitStatus) }}</text><u-icon name="close" size="12"></u-icon>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- 筛选弹窗 -->
    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>

        <view class="form-item">
          <view class="form-label">回访类型</view>
          <view class="form-options">
            <view v-for="item in visitTypeOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.visitType === item.value }" @click="setFilter('visitType', item.value)">{{ item.label }}</view>
          </view>
        </view>

        <view class="form-item">
          <view class="form-label">回访方式</view>
          <view class="form-options">
            <view v-for="item in visitModeOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.visitMode === item.value }" @click="setFilter('visitMode', item.value)">{{ item.label }}</view>
          </view>
        </view>

        <view class="form-item">
          <view class="form-label">状态</view>
          <view class="form-options">
            <view v-for="item in visitStatusOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.visitStatus === item.value }" @click="setFilter('visitStatus', item.value)">{{ item.label }}</view>
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
        <view v-for="(item, index) in list" :key="item.visitId || index" class="visit-card" @click="handleDetail(item)">
          <view class="card-top">
            <text class="enterprise-name">{{ item.enterpriseName }}</text>
            <view class="status-tag" :class="getStatusClass(item.visitStatus)">
              <text>{{ getStatusLabel(item.visitStatus) }}</text>
            </view>
          </view>
          <view v-if="item.storeName" class="card-sub">
            <u-icon name="shop" size="14" color="#86909C"></u-icon>
            <text class="sub-text">{{ item.storeName }}</text>
          </view>
          <view class="card-tags">
            <view class="tag tag-type">{{ getVisitTypeLabel(item.visitType) }}</view>
            <view class="tag" :class="item.visitMode === '1' ? 'tag-mode-staff' : 'tag-mode-h5'">
              {{ getVisitModeLabel(item.visitMode) }}
            </view>
          </view>
          <!-- 满意度 -->
          <view v-if="item.satisfactionScore" class="card-rate">
            <view class="rate-stars">
              <u-icon v-for="n in 5" :key="n" :name="n <= Number(item.satisfactionScore) ? 'star-fill' : 'star'" size="16" :color="n <= Number(item.satisfactionScore) ? '#FF7D00' : '#E5E6EB'"></u-icon>
            </view>
            <text class="rate-text">{{ Number(item.satisfactionScore).toFixed(1) }} 分</text>
          </view>
          <view class="card-info">
            <view class="info-item">
              <text class="info-label">回访员工</text>
              <text class="info-value">{{ item.visitorUserName || '-' }}</text>
            </view>
            <view class="info-item">
              <text class="info-label">回访时间</text>
              <text class="info-value">{{ formatTime(item.visitTime) }}</text>
            </view>
          </view>
          <!-- 卡片底部操作按钮 -->
          <view class="card-footer">
            <text class="footer-time">{{ formatTime(item.createTime) }}</text>
            <view class="action-btns">
              <view class="action-btn edit" @click.stop="handleEdit(item)">
                <u-icon name="edit-pen" size="14" color="#3D6DF7"></u-icon>
                <text>编辑</text>
              </view>
              <view v-if="item.visitMode === '2' && item.visitStatus !== '1'" class="action-btn link" @click.stop="handleGenerateLink(item)">
                <u-icon name="share" size="14" color="#00B42A"></u-icon>
                <text>生成链接</text>
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
        <text class="empty-text">暂无回访数据</text>
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
 * @description 回访任务列表页 - 展示回访任务列表，支持搜索/筛选/新增/详情/编辑/删除
 */
import { ref, reactive, computed } from 'vue'
import { onShow, onReachBottom } from '@dcloudio/uni-app'
import { listVisit, delVisit, generateVisitLink } from '@/api/business/visitManage'
import { copyToClipboard } from '@/utils/common'
import config from '@/config'

// 字段常量
const visitTypeOptions = [
  { value: 'after_service', label: '服务后回访' },
  { value: 'monthly', label: '月度回访' },
  { value: 'quarterly', label: '季度回访' },
  { value: 'custom', label: '自定义' }
]
const visitModeOptions = [
  { value: '1', label: '员工填写' },
  { value: '2', label: 'H5链接' }
]
const visitStatusOptions = [
  { value: '0', label: '待回访' },
  { value: '1', label: '已完成' },
  { value: '2', label: '已取消' }
]

const list = ref([])
const loading = ref(false)
const hasMore = ref(true)
const showFilter = ref(false)

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  enterpriseName: '',
  visitType: '',
  visitMode: '',
  visitStatus: ''
})

const hasActiveFilters = computed(() => {
  return !!(queryParams.visitType || queryParams.visitMode ||
    (queryParams.visitStatus !== '' && queryParams.visitStatus !== undefined && queryParams.visitStatus !== null))
})

function getVisitTypeLabel(val) {
  const item = visitTypeOptions.find(o => o.value === String(val))
  return item ? item.label : (val || '-')
}
function getVisitModeLabel(val) {
  const item = visitModeOptions.find(o => o.value === String(val))
  return item ? item.label : '-'
}
function getStatusLabel(val) {
  const item = visitStatusOptions.find(o => o.value === String(val))
  return item ? item.label : '-'
}
function getStatusClass(val) {
  const map = { '0': 'status-pending', '1': 'status-done', '2': 'status-cancel' }
  return map[String(val)] || 'status-pending'
}

function formatTime(val) {
  if (!val) return '-'
  // 兼容后端返回的 YYYY-MM-DD HH:mm:ss
  const str = String(val).replace(/-/g, '/')
  const d = new Date(str)
  if (isNaN(d.getTime())) return val
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  const hh = String(d.getHours()).padStart(2, '0')
  const mm = String(d.getMinutes()).padStart(2, '0')
  return `${y}-${m}-${day} ${hh}:${mm}`
}

function handleEdit(item) {
  uni.navigateTo({ url: '/pages/visit/form?visitId=' + item.visitId })
}

function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: '是否确认删除该回访任务？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await delVisit(item.visitId)
          uni.showToast({ title: '删除成功', icon: 'success' })
          loadList(true)
        } catch (e) {
          console.error('删除失败', e)
        }
      }
    }
  })
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
    const res = await listVisit(queryParams)
    const rows = res.rows || []
    if (reset) {
      list.value = rows
    } else {
      list.value = [...list.value, ...rows]
    }
    const total = res.total || 0
    hasMore.value = list.value.length < total
  } catch (e) {
    console.error('加载回访列表失败', e)
    if (reset) list.value = []
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  loadList(true)
}

function clearKeyword() {
  queryParams.enterpriseName = ''
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
  queryParams.visitType = ''
  queryParams.visitMode = ''
  queryParams.visitStatus = ''
}

function confirmFilter() {
  showFilter.value = false
  loadList(true)
}

function handleDetail(item) {
  uni.navigateTo({ url: '/pages/visit/detail?visitId=' + item.visitId })
}

function handleAdd() {
  uni.navigateTo({ url: '/pages/visit/form' })
}

async function handleGenerateLink(item) {
  uni.showLoading({ title: '生成中...', mask: true })
  try {
    const res = await generateVisitLink(item.visitId)
    const data = res.data || res
    const token = data.visitToken || data.h5Token || ''
    if (!token) {
      uni.showToast({ title: '链接生成失败', icon: 'none' })
      return
    }
    const url = buildH5Url(token)
    uni.showModal({
      title: 'H5回访链接',
      content: `链接（7天内有效）：\n${url}`,
      confirmText: '复制链接',
      success: (r) => {
        if (r.confirm) {
          copyToClipboard(url)
        }
      }
    })
  } catch (e) {
    console.error('生成链接失败', e)
  } finally {
    uni.hideLoading()
  }
}

// 根据token拼接完整H5回访链接（hash路由需含#）
function buildH5Url(token) {
  if (!token) return ''
  // #ifdef H5
  const origin = window.location.origin
  const base = window.location.pathname.replace(/\/[^/]*$/, '')
  return `${origin}${base}/#/pages/visit/fill?token=${token}`
  // #endif
  // #ifndef H5
  // 非H5环境（App/小程序）用配置的站点地址拼接完整可分享链接
  const siteUrl = (config.appInfo.site_url || '').replace(/\/$/, '')
  return `${siteUrl}/#/pages/visit/fill?token=${token}`
  // #endif
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

.visit-list-container {
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

.visit-card {
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
  margin-bottom: 12rpx;
  gap: 12rpx;
}

.enterprise-name {
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

  &.status-pending {
    background: rgba(230, 162, 60, 0.1);
    color: #e6a23c;
  }

  &.status-done {
    background: rgba(82, 196, 26, 0.1);
    color: #52c41a;
  }

  &.status-cancel {
    background: rgba(193, 197, 204, 0.2);
    color: #909399;
  }
}

.card-sub {
  display: flex;
  align-items: center;
  gap: 6rpx;
  margin-bottom: 12rpx;
}

.sub-text {
  font-size: 24rpx;
  color: #86909C;
}

.card-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8rpx;
  margin-bottom: 12rpx;
}

.tag {
  font-size: 20rpx;
  padding: 4rpx 12rpx;
  border-radius: 4rpx;
  background: rgba(61, 109, 247, 0.08);
  color: #3D6DF7;

  &.tag-mode-staff {
    background: rgba(103, 194, 58, 0.1);
    color: #67c23a;
  }

  &.tag-mode-h5 {
    background: rgba(0, 180, 42, 0.1);
    color: #00B42A;
  }
}

.card-rate {
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 12rpx 0;
  border-top: 1rpx solid #F0F0F0;
  border-bottom: 1rpx solid #F0F0F0;
  margin-bottom: 12rpx;
}

.rate-stars {
  display: flex;
  gap: 2rpx;
}

.rate-text {
  font-size: 22rpx;
  color: #FF7D00;
  font-weight: 600;
}

.card-info {
  display: flex;
  gap: 32rpx;
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
  max-width: 240rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
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

  &.link {
    color: #00B42A;
    background: #E8F8EE;
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
