<template>
  <view class="approve-container">
    <view class="tabs-wrapper">
      <u-tabs :list="tabList" :current="currentTab" @click="onTabChange" :activeStyle="{ color: '#3D6DF7', fontWeight: 'bold' }" :lineColor="'#3D6DF7'" :scrollable="false"></u-tabs>
    </view>

    <scroll-view
      scroll-y
      class="list-scroll"
      @scrolltolower="loadMore"
      refresher-enabled
      :refresher-triggered="refreshing"
      @refresherrefresh="onPullDownRefresh"
    >
      <view v-if="leaveList.length > 0" class="card-list">
        <view
          v-for="item in leaveList"
          :key="item.leaveId"
          class="leave-card"
          @click="goDetail(item)"
        >
          <view class="card-header">
            <view class="applicant-info">
              <u-icon name="account-fill" size="16" color="#3D6DF7"></u-icon>
              <text class="applicant-name">{{ item.userName || item.nickName || '未知' }}</text>
            </view>
            <view class="status-tag" :class="getStatusClass(item.status)">{{ getStatusName(item.status) }}</view>
          </view>

          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="label">休假类型</text>
                <view class="type-tag">{{ item.typeName || '未分类' }}</view>
              </view>
              <view class="info-item">
                <text class="label">天数</text>
                <text class="days-value">{{ item.leaveDays || 0 }} 天</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item full">
                <text class="label">时间</text>
                <text class="value">{{ item.startDate }} {{ getSegmentShort(item.startTimeType) }} 至 {{ item.endDate }} {{ getSegmentShort(item.endTimeType) }}</text>
              </view>
            </view>
            <view class="info-row" v-if="item.reason">
              <view class="info-item full">
                <text class="label">事由</text>
                <text class="value reason-text">{{ item.reason }}</text>
              </view>
            </view>
          </view>

          <view class="card-footer" v-if="currentTab === 0">
            <view class="time-text">{{ formatTime(item.createTime) }}</view>
            <view class="action-btns">
              <view class="action-btn approve" @click.stop="handleApprove(item)">
                <u-icon name="checkmark-circle" size="14"></u-icon>
                <text>通过</text>
              </view>
              <view class="action-btn reject" @click.stop="openRejectPopup(item)">
                <u-icon name="close-circle" size="14"></u-icon>
                <text>驳回</text>
              </view>
            </view>
          </view>
          <view class="card-footer" v-else>
            <view class="time-text">{{ formatTime(item.createTime) }}</view>
            <view class="action-arrow">
              <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
            </view>
          </view>
        </view>
      </view>

      <u-empty
        v-else-if="!loading"
        mode="data"
        :text="currentTab === 0 ? '暂无待审核请假' : '暂无已处理请假'"
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

    <!-- 驳回弹窗 -->
    <u-popup :show="showRejectPopup" mode="bottom" round="16" @close="closeRejectPopup">
      <view class="reject-popup">
        <view class="popup-header">
          <text class="popup-title">驳回原因</text>
          <view class="popup-close" @click="closeRejectPopup">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <view class="popup-body">
          <view class="form-label">审核备注</view>
          <textarea
            class="reject-textarea"
            v-model="rejectForm.approveRemark"
            placeholder="请输入驳回原因"
            placeholder-class="field-placeholder"
            :maxlength="500"
            auto-height
          ></textarea>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="取消" @click="closeRejectPopup"></u-button>
          <u-button type="error" text="确认驳回" :loading="rejecting" @click="confirmReject" :color="'#F53F3F'"></u-button>
        </view>
      </view>
    </u-popup>
  </view>
</template>

<script setup>
/**
 * @description 请假审批页 - 管理者审批员工请假申请
 * @description Tab1: 待审核列表，提供通过/驳回操作
 * Tab2: 已处理列表，仅查看
 * 通过调用 approveLeave，驳回需填写原因后调用 rejectLeave
 */
import { ref, reactive, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listLeave, approveLeave, rejectLeave } from '@/api/business/leave'

const currentTab = ref(0)
const tabList = [
  { name: '待审核' },
  { name: '已处理' }
]

const leaveList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')

const showRejectPopup = ref(false)
const rejecting = ref(false)
const rejectForm = reactive({
  leaveId: null,
  approveRemark: ''
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  status: '0'
})

const statusMap = {
  '0': { name: '待审核', class: 'status-info' },
  '1': { name: '已通过', class: 'status-success' },
  '2': { name: '已拒绝', class: 'status-danger' },
  '3': { name: '已撤销', class: 'status-warning' }
}

const segmentMap = { '0': '全天', '1': '上午', '2': '下午' }

function getStatusName(value) {
  return statusMap[String(value)] ? statusMap[String(value)].name : '-'
}

function getStatusClass(value) {
  return statusMap[String(value)] ? statusMap[String(value)].class : ''
}

function getSegmentShort(value) {
  const v = String(value || '')
  return segmentMap[v] || ''
}

function formatTime(time) {
  if (!time) return ''
  return time.substring(0, 10)
}

function onTabChange(e) {
  currentTab.value = e.index
  if (currentTab.value === 0) {
    queryParams.status = '0'
  } else {
    queryParams.status = '1,2,3'
  }
  getList(true)
}

