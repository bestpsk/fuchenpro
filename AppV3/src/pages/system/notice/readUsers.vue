<template>
  <view class="readusers-container">
    <scroll-view
      scroll-y
      class="list-scroll"
      @scrolltolower="loadMore"
      refresher-enabled
      :refresher-triggered="refreshing"
      @refresherrefresh="onPullDownRefresh"
    >
      <view v-if="dataList.length > 0" class="card-list">
        <view
          v-for="item in dataList"
          :key="item.userId"
          class="user-card"
        >
          <view class="card-header">
            <view class="user-name">
              <u-icon name="account-fill" size="18" color="#3D6DF7"></u-icon>
              <text class="name-text">{{ item.nickName || '-' }}</text>
            </view>
          </view>

          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="label">登录名称</text>
                <text class="value">{{ item.userName || '-' }}</text>
              </view>
              <view class="info-item">
                <text class="label">所属部门</text>
                <text class="value dept-text">{{ item.dept ? item.dept.deptName : (item.deptName || '-') }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">手机号码</text>
                <text class="value">{{ item.phonenumber || '-' }}</text>
              </view>
              <view class="info-item">
                <text class="label">阅读时间</text>
                <text class="value">{{ formatTime(item.readTime) }}</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <u-empty
        v-else-if="!loading"
        mode="data"
        text="暂无已读用户"
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
import { ref, reactive, onMounted } from 'vue'
import { listNoticeReadUsers } from '@/api/system/notice'

const dataList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const noticeId = ref('')

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  noticeId: ''
})

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) {
    queryParams.pageNum = 1
    loadStatus.value = 'loadmore'
  }
  try {
    const response = await listNoticeReadUsers(queryParams)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0
    dataList.value = isRefresh ? list : [...dataList.value, ...list]
    loadStatus.value = dataList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) {
    console.error('获取已读用户列表失败:', e)
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

function formatTime(time) {
  if (!time) return ''
  return String(time).substring(0, 16)
}

onMounted(() => {
  const pages = getCurrentPages()
  const page = pages[pages.length - 1]
  const options = page.options || page.$page?.options || {}
  noticeId.value = options.noticeId || ''
  queryParams.noticeId = noticeId.value
  if (noticeId.value) {
    getList(true)
  }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.readusers-container { display: flex; flex-direction: column; height: 100%; padding: 24rpx; }

.list-scroll { flex: 1; overflow: hidden; }
.card-list { display: flex; flex-direction: column; gap: 20rpx; }
.user-card {
  background: #fff; border-radius: 16rpx; padding: 28rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.user-name {
  display: flex; align-items: center; gap: 12rpx;
  .name-text { font-size: 30rpx; font-weight: 600; color: #1D2129; }
}
.card-body { padding: 20rpx 0; border-top: 1rpx solid #F2F3F5; }
.info-row { display: flex; margin-bottom: 16rpx; &:last-child { margin-bottom: 0; } }
.info-item {
  flex: 1; display: flex; align-items: center; gap: 12rpx;
  .label { font-size: 24rpx; color: #86909C; min-width: 100rpx; }
  .value { font-size: 26rpx; color: #1D2129; &.dept-text { color: #3D6DF7; } }
}
</style>
