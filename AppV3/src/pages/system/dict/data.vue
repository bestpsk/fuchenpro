<template>
  <view class="data-container">
    <view class="search-section">
      <view class="dict-type-header">
        <u-icon name="list" size="16" color="#fff"></u-icon>
        <text class="dict-type-label">{{ dictTypeName || dictType }}</text>
      </view>
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.dictLabel"
          placeholder="搜索字典标签"
          placeholder-class="search-placeholder"
          confirm-type="search"
          @input="onSearchInput"
          @confirm="handleSearch"
        />
        <view v-if="queryParams.dictLabel" class="clear-btn" @click="clearKeyword">
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
          <view class="form-label">数据状态</view>
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
      <view v-if="dataList.length > 0" class="card-list">
        <view
          v-for="item in dataList"
          :key="item.dictCode"
          class="data-card"
        >
          <view class="card-header">
            <view class="dict-label-row">
              <view class="label-tag" :class="getTagClass(item.cssClass)">
                {{ item.dictLabel }}
              </view>
            </view>
            <view class="status-tag" :class="item.status === '0' ? 'status-normal' : 'status-stop'">
              {{ item.status === '0' ? '正常' : '停用' }}
            </view>
          </view>

          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="label">键值</text>
                <text class="value">{{ item.dictValue }}</text>
              </view>
              <view class="info-item">
                <text class="label">排序</text>
                <text class="value">{{ item.dictSort }}</text>
              </view>
            </view>
            <view v-if="item.remark" class="info-row">
              <view class="info-item full">
                <text class="label">备注</text>
                <text class="value">{{ item.remark }}</text>
              </view>
            </view>
          </view>

          <view class="card-footer">
            <view class="time-text">编号: {{ item.dictCode }}</view>
            <view class="action-btns">
              <view v-if="checkPermi('system:dict:edit')" class="action-btn edit" @click.stop="goEdit(item)">
                <u-icon name="edit-pen" size="14"></u-icon>
                <text>编辑</text>
              </view>
              <view v-if="checkPermi('system:dict:remove')" class="action-btn delete" @click.stop="handleDelete(item)">
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
        text="暂无字典数据"
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

    <view v-if="checkPermi('system:dict:add')" class="fab-btn" @click="goAdd">
      <u-icon name="plus" size="24" color="#fff"></u-icon>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, computed, onUnmounted } from 'vue'
import { listData, delData } from '@/api/system/dictData'
import { checkPermi } from '@/utils/permission'

const dataList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)
const dictType = ref('')
const dictTypeName = ref('')

let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const hasActiveFilters = computed(() => {
  return queryParams.status !== '' && queryParams.status !== undefined
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  dictType: '',
  dictLabel: '',
  status: ''
})

function getTagClass(cssClass) {
  const classMap = {
    'default': 'tag-default',
    'primary': 'tag-primary',
    'success': 'tag-success',
    'info': 'tag-info',
    'warning': 'tag-warning',
    'danger': 'tag-danger'
  }
  return classMap[cssClass] || 'tag-default'
}

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) {
    queryParams.pageNum = 1
    loadStatus.value = 'loadmore'
  }
  try {
    const response = await listData(queryParams)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0
    dataList.value = isRefresh ? list : [...dataList.value, ...list]
    loadStatus.value = dataList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) {
    console.error('获取字典数据列表失败:', e)
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
  queryParams.dictLabel = ''
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
  if (field === 'status') {
    queryParams.status = ''
  }
  getList(true)
}

function goEdit(item) {
  uni.navigateTo({ url: `/pages/system/dict/dataForm?mode=edit&id=${item.dictCode}&dictType=${dictType.value}` })
}

function goAdd() {
  uni.navigateTo({ url: `/pages/system/dict/dataForm?mode=add&dictType=${dictType.value}` })
}

