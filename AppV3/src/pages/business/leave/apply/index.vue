<template>
  <view class="form-container">
    <view class="form-section">
      <view class="section-title">
        <u-icon name="edit-pen-fill" size="18" color="#3D6DF7"></u-icon>
        <text class="section-title-text">请假信息</text>
      </view>

      <view class="form-field" @click="showTypePicker = true">
        <view class="field-input-box">
          <u-icon name="grid-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.typeName" placeholder="* 休假类型" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="openStartDatePicker">
        <view class="field-input-box">
          <u-icon name="calendar-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.startDate" placeholder="* 开始日期" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="showStartSegmentPicker = true">
        <view class="field-input-box">
          <u-icon name="clock-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="getSegmentName(form.startTimeSegment)" placeholder="* 开始时段" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="openEndDatePicker">
        <view class="field-input-box">
          <u-icon name="calendar-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.endDate" placeholder="* 结束日期" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="showEndSegmentPicker = true">
        <view class="field-input-box">
          <u-icon name="clock-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="getSegmentName(form.endTimeSegment)" placeholder="* 结束时段" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" v-if="form.leaveDays">
        <view class="field-input-box days-box">
          <u-icon name="rmb-circle-fill" size="18" color="#3D6DF7"></u-icon>
          <text class="days-label">请假天数</text>
          <text class="days-value">{{ form.leaveDays }} 天</text>
        </view>
      </view>

      <view class="form-field">
        <view class="field-textarea-box">
          <view class="textarea-prefix">
            <u-icon name="edit-pen" size="18" color="#86909C"></u-icon>
            <text class="prefix-text">事由</text>
          </view>
          <textarea class="field-textarea" v-model="form.reason" placeholder="请输入请假事由" placeholder-class="field-placeholder" :maxlength="500" auto-height></textarea>
        </view>
      </view>
    </view>

    <u-picker
      :show="showTypePicker"
      :columns="[typeColumns]"
      keyName="label"
      title="选择休假类型"
      @confirm="onTypeConfirm"
      @cancel="showTypePicker = false"
      @close="showTypePicker = false"
    ></u-picker>

    <u-datetime-picker
      :show="showStartDatePicker"
      mode="date"
      v-model="startDatePickerModel"
      @confirm="onStartDateConfirm"
      @cancel="showStartDatePicker = false"
      @close="showStartDatePicker = false"
    ></u-datetime-picker>

    <u-datetime-picker
      :show="showEndDatePicker"
      mode="date"
      v-model="endDatePickerModel"
      @confirm="onEndDateConfirm"
      @cancel="showEndDatePicker = false"
      @close="showEndDatePicker = false"
    ></u-datetime-picker>

    <!-- 开始时段选择 -->
    <u-popup :show="showStartSegmentPicker" mode="bottom" round="16" @close="showStartSegmentPicker = false">
      <view class="picker-popup">
        <view class="picker-header">
          <text class="picker-title">选择开始时段</text>
          <view class="picker-close" @click="showStartSegmentPicker = false">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <view class="segment-list">
          <view
            v-for="item in segmentOptions"
            :key="item.value"
            class="segment-item"
            :class="{ active: form.startTimeSegment === item.value }"
            @click="onStartSegmentSelect(item)"
          >
            <text class="segment-text">{{ item.label }}</text>
            <u-icon v-if="form.startTimeSegment === item.value" name="checkmark" size="18" color="#3D6DF7"></u-icon>
          </view>
        </view>
      </view>
    </u-popup>

    <!-- 结束时段选择 -->
    <u-popup :show="showEndSegmentPicker" mode="bottom" round="16" @close="showEndSegmentPicker = false">
      <view class="picker-popup">
        <view class="picker-header">
          <text class="picker-title">选择结束时段</text>
          <view class="picker-close" @click="showEndSegmentPicker = false">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <view class="segment-list">
          <view
            v-for="item in segmentOptions"
            :key="item.value"
            class="segment-item"
            :class="{ active: form.endTimeSegment === item.value }"
            @click="onEndSegmentSelect(item)"
          >
            <text class="segment-text">{{ item.label }}</text>
            <u-icon v-if="form.endTimeSegment === item.value" name="checkmark" size="18" color="#3D6DF7"></u-icon>
          </view>
        </view>
      </view>
    </u-popup>

    <view class="form-actions">
      <u-button type="primary" text="提交申请" :loading="submitting" @click="submitForm" :color="'#3D6DF7'"></u-button>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 请假申请页 - 员工提交请假申请
 * @description 包含休假类型选择、起止日期与时段选择、请假事由填写，
 * 提交时调用 addLeave 接口，成功后返回上一页
 */
