<template>
  <view class="detail-container">
    <view v-if="leave.leaveId" class="detail-content">
      <!-- 基本信息 -->
      <view class="info-section">
        <view class="section-title">
          <u-icon name="file-text-fill" size="18" color="#3D6DF7"></u-icon>
          <text class="section-title-text">基本信息</text>
        </view>
        <view class="info-card">
          <view class="info-row">
            <text class="label">单号</text>
            <text class="value">{{ leave.leaveNo || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="label">状态</text>
            <view class="status-tag" :class="getStatusClass(leave.status)">{{ getStatusName(leave.status) }}</view>
          </view>
          <view class="info-row">
            <text class="label">休假类型</text>
            <view class="type-tag">{{ leave.typeName || '未分类' }}</view>
          </view>
          <view class="info-row" v-if="leave.userName || leave.nickName">
            <text class="label">申请人</text>
            <text class="value">{{ leave.userName || leave.nickName }}</text>
          </view>
        </view>
      </view>

      <!-- 时间信息 -->
      <view class="info-section">
        <view class="section-title">
          <u-icon name="calendar-fill" size="18" color="#3D6DF7"></u-icon>
          <text class="section-title-text">时间信息</text>
        </view>
        <view class="info-card">
          <view class="info-row">
            <text class="label">开始日期</text>
            <text class="value">{{ leave.startDate }} {{ getSegmentName(leave.startTimeSegment) }}</text>
          </view>
          <view class="info-row">
            <text class="label">结束日期</text>
            <text class="value">{{ leave.endDate }} {{ getSegmentName(leave.endTimeSegment) }}</text>
          </view>
          <view class="info-row">
            <text class="label">请假天数</text>
            <text class="value days-value">{{ leave.leaveDays || 0 }} 天</text>
          </view>
        </view>
      </view>

      <!-- 事由 -->
      <view class="info-section">
        <view class="section-title">
          <u-icon name="edit-pen-fill" size="18" color="#3D6DF7"></u-icon>
          <text class="section-title-text">请假事由</text>
        </view>
        <view class="info-card">
          <text class="reason-text">{{ leave.reason || '无' }}</text>
        </view>
      </view>

      <!-- 审核信息 -->
      <view class="info-section" v-if="leave.status && leave.status !== '0'">
        <view class="section-title">
          <u-icon name="checkmark-circle-fill" size="18" color="#3D6DF7"></u-icon>
          <text class="section-title-text">审核信息</text>
        </view>
        <view class="info-card">
          <view class="info-row">
            <text class="label">审核人</text>
            <text class="value">{{ leave.approverName || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="label">审核时间</text>
            <text class="value">{{ leave.approveTime || '-' }}</text>
          </view>
          <view class="info-row" v-if="leave.approveRemark">
            <text class="label">审核备注</text>
            <text class="value remark-text">{{ leave.approveRemark }}</text>
          </view>
        </view>
      </view>

      <!-- 操作按钮 -->
      <view class="action-section" v-if="showActions">
        <view class="action-btns">
          <u-button
            v-if="canCancel"
            type="warning"
            plain
            text="撤销申请"
            @click="handleCancel"
          ></u-button>
          <u-button
            v-if="canApprove"
            type="primary"
            text="通过"
            @click="handleApprove"
            :color="'#3D6DF7'"
          ></u-button>
          <u-button
            v-if="canApprove"
            type="error"
            plain
            text="驳回"
            @click="openRejectPopup"
          ></u-button>
        </view>
      </view>
    </view>

    <u-empty v-else-if="!loading" mode="data" text="暂无数据" :marginTop="100"></u-empty>

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
            v-model="rejectRemark"
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
 * @description 请假详情页 - 查看请假详细信息并执行审核/撤销操作
 * @description 展示基本信息、时间信息、事由、审核信息，
 * 待审核状态下本人可撤销，有审核权限者可通过/驳回
 */
import { ref, reactive, computed, onMounted } from 'vue'
import { getLeave, approveLeave, rejectLeave, cancelLeave } from '@/api/business/leave'
import { useUserStore } from '@/store/modules/user'
import { checkPermi } from '@/utils/permission'

const userStore = useUserStore()

const leave = ref({})
const loading = ref(false)
const leaveId = ref(null)

const showRejectPopup = ref(false)
const rejecting = ref(false)
const rejectRemark = ref('')

const statusMap = {
  '0': { name: '待审核', class: 'status-info' },
  '1': { name: '已通过', class: 'status-success' },
  '2': { name: '已拒绝', class: 'status-danger' },
  '3': { name: '已撤销', class: 'status-warning' }
}

const segmentMap = { '1': '全天', '2': '上午', '3': '下午' }

function getStatusName(value) {
  return statusMap[String(value)] ? statusMap[String(value)].name : '-'
}

function getStatusClass(value) {
  return statusMap[String(value)] ? statusMap[String(value)].class : ''
}

function getSegmentName(value) {
  const v = String(value || '')
  return segmentMap[v] || ''
}

/** 是否为当前用户自己的请假 */
const isOwnLeave = computed(() => {
  if (!leave.value.userId) return false
  return String(leave.value.userId) === String(userStore.id)
})

/** 是否拥有审核权限 */
const hasApprovePermi = computed(() => checkPermi('business:leave:approve'))

/** 是否待审核状态 */
const isPending = computed(() => String(leave.value.status) === '0')

/** 是否显示操作按钮区 */
const showActions = computed(() => {
  if (!isPending.value) return false
  return isOwnLeave.value || hasApprovePermi.value
})

/** 是否可撤销（本人待审核） */
const canCancel = computed(() => isPending.value && isOwnLeave.value)

/** 是否可审核（有权限且待审核，且非本人申请避免自审） */
const canApprove = computed(() => isPending.value && hasApprovePermi.value && !isOwnLeave.value)

/** 加载请假详情 */
async function loadDetail() {
  if (!leaveId.value) return
  loading.value = true
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getLeave(leaveId.value)
    const data = response.data || response
    leave.value = data || {}
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    loading.value = false
    uni.hideLoading()
  }
}

/** 撤销请假申请 */
function handleCancel() {
  uni.showModal({
    title: '提示',
    content: '确认撤销该请假申请?',
    success: async (res) => {
      if (res.confirm) {
        try {
          await cancelLeave({ leaveId: leave.value.leaveId })
          uni.showToast({ title: '撤销成功', icon: 'success' })
          setTimeout(() => loadDetail(), 1000)
        } catch (e) {
          console.error('撤销失败:', e)
          const msg = e?.msg || e?.message || '操作失败'
          uni.showToast({ title: msg, icon: 'none' })
        }
      }
    }
  })
}

/** 通过请假申请 */
function handleApprove() {
  uni.showModal({
    title: '提示',
    content: '确认通过该请假申请?',
    success: async (res) => {
      if (res.confirm) {
        try {
          await approveLeave({ leaveId: leave.value.leaveId })
          uni.showToast({ title: '已通过', icon: 'success' })
          setTimeout(() => loadDetail(), 1000)
        } catch (e) {
          console.error('通过失败:', e)
          const msg = e?.msg || e?.message || '操作失败'
          uni.showToast({ title: msg, icon: 'none' })
        }
      }
    }
  })
}

function openRejectPopup() {
  rejectRemark.value = ''
  showRejectPopup.value = true
}

function closeRejectPopup() {
  showRejectPopup.value = false
  rejectRemark.value = ''
}

/** 确认驳回 */
async function confirmReject() {
  if (!rejectRemark.value) {
    uni.showToast({ title: '请输入驳回原因', icon: 'none' })
    return
  }
  rejecting.value = true
  try {
    await rejectLeave({
      leaveId: leave.value.leaveId,
      approveRemark: rejectRemark.value
    })
    uni.showToast({ title: '已驳回', icon: 'success' })
    closeRejectPopup()
    setTimeout(() => loadDetail(), 1000)
  } catch (e) {
    console.error('驳回失败:', e)
    const msg = e?.msg || e?.message || '操作失败'
    uni.showToast({ title: msg, icon: 'none' })
  } finally {
    rejecting.value = false
  }
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  leaveId.value = options.leaveId
  loadDetail()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }

.detail-container {
  min-height: 100vh;
  padding: 24rpx;
  padding-bottom: 160rpx;
}

.detail-content {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.info-section {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.section-title {
  display: flex;
  align-items: center;
  gap: 10rpx;
  margin-bottom: 20rpx;
  padding-bottom: 16rpx;
  border-bottom: 1rpx solid #F2F3F5;
}

.section-title-text {
  font-size: 30rpx;
  font-weight: 600;
  color: #1D2129;
}

.info-card {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.info-row {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.label {
  font-size: 26rpx;
  color: #86909C;
  width: 140rpx;
  flex-shrink: 0;
}

.value {
  font-size: 28rpx;
  color: #1D2129;
  flex: 1;

  &.days-value {
    color: #FF6B35;
    font-weight: 600;
  }

  &.remark-text {
    color: #4E5969;
    line-height: 1.5;
  }
}

.status-tag {
  padding: 6rpx 16rpx;
  border-radius: 6rpx;
  font-size: 22rpx;
  font-weight: 500;

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

.type-tag {
  padding: 6rpx 16rpx;
  background: #E8F0FE;
  color: #3D6DF7;
  border-radius: 6rpx;
  font-size: 24rpx;
  font-weight: 500;
}

.reason-text {
  font-size: 28rpx;
  color: #1D2129;
  line-height: 1.6;
}

.action-section {
  position: fixed;
  left: 24rpx;
  right: 24rpx;
  bottom: 40rpx;
  z-index: 100;
}

.action-btns {
  display: flex;
  gap: 20rpx;
  background: #fff;
  padding: 20rpx;
  border-radius: 24rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.08);

  .u-button {
    flex: 1;
    height: 80rpx;
    border-radius: 40rpx;
    font-size: 28rpx;
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
