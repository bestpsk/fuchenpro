<template>
  <view class="goal-form-container">
    <view class="form-card">
      <!-- 目标名称 -->
      <view class="form-item">
        <text class="form-label required">目标名称</text>
        <input class="form-input" type="text" v-model="form.goalName" placeholder="请输入目标名称" maxlength="100" />
      </view>

      <!-- 归属层级 -->
      <view class="form-item">
        <text class="form-label required">归属层级</text>
        <view class="radio-group">
          <view v-for="item in ownerTypeOptions" :key="item.value" class="radio-item" :class="{ active: form.ownerType === item.value }" @click="handleOwnerTypeChange(item.value)">
            <text>{{ item.label }}</text>
          </view>
        </view>
      </view>

      <!-- 归属对象 -->
      <view class="form-item" @click="openOwnerPicker">
        <text class="form-label required">归属对象</text>
        <view class="picker-value">
          <text :class="{ 'placeholder-text': !form.ownerName }">{{ form.ownerName || '请选择归属对象' }}</text>
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <!-- 周期类型 -->
      <view class="form-item" @click="showPeriodPicker = true">
        <text class="form-label required">周期类型</text>
        <view class="picker-value">
          <text :class="{ 'placeholder-text': !form.periodType }">{{ getPeriodTypeLabel(form.periodType) || '请选择周期类型' }}</text>
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <!-- 周期辅助选择 -->
      <view v-if="form.periodType" class="form-item" @click="openPeriodDatePicker">
        <text class="form-label required">{{ periodDateLabel }}</text>
        <view class="picker-value">
          <text :class="{ 'placeholder-text': !periodPickerValue }">{{ periodPickerValue || '请选择' }}</text>
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <!-- 起止日期显示 -->
      <view v-if="form.startDate" class="form-item">
        <text class="form-label">起止日期</text>
        <view class="date-display">
          <text class="date-text">{{ form.startDate }} ~ {{ form.endDate }}</text>
        </view>
      </view>

      <!-- 周期名称 -->
      <view class="form-item">
        <text class="form-label">周期名称</text>
        <input class="form-input" type="text" v-model="form.periodName" placeholder="自动生成或手动输入" />
      </view>

      <!-- 口径类型 -->
      <view class="form-item" @click="showMetricPicker = true">
        <text class="form-label required">口径类型</text>
        <view class="picker-value">
          <text :class="{ 'placeholder-text': !form.metricType }">{{ getMetricTypeLabel(form.metricType) || '请选择口径' }}</text>
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <!-- 目标值 -->
      <view class="form-item">
        <text class="form-label required">目标值</text>
        <view class="value-row">
          <input class="form-input value-input" type="digit" v-model="form.targetValue" placeholder="请输入目标值" />
          <input class="form-input unit-input" type="text" v-model="form.unit" placeholder="单位" />
        </view>
      </view>

      <!-- 品项（口径为4/5时） -->
      <view v-if="form.metricType === '4' || form.metricType === '5'" class="form-item" @click="openCardItemPicker">
        <text class="form-label">品项</text>
        <view class="picker-value">
          <text :class="{ 'placeholder-text': !cardItemName }">{{ cardItemName || '请选择品项' }}</text>
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <!-- 活动名称 -->
      <view class="form-item">
        <text class="form-label">活动名称</text>
        <input class="form-input" type="text" v-model="form.activityName" placeholder="活动专项目标，可选" maxlength="100" />
      </view>

      <!-- 备注 -->
      <view class="form-item form-item-column">
        <text class="form-label">备注</text>
        <textarea class="form-textarea" v-model="form.remark" placeholder="请输入备注" maxlength="500"></textarea>
      </view>
    </view>

    <!-- 底部按钮 -->
    <view class="bottom-bar">
      <view class="submit-btn" :class="{ disabled: submitting }" @click="submitForm">
        <text>{{ submitting ? '提交中...' : '确定' }}</text>
      </view>
    </view>

    <!-- 周期类型选择 -->
    <u-picker :show="showPeriodPicker" :columns="[periodTypeOptions]" keyName="label" @confirm="onPeriodConfirm" @cancel="showPeriodPicker = false" @close="showPeriodPicker = false"></u-picker>

    <!-- 口径类型选择 -->
    <u-picker :show="showMetricPicker" :columns="[metricTypeOptions]" keyName="label" @confirm="onMetricConfirm" @cancel="showMetricPicker = false" @close="showMetricPicker = false"></u-picker>

    <!-- 日期选择器 -->
    <u-datetime-picker :show="showDatePicker" :mode="datePickerMode" v-model="datePickerValue" @confirm="onDateConfirm" @cancel="showDatePicker = false" @close="showDatePicker = false"></u-datetime-picker>

    <!-- 归属对象选择弹窗 -->
    <u-popup :show="showOwnerPicker" mode="bottom" round="16" @close="showOwnerPicker = false">
      <view class="picker-popup">
        <view class="picker-popup-title">选择{{ form.ownerType === '2' ? '部门' : '用户' }}</view>
        <scroll-view scroll-y class="picker-popup-list">
          <view v-if="ownerLoading" class="picker-loading">加载中...</view>
          <view v-else-if="ownerOptions.length === 0" class="picker-empty">暂无数据</view>
          <view v-else v-for="item in ownerOptions" :key="item.id" class="picker-popup-item" :class="{ active: form.ownerId === item.id }" @click="selectOwner(item)">
            <text>{{ item.label }}</text>
            <u-icon v-if="form.ownerId === item.id" name="checkmark" size="16" color="#3D6DF7"></u-icon>
          </view>
        </scroll-view>
      </view>
    </u-popup>

    <!-- 品项选择弹窗 -->
    <u-popup :show="showCardItemPicker" mode="bottom" round="16" @close="showCardItemPicker = false">
      <view class="picker-popup">
        <view class="picker-popup-title">选择品项</view>
        <view class="picker-popup-search">
          <input class="search-input" type="text" v-model="cardItemKeyword" placeholder="搜索品项名称" confirm-type="search" @confirm="loadCardItemOptions" />
        </view>
        <scroll-view scroll-y class="picker-popup-list">
          <view v-if="cardItemLoading" class="picker-loading">加载中...</view>
          <view v-else-if="cardItemOptions.length === 0" class="picker-empty">暂无数据</view>
          <view v-else v-for="item in cardItemOptions" :key="item.cardItemId" class="picker-popup-item" :class="{ active: form.cardItemId === item.cardItemId }" @click="selectCardItem(item)">
            <text>{{ item.cardItemName }}</text>
            <u-icon v-if="form.cardItemId === item.cardItemId" name="checkmark" size="16" color="#3D6DF7"></u-icon>
          </view>
        </scroll-view>
      </view>
    </u-popup>
  </view>