import { ref, reactive, computed, onMounted } from 'vue'
import { addLeave, listAllLeaveType } from '@/api/business/leave'

const submitting = ref(false)
const showTypePicker = ref(false)
const showStartDatePicker = ref(false)
const showEndDatePicker = ref(false)
const showStartSegmentPicker = ref(false)
const showEndSegmentPicker = ref(false)
const typeColumns = ref([])

const segmentOptions = [
  { label: '全天', value: '1' },
  { label: '上午', value: '2' },
  { label: '下午', value: '3' }
]

const form = reactive({
  leaveType: '',
  typeName: '',
  startDate: '',
  endDate: '',
  startTimeSegment: '',
  endTimeSegment: '',
  leaveDays: 0,
  reason: ''
})

const startDatePickerModel = ref(Date.now())
const endDatePickerModel = ref(Date.now())

/** 根据时段编码获取时段名称 */
function getSegmentName(value) {
  if (!value) return ''
  const item = segmentOptions.find(s => s.value === String(value))
  return item ? item.label : ''
}

/** 加载启用的休假类型列表 */
async function loadLeaveTypes() {
  try {
    const response = await listAllLeaveType()
    const data = response.data || response
    const list = Array.isArray(data) ? data : (data.rows || [])
    typeColumns.value = list.map(item => ({
      label: item.typeName || item.name || '',
      value: String(item.leaveType ?? item.id ?? item.typeId)
    }))
  } catch (e) {
    console.error('加载休假类型失败:', e)
  }
}

/** 休假类型选择确认 */
function onTypeConfirm(e) {
  const item = e.value[0]
  form.leaveType = item.value
  form.typeName = item.label
  showTypePicker.value = false
  calcLeaveDays()
}

function formatDate(timestamp) {
  const d = new Date(timestamp)
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

function openStartDatePicker() {
  startDatePickerModel.value = form.startDate ? new Date(form.startDate).getTime() : Date.now()
  showStartDatePicker.value = true
}

function openEndDatePicker() {
  endDatePickerModel.value = form.endDate ? new Date(form.endDate).getTime() : Date.now()
  showEndDatePicker.value = true
}

function onStartDateConfirm(e) {
  const timestamp = Number(e.value)
  form.startDate = formatDate(timestamp)
  showStartDatePicker.value = false
  calcLeaveDays()
}

function onEndDateConfirm(e) {
  const timestamp = Number(e.value)
  form.endDate = formatDate(timestamp)
  showEndDatePicker.value = false
  calcLeaveDays()
}

function onStartSegmentSelect(item) {
  form.startTimeSegment = item.value
  showStartSegmentPicker.value = false
  calcLeaveDays()
}

function onEndSegmentSelect(item) {
  form.endTimeSegment = item.value
  showEndSegmentPicker.value = false
  calcLeaveDays()
}

/** 计算请假天数：全天按1天计，上午/下午按0.5天计 */
function calcLeaveDays() {
  if (!form.startDate || !form.endDate || !form.startTimeSegment || !form.endTimeSegment) {
    form.leaveDays = 0
    return
  }
  const start = new Date(form.startDate)
  const end = new Date(form.endDate)
  if (isNaN(start.getTime()) || isNaN(end.getTime())) {
    form.leaveDays = 0
    return
  }
  if (end < start) {
    form.leaveDays = 0
    return
  }
  const diffDays = Math.floor((end - start) / (1000 * 60 * 60 * 24)) + 1
  const startHalf = form.startTimeSegment !== '1' // 上午/下午为半天
  const endHalf = form.endTimeSegment !== '1'
  // 同一天：根据时段计算
  let days = diffDays
  if (diffDays === 1) {
    if (form.startTimeSegment === '1' && form.endTimeSegment === '1') {
      days = 1
    } else if (form.startTimeSegment === '1' || form.endTimeSegment === '1') {
      days = 1
    } else if (form.startTimeSegment === form.endTimeSegment) {
      days = 0.5
    } else {
      days = 1
    }
  } else {
    // 跨天：首尾按半天扣除
    if (startHalf) days -= 0.5
    if (endHalf) days -= 0.5
  }
  form.leaveDays = days > 0 ? days : 0
}

/** 校验并提交请假申请 */
async function submitForm() {
  if (!form.leaveType) { uni.showToast({ title: '请选择休假类型', icon: 'none' }); return }
  if (!form.startDate) { uni.showToast({ title: '请选择开始日期', icon: 'none' }); return }
  if (!form.startTimeSegment) { uni.showToast({ title: '请选择开始时段', icon: 'none' }); return }
  if (!form.endDate) { uni.showToast({ title: '请选择结束日期', icon: 'none' }); return }
  if (!form.endTimeSegment) { uni.showToast({ title: '请选择结束时段', icon: 'none' }); return }
  if (new Date(form.endDate) < new Date(form.startDate)) {
    uni.showToast({ title: '结束日期不能早于开始日期', icon: 'none' }); return
  }
  if (!form.reason) { uni.showToast({ title: '请输入请假事由', icon: 'none' }); return }

  submitting.value = true
  try {
    await addLeave({
      leaveTypeId: form.leaveType,
      typeName: form.typeName,
      startDate: form.startDate,
      endDate: form.endDate,
      startTimeSegment: form.startTimeSegment,
      endTimeSegment: form.endTimeSegment,
      leaveDays: form.leaveDays,
      reason: form.reason
    })
    uni.showToast({ title: '提交成功', icon: 'success' })
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('提交失败:', e)
    const msg = e?.msg || e?.message || '提交失败，请重试'
    uni.showToast({ title: msg, icon: 'none', duration: 2000 })
  } finally {
    submitting.value = false
  }
}

function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.redirectTo({ url: '/pages/business/leave/list/index' })
}

