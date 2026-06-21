<template>
  <view class="config-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.keyword"
          placeholder="搜索参数名称/键名"
          placeholder-class="search-placeholder"
          confirm-type="search"
          @input="onSearchInput"
          @confirm="handleSearch"
        />
        <view v-if="queryParams.keyword" class="clear-btn" @click="clearKeyword">
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
            v-if="queryParams.configType !== '' && queryParams.configType !== undefined"
            class="filter-tag active"
            @click="clearFilter('configType')"
          >
            <text>{{ getConfigTypeLabel(queryParams.configType) }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
        </view>
      </scroll-view>
    </view>

    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <view class="form-label">系统内置</view>
          <view class="form-options">
            <view
              v-for="dict in configTypeOptions"
              :key="dict.dictValue"
              class="option-tag"
              :class="{ active: queryParams.configType === dict.dictValue }"
              @click="queryParams.configType = queryParams.configType === dict.dictValue ? '' : dict.dictValue"
            >{{ dict.dictLabel }}</view>
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
      <view v-if="configList.length > 0" class="card-list">
        <view
          v-for="item in configList"
          :key="item.configId"
          class="config-card"
        >
          <view class="card-header">
            <view class="config-name">
              <u-icon name="setting-fill" size="18" color="#3D6DF7"></u-icon>
              <text class="name-text">{{ item.configName }}</text>
            </view>
            <view class="status-tag" :class="item.configType === 'Y' ? 'status-yes' : 'status-no'">
              {{ item.configType === 'Y' ? '内置' : '外置' }}
            </view>
          </view>

          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="label">键名</text>
                <text class="value key-text">{{ item.configKey || '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">键值</text>
                <text class="value">{{ item.configValue || '-' }}</text>
              </view>
            </view>
            <view v-if="item.remark" class="info-row">
              <view class="info-item">
                <text class="label">备注</text>
                <text class="value remark-text">{{ item.remark }}</text>
              </view>
            </view>
          </view>

          <view class="card-footer">
            <view class="time-text">编号: {{ item.configId }}</view>
            <view class="action-btns">
              <view v-if="checkPermi('system:config:edit')" class="action-btn edit" @click.stop="goEdit(item)">
                <u-icon name="edit-pen" size="14"></u-icon>
                <text>编辑</text>
              </view>
              <view v-if="checkPermi('system:config:remove')" class="action-btn delete" @click.stop="handleDelete(item)">
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
        text="暂无参数数据"
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

    <view v-if="checkPermi('system:config:add')" class="fab-btn" @click="goAdd">
      <u-icon name="plus" size="24" color="#fff"></u-icon>
    </view>

    <view v-if="checkPermi('system:config:remove')" class="cache-btn" @click="handleRefreshCache">
      <u-icon name="reload" size="18" color="#3D6DF7"></u-icon>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, computed, onUnmounted } from 'vue'
import { listConfig, delConfig, refreshCache } from '@/api/system/config'
import { checkPermi } from '@/utils/permission'
import { getDicts } from '@/api/system/dictData'

const configList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)
const configTypeOptions = ref([])

let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const hasActiveFilters = computed(() => {
  return queryParams.configType !== '' && queryParams.configType !== undefined
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: '',
  configName: '',
  configKey: '',
  configType: ''
})

function getConfigTypeLabel(type) {
  const dict = configTypeOptions.value.find(d => d.dictValue === type)
  return dict ? dict.dictLabel : type
}

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) {
    queryParams.pageNum = 1
    loadStatus.value = 'loadmore'
  }
  try {
    const params = { ...queryParams }
    if (params.keyword) {
      params.configName = params.keyword
      params.configKey = params.keyword
    }
    delete params.keyword
    const response = await listConfig(params)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0
    configList.value = isRefresh ? list : [...configList.value, ...list]
    loadStatus.value = configList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) {
    console.error('获取参数列表失败:', e)
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

function toggleFilter() {
  showFilter.value = !showFilter.value
}

function resetFilter() {
  queryParams.configType = ''
}

function confirmFilter() {
  showFilter.value = false
  getList(true)
}

function clearFilter(field) {
  if (field === 'configType') {
    queryParams.configType = ''
  }
  getList(true)
}

function goEdit(item) {
  uni.navigateTo({ url: `/pages/system/config/form?id=${item.configId}&mode=edit` })
}

function goAdd() {
  uni.navigateTo({ url: '/pages/system/config/form?mode=add' })
}

function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: `是否确认删除参数"${item.configName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delConfig(item.configId)
          uni.showToast({ title: '删除成功', icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('删除失败:', e)
        }
      }
    }
  })
}

function handleRefreshCache() {
  uni.showModal({
    title: '提示',
    content: '是否确认刷新参数缓存?',
    success: async (res) => {
      if (res.confirm) {
        try {
          await refreshCache()
          uni.showToast({ title: '刷新成功', icon: 'success' })
        } catch (e) {
          console.error('刷新缓存失败:', e)
        }
      }
    }
  })
}

async function loadDicts() {
  try {
    const res = await getDicts('sys_yes_no')
    configTypeOptions.value = res.data || []
  } catch (e) {
    console.error('获取字典失败:', e)
  }
}

onMounted(() => {
  loadDicts()
  getList(true)
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.config-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx;
  :deep(.u-popup) { flex: none !important; }
}

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
.config-card {
  background: #fff; border-radius: 16rpx; padding: 28rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
  &:active { transform: scale(0.98); opacity: 0.9; }
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.config-name {
  display: flex; align-items: center; gap: 12rpx; flex: 1; min-width: 0;
  .name-text { font-size: 30rpx; font-weight: 600; color: #1D2129; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
}
.status-tag {
  padding: 6rpx 16rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-yes { background: #E8F0FE; color: #3D6DF7; }
  &.status-no { background: #F2F3F5; color: #86909C; }
}
.card-body { padding: 20rpx 0; border-top: 1rpx solid #F2F3F5; border-bottom: 1rpx solid #F2F3F5; }
.info-row { display: flex; margin-bottom: 16rpx; &:last-child { margin-bottom: 0; } }
.info-item {
  flex: 1; display: flex; align-items: flex-start; gap: 12rpx;
  .label { font-size: 24rpx; color: #86909C; min-width: 60rpx; flex-shrink: 0; }
  .value { font-size: 26rpx; color: #1D2129; word-break: break-all; }
  .key-text { color: #3D6DF7; font-family: monospace; }
  .remark-text { color: #86909C; }
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
.cache-btn {
  position: fixed; right: 32rpx; bottom: 240rpx; width: 80rpx; height: 80rpx;
  border-radius: 50%; background: #fff;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.1);
  &:active { transform: scale(0.95); opacity: 0.9; }
}
</style>
