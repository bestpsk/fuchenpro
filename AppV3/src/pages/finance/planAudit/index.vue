<template>
  <view class="plan-audit-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.keyword"
          placeholder="搜索企业名称/方案名称"
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
            v-if="queryParams.auditStatus"
            class="filter-tag active"
            @click="clearFilter('auditStatus')"
          >
            <text>{{ getAuditStatusName(queryParams.auditStatus) }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
        </view>
      </scroll-view>
    </view>

    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <view class="form-label">审核状态</view>
          <view class="form-options">
            <view
              v-for="item in auditStatusOptions"
              :key="item.value"
              class="option-tag"
              :class="{ active: queryParams.auditStatus === item.value }"
              @click="queryParams.auditStatus = queryParams.auditStatus === item.value ? '' : item.value"
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
      <view v-if="planList.length > 0" class="card-list">
        <view
          v-for="(item, index) in planList"
          :key="item.planId"
          class="plan-card"
          @click="handleView(item)"
        >
          <view class="card-header">
            <view class="header-left">
              <text class="plan-no">{{ item.planNo || '-' }}</text>
            </view>
            <view class="status-tag" :class="getStatusClass(item.auditStatus)">
              {{ getAuditStatusName(item.auditStatus) }}
            </view>
          </view>

          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="label">企业名称</text>
                <text class="value">{{ item.enterpriseName || '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">方案名称</text>
                <text class="value">{{ item.planName || '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">方案金额</text>
                <text class="value amount-text">¥{{ formatMoney(item.planAmount) }}</text>
              </view>
            </view>
          </view>

          <view class="card-footer">
            <view class="time-text">{{ formatTime(item.submitTime) }}</view>
            <view class="action-btns" v-if="item.auditStatus === '1' && checkPermi('finance:planAudit:audit')">
              <view class="action-btn pass" @click.stop="handleAuditPass(item)">
                <u-icon name="checkmark" size="14"></u-icon>
                <text>通过</text>
              </view>
              <view class="action-btn reject" @click.stop="handleAuditReject(item)">
                <u-icon name="close" size="14"></u-icon>
                <text>驳回</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <u-empty
        v-else-if="!loading"
        mode="data"
        text="暂无审核数据"
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
    <u-popup :show="detailOpen" mode="bottom" round="16" :closeable="true" @close="closeDetail" :customStyle="{ width: '100vw', maxWidth: '100vw', left: 0 }">
      <view class="detail-popup">
        <view class="detail-header">
          <text class="detail-title">方案详情</text>
          <u-icon name="close" size="20" @click="closeDetail"></u-icon>
        </view>
        <scroll-view scroll-y class="detail-scroll">
          <view class="detail-section">
            <view class="detail-row">
              <text class="detail-label">方案编号</text>
              <text class="detail-value">{{ detailForm.planNo }}</text>
            </view>
            <view class="detail-row">
              <text class="detail-label">方案名称</text>
              <text class="detail-value">{{ detailForm.planName }}</text>
            </view>
            <view class="detail-row">
              <text class="detail-label">企业名称</text>
              <text class="detail-value">{{ detailForm.enterpriseName }}</text>
            </view>
            <view class="detail-row">
              <text class="detail-label">方案金额</text>
              <text class="detail-value amount-text">¥{{ formatMoney(detailForm.planAmount) }}</text>
            </view>
            <view class="detail-row">
              <text class="detail-label">配赠金额</text>
              <text class="detail-value">¥{{ formatMoney(detailForm.giftAmount) }}</text>
            </view>
            <view class="detail-row">
              <text class="detail-label">剩余金额</text>
              <text class="detail-value">¥{{ formatMoney(detailForm.remainingAmount) }}</text>
            </view>
            <view class="detail-row">
              <text class="detail-label">生效日期</text>
              <text class="detail-value">{{ detailForm.effectiveDate || '-' }}</text>
            </view>
            <view class="detail-row">
              <text class="detail-label">失效日期</text>
              <text class="detail-value">{{ detailForm.expiryDate || '-' }}</text>
            </view>
            <view class="detail-row">
              <text class="detail-label">审核状态</text>
              <view class="status-tag" :class="getStatusClass(detailForm.auditStatus)">
                {{ getAuditStatusName(detailForm.auditStatus) }}
              </view>
            </view>
            <view class="detail-row">
              <text class="detail-label">备注</text>
              <text class="detail-value">{{ detailForm.remark || '-' }}</text>
            </view>
            <view class="detail-row">
              <text class="detail-label">审核人</text>
              <text class="detail-value">{{ detailForm.auditBy || '-' }}</text>
            </view>
            <view class="detail-row">
              <text class="detail-label">审核时间</text>
              <text class="detail-value">{{ formatTime(detailForm.auditTime) || '-' }}</text>
            </view>
            <view class="detail-row">
              <text class="detail-label">审核备注</text>
              <text class="detail-value">{{ detailForm.auditRemark || '-' }}</text>
            </view>
          </view>

          <view class="detail-section" v-if="detailForm.items && detailForm.items.length">
            <view class="section-title">方案明细</view>
            <view class="item-list">
              <view
                v-for="(item, idx) in detailForm.items"
                :key="item.planItemId || idx"
                class="item-card"
              >
                <view class="item-name">{{ item.productName }}</view>
                <view class="item-info">
                  <text>数量：{{ item.quantity }}</text>
                  <text>单价：¥{{ formatMoney(item.salePrice) }}</text>
                  <text class="item-amount">金额：¥{{ formatMoney(item.amount) }}</text>
                </view>
              </view>
            </view>
          </view>
        </scroll-view>

        <view
          class="detail-actions"
          v-if="detailForm.auditStatus === '1' && checkPermi('finance:planAudit:audit')"
        >
          <u-button type="success" text="通过" @click="handleAuditPass(detailForm)"></u-button>
          <u-button type="error" plain text="驳回" @click="handleAuditReject(detailForm)"></u-button>
        </view>
      </view>
    </u-popup>

    <!-- 驳回原因弹窗 -->
    <u-popup :show="rejectOpen" mode="center" round="16" @close="rejectOpen = false">
      <view class="reject-popup">
        <view class="reject-title">审核驳回</view>
        <view class="reject-form">
          <textarea
            class="reject-textarea"
            v-model="rejectForm.auditRemark"
            placeholder="请输入驳回原因"
            :maxlength="200"
          />
        </view>
        <view class="reject-actions">
          <u-button type="info" plain text="取消" @click="rejectOpen = false"></u-button>
          <u-button type="primary" text="确定" @click="submitReject"></u-button>
        </view>
      </view>
    </u-popup>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, computed, onUnmounted } from 'vue'
import { listPlanAudit, getPlanAudit, auditPlan } from '@/api/finance/planAudit'
import { getDicts } from '@/api/system/dictData'
import { checkPermi } from '@/utils/permission'

const planList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)
const detailOpen = ref(false)
const detailForm = ref({})
const rejectOpen = ref(false)
const rejectForm = ref({})

const auditStatusOptions = ref([])

let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const hasActiveFilters = computed(() => {
  return !!queryParams.auditStatus
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: '',
  auditStatus: ''
})

/** 加载审核状态字典 */
async function loadDicts() {
  try {
    const res = await getDicts('audit_status')
    auditStatusOptions.value = (res.data || []).map(item => ({
      label: item.dictLabel,
      value: item.dictValue
    }))
  } catch (e) {
    console.error('获取字典失败:', e)
  }
}

/** 根据审核状态值获取名称 */
function getAuditStatusName(value) {
  const item = auditStatusOptions.value.find(t => String(t.value) === String(value))
  if (item) return item.label
  const fallback = { '0': '草稿', '1': '待审核', '2': '已审核', '3': '已完成', '4': '已驳回' }
  return fallback[String(value)] || '未知'
}

/** 根据审核状态值获取样式类名 */
function getStatusClass(status) {
  return 'status-' + String(status || '0')
}

function formatMoney(value) {
  return Number(value || 0).toFixed(2)
}

function formatTime(time) {
  if (!time) return ''
  return time.substring(0, 16)
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
    // 保留 keyword 字段，由后端 BizPlanService::selectPlanList 对 planName/enterpriseName 做 OR 匹配

    const response = await listPlanAudit(params)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0

    if (isRefresh) {
      planList.value = list
    } else {
      planList.value = [...planList.value, ...list]
    }

    if (planList.value.length >= total) {
      loadStatus.value = 'nomore'
    } else {
      loadStatus.value = 'loadmore'
    }
  } catch (e) {
    console.error('获取方案审核列表失败:', e)
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
  queryParams.auditStatus = ''
}

function confirmFilter() {
  showFilter.value = false
  getList(true)
}

function clearFilter(field) {
  queryParams[field] = ''
  getList(true)
}

function handleView(row) {
  getPlanAudit(row.planId).then(response => {
    detailForm.value = response.data
    detailOpen.value = true
  })
}

function closeDetail() {
  detailOpen.value = false
}

function handleAuditPass(row) {
  uni.showModal({
    title: '提示',
    content: '确认审核通过该方案？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await auditPlan({ planId: row.planId, passed: true })
          uni.showToast({ title: '审核通过', icon: 'success' })
          detailOpen.value = false
          getList(true)
        } catch (e) {
          console.error('审核失败:', e)
        }
      }
    }
  })
}