function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: `是否确认删除字典数据"${item.dictLabel}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delData(item.dictCode)
          uni.showToast({ title: '删除成功', icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('删除失败:', e)
        }
      }
    }
  })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  dictType.value = options.dictType || ''
  queryParams.dictType = dictType.value
  dictTypeName.value = options.dictType || ''

  if (dictType.value) {
    uni.setNavigationBarTitle({ title: '字典数据' })
  }

  getList(true)
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.data-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx;
  :deep(.u-popup) { flex: none !important; }
}

.search-section {
  flex-shrink: 0;
  padding: 20rpx 24rpx; margin-left: -24rpx; margin-right: -24rpx;
  background: linear-gradient(180deg, #3D6DF7 0%, #4A7AEF 100%);
}
.dict-type-header {
  display: flex; align-items: center; gap: 8rpx; margin-bottom: 16rpx;
}
.dict-type-label { font-size: 26rpx; color: rgba(255, 255, 255, 0.9); font-weight: 500; }
.search-box {
  display: flex; align-items: center; background: #fff; border-radius: 36rpx;
  padding: 0 8rpx 0 28rpx; height: 72rpx; gap: 12rpx; box-sizing: border-box;
}
.search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; min-width: 0; }
.search-placeholder { color: #86909C; font-size: 28rpx; }
.clear-btn { flex-shrink: 0; padding: 8rpx; display: flex; align-items: center; }
.filter-btn {
  flex-shrink: 0; display: flex; align-items: center; justify-content: center;
  gap: 4rpx; height: 56rpx; padding: 0 22rpx; background: #E8F0FE; border-radius: 28rpx;
  text { font-size: 26rpx; color: #3D6DF7; font-weight: 500; white-space: nowrap; }
  .icon-rotate { transform: rotate(180deg); transition: transform 0.3s ease; }
}

.active-filters {
  flex-shrink: 0;
  padding: 12rpx 24rpx 16rpx; margin-left: -24rpx; margin-right: -24rpx;
  background: linear-gradient(180deg, #4A7AEF 0%, #F5F7FA 100%);
}
.filter-scroll { white-space: nowrap; }
.filter-tags { display: inline-flex; gap: 16rpx; padding: 16rpx 0; }
.filter-tag {
  display: inline-flex; align-items: center; gap: 8rpx; padding: 10rpx 20rpx;
  background: rgba(255, 255, 255, 0.2); border-radius: 28rpx; font-size: 24rpx; color: #fff;
  &.active { background: #fff; color: #3D6DF7; }
}

.popup-content { padding: 30rpx; background: #fff; }
.popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; margin-bottom: 30rpx; }
.form-item { margin-bottom: 30rpx; }
.form-label { font-size: 28rpx; color: #1D2129; font-weight: 500; margin-bottom: 16rpx; }
.form-options { display: flex; flex-wrap: wrap; gap: 16rpx; }
.option-tag {
  padding: 14rpx 28rpx; background: #F5F7FA; border-radius: 8rpx; font-size: 26rpx;
  color: #4E5969; border: 2rpx solid transparent;
  &.active { background: #E8F0FE; color: #3D6DF7; border-color: #3D6DF7; }
}
.popup-actions {
  display: flex; gap: 20rpx; margin-top: 40rpx; padding-top: 30rpx; border-top: 1rpx solid #E5E6EB;
  .u-button { flex: 1; }
}

.list-scroll { flex: 1; overflow: hidden; padding: 20rpx 0; }
.card-list { display: flex; flex-direction: column; gap: 20rpx; }
.data-card {
  background: #fff; border-radius: 16rpx; padding: 28rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
  &:active { transform: scale(0.98); opacity: 0.9; }
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.dict-label-row { display: flex; align-items: center; gap: 12rpx; }
.label-tag {
  padding: 8rpx 20rpx; border-radius: 8rpx; font-size: 26rpx; font-weight: 500;
  &.tag-default { background: #F2F3F5; color: #4E5969; }
  &.tag-primary { background: #E8F0FE; color: #3D6DF7; }
  &.tag-success { background: #E8FFEA; color: #00B42A; }
  &.tag-info { background: #E8F7FF; color: #0FC6C2; }
  &.tag-warning { background: #FFF7E8; color: #FF7D00; }
  &.tag-danger { background: #FFF1F0; color: #F53F3F; }
}
.status-tag {
  padding: 6rpx 16rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500;
  &.status-normal { background: #E8FFEA; color: #00B42A; }
  &.status-stop { background: #FFF1F0; color: #F53F3F; }
}
.card-body { padding: 20rpx 0; border-top: 1rpx solid #F2F3F5; border-bottom: 1rpx solid #F2F3F5; }
.info-row { display: flex; margin-bottom: 16rpx; &:last-child { margin-bottom: 0; } }
.info-item {
  flex: 1; display: flex; align-items: center; gap: 12rpx;
  &.full { flex: none; width: 100%; }
  .label { font-size: 24rpx; color: #86909C; min-width: 60rpx; }
  .value { font-size: 26rpx; color: #1D2129; }
}
.card-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 20rpx; padding-top: 16rpx; }
.time-text { font-size: 22rpx; color: #C9CDD4; }
.action-btns { display: flex; gap: 16rpx; }
.action-btn {
  display: flex; align-items: center; gap: 6rpx; font-size: 24rpx;
  padding: 8rpx 14rpx; border-radius: 8rpx;
  &.edit { color: #3D6DF7; background: #E8F0FE; }
  &.delete { color: #F53F3F; background: #FFF1F0; }
}
.fab-btn {
  position: fixed; right: 32rpx; bottom: 120rpx; width: 100rpx; height: 100rpx;
  border-radius: 50%; background: linear-gradient(135deg, #3D6DF7, #5B8DEF);
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 8rpx 24rpx rgba(61, 109, 247, 0.4);
  &:active { transform: scale(0.95); opacity: 0.9; }
}
</style>
