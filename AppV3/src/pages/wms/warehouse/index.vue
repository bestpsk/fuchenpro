<template>
  <view class="warehouse-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="queryParams.keyword" placeholder="搜索仓库名称/编码" placeholder-class="search-placeholder" confirm-type="search" @input="onSearchInput" @confirm="handleSearch" />
        <view v-if="queryParams.keyword" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>
    </view>

    <view v-if="warehouseList.length > 0" class="card-list">
      <view v-for="item in warehouseList" :key="item.warehouseId" class="warehouse-card" @click="goDetail(item)">
        <view class="card-header">
          <text class="warehouse-name">{{ item.warehouseName || '-' }}</text>
          <view class="status-badge" :class="'status-' + item.status">{{ item.status === '0' ? '正常' : '停用' }}</view>
        </view>
        <view class="card-body">
          <view class="info-row">
            <view class="info-item">
              <text class="info-label">编码</text>
              <text class="info-value">{{ item.warehouseCode || '-' }}</text>
            </view>
            <view class="info-item">
              <text class="info-label">联系人</text>
              <text class="info-value">{{ item.contactPerson || '-' }}</text>
            </view>
          </view>
          <view class="info-row">
            <view class="info-item" @click.stop="item.contactPhone && callPhone(item.contactPhone)">
              <text class="info-label">电话</text>
              <text class="info-value" :class="{ 'phone-link': item.contactPhone }">{{ item.contactPhone || '-' }}</text>
            </view>
          </view>
          <view v-if="item.address" class="info-row single">
            <text class="info-label">地址</text>
            <text class="info-value address-text">{{ item.address }}</text>
          </view>
        </view>
        <view class="card-actions">
          <view class="action-btn edit-btn" @click.stop="goEdit(item)">
            <u-icon name="edit-pen" size="14" color="#3D6DF7"></u-icon>
            <text>编辑</text>
          </view>
          <view class="action-btn delete-btn" @click.stop="handleDelete(item)">
            <u-icon name="trash" size="14" color="#F53F3F"></u-icon>
            <text>删除</text>
          </view>
        </view>
      </view>
    </view>
    <u-empty v-else-if="!loading" mode="data" text="暂无仓库数据" :marginTop="100"></u-empty>
    <u-loadmore v-if="warehouseList.length > 0" :status="loadStatus" :loading-text="'加载中...'" :loadmore-text="'上拉加载更多'" :nomore-text="'没有更多了'" :marginTop="20" />

    <view class="fab-btn" @click="handleAdd">
      <u-icon name="plus" size="28" color="#fff"></u-icon>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onUnmounted } from 'vue'
import { onShow, onPullDownRefresh, onReachBottom } from '@dcloudio/uni-app'
import { listWarehouse, delWarehouse } from '@/api/wms/warehouse'

const warehouseList = ref([])
const loading = ref(false)
const loadStatus = ref('loadmore')

let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const queryParams = reactive({ pageNum: 1, pageSize: 10, keyword: '' })

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) { queryParams.pageNum = 1; loadStatus.value = 'loadmore' }
  try {
    const params = { pageNum: queryParams.pageNum, pageSize: queryParams.pageSize }
    if (queryParams.keyword) { params.warehouseName = queryParams.keyword; params.warehouseCode = queryParams.keyword }
    const response = await listWarehouse(params)
    const data = response.data || response
    const list = data.rows || data.items || []
    const total = data.total || 0
    warehouseList.value = isRefresh ? list : [...warehouseList.value, ...list]
    loadStatus.value = warehouseList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) { console.error('获取仓库列表失败:', e); loadStatus.value = 'error' }
  finally { loading.value = false }
}

function loadMore() {
  if (loading.value || loadStatus.value === 'nomore') return
  loadStatus.value = 'loading'
  queryParams.pageNum++
  getList()
}

onPullDownRefresh(async () => {
  try { await getList(true) }
  finally { uni.stopPullDownRefresh() }
})

