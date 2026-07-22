<template>
  <view class="authuser-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.keyword"
          placeholder="搜索用户名/手机号"
          placeholder-class="search-placeholder"
          confirm-type="search"
          @input="onSearchInput"
          @confirm="handleSearch"
        />
        <view v-if="queryParams.keyword" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>
    </view>

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
              <text class="name-text">{{ item.nickName || item.userName || '-' }}</text>
            </view>
            <view class="status-tag" :class="item.status === '0' ? 'status-normal' : 'status-stop'">
              {{ item.status === '0' ? '正常' : '停用' }}
            </view>
          </view>

          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="label">用户名</text>
                <text class="value">{{ item.userName || '-' }}</text>
              </view>
              <view class="info-item">
                <text class="label">部门</text>
                <text class="value">{{ item.dept ? item.dept.deptName : (item.deptName || '-') }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">手机号</text>
                <text class="value">{{ item.phonenumber || '-' }}</text>
              </view>
              <view class="info-item">
                <text class="label">邮箱</text>
                <text class="value">{{ item.email || '-' }}</text>
              </view>
            </view>
          </view>

          <view class="card-footer">
            <text class="time-text">{{ formatTime(item.createTime) }}</text>
            <view v-if="checkPermi('system:role:remove')" class="action-btn cancel" @click.stop="handleCancelAuth(item)">
              <u-icon name="close-circle" size="14"></u-icon>
              <text>取消授权</text>
            </view>
          </view>
        </view>
      </view>

      <u-empty
        v-else-if="!loading"
        mode="data"
        text="暂无已分配用户"
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
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { allocatedUserList, authUserCancel } from '@/api/system/role'
import { checkPermi } from '@/utils/permission'

const dataList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const roleId = ref('')

let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: '',
  roleId: ''
})

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) {
    queryParams.pageNum = 1
    loadStatus.value = 'loadmore'
  }
  try {
    const params = { ...queryParams }
    // keyword 由后端 OR 查询 user_name/phonenumber
    const response = await allocatedUserList(params)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0
    dataList.value = isRefresh ? list : [...dataList.value, ...list]
    loadStatus.value = dataList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) {
    console.error('获取已分配用户列表失败:', e)
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

function handleCancelAuth(item) {
  uni.showModal({
    title: '提示',
    content: `确认要取消用户"${item.nickName || item.userName}"的角色授权吗?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await authUserCancel({ roleId: roleId.value, userId: item.userId })
          uni.showToast({ title: '取消授权成功', icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('取消授权失败:', e)
        }
      }
    }
  })
}

function formatTime(time) {
  if (!time) return ''
  return String(time).substring(0, 10)
}

onMounted(() => {
  const pages = getCurrentPages()
  const page = pages[pages.length - 1]
  const options = page.options || page.$page?.options || {}
  roleId.value = options.id || ''
  queryParams.roleId = roleId.value
  const name = options.name ? decodeURIComponent(options.name) : ''
  if (name) {
    uni.setNavigationBarTitle({ title: `分配用户-${name}` })
  }
  if (roleId.value) {
    getList(true)
  }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.authuser-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx; }

.search-section {
  flex-shrink: 0;
  padding: 20rpx 24rpx; margin-left: -24rpx; margin-right: -24rpx;
  background: linear-gradient(180deg, #3D6DF7 0%, #4A7AEF 100%);
}
.search-box {
  display: flex; align-items: center; background: #fff; border-radius: 36rpx;
  padding: 0 8rpx 0 28rpx; height: 72rpx; gap: 12rpx; box-sizing: border-box;
}
.search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; min-width: 0; }
.search-placeholder { color: #86909C; font-size: 28rpx; }
.clear-btn { flex-shrink: 0; padding: 8rpx; display: flex; align-items: center; }

.list-scroll { flex: 1; overflow: hidden; padding: 20rpx 0; }
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
.status-tag {
  padding: 6rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500;
  &.status-normal { background: #E8FFEA; color: #00B42A; }
  &.status-stop { background: #FFF1F0; color: #F53F3F; }
}
.card-body { padding: 20rpx 0; border-top: 1rpx solid #F2F3F5; border-bottom: 1rpx solid #F2F3F5; }
.info-row { display: flex; margin-bottom: 16rpx; &:last-child { margin-bottom: 0; } }
.info-item {
  flex: 1; display: flex; align-items: center; gap: 12rpx;
  .label { font-size: 24rpx; color: #86909C; min-width: 80rpx; }
  .value { font-size: 26rpx; color: #1D2129; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
}
.card-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 20rpx; }
.time-text { font-size: 22rpx; color: #C9CDD4; }
.action-btn {
  display: flex; align-items: center; gap: 6rpx; font-size: 24rpx;
  padding: 8rpx 14rpx; border-radius: 8rpx;
  &.cancel { color: #F53F3F; background: #FFF1F0; }
}
</style>