</template>

<script setup>
/**
 * @description 目标表单页 - 新增/编辑目标，支持归属对象、周期、口径选择
 */
import { ref, reactive, computed } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import { addGoal, updateGoal, getGoal } from '@/api/goal'
import { listUser, deptTreeSelect } from '@/api/system/user'
import { listCardItem } from '@/api/business/cardItem'

const ownerTypeOptions = [
  { value: '2', label: '部门' },
  { value: '4', label: '个人' }
]
const periodTypeOptions = [
  { value: '1', label: '年度' },
  { value: '2', label: '季度' },
  { value: '3', label: '月度' },
  { value: '4', label: '自定义' }
]
const metricTypeOptions = [
  { value: '1', label: '实收业绩' },
  { value: '2', label: '消耗业绩' },
  { value: '3', label: '出货金额' },
  { value: '4', label: '品项件数' },
  { value: '5', label: '品项金额' },
  { value: '6', label: '到店客次' },
  { value: '7', label: '新客数' },
  { value: '8', label: '活跃门店数' }
]
const unitMap = { 1: '元', 2: '元', 3: '元', 5: '元', 4: '件', 6: '人次', 7: '人次', 8: '家' }
const quarterOptions = ['第1季度', '第2季度', '第3季度', '第4季度']

const submitting = ref(false)
const isEdit = ref(false)
const showPeriodPicker = ref(false)
const showMetricPicker = ref(false)
const showDatePicker = ref(false)
const showOwnerPicker = ref(false)
const showCardItemPicker = ref(false)
const datePickerMode = ref('date')
const datePickerValue = ref(Date.now())

// 归属对象选择
const ownerLoading = ref(false)
const ownerOptions = ref([])

// 品项选择
const cardItemLoading = ref(false)
const cardItemOptions = ref([])
const cardItemKeyword = ref('')
const cardItemName = ref('')

// 周期辅助值
const periodYear = ref('')
const periodQuarter = ref('')
const periodMonth = ref('')

