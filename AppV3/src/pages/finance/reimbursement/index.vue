<template>
  <view class="reimbursement-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.keyword"
          placeholder="搜索报销单号/申请人"
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
            v-if="queryParams.category"
            class="filter-tag active"
            @click="clearFilter('category')"
          >
            <text>{{ getCategoryName(queryParams.category) }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
          <view
            v-if="queryParams.status !== '' && queryParams.status !== undefined"
            class="filter-tag active"
            @click="clearFilter('status')"
          >
            <text>{{ getStatusName(queryParams.status) }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
        </view>
      </scroll-view>
    </view>

    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <view class="form-label">分类</view>
          <view class="form-options">
            <view
              v-for="item in categoryOptions"
              :key="item.value"
              class="option-tag"
              :class="{ active: queryParams.category === item.value }"
              @click="queryParams.category = queryParams.category === item.value ? '' : item.value"
            >
              {{ item.label }}
            </view>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">状态</view>
          <view class="form-options">
            <view
              v-for="item in statusOptions"
              :key="item.value"
              class="option-tag"
              :class="{ active: queryParams.status === item.value }"
              @click="queryParams.status = queryParams.status === item.value ? '' : item.value"
            >
              {{ item.label }}
            </view>
          </view>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
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
      <view v-if="reimbursementList.length > 0" class="card-list">
        <view
          v-for="(item, index) in reimbursementList"
          :key="item.reimbursementId"
          class="reimbursement-card"
          @click="showDetail(item)"
        >
          <view class="card-header">
            <view class="reimbursement-no">
              <u-icon name="order" size="18" color="#3D6DF7"></u-icon>
              <text class="no-text">{{ item.reimbursementNo }}</text>
            </view>
            <view class="status-tag" :class="'status-' + item.status">
              {{ getStatusName(item.status) }}
            </view>
          </view>

          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="label">申请人</text>
                <text class="value">{{ item.applicantName || '-' }}</text>
              </view>
              <view class="info-item">
                <text class="label">部门</text>
                <text class="value">{{ item.deptName || '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">申请日期</text>
                <text class="value">{{ formatDate(item.applyDate) }}</text>
              </view>
              <view class="info-item">
                <text class="label">分类</text>
                <text class="value category-text">{{ getCategoryName(item.category) }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item full">
                <text class="label">支出金额</text>
                <text class="value amount-text">¥{{ formatMoney(item.expenseAmount) }}</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <u-empty
        v-else-if="!loading"
        mode="data"
        text="暂无报销数据"
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

    <!-- 详情弹窗 -->
    <u-popup :show="showDetailPopup" mode="bottom" round="16" @close="closeDetail">
      <view class="detail-popup">
        <view class="detail-header">
          <text class="detail-title">报销详情</text>
          <u-icon name="close" size="20" @click="closeDetail"></u-icon>
        </view>
        <scroll-view scroll-y class="detail-scroll">
          <view class="detail-content">
          <view class="detail-section">
            <view class="detail-row">
              <text class="detail-label">报销单号</text>
              <view class="detail-value">{{ detailData.reimbursementNo }}</view>
            </view>
            <view class="detail-row">
              <text class="detail-label">申请人</text>
              <view class="detail-value">{{ detailData.applicantName }}</view>
            </view>
            <view class="detail-row">
              <text class="detail-label">部门</text>
              <view class="detail-value">{{ detailData.deptName }}</view>
            </view>
            <view class="detail-row">
              <text class="detail-label">申请日期</text>
              <view class="detail-value">{{ detailData.applyDate }}</view>
            </view>
            <view class="detail-row">
              <text class="detail-label">分类</text>
              <view class="detail-value">{{ getCategoryName(detailData.category) }}</view>
            </view>
            <view class="detail-row">
              <text class="detail-label">支出类型</text>
              <view class="detail-value">{{ getExpenseTypeName(detailData.expenseType) }}</view>
            </view>
            <view class="detail-row">
              <text class="detail-label">支出金额</text>
              <view class="detail-value amount-text">¥{{ formatMoney(detailData.expenseAmount) }}</view>
            </view>
            <view class="detail-row">
              <text class="detail-label">收入金额</text>
              <view class="detail-value">¥{{ formatMoney(detailData.incomeAmount) }}</view>
            </view>
            <view class="detail-row">
              <text class="detail-label">状态</text>
              <view class="detail-value">
                <view class="status-tag" :class="'status-' + detailData.status">
                  {{ getStatusName(detailData.status) }}
                </view>
              </view>
            </view>
            <view class="detail-row" v-if="detailData.auditBy">
              <text class="detail-label">审核人</text>
              <view class="detail-value">{{ detailData.auditBy }}</view>
            </view>
            <view class="detail-row" v-if="detailData.auditTime">
              <text class="detail-label">审核时间</text>
              <view class="detail-value">{{ detailData.auditTime }}</view>
            </view>
            <view class="detail-row" v-if="detailData.auditRemark">
              <text class="detail-label">审核备注</text>
              <view class="detail-value">{{ detailData.auditRemark }}</view>
            </view>
            <view class="detail-row" v-if="detailData.payBy">
              <text class="detail-label">支付人</text>
              <view class="detail-value">{{ detailData.payBy }}</view>
            </view>
            <view class="detail-row" v-if="detailData.payTime">
              <text class="detail-label">支付时间</text>
              <view class="detail-value">{{ detailData.payTime }}</view>
            </view>
            <view class="detail-row" v-if="detailData.remark">
              <text class="detail-label">备注</text>
              <view class="detail-value">{{ detailData.remark }}</view>
            </view>
          </view>

          <view v-if="detailImages.length > 0" class="detail-section">
            <view class="detail-section-title">凭证图片</view>
            <view class="image-grid">
              <image
                v-for="(img, idx) in detailImages"
                :key="idx"
                :src="getFullUrl(img)"
                class="voucher-img"
                mode="aspectFill"
                @click="previewImage(idx)"
              ></image>
            </view>
          </view>
          </view>
        </scroll-view>

        <view class="detail-actions" v-if="detailData.reimbursementId">
          <template v-if="String(detailData.status) === '0'">
            <view class="action-btn edit" v-if="checkPermi('finance:reimbursement:edit')" @click="goEdit(detailData)">
              <u-icon name="edit-pen" size="14"></u-icon>
              <text>编辑</text>
            </view>
            <view class="action-btn audit-pass" v-if="checkPermi('finance:reimbursement:audit')" @click="handleAuditPass(detailData)">
              <u-icon name="checkmark" size="14"></u-icon>
              <text>审核通过</text>
            </view>
            <view class="action-btn audit-reject" v-if="checkPermi('finance:reimbursement:audit')" @click="showRejectPopup">
              <u-icon name="close" size="14"></u-icon>
              <text>驳回</text>
            </view>
            <view class="action-btn delete" v-if="checkPermi('finance:reimbursement:remove')" @click="handleDelete(detailData)">
              <u-icon name="trash" size="14"></u-icon>
              <text>删除</text>
            </view>
          </template>
          <template v-if="String(detailData.status) === '1'">
            <view class="action-btn pay" v-if="checkPermi('finance:reimbursement:pay')" @click="handlePay(detailData)">
              <u-icon name="coupon" size="14"></u-icon>
              <text>支付</text>
            </view>
          </template>
        </view>
      </view>
    </u-popup>

    <!-- 驳回弹窗 -->
    <u-popup :show="showReject" mode="center" round="16" @close="showReject = false">
      <view class="reject-popup">
        <view class="reject-title">驳回原因</view>
        <textarea
          class="reject-textarea"
          v-model="rejectRemark"
          placeholder="请输入驳回原因"
          :maxlength="200"
        ></textarea>
        <view class="reject-actions">
          <u-button type="info" plain text="取消" @click="showReject = false"></u-button>
          <u-button type="error" text="确认驳回" @click="submitReject"></u-button>
        </view>
      </view>
    </u-popup>

    <!-- 确认弹窗 -->
    <u-popup :show="showConfirm" mode="center" round="16" @close="showConfirm = false">
      <view class="confirm-popup">
        <view class="confirm-title">{{ confirmConfig.title }}</view>
        <view class="confirm-content">{{ confirmConfig.content }}</view>
        <view class="confirm-actions">
          <u-button type="info" plain text="取消" @click="showConfirm = false"></u-button>
          <u-button type="primary" text="确认" @click="onConfirmOk"></u-button>
        </view>
      </view>
    </u-popup>

    <!-- 图片预览弹窗 -->
    <u-popup :show="showImagePreview" mode="center" :customStyle="{ background: 'rgba(0,0,0,0.9)' }" @close="showImagePreview = false">
      <view class="image-preview-wrap">
        <view class="preview-close" @click="showImagePreview = false">
          <u-icon name="close" color="#fff" size="20"></u-icon>
        </view>
        <view class="preview-counter">{{ previewCurrent + 1 }} / {{ previewUrls.length }}</view>
        <swiper
          class="preview-swiper"
          :current="previewCurrent"
          @change="onSwiperChange"
          :indicator-dots="false"
        >
          <swiper-item v-for="(url, idx) in previewUrls" :key="idx">
            <image :src="url" class="preview-img" mode="aspectFit" @click="showImagePreview = false"></image>
          </swiper-item>
        </swiper>
      </view>
    </u-popup>

    <view class="fab-btn" v-if="checkPermi('finance:reimbursement:add')" @click="goAdd">
      <u-icon name="plus" size="24" color="#fff"></u-icon>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { listReimbursement, getReimbursement, delReimbursement, auditReimbursement, payReimbursement } from '@/api/finance/reimbursement'
import { getDicts } from '@/api/system/dictData'
import { checkPermi } from '@/utils/permission'
import config from '@/config'

const baseUrl = config.baseUrl

const reimbursementList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)
const showDetailPopup = ref(false)
const showReject = ref(false)
const rejectRemark = ref('')
const showConfirm = ref(false)
const confirmConfig = reactive({ title: '提示', content: '', onConfirm: null })
const showImagePreview = ref(false)
const previewCurrent = ref(0)
const previewUrls = ref([])
const detailData = ref({})
const detailImages = ref([])

let searchTimer = null

const categoryOptions = ref([])
const statusOptions = ref([])
const expenseTypeOptions = ref([])

const hasActiveFilters = computed(() => {
  return queryParams.category || (queryParams.status !== '' && queryParams.status !== undefined)
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: '',
  reimbursementNo: '',
  applicantName: '',
  category: '',
  status: ''
})

function getCategoryName(value) {
  if (!value) return '-'
  const item = categoryOptions.value.find(t => t.value === String(value))
  return item ? item.label : value
}

function getStatusName(value) {
  if (value === undefined || value === null || value === '') return '-'
  const item = statusOptions.value.find(t => t.value === String(value))
  return item ? item.label : value
}

function getExpenseTypeName(value) {
  if (!value) return '-'
  const item = expenseTypeOptions.value.find(t => t.value === String(value))
  return item ? item.label : value
}

function formatMoney(value) {
  return Number(value || 0).toFixed(2)
}

function formatDate(date) {
  if (!date) return '-'
  return date.substring(0, 10)
}

function getFullUrl(url) {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return baseUrl + url
}

function parseImages(jsonStr) {
  if (!jsonStr) return []
  try {
    const parsed = JSON.parse(jsonStr)
    if (Array.isArray(parsed)) {
      return parsed.filter(url => url && typeof url === 'string')
    }
    return []
  } catch (e) {
    if (typeof jsonStr === 'string' && (jsonStr.startsWith('http') || jsonStr.startsWith('/'))) {
      return [jsonStr]
    }
    return []
  }
}

async function loadDictData() {
  try {
    const [catRes, statusRes, expRes] = await Promise.all([
      getDicts('fin_reimbursement_category'),
      getDicts('fin_reimbursement_status'),
      getDicts('fin_reimbursement_expense_type')
    ])
    categoryOptions.value = (catRes.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
    statusOptions.value = (statusRes.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
    expenseTypeOptions.value = (expRes.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
  } catch (e) {
    console.error('加载字典数据失败:', e)
  }
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
      params.applicantName = params.keyword
    }
    delete params.keyword

    const response = await listReimbursement(params)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0

    if (isRefresh) {
      reimbursementList.value = list
    } else {
      reimbursementList.value = [...reimbursementList.value, ...list]
    }

    if (reimbursementList.value.length >= total) {
      loadStatus.value = 'nomore'
    } else {
      loadStatus.value = 'loadmore'
    }
  } catch (e) {
    console.error('获取报销列表失败:', e)
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
  queryParams.category = ''
  queryParams.status = ''
}

function confirmFilter() {
  showFilter.value = false
  getList(true)
}

function clearFilter(field) {
  queryParams[field] = ''
  getList(true)
}

async function showDetail(item) {
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getReimbursement(item.reimbursementId)
    const data = response.data || response
    detailData.value = data
    detailImages.value = parseImages(data.voucherImages)
    showDetailPopup.value = true
  } catch (e) {
    console.error('获取详情失败:', e)
    uni.showToast({ title: '获取详情失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

function closeDetail() {
  showDetailPopup.value = false
}

function previewImage(idx) {
  previewUrls.value = detailImages.value.map(img => getFullUrl(img))
  previewCurrent.value = idx
  showImagePreview.value = true
}

function onSwiperChange(e) {
  previewCurrent.value = e.detail.current
}

function goAdd() {
  uni.navigateTo({
    url: '/pages/finance/reimbursement/form?mode=add'
  })
}

function goEdit(item) {
  closeDetail()
  uni.navigateTo({
    url: `/pages/finance/reimbursement/form?id=${item.reimbursementId}&mode=edit`
  })
}

function handleAuditPass(item) {
  confirmConfig.title = '提示'
  confirmConfig.content = '确认审核通过该报销单？'
  confirmConfig.onConfirm = () => doAuditPass(item)
  showConfirm.value = true
}

async function doAuditPass(item) {
  try {
    await auditReimbursement({ reimbursementId: item.reimbursementId, passed: true })
    uni.showToast({ title: '审核通过', icon: 'success' })
    closeDetail()
    getList(true)
  } catch (e) {
    console.error('审核失败:', e)
    uni.showToast({ title: '审核失败', icon: 'none' })
  }
}

function showRejectPopup() {
  rejectRemark.value = ''
  showReject.value = true
}

async function submitReject() {
  if (!rejectRemark.value.trim()) {
    uni.showToast({ title: '请输入驳回原因', icon: 'none' })
    return
  }
  try {
    await auditReimbursement({
      reimbursementId: detailData.value.reimbursementId,
      passed: false,
      auditRemark: rejectRemark.value.trim()
    })
    uni.showToast({ title: '已驳回', icon: 'success' })
    showReject.value = false
    closeDetail()
    getList(true)
  } catch (e) {
    console.error('驳回失败:', e)
  }
}

function handleDelete(item) {
  confirmConfig.title = '提示'
  confirmConfig.content = `是否确认删除报销单"${item.reimbursementNo}"?`
  confirmConfig.onConfirm = () => doDelete(item)
  showConfirm.value = true
}

async function doDelete(item) {
  try {
    await delReimbursement([item.reimbursementId])
    uni.showToast({ title: '删除成功', icon: 'success' })
    closeDetail()
    getList(true)
  } catch (e) {
    console.error('删除失败:', e)
    uni.showToast({ title: '删除失败', icon: 'none' })
  }
}

function handlePay(item) {
  confirmConfig.title = '提示'
  confirmConfig.content = '确认已支付该报销单？'
  confirmConfig.onConfirm = () => doPay(item)
  showConfirm.value = true
}

async function doPay(item) {
  try {
    await payReimbursement({ reimbursementId: item.reimbursementId })
    uni.showToast({ title: '支付成功', icon: 'success' })
    closeDetail()
    getList(true)
  } catch (e) {
    console.error('支付失败:', e)
    uni.showToast({ title: '支付失败', icon: 'none' })
  }
}

function onConfirmOk() {
  showConfirm.value = false
  if (confirmConfig.onConfirm) {
    confirmConfig.onConfirm()
  }
}

onMounted(() => {
  loadDictData()
  getList(true)
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
  height: 100%;
  overflow: hidden;
}

.reimbursement-container {
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

.reimbursement-card {
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
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.reimbursement-no {
  display: flex;
  align-items: center;
  gap: 12rpx;

  .no-text {
    font-size: 30rpx;
    font-weight: 600;
    color: #1D2129;
  }
}

.status-tag {
  padding: 6rpx 16rpx;
  border-radius: 6rpx;
  font-size: 22rpx;
  font-weight: 500;

  &.status-0 {
    background: #FFF7E8;
    color: #FF7D00;
  }

  &.status-1 {
    background: #E8FFEA;
    color: #00B42A;
  }

  &.status-2 {
    background: #FFF1F0;
    color: #F53F3F;
  }

  &.status-3 {
    background: #E8F3FF;
    color: #3D6DF7;
  }
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

  &.full {
    flex: none;
    width: 100%;
  }

  .label {
    font-size: 24rpx;
    color: #86909C;
    min-width: 80rpx;
  }

  .value {
    font-size: 26rpx;
    color: #1D2129;

    &.category-text {
      color: #3D6DF7;
    }

    &.amount-text {
      color: #F53F3F;
      font-weight: bold;
      font-size: 30rpx;
    }
  }
}

// 详情弹窗
.detail-popup {
  max-height: 80vh;
  width: 100%;
  display: flex;
  flex-direction: column;
  background: #fff;
  overflow: hidden;
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 30rpx;
  border-bottom: 1rpx solid #F2F3F5;
}

.detail-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #1D2129;
}

.detail-scroll {
  flex: 1;
  overflow-x: hidden;
}

.detail-content {
  width: 100%;
  box-sizing: border-box;
  padding: 24rpx 30rpx;
}

.detail-section {
  margin-bottom: 30rpx;
}

.detail-section-title {
  font-size: 28rpx;
  font-weight: 600;
  color: #1D2129;
  margin-bottom: 20rpx;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 16rpx 0;
  border-bottom: 1rpx solid #F7F8FA;
  overflow: hidden;
  width: 100%;
}

.detail-label {
  font-size: 26rpx;
  color: #86909C;
  width: 140rpx;
  flex-shrink: 0;
}

.detail-value {
  font-size: 26rpx;
  color: #1D2129;
  text-align: right;
  flex: 1;
  min-width: 0;
  word-break: break-all;
  word-wrap: break-word;
  overflow-wrap: break-word;

  &.amount-text {
    color: #F53F3F;
    font-weight: bold;
  }
}

.image-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.voucher-img {
  width: 160rpx;
  height: 160rpx;
  border-radius: 12rpx;
}

.detail-actions {
  display: flex;
  gap: 16rpx;
  padding: 20rpx 30rpx 40rpx;
  border-top: 1rpx solid #F2F3F5;
  flex-wrap: wrap;
  flex-shrink: 0;
}

.action-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6rpx;
  font-size: 24rpx;
  padding: 14rpx 24rpx;
  border-radius: 8rpx;
  font-weight: 500;

  &.edit {
    color: #3D6DF7;
    background: #E8F0FE;
  }

  &.audit-pass {
    color: #00B42A;
    background: #E8FFEA;
  }

  &.audit-reject {
    color: #FF7D00;
    background: #FFF7E8;
  }

  &.delete {
    color: #F53F3F;
    background: #FFF1F0;
  }

  &.pay {
    color: #3D6DF7;
    background: #E8F3FF;
  }
}

// 驳回弹窗
.reject-popup {
  width: 600rpx;
  padding: 30rpx;
}

.reject-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #1D2129;
  margin-bottom: 20rpx;
}

.reject-textarea {
  width: 100%;
  min-height: 200rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 20rpx;
  font-size: 28rpx;
  color: #1D2129;
  box-sizing: border-box;
}

.reject-actions {
  display: flex;
  gap: 20rpx;
  margin-top: 24rpx;

  .u-button {
    flex: 1;
  }
}

.confirm-popup {
  width: 600rpx;
  padding: 30rpx;
}

.confirm-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #1D2129;
  margin-bottom: 20rpx;
}

.confirm-content {
  font-size: 28rpx;
  color: #4E5969;
  line-height: 1.6;
  margin-bottom: 10rpx;
}

.confirm-actions {
  display: flex;
  gap: 20rpx;
  margin-top: 24rpx;

  .u-button {
    flex: 1;
  }
}

.image-preview-wrap {
  width: 100vw;
  height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
}

.preview-close {
  position: absolute;
  top: 60rpx;
  right: 30rpx;
  z-index: 10;
  padding: 20rpx;
}

.preview-counter {
  position: absolute;
  top: 70rpx;
  left: 0;
  right: 0;
  text-align: center;
  color: #fff;
  font-size: 28rpx;
  z-index: 10;
}

.preview-swiper {
  width: 100%;
  height: 70vh;
}

.preview-img {
  width: 100%;
  height: 100%;
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
