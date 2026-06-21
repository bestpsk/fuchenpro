<template>
  <view class="rule-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.ruleName"
          placeholder="搜索规则名称"
          placeholder-class="search-placeholder"
          confirm-type="search"
          @input="onSearchInput"
          @confirm="handleSearch"
        />
        <view v-if="queryParams.ruleName" class="clear-btn" @click="clearKeyword">
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
            v-if="queryParams.status !== '' && queryParams.status !== undefined"
            class="filter-tag active"
            @click="clearFilter('status')"
          >
            <text>{{ queryParams.status === '0' ? '正常' : '停用' }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
        </view>
      </scroll-view>
    </view>

    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <view class="form-label">状态</view>
          <view class="form-options">
            <view
              class="option-tag"
              :class="{ active: queryParams.status === '0' }"
              @click="queryParams.status = queryParams.status === '0' ? '' : '0'"
            >正常</view>
            <view
              class="option-tag"
              :class="{ active: queryParams.status === '1' }"
              @click="queryParams.status = queryParams.status === '1' ? '' : '1'"
            >停用</view>
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
      <view v-if="ruleList.length > 0" class="card-list">
        <view
          v-for="item in ruleList"
          :key="item.ruleId"
          class="rule-card"
        >
          <view class="card-header">
            <view class="rule-name">
              <u-icon name="clock-fill" size="18" color="#3D6DF7"></u-icon>
              <text class="name-text">{{ item.ruleName }}</text>
            </view>
            <view class="status-tag" :class="item.status === '0' ? 'status-normal' : 'status-stop'">
              {{ item.status === '0' ? '正常' : '停用' }}
            </view>
          </view>

          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="label">工作时间</text>
                <text class="value time-text">{{ item.workStartTime || '-' }} - {{ item.workEndTime || '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">迟到容忍</text>
                <text class="value">{{ item.lateTolerance != null ? item.lateTolerance + ' 分钟' : '-' }}</text>
              </view>
              <view class="info-item">
                <text class="label">早退容忍</text>
                <text class="value">{{ item.earlyLeaveTolerance != null ? item.earlyLeaveTolerance + ' 分钟' : '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item full">
                <text class="label">考勤地点</text>
                <text class="value address-text">{{ item.workAddress || '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">允许距离</text>
                <text class="value highlight">{{ item.allowedDistance != null ? item.allowedDistance + ' 米' : '-' }}</text>
              </view>
              <view v-if="checkPermi('business:attendance:rule:edit')" class="info-item">
                <text class="label">状态</text>
                <view class="switch-wrap" @click.stop="toggleStatus(item)">
                  <u-switch
                    :modelValue="item.status === '0'"
                    size="20"
                    activeColor="#3D6DF7"
                  ></u-switch>
                </view>
              </view>
            </view>
          </view>

          <view class="card-footer">
            <view class="time-text">{{ formatTime(item.createTime) }}</view>
            <view class="action-btns">
              <view v-if="checkPermi('business:attendance:rule:edit')" class="action-btn edit" @click.stop="handleEdit(item)">
                <u-icon name="edit-pen" size="14"></u-icon>
                <text>编辑</text>
              </view>
              <view v-if="checkPermi('business:attendance:rule:remove')" class="action-btn delete" @click.stop="handleDelete(item)">
                <u-icon name="trash" size="14"></u-icon>
                <text>删除</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <u-empty
        v-else-if="!loading"
        mode="data"
        text="暂无考勤规则"
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

    <view v-if="checkPermi('business:attendance:rule:add')" class="fab-btn" @click="handleAdd">
      <u-icon name="plus" size="24" color="#fff"></u-icon>
    </view>

    <u-popup :show="showForm" mode="bottom" round="20" @close="showForm = false">
      <view class="form-container">
        <view class="form-header">
          <text class="form-title">{{ isEdit ? '编辑考勤规则' : '新增考勤规则' }}</text>
          <view class="form-close" @click="showForm = false">
            <u-icon name="close" size="20" color="#86909C" />
          </view>
        </view>
        <scroll-view scroll-y class="form-scroll">
          <view class="form-item">
            <text class="form-label"><text class="required">*</text> 规则名称</text>
            <input class="form-input" v-model="form.ruleName" placeholder="请输入规则名称" />
          </view>
          <view class="form-item">
            <text class="form-label">上班时间</text>
            <picker mode="time" :value="form.workStartTime" @change="onStartTimeChange">
              <view class="form-picker">
                <text :class="{ 'picker-placeholder': !form.workStartTime }">
                  {{ form.workStartTime || '请选择上班时间' }}
                </text>
                <u-icon name="arrow-right" size="14" color="#86909C" />
              </view>
            </picker>
          </view>
          <view class="form-item">
            <text class="form-label">下班时间</text>
            <picker mode="time" :value="form.workEndTime" @change="onEndTimeChange">
              <view class="form-picker">
                <text :class="{ 'picker-placeholder': !form.workEndTime }">
                  {{ form.workEndTime || '请选择下班时间' }}
                </text>
                <u-icon name="arrow-right" size="14" color="#86909C" />
              </view>
            </picker>
          </view>
          <view class="form-item">
            <text class="form-label">迟到容忍(分钟)</text>
            <input class="form-input" type="number" v-model="form.lateTolerance" placeholder="请输入迟到容忍分钟数" />
          </view>
          <view class="form-item">
            <text class="form-label">早退容忍(分钟)</text>
            <input class="form-input" type="number" v-model="form.earlyLeaveTolerance" placeholder="请输入早退容忍分钟数" />
          </view>
          <view class="form-item">
            <text class="form-label">考勤地点</text>
            <view class="location-row">
              <input class="form-input location-input" v-model="form.workAddress" placeholder="请选择考勤地点" readonly @click="chooseLocation" />
              <view class="location-btn" @click="chooseLocation">
                <u-icon name="map" size="18" color="#3D6DF7"></u-icon>
              </view>
            </view>
            <view v-if="form.workLongitude || form.workLatitude" class="location-info">
              <text class="location-text">经度: {{ form.workLongitude }}  纬度: {{ form.workLatitude }}</text>
            </view>
          </view>
          <view class="form-item">
            <text class="form-label">允许距离(米)</text>
            <input class="form-input" type="number" v-model="form.allowedDistance" placeholder="请输入允许打卡距离" />
          </view>
          <view class="form-item">
            <text class="form-label">状态</text>
            <view class="radio-group">
              <view class="radio-item" :class="{ 'radio-active': form.status === '0' }" @click="form.status = '0'">
                <text>正常</text>
              </view>
              <view class="radio-item" :class="{ 'radio-active': form.status === '1' }" @click="form.status = '1'">
                <text>停用</text>
              </view>
            </view>
          </view>
          <view class="form-item">
            <text class="form-label">备注</text>
            <textarea class="form-textarea" v-model="form.remark" placeholder="请输入备注" maxlength="200" />
          </view>
        </scroll-view>
        <view class="form-footer">
          <view class="btn-cancel" @click="showForm = false">
            <text>取消</text>
          </view>
          <view class="btn-confirm" @click="submitForm">
            <text>确定</text>
          </view>
        </view>
      </view>
    </u-popup>
  </view>
</template>

<script setup>
/**
 * @description 考勤规则管理页 - 考勤规则CRUD
 * @description 展示考勤规则列表，支持按名称搜索、状态筛选、分页加载、下拉刷新、
 * 新增/编辑/删除规则、状态切换，表单包含时间选择、地图选点等功能
 */
import { ref, reactive, onMounted, computed, onUnmounted } from 'vue'
import { listAttendanceRule, getAttendanceRule, addAttendanceRule, updateAttendanceRule, delAttendanceRule } from '@/api/attendance'
import { checkPermi } from '@/utils/permission'

const ruleList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)
const showForm = ref(false)
const isEdit = ref(false)

let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const hasActiveFilters = computed(() => {
  return queryParams.status !== '' && queryParams.status !== undefined
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  ruleName: '',
  status: ''
})

const form = ref({
  ruleId: undefined,
  ruleName: '',
  workStartTime: '',
  workEndTime: '',
  lateTolerance: 0,
  earlyLeaveTolerance: 0,
  workAddress: '',
  workLongitude: '',
  workLatitude: '',
  allowedDistance: 500,
  status: '0',
  remark: ''
})

function formatTime(time) {
  if (!time) return ''
  return time.substring(0, 10)
}

/** 加载考勤规则列表，isRefresh为true时重置到第一页 */
async function getList(isRefresh = false) {
  if (loading.value) return

  loading.value = true
  if (isRefresh) {
    queryParams.pageNum = 1
    loadStatus.value = 'loadmore'
  }

  try {
    const params = { ...queryParams }
    const response = await listAttendanceRule(params)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0

    if (isRefresh) {
      ruleList.value = list
    } else {
      ruleList.value = [...ruleList.value, ...list]
    }

    if (ruleList.value.length >= total) {
      loadStatus.value = 'nomore'
    } else {
      loadStatus.value = 'loadmore'
    }
  } catch (e) {
    console.error('获取考勤规则列表失败:', e)
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
  queryParams.ruleName = ''
  handleSearch()
}

function toggleFilter() {
  showFilter.value = !showFilter.value
}

function resetFilter() {
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

function resetForm() {
  form.value = {
    ruleId: undefined,
    ruleName: '',
    workStartTime: '',
    workEndTime: '',
    lateTolerance: 0,
    earlyLeaveTolerance: 0,
    workAddress: '',
    workLongitude: '',
    workLatitude: '',
    allowedDistance: 500,
    status: '0',
    remark: ''
  }
}

function handleAdd() {
  resetForm()
  isEdit.value = false
  showForm.value = true
}

function handleEdit(item) {
  getAttendanceRule(item.ruleId).then(res => {
    const data = res.data || {}
    form.value = {
      ruleId: data.ruleId,
      ruleName: data.ruleName || '',
      workStartTime: data.workStartTime ? data.workStartTime.substring(0, 5) : '',
      workEndTime: data.workEndTime ? data.workEndTime.substring(0, 5) : '',
      lateTolerance: data.lateTolerance ?? 0,
      earlyLeaveTolerance: data.earlyLeaveTolerance ?? 0,
      workAddress: data.workAddress || '',
      workLongitude: data.workLongitude || '',
      workLatitude: data.workLatitude || '',
      allowedDistance: data.allowedDistance ?? 500,
      status: data.status || '0',
      remark: data.remark || ''
    }
    isEdit.value = true
    showForm.value = true
  })
}

function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: `是否确认删除考勤规则"${item.ruleName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delAttendanceRule(item.ruleId)
          uni.showToast({ title: '删除成功', icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('删除失败:', e)
        }
      }
    }
  })
}

/** 切换规则状态 */
function toggleStatus(item) {
  const newStatus = item.status === '0' ? '1' : '0'
  const statusText = newStatus === '0' ? '正常' : '停用'
  uni.showModal({
    title: '提示',
    content: `是否将规则"${item.ruleName}"状态改为${statusText}?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await updateAttendanceRule({ ...item, status: newStatus })
          uni.showToast({ title: '操作成功', icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('状态切换失败:', e)
        }
      }
    }
  })
}

function onStartTimeChange(e) {
  form.value.workStartTime = e.detail.value
}

function onEndTimeChange(e) {
  form.value.workEndTime = e.detail.value
}

/** 调用地图选择考勤地点 */
function chooseLocation() {
  uni.chooseLocation({
    success: (res) => {
      form.value.workAddress = res.address || res.name || ''
      form.value.workLatitude = String(res.latitude)
      form.value.workLongitude = String(res.longitude)
    },
    fail: (err) => {
      console.error('选择位置失败:', err)
    }
  })
}

function submitForm() {
  if (!form.value.ruleName) {
    uni.showToast({ title: '请输入规则名称', icon: 'none' })
    return
  }

  const submitData = {
    ...form.value,
    workStartTime: form.value.workStartTime ? form.value.workStartTime + ':00' : undefined,
    workEndTime: form.value.workEndTime ? form.value.workEndTime + ':00' : undefined,
    lateTolerance: Number(form.value.lateTolerance) || 0,
    earlyLeaveTolerance: Number(form.value.earlyLeaveTolerance) || 0,
    allowedDistance: Number(form.value.allowedDistance) || 0
  }

  const request = isEdit.value ? updateAttendanceRule(submitData) : addAttendanceRule(submitData)
  request.then(() => {
    uni.showToast({ title: isEdit.value ? '修改成功' : '新增成功', icon: 'success' })
    showForm.value = false
    getList(true)
  }).catch(err => {
    uni.showToast({ title: err.message || '操作失败', icon: 'none' })
  })
}

onMounted(() => {
  getList(true)
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
  height: 100%;
  overflow: hidden;
}

.rule-container {
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

.rule-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 28rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.rule-name {
  display: flex;
  align-items: center;
  gap: 12rpx;

  .name-text {
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

  &.status-normal {
    background: #E8FFEA;
    color: #00B42A;
  }

  &.status-stop {
    background: #FFF1F0;
    color: #F53F3F;
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

    &.time-text {
      color: #3D6DF7;
      font-weight: 500;
    }

    &.address-text {
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    &.highlight {
      color: #FF6B35;
      font-weight: 500;
    }
  }
}

.switch-wrap {
  display: flex;
  align-items: center;
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

  &.edit {
    color: #3D6DF7;
    background: #E8F0FE;
  }

  &.delete {
    color: #F53F3F;
    background: #FFF1F0;
  }
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

.form-container {
  max-height: 80vh;
  display: flex;
  flex-direction: column;
}

.form-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28rpx 32rpx;
  border-bottom: 1rpx solid #F0F0F0;
}

.form-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #1D2129;
}

.form-close {
  padding: 8rpx;
}

.form-scroll {
  flex: 1;
  padding: 24rpx 32rpx;
}

.form-item {
  margin-bottom: 28rpx;
}

.form-label {
  font-size: 26rpx;
  color: #4E5969;
  font-weight: 500;
  margin-bottom: 12rpx;
  display: block;

  .required {
    color: #F53F3F;
  }
}

.form-input {
  width: 100%;
  height: 76rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 0 20rpx;
  font-size: 26rpx;
  color: #1D2129;
  border: 2rpx solid #E5E6EB;
  box-sizing: border-box;
}

.form-textarea {
  width: 100%;
  height: 140rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 20rpx;
  font-size: 26rpx;
  color: #1D2129;
  border: 2rpx solid #E5E6EB;
  box-sizing: border-box;
}

.radio-group {
  display: flex;
  gap: 16rpx;
}

.radio-item {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 18rpx 0;
  border-radius: 12rpx;
  background: #F7F8FA;
  border: 2rpx solid #E5E6EB;
  font-size: 26rpx;
  color: #4E5969;
  transition: all 0.2s ease;
}

.radio-active {
  background: #F0F5FF;
  border-color: #3D6DF7;
  color: #3D6DF7;
  font-weight: 500;
}

.form-picker {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 76rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 0 20rpx;
  font-size: 26rpx;
  color: #1D2129;
  border: 2rpx solid #E5E6EB;
}

.picker-placeholder {
  color: #c0c4cc;
}

.location-row {
  display: flex;
  gap: 12rpx;
  align-items: center;
}

.location-input {
  flex: 1;
}

.location-btn {
  flex-shrink: 0;
  width: 76rpx;
  height: 76rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #F0F5FF;
  border-radius: 12rpx;
  border: 2rpx solid #E5E6EB;
}

.location-info {
  margin-top: 8rpx;
}

.location-text {
  font-size: 22rpx;
  color: #86909C;
}

.form-footer {
  display: flex;
  gap: 20rpx;
  padding: 24rpx 32rpx;
  border-top: 1rpx solid #F0F0F0;
}

.btn-cancel, .btn-confirm {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 22rpx 0;
  border-radius: 12rpx;
  font-size: 28rpx;
  font-weight: 500;
}

.btn-cancel {
  background: #F7F8FA;
  color: #4E5969;
  border: 1rpx solid #E5E6EB;
}

.btn-confirm {
  background: linear-gradient(180deg, #5B8FF9 0%, #3D6DF7 100%);
  color: #fff;
}
</style>