const form = reactive({
  goalId: undefined,
  goalName: '',
  ownerType: '2',
  ownerId: undefined,
  ownerName: '',
  periodType: '',
  periodName: '',
  startDate: '',
  endDate: '',
  metricType: '',
  targetValue: '',
  unit: '',
  cardItemId: undefined,
  activityName: '',
  remark: ''
})

const periodDateLabel = computed(() => {
  const pt = form.periodType
  if (pt === '1') return '选择年度'
  if (pt === '2') return '选择季度'
  if (pt === '3') return '选择月份'
  if (pt === '4') return '选择日期范围'
  return '选择周期'
})

const periodPickerValue = computed(() => {
  const pt = form.periodType
  if (pt === '1') return periodYear.value
  if (pt === '2') return periodYear.value && periodQuarter.value ? `${periodYear.value} ${periodQuarter.value}` : ''
  if (pt === '3') return periodMonth.value
  if (pt === '4') return form.startDate ? `${form.startDate} ~ ${form.endDate}` : ''
  return ''
})

function getPeriodTypeLabel(val) {
  if (!val) return ''
  const item = periodTypeOptions.find(o => o.value === String(val))
  return item ? item.label : ''
}

function getMetricTypeLabel(val) {
  if (!val) return ''
  const item = metricTypeOptions.find(o => o.value === String(val))
  return item ? item.label : ''
}

function pad(n) {
  return n < 10 ? '0' + n : '' + n
}

function getMonthEnd(year, month) {
  const lastDay = new Date(Number(year), month, 0).getDate()
  return `${year}-${pad(month)}-${pad(lastDay)}`
}

function getQuarterRange(year, quarter) {
  const startMonth = (quarter - 1) * 3 + 1
  const endMonth = startMonth + 2
  return {
    start: `${year}-${pad(startMonth)}-01`,
    end: getMonthEnd(year, endMonth)
  }
}

function handleOwnerTypeChange(val) {
  if (form.ownerType === val) return
  form.ownerType = val
  form.ownerId = undefined
  form.ownerName = ''
  ownerOptions.value = []
}

async function openOwnerPicker() {
  showOwnerPicker.value = true
  ownerLoading.value = true
  try {
    if (form.ownerType === '2') {
      // 部门
      const res = await deptTreeSelect()
      const flatten = (tree) => {
        const result = []
        const walk = (nodes) => {
          for (const node of nodes) {
            result.push({ id: node.id, label: node.label })
            if (node.children && node.children.length > 0) {
              walk(node.children)
            }
          }
        }
        walk(tree)
        return result
      }
      ownerOptions.value = flatten(res.data || [])
    } else if (form.ownerType === '4') {
      // 个人
      const res = await listUser({ status: '0', pageNum: 1, pageSize: 100 })
      ownerOptions.value = (res.rows || []).map(u => ({
        id: u.userId,
        label: u.nickName || u.userName
      }))
    }
  } catch (e) {
    console.error('加载归属对象失败', e)
    ownerOptions.value = []
  } finally {
    ownerLoading.value = false
  }
}

function selectOwner(item) {
  form.ownerId = item.id
  form.ownerName = item.label
  showOwnerPicker.value = false
}

async function openCardItemPicker() {
  showCardItemPicker.value = true
  if (cardItemOptions.value.length === 0) {
    await loadCardItemOptions()
  }
}

async function loadCardItemOptions() {
  cardItemLoading.value = true
  try {
    const res = await listCardItem({ cardItemName: cardItemKeyword.value, pageNum: 1, pageSize: 50 })
    cardItemOptions.value = res.rows || []
  } catch (e) {
    console.error('加载品项失败', e)
    cardItemOptions.value = []
  } finally {
    cardItemLoading.value = false
  }
}

function selectCardItem(item) {
  form.cardItemId = item.cardItemId
  cardItemName.value = item.cardItemName
  showCardItemPicker.value = false
}

function onPeriodConfirm(e) {
  const item = e.value[0]
  form.periodType = item.value
  // 重置周期辅助值和起止日期
  periodYear.value = ''
  periodQuarter.value = ''
  periodMonth.value = ''
  form.startDate = ''
  form.endDate = ''
  form.periodName = ''
  showPeriodPicker.value = false
}

function onMetricConfirm(e) {
  const item = e.value[0]
  form.metricType = item.value
  form.unit = unitMap[item.value] || ''
  // 非品项口径清空品项
  if (item.value !== '4' && item.value !== '5') {
    form.cardItemId = undefined
    cardItemName.value = ''
  }
  showMetricPicker.value = false
}