onMounted(() => {
  loadLeaveTypes()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }

.form-container { min-height: 100vh; padding-bottom: 140rpx; }

.form-section {
  margin: 24rpx;
  background: #fff;
  border-radius: 20rpx;
  padding: 32rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05);
}

.section-title {
  display: flex;
  align-items: center;
  gap: 10rpx;
  margin-bottom: 24rpx;
  padding-bottom: 20rpx;
  border-bottom: 1rpx solid #F2F3F5;
}

.section-title-text {
  font-size: 30rpx;
  font-weight: 600;
  color: #1D2129;
}

.form-field {
  margin-bottom: 20rpx;
  &:last-child { margin-bottom: 0; }
}

.field-input-box {
  display: flex;
  align-items: center;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 0 20rpx;
  height: 88rpx;
  gap: 16rpx;
  border: 2rpx solid transparent;
  transition: all 0.2s;

  &:active { background: #EFF0F1; }

  &.days-box {
    background: #E8F0FE;
  }
}

.field-input {
  flex: 1;
  font-size: 30rpx;
  color: #1D2129;
  height: 88rpx;
  line-height: 88rpx;
}

.field-placeholder { color: #C9CDD4; font-size: 30rpx; }

.days-label {
  font-size: 28rpx;
  color: #4E5969;
}

.days-value {
  font-size: 30rpx;
  font-weight: 600;
  color: #3D6DF7;
}

.field-textarea-box {
  display: flex;
  flex-direction: column;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 16rpx 20rpx;
  gap: 8rpx;
  border: 2rpx solid transparent;
}

.textarea-prefix {
  display: flex;
  align-items: center;
  gap: 10rpx;
}

.prefix-text {
  font-size: 26rpx;
  color: #86909C;
  font-weight: 500;
}

.field-textarea {
  width: 100%;
  min-height: 160rpx;
  font-size: 28rpx;
  color: #1D2129;
  line-height: 1.6;
}

.form-actions {
  position: fixed;
  left: 24rpx;
  right: 24rpx;
  bottom: 40rpx;
  z-index: 100;

  .u-button {
    width: 100%;
    height: 88rpx;
    border-radius: 44rpx;
    font-size: 30rpx;
    font-weight: 600;
  }
}

.picker-popup {
  background: #fff;
  border-radius: 24rpx 24rpx 0 0;
  max-height: 70vh;
  display: flex;
  flex-direction: column;
}

.picker-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28rpx 32rpx;
  border-bottom: 1rpx solid #F2F3F5;
}

.picker-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #1D2129;
}

.picker-close { padding: 8rpx; }

.segment-list {
  padding: 16rpx 32rpx 40rpx;
}

.segment-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28rpx 20rpx;
  border-bottom: 1rpx solid #F2F3F5;

  &:last-child { border-bottom: none; }

  &:active { background: #F7F8FA; }

  &.active .segment-text {
    color: #3D6DF7;
    font-weight: 600;
  }
}

.segment-text {
  font-size: 30rpx;
  color: #1D2129;
}
</style>