/** 加载请假审批列表 */
async function getList(isRefresh = false) {
  if (loading.value) return

  loading.value = true
  if (isRefresh) {
    queryParams.pageNum = 1
    loadStatus.value = 'loadmore'
  }

  try {
    const response = await listLeave({ ...queryParams })
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0

    if (isRefresh) {
      leaveList.value = list
    } else {
      leaveList.value = [...leaveList.value, ...list]
    }

    if (leaveList.value.length >= total) {
      loadStatus.value = 'nomore'
    } else {
      loadStatus.value = 'loadmore'
    }
  } catch (e) {
    console.error('获取审批列表失败:', e)
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

/** 通过请假申请 */
function handleApprove(item) {
  uni.showModal({
    title: '提示',
    content: `确认通过 ${item.userName || item.nickName || ''} 的请假申请?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await approveLeave({ leaveId: item.leaveId })
          uni.showToast({ title: '已通过', icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('通过失败:', e)
          const msg = e?.msg || e?.message || '操作失败'
          uni.showToast({ title: msg, icon: 'none' })
        }
      }
    }
  })
}

function openRejectPopup(item) {
  rejectForm.leaveId = item.leaveId
  rejectForm.approveRemark = ''
  showRejectPopup.value = true
}

function closeRejectPopup() {
  showRejectPopup.value = false
  rejectForm.leaveId = null
  rejectForm.approveRemark = ''
}

/** 确认驳回请假申请 */
async function confirmReject() {
  if (!rejectForm.approveRemark) {
    uni.showToast({ title: '请输入驳回原因', icon: 'none' })
    return
  }
  rejecting.value = true
  try {
    await rejectLeave({
      leaveId: rejectForm.leaveId,
      approveRemark: rejectForm.approveRemark
    })
    uni.showToast({ title: '已驳回', icon: 'success' })
    closeRejectPopup()
    getList(true)
  } catch (e) {
    console.error('驳回失败:', e)
    const msg = e?.msg || e?.message || '操作失败'
    uni.showToast({ title: msg, icon: 'none' })
  } finally {
    rejecting.value = false
  }
}

function goDetail(item) {
  uni.navigateTo({
    url: `/pages/business/leave/detail/index?leaveId=${item.leaveId}`
  })
}

onMounted(() => {
  getList(true)
})

onShow(() => {
  getList(true)
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
  height: 100%;
  overflow: hidden;
}

.approve-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
  padding: 0 24rpx;

  :deep(.u-popup) {
    flex: none !important;
  }
}

.tabs-wrapper {
  flex-shrink: 0;
  background: #fff;
  margin-left: -24rpx;
  margin-right: -24rpx;
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

.leave-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
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
  border-bottom: 1rpx solid #F2F3F5;
}

.applicant-info {
  display: flex;
  align-items: center;
  gap: 8rpx;
  flex: 1;
  min-width: 0;
}

.applicant-name {
  font-size: 28rpx;
  font-weight: 600;
  color: #1D2129;
}

.status-tag {
  padding: 6rpx 16rpx;
  border-radius: 6rpx;
  font-size: 22rpx;
  font-weight: 500;
  flex-shrink: 0;

  &.status-info {
    background: #E8F0FE;
    color: #3D6DF7;
  }

  &.status-success {
    background: #E8FFEA;
    color: #00B42A;
  }

  &.status-danger {
    background: #FFF1F0;
    color: #F53F3F;
  }

  &.status-warning {
    background: #FFF7E8;
    color: #FF7D00;
  }
}

.card-body {
  padding: 0;
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
    flex-shrink: 0;
  }

  .value {
    font-size: 26rpx;
    color: #1D2129;
    flex: 1;

    &.reason-text {
      color: #4E5969;
      line-height: 1.5;
    }
  }
}

.type-tag {
  padding: 4rpx 14rpx;
  background: #E8F0FE;
  color: #3D6DF7;
  border-radius: 6rpx;
  font-size: 22rpx;
  font-weight: 500;
}

.days-value {
  font-size: 26rpx;
  color: #FF6B35;
  font-weight: 600;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16rpx;
  padding-top: 16rpx;
  border-top: 1rpx solid #F2F3F5;
}

.time-text {
  font-size: 22rpx;
  color: #C9CDD4;
}

.action-arrow {
  display: flex;
  align-items: center;
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
  padding: 10rpx 20rpx;
  border-radius: 8rpx;

  &.approve {
    color: #00B42A;
    background: #E8FFEA;
  }

  &.reject {
    color: #F53F3F;
    background: #FFF1F0;
  }
}

.reject-popup {
  background: #fff;
  border-radius: 24rpx 24rpx 0 0;
  display: flex;
  flex-direction: column;
}

.popup-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28rpx 32rpx;
  border-bottom: 1rpx solid #F2F3F5;
}

.popup-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #1D2129;
}

.popup-close {
  padding: 8rpx;
}

.popup-body {
  padding: 24rpx 32rpx;
}

.form-label {
  font-size: 28rpx;
  color: #1D2129;
  font-weight: 500;
  margin-bottom: 16rpx;
}

.reject-textarea {
  width: 100%;
  min-height: 200rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 20rpx;
  font-size: 28rpx;
  color: #1D2129;
  line-height: 1.6;
  box-sizing: border-box;
}

.field-placeholder {
  color: #C9CDD4;
  font-size: 28rpx;
}

.popup-actions {
  display: flex;
  gap: 20rpx;
  padding: 20rpx 32rpx 40rpx;

  .u-button {
    flex: 1;
    height: 80rpx;
    border-radius: 40rpx;
    font-size: 28rpx;
  }
}
</style>
