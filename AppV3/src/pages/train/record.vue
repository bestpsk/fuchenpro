<template>
  <view class="record-container">
    <scroll-view
      scroll-y
      class="list-scroll"
      @scrolltolower="loadMore"
      refresher-enabled
      :refresher-triggered="refreshing"
      @refresherrefresh="onPullDownRefresh"
    >
      <view v-if="logList.length > 0" class="card-list">
        <view
          v-for="(item, index) in logList"
          :key="item.logId"
          class="record-card"
        >
          <view class="card-header">
            <view class="material-name">
              <u-icon name="file-text-fill" size="16" color="#3D6DF7"></u-icon>
              <text class="name-text">{{ item.materialTitle || '未知材料' }}</text>
            </view>
            <view class="status-tag" :class="getStatusClass(item.status)">
              {{ getStatusName(item.status) }}
            </view>
          </view>

          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="label">开始时间</text>
                <text class="value">{{ item.startTime }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">结束时间</text>
                <text class="value">{{ item.endTime || '学习中' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">有效时长</text>
                <text class="value highlight">{{ formatDuration(item.validDuration) }}</text>
              </view>
              <view class="info-item">
                <text class="label">切屏</text>
                <text class="value" :class="{ warn: item.switchCount > 0 }">{{ item.switchCount || 0 }}次</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <u-empty
        v-else-if="!loading"
        mode="data"
        text="暂无学习记录"
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
  </view>
</template>

<script setup>
/**
 * @description 我的学习记录页 - 展示当前用户的学习历史
 */
import { ref, reactive, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listMyStudyLog } from '@/api/train/material'
import { getDicts } from '@/api/system/dictData'

const logList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')

const statusOptions = ref([])

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10
})

function getStatusName(value) {
  const item = statusOptions.value.find(s => s.value === value)
  return item ? item.label : '未知'
}

function getStatusClass(value) {
  if (value === '0') return 'status-progress'
  if (value === '1') return 'status-done'
  return 'status-abnormal'
}

function formatDuration(seconds) {
  if (!seconds) return '0秒'
  const m = Math.floor(seconds / 60)
  const s = seconds % 60
  return m > 0 ? `${m}分${s}秒` : `${s}秒`
}

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) {
    queryParams.pageNum = 1
    loadStatus.value = 'loadmore'
  }
  try {
    const response = await listMyStudyLog(queryParams)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0
    if (isRefresh) {
      logList.value = list
    } else {
      logList.value = [...logList.value, ...list]
    }
    loadStatus.value = logList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) {
    console.error('获取学习记录失败:', e)
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
  if (loading.value) {
    refreshing.value = false
    return
  }
  refreshing.value = true
  getList(true)
}

onMounted(async () => {
  try {
    const res = await getDicts('biz_train_study_status')
    statusOptions.value = (res.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
  } catch (e) {
    console.warn('加载字典失败', e)
  }
  getList(true)
})

const isFirstShow = ref(true)
onShow(() => {
  if (isFirstShow.value) {
    isFirstShow.value = false
    return
  }
  getList(true)
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
  height: 100%;
  overflow: hidden;
}

.record-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
  padding: 0 24rpx;
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

.record-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16rpx;
  padding-bottom: 16rpx;
  border-bottom: 1rpx solid #F2F3F5;
}

.material-name {
  display: flex;
  align-items: center;
  gap: 8rpx;
  flex: 1;
  min-width: 0;

  .name-text {
    font-size: 30rpx;
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

  &.status-progress {
    background: #E8F0FE;
    color: #3D6DF7;
  }

  &.status-done {
    background: #E6F7F1;
    color: #10B981;
  }

  &.status-abnormal {
    background: #FFF1F0;
    color: #F53F3F;
  }
}

.card-body {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.info-row {
  display: flex;
  gap: 24rpx;
}

.info-item {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12rpx;

  .label {
    font-size: 24rpx;
    color: #86909C;
    min-width: 80rpx;
  }

  .value {
    font-size: 26rpx;
    color: #1D2129;

    &.highlight {
      color: #3D6DF7;
      font-weight: 500;
    }

    &.warn {
      color: #FF9F1F;
    }
  }
}
</style>