function openPeriodDatePicker() {
  const pt = form.periodType
  if (pt === '1') {
    datePickerMode.value = 'year'
  } else if (pt === '3') {
    datePickerMode.value = 'year-month'
  } else if (pt === '4') {
    // 自定义日期范围，先选开始日期
    datePickerMode.value = 'date'
  }
  showDatePicker.value = true
}

function onDateConfirm(e) {
  const d = new Date(e.value)
  const pt = form.periodType

  if (pt === '1') {
    // 年度
    const year = d.getFullYear()
    form.startDate = `${year}-01-01`
    form.endDate = `${year}-12-31`
    form.periodName = `${year}年`
    periodYear.value = String(year)
  } else if (pt === '3') {
    // 月度
    const year = d.getFullYear()
    const month = d.getMonth() + 1
    form.startDate = `${year}-${pad(month)}-01`
    form.endDate = getMonthEnd(year, month)
    form.periodName = `${year}年${month}月`
    periodMonth.value = `${year}-${pad(month)}`
  } else if (pt === '4') {
    // 自定义日期
    const dateStr = `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
    if (!form.startDate) {
      form.startDate = dateStr
      // 继续选结束日期
      showDatePicker.value = false
      setTimeout(() => {
        uni.showModal({
          title: '选择结束日期',
          editable: true,
          placeholderText: 'YYYY-MM-DD',
          success: (res) => {
            if (res.confirm && res.content) {
              form.endDate = res.content
              form.periodName = `${form.startDate} ~ ${form.endDate}`
            }
          }
        })
      }, 200)
      return
    } else {
      form.endDate = dateStr
      form.periodName = `${form.startDate} ~ ${form.endDate}`
    }
  }
  showDatePicker.value = false
}

// 季度选择单独处理（用 actionSheet）
function openQuarterPicker() {
  uni.showActionSheet({
    itemList: quarterOptions,
    success: (res) => {
      const quarter = res.tapIndex + 1
      periodQuarter.value = quarterOptions[res.tapIndex]
      if (periodYear.value) {
        const { start, end } = getQuarterRange(Number(periodYear.value), quarter)
        form.startDate = start
        form.endDate = end
        form.periodName = `${periodYear.value}年第${quarter}季度`
      }
    }
  })
}

async function loadGoalInfo(goalId) {
  try {
    const res = await getGoal(goalId)
    const data = res.data || {}
    Object.assign(form, {
      goalId: data.goalId,
      goalName: data.goalName || '',
      ownerType: String(data.ownerType || '2'),
      ownerId: data.ownerId,
      ownerName: data.ownerName || '',
      periodType: String(data.periodType || ''),
      periodName: data.periodName || '',
      startDate: data.startDate || '',
      endDate: data.endDate || '',
      metricType: String(data.metricType || ''),
      targetValue: data.targetValue != null ? String(data.targetValue) : '',
      unit: data.unit || '',
      cardItemId: data.cardItemId,
      activityName: data.activityName || '',
      remark: data.remark || ''
    })
    // 回显品项名称
    if (form.cardItemId) {
      try {
        const cardRes = await listCardItem({ cardItemId: form.cardItemId, pageNum: 1, pageSize: 1 })
        if (cardRes.rows && cardRes.rows.length > 0) {
          cardItemName.value = cardRes.rows[0].cardItemName
        }
      } catch (e) {
        // 忽略品项名称加载失败
      }
    }
    // 反向同步周期辅助值
    if (form.startDate) {
      const yStr = form.startDate.substring(0, 4)
      if (form.periodType === '1') {
        periodYear.value = yStr
      } else if (form.periodType === '3') {
        periodMonth.value = form.startDate.substring(0, 7)
      }
    }
  } catch (e) {
    console.error('加载目标详情失败', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  }
}

function validateForm() {
  if (!form.goalName || !form.goalName.trim()) {
    uni.showToast({ title: '请输入目标名称', icon: 'none' })
    return false
  }
  if (!form.ownerId) {
    uni.showToast({ title: '请选择归属对象', icon: 'none' })
    return false
  }
  if (!form.periodType) {
    uni.showToast({ title: '请选择周期类型', icon: 'none' })
    return false
  }
  if (!form.startDate || !form.endDate) {
    uni.showToast({ title: '请设置起止日期', icon: 'none' })
    return false
  }
  if (!form.metricType) {
    uni.showToast({ title: '请选择口径类型', icon: 'none' })
    return false
  }
  if (form.targetValue === '' || form.targetValue === null) {
    uni.showToast({ title: '请输入目标值', icon: 'none' })
    return false
  }
  return true
}

async function submitForm() {
  if (submitting.value) return
  if (!validateForm()) return

  submitting.value = true
  try {
    const submitData = { ...form }
    submitData.targetValue = Number(submitData.targetValue) || 0
    if (isEdit.value) {
      await updateGoal(submitData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      await addGoal(submitData)
      uni.showToast({ title: '新增成功', icon: 'success' })
    }
    setTimeout(() => {
      uni.navigateBack()
    }, 1000)
  } catch (e) {
    console.error('提交失败', e)
  } finally {
    submitting.value = false
  }
}

onLoad((options) => {
  if (options.goalId) {
    isEdit.value = true
    loadGoalInfo(options.goalId)
  }
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
}

.goal-form-container {
  min-height: 100vh;
  padding: 16rpx 24rpx 160rpx;
}

.form-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 8rpx 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.form-item {
  display: flex;
  align-items: center;
  padding: 24rpx 0;
  border-bottom: 1rpx solid #F0F0F0;
  gap: 16rpx;

  &.form-item-column {
    flex-direction: column;
    align-items: flex-start;
    gap: 12rpx;
  }

  &:last-child {
    border-bottom: none;
  }
}

.form-label {
  width: 160rpx;
  font-size: 28rpx;
  color: #4E5969;
  flex-shrink: 0;

  &.required::before {
    content: '*';
    color: #f56c6c;
    margin-right: 4rpx;
  }
}

.form-input {
  flex: 1;
  font-size: 28rpx;
  color: #1D2129;
}

.value-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
  flex: 1;
}

.value-input {
  flex: 1;
}

.unit-input {
  width: 120rpx;
  text-align: center;
}

.form-textarea {
  width: 100%;
  min-height: 120rpx;
  background: #F5F7FA;
  border-radius: 12rpx;
  padding: 16rpx;
  font-size: 26rpx;
  color: #1D2129;
}

.radio-group {
  display: flex;
  gap: 16rpx;
  flex: 1;
}

.radio-item {
  padding: 12rpx 32rpx;
  border-radius: 8rpx;
  background: #F5F7FA;
  font-size: 26rpx;
  color: #4E5969;
  border: 1rpx solid transparent;

  &.active {
    color: #3D6DF7;
    background: #E8F0FE;
    border-color: #3D6DF7;
  }
}

.picker-value {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 28rpx;
  color: #1D2129;
}

.placeholder-text {
  color: #C9CDD4;
}

.date-display {
  flex: 1;
  text-align: right;
}

.date-text {
  font-size: 26rpx;
  color: #1D2129;
}

/* 底部按钮 */
.bottom-bar {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  padding: 16rpx 24rpx;
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
  background: #fff;
  box-shadow: 0 -2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.submit-btn {
  background: linear-gradient(135deg, #3D6DF7 0%, #5B8FF9 100%);
  color: #fff;
  text-align: center;
  padding: 24rpx 0;
  border-radius: 12rpx;
  font-size: 30rpx;
  font-weight: 600;

  &.disabled {
    opacity: 0.6;
  }
}

/* 选择弹窗 */
.picker-popup {
  padding: 24rpx;
  max-height: 60vh;
}

.picker-popup-title {
  font-size: 30rpx;
  font-weight: 700;
  color: #1D2129;
  text-align: center;
  margin-bottom: 16rpx;
}

.picker-popup-search {
  margin-bottom: 16rpx;
}

.picker-popup-list {
  max-height: 50vh;
}

.picker-popup-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24rpx 16rpx;
  border-bottom: 1rpx solid #F0F0F0;
  font-size: 28rpx;
  color: #1D2129;

  &.active {
    color: #3D6DF7;
    background: #E8F0FE;
  }
}

.picker-loading,
.picker-empty {
  text-align: center;
  padding: 60rpx 0;
  font-size: 26rpx;
  color: #86909C;
}

.search-input {
  background: #F5F7FA;
  border-radius: 8rpx;
  padding: 16rpx 24rpx;
  font-size: 26rpx;
  width: 100%;
}
</style>