onReachBottom(() => { loadMore() })

function handleSearch() { getList(true) }
function onSearchInput() { if (searchTimer) clearTimeout(searchTimer); searchTimer = setTimeout(() => handleSearch(), 500) }
function clearKeyword() { queryParams.keyword = ''; handleSearch() }

function callPhone(phone) { uni.makePhoneCall({ phoneNumber: phone }) }

function goDetail(item) {
  uni.navigateTo({ url: `/pages/wms/warehouse/detail?id=${item.warehouseId}` })
}

function goEdit(item) {
  uni.navigateTo({ url: `/pages/wms/warehouse/form?mode=edit&id=${item.warehouseId}` })
}

function handleAdd() {
  uni.navigateTo({ url: '/pages/wms/warehouse/form?mode=add' })
}

function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: '确认删除该仓库？删除后不可恢复。',
    success: async (res) => {
      if (res.confirm) {
        try {
          await delWarehouse(item.warehouseId)
          uni.showToast({ title: '删除成功', icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('删除失败:', e)
          const msg = e?.msg || e?.message || '删除失败，请重试'
          uni.showToast({ title: msg, icon: 'none', duration: 2000 })
        }
      }
    }
  })
}

onShow(() => { getList(true) })
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.warehouse-container { padding: 0 24rpx 160rpx; }

.search-section { position: sticky; top: 0; z-index: 10; background: #F5F7FA; padding: 20rpx 0; }
.search-box { display: flex; align-items: center; background: #fff; border-radius: 36rpx; padding: 0 28rpx; height: 72rpx; gap: 12rpx; box-sizing: border-box; box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.04); }
.search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; min-width: 0; }
.search-placeholder { color: #86909C; font-size: 28rpx; }
.clear-btn { flex-shrink: 0; padding: 8rpx; display: flex; align-items: center; }

.card-list { display: flex; flex-direction: column; gap: 16rpx; padding-top: 12rpx; }

.warehouse-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; transition: all 0.15s;
  &:active { transform: scale(0.985); background: #FAFBFC; }
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.warehouse-name { font-size: 30rpx; font-weight: 600; color: #1D2129; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; margin-right: 16rpx; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #e8f0fe; color: #3D6DF7; }
  &.status-1 { background: #F2F3F5; color: #86909C; }
}

.card-body { display: flex; flex-direction: column; gap: 12rpx; }
.info-row { display: flex; gap: 32rpx;
  &.single { gap: 12rpx; }
}
.info-item { display: flex; align-items: center; gap: 8rpx; flex: 1; min-width: 0; }
.info-label { font-size: 24rpx; color: #86909C; flex-shrink: 0; }
.info-value { font-size: 26rpx; color: #1D2129; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
  &.phone-link { color: #3D6DF7; }
  &.address-text { white-space: normal; overflow: visible; }
}

.card-actions { display: flex; justify-content: flex-end; gap: 16rpx; margin-top: 20rpx; padding-top: 20rpx; border-top: 1rpx solid #F2F3F5; }
.action-btn { display: flex; align-items: center; gap: 6rpx; padding: 10rpx 24rpx; border-radius: 28rpx; font-size: 26rpx; transition: all 0.15s;
  text { font-weight: 500; }
  &.edit-btn { background: #e8f0fe;
    text { color: #3D6DF7; }
  }
  &.delete-btn { background: #FEE8E8;
    text { color: #F53F3F; }
  }
  &:active { transform: scale(0.94); }
}

.fab-btn { position: fixed; right: 40rpx; bottom: 80rpx; width: 100rpx; height: 100rpx; border-radius: 50%; background: #3D6DF7; display: flex; align-items: center; justify-content: center; box-shadow: 0 8rpx 24rpx rgba(61,109,247,0.35); z-index: 100;
  &:active { transform: scale(0.92); }
}
</style>