function handleAuditReject(row) {
  rejectForm.value = { planId: row.planId, passed: false, auditRemark: '' }
  rejectOpen.value = true
}

async function submitReject() {
  if (!rejectForm.value.auditRemark) {
    uni.showToast({ title: '请输入驳回原因', icon: 'none' })
    return
  }
  try {
    await auditPlan({ planId: rejectForm.value.planId, passed: false, auditRemark: rejectForm.value.auditRemark })
    rejectOpen.value = false
    detailOpen.value = false
    uni.showToast({ title: '驳回成功', icon: 'success' })
    getList(true)
  } catch (e) {
    console.error('驳回失败:', e)
  }
}

onMounted(() => {
  loadDicts()
  getList(true)
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
  height: 100%;
  overflow: hidden;
}

.plan-audit-container {
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

.plan-card {
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

.header-left {
  display: flex;
  align-items: center;
  gap: 12rpx;
  flex: 1;
  min-width: 0;

  .plan-no {
    font-size: 28rpx;
    font-weight: 600;
    color: #1D2129;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
}

.status-tag {
  padding: 6rpx 16rpx;
  border-radius: 6rpx;
  font-size: 22rpx;
  font-weight: 500;
  flex-shrink: 0;

  &.status-0 { background: #F2F3F5; color: #86909C; }
  &.status-1 { background: #E8F0FE; color: #3D6DF7; }
  &.status-2 { background: #E8FFEA; color: #00B42A; }
  &.status-3 { background: #F0E8FF; color: #8B5CF6; }
  &.status-4 { background: #FFECE8; color: #F53F3F; }
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
    min-width: 100rpx;
  }

  .value {
    font-size: 26rpx;
    color: #1D2129;

    &.amount-text {
      color: #00B42A;
      font-weight: bold;
    }
  }
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

  &.pass {
    color: #00B42A;
    background: #E8FFEA;
  }

  &.reject {
    color: #F53F3F;
    background: #FFF1F0;
  }
}

/* 详情弹窗 */
.detail-popup {
  max-height: 85vh;
  display: flex;
  flex-direction: column;
  background: #fff;
  border-radius: 32rpx 32rpx 0 0;
  width: 100%;
  max-width: 100vw;
  box-sizing: border-box;
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
  padding: 30rpx;
  overflow-x: hidden;
  width: 100%;
  box-sizing: border-box;
}

.detail-section {
  margin-bottom: 30rpx;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 16rpx 0;
  border-bottom: 1rpx solid #F7F8FA;
  overflow: hidden;
  width: 100%;

  &:last-child {
    border-bottom: none;
  }
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
  min-width: 0;
  word-break: break-all;
  word-wrap: break-word;
  overflow-wrap: break-word;
  text-align: right;
  flex: 1;
  margin-left: 20rpx;

  &.amount-text {
    color: #00B42A;
    font-weight: bold;
  }
}

.section-title {
  font-size: 28rpx;
  font-weight: 600;
  color: #1D2129;
  margin-bottom: 20rpx;
  padding-left: 16rpx;
  border-left: 6rpx solid #3D6DF7;
}

.item-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.item-card {
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 20rpx;
}

.item-name {
  font-size: 26rpx;
  font-weight: 500;
  color: #1D2129;
  margin-bottom: 12rpx;
}

.item-info {
  display: flex;
  gap: 24rpx;
  font-size: 24rpx;
  color: #86909C;

  .item-amount {
    color: #00B42A;
    font-weight: 500;
  }
}

.detail-actions {
  display: flex;
  gap: 20rpx;
  padding: 20rpx 30rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  border-top: 1rpx solid #F2F3F5;

  .u-button {
    flex: 1;
  }
}

/* 驳回弹窗 */
.reject-popup {
  width: 600rpx;
  padding: 30rpx;
}

.reject-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #1D2129;
  text-align: center;
  margin-bottom: 30rpx;
}

.reject-form {
  margin-bottom: 30rpx;
}

.reject-textarea {
  width: 100%;
  height: 200rpx;
  background: #F5F7FA;
  border-radius: 12rpx;
  padding: 20rpx;
  font-size: 28rpx;
  color: #1D2129;
  box-sizing: border-box;
}

.reject-actions {
  display: flex;
  gap: 20rpx;

  .u-button {
    flex: 1;
  }
}
</style>
