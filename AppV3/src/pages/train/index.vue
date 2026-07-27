<template>
  <view class="train-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.keyword"
          placeholder="搜索材料标题"
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

    <scroll-view scroll-x class="category-tabs">
      <view class="tab-list">
        <view
          class="tab-item"
          :class="{ active: queryParams.category === '' }"
          @click="switchCategory('')"
        >全部</view>
        <view
          v-for="item in categoryOptions"
          :key="item.value"
          class="tab-item"
          :class="{ active: queryParams.category === item.value }"
          @click="switchCategory(item.value)"
        >{{ item.label }}</view>
      </view>
    </scroll-view>

    <scroll-view
      scroll-y
      class="list-scroll"
      @scrolltolower="loadMore"
      refresher-enabled
      :refresher-triggered="refreshing"
      @refresherrefresh="onPullDownRefresh"
    >
      <view v-if="materialList.length > 0" class="card-list">
        <view
          v-for="(item, index) in materialList"
          :key="item.materialId"
          class="material-card"
          @click="goStudy(item)"
        >
          <view class="card-top">
            <image
              v-if="item.coverUrl"
              class="cover-img"
              :src="getFullUrl(item.coverUrl)"
              mode="aspectFill"
            />
            <view v-else class="cover-placeholder">
              <u-icon name="file-text" size="32" color="#C9CDD4"></u-icon>
            </view>
            <view class="card-info">
              <view class="material-title">
                <u-icon name="file-text-fill" size="16" color="#3D6DF7"></u-icon>
                <text class="title-text">{{ item.title }}</text>
              </view>
              <view class="tag-row">
                <view class="category-tag">{{ getCategoryName(item.category) }}</view>
                <view class="type-tag">{{ getFileTypeName(item.fileType) }}</view>
              </view>
              <view class="duration-row">
                <u-icon name="clock" size="13" color="#86909C"></u-icon>
                <text class="duration-text">建议学习 {{ formatDuration(item.studyDuration) }}</text>
              </view>
            </view>
          </view>
          <view class="card-actions">
            <view
              v-if="checkPermi('train:material:query')"
              class="action-btn download"
              @click.stop="handleDownload(item)"
            >
              <u-icon name="download" size="14" color="#00B42A"></u-icon>
              <text>下载</text>
            </view>
            <view
              v-if="checkPermi('train:material:edit')"
              class="action-btn edit"
              @click.stop="goEdit(item)"
            >
              <u-icon name="edit-pen" size="14" color="#3D6DF7"></u-icon>
              <text>修改</text>
            </view>
            <view
              v-if="checkPermi('train:material:remove')"
              class="action-btn delete"
              @click.stop="handleDelete(item)"
            >
              <u-icon name="trash" size="14" color="#F53F3F"></u-icon>
              <text>删除</text>
            </view>
          </view>
        </view>
      </view>

      <u-empty
        v-else-if="!loading"
        mode="data"
        text="暂无学习材料"
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

    <view v-if="checkPermi('train:material:add')" class="fab-btn" @click="goAdd">
      <u-icon name="plus" size="28" color="#fff"></u-icon>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 培训学习材料列表页
 * @description 展示可学习的培训材料，支持分类切换、关键词搜索、分页加载
 */
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listMaterial, delMaterial } from '@/api/train/material'
import { getDicts } from '@/api/system/dictData'
import { checkPermi } from '@/utils/permission'
import config from '@/config'

const BASE_URL = config.baseUrl || ''

const materialList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')

const categoryOptions = ref([])
const fileTypeOptions = ref([])

let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: '',
  category: ''
})

function getFullUrl(url) {
  if (!url) return ''
  return url.startsWith('http') ? url : BASE_URL + url
}

function getCategoryName(value) {
  const item = categoryOptions.value.find(c => c.value === value)
  return item ? item.label : '-'
}

function getFileTypeName(value) {
  const item = fileTypeOptions.value.find(c => c.value === value)
  return item ? item.label : '-'
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
    const response = await listMaterial(queryParams)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0
    if (isRefresh) {
      materialList.value = list
    } else {
      materialList.value = [...materialList.value, ...list]
    }
    loadStatus.value = materialList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) {
    console.error('获取学习材料失败:', e)
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

function handleSearch() { getList(true) }

function onSearchInput() {
  if (searchTimer) clearTimeout(searchTimer)
  searchTimer = setTimeout(() => { handleSearch() }, 500)
}

function clearKeyword() {
  queryParams.keyword = ''
  handleSearch()
}

function switchCategory(value) {
  queryParams.category = value
  getList(true)
}

function goStudy(item) {
  uni.navigateTo({
    url: `/pages/train/detail?materialId=${item.materialId}&title=${encodeURIComponent(item.title)}`
  })
}

// 下载原始文件（PPT 等），后端带权限和授权校验
function handleDownload(item) {
  if (!item.fileUrl) {
    uni.showToast({ title: '该材料暂无可下载的文件', icon: 'none' })
    return
  }
  const token = uni.getStorageSync('token')
  if (!token) {
    uni.showToast({ title: '请先登录', icon: 'none' })
    return
  }
  // 提取扩展名，构建下载文件名
  const ext = (item.fileUrl.split('.').pop() || '').split('?')[0]
  const safeTitle = (item.title || 'material').replace(/[\\/:*?"<>|]/g, '')
  const fileName = ext ? `${safeTitle}.${ext}` : safeTitle
  const downloadUrl = `${BASE_URL}/train/material/download/${item.materialId}`

  uni.showLoading({ title: '下载中...', mask: true })

  // #ifdef H5
  // H5 端使用 fetch 获取 blob，再通过 <a> 标签触发下载
  fetch(downloadUrl, {
    method: 'GET',
    headers: { Authorization: `Bearer ${token}` }
  })
    .then((res) => {
      if (!res.ok) {
        if (res.status === 403) throw new Error('没有下载权限')
        if (res.status === 401) throw new Error('登录已过期，请重新登录')
        throw new Error('下载失败')
      }
      return res.blob()
    })
    .then((blob) => {
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = fileName
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      window.URL.revokeObjectURL(url)
      uni.hideLoading()
    })
    .catch((err) => {
      console.error('下载失败:', err)
      uni.hideLoading()
      uni.showToast({ title: err.message || '下载失败', icon: 'none' })
    })
  // #endif

  // #ifndef H5
  // App/小程序端使用 uni.downloadFile + uni.openDocument
  const downloadTask = uni.downloadFile({
    url: downloadUrl,
    header: { Authorization: `Bearer ${token}` },
    success: (res) => {
      uni.hideLoading()
      if (res.statusCode === 200) {
        uni.openDocument({
          filePath: res.tempFilePath,
          showMenu: true,
          fail: () => {
            uni.showToast({ title: '下载完成但无法直接打开，请检查文件类型', icon: 'none', duration: 2500 })
          }
        })
      } else if (res.statusCode === 403) {
        uni.showToast({ title: '没有下载权限', icon: 'none' })
      } else if (res.statusCode === 401) {
        uni.showToast({ title: '登录已过期，请重新登录', icon: 'none' })
      } else {
        uni.showToast({ title: '下载失败', icon: 'none' })
      }
    },
    fail: (err) => {
      console.error('下载失败:', err)
      uni.hideLoading()
      uni.showToast({ title: '下载失败，请稍后重试', icon: 'none' })
    }
  })
  downloadTask.onProgressUpdate((res) => {
    uni.showLoading({ title: `下载中 ${res.progress}%`, mask: true })
  })
  // #endif
}

function goAdd() {
  uni.navigateTo({ url: '/pages/train/form?mode=add' })
}

function goEdit(item) {
  uni.navigateTo({
    url: `/pages/train/form?materialId=${item.materialId}&mode=edit`
  })
}

function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: `确认删除"${item.title}"吗？`,
    confirmColor: '#F53F3F',
    success: (res) => {
      if (!res.confirm) return
      uni.showLoading({ title: '删除中...', mask: true })
      delMaterial(item.materialId)
        .then(() => {
          uni.showToast({ title: '删除成功', icon: 'success' })
          getList(true)
        })
        .catch((e) => {
          console.error('删除学习材料失败:', e)
          uni.showToast({ title: e?.msg || '删除失败', icon: 'none', duration: 2000 })
        })
        .finally(() => {
          uni.hideLoading()
        })
    }
  })
}

onMounted(async () => {
  try {
    const [catRes, typeRes] = await Promise.all([
      getDicts('biz_train_material_category'),
      getDicts('biz_train_material_file_type')
    ])
    categoryOptions.value = (catRes.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
    fileTypeOptions.value = (typeRes.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
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

.train-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
  padding: 0 24rpx;
}

.search-section {
  flex-shrink: 0;
  padding: 20rpx 24rpx;
  margin-left: -24rpx;
  margin-right: -24rpx;
  background: linear-gradient(180deg, #3D6DF7 0%, #5B8FF9 100%);
}

.search-box {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 36rpx;
  padding: 0 28rpx;
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

.category-tabs {
  flex-shrink: 0;
  background: #fff;
  padding: 16rpx 24rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.03);
}

.tab-list {
  display: inline-flex;
  gap: 16rpx;
  white-space: nowrap;
}

.tab-item {
  padding: 12rpx 28rpx;
  background: #F5F7FA;
  border-radius: 28rpx;
  font-size: 26rpx;
  color: #4E5969;
  border: 2rpx solid transparent;

  &.active {
    background: #EBF0FF;
    color: #3D6DF7;
    border-color: #3D6DF7;
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

.material-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);

  &:active {
    transform: scale(0.98);
    opacity: 0.9;
  }
}

.card-top {
  display: flex;
  gap: 20rpx;
}

.cover-img {
  width: 140rpx;
  height: 140rpx;
  border-radius: 12rpx;
  flex-shrink: 0;
}

.cover-placeholder {
  width: 140rpx;
  height: 140rpx;
  border-radius: 12rpx;
  flex-shrink: 0;
  background: #F5F7FA;
  display: flex;
  align-items: center;
  justify-content: center;
}

.card-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-width: 0;
}

.material-title {
  display: flex;
  align-items: center;
  gap: 8rpx;

  .title-text {
    font-size: 30rpx;
    font-weight: 600;
    color: #1D2129;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
}

.tag-row {
  display: flex;
  gap: 12rpx;
}

.category-tag {
  padding: 4rpx 16rpx;
  background: #EBF0FF;
  color: #3D6DF7;
  border-radius: 6rpx;
  font-size: 22rpx;
}

.type-tag {
  padding: 4rpx 16rpx;
  background: #E8F0FE;
  color: #3D6DF7;
  border-radius: 6rpx;
  font-size: 22rpx;
}

.duration-row {
  display: flex;
  align-items: center;
  gap: 6rpx;

  .duration-text {
    font-size: 24rpx;
    color: #86909C;
  }
}

.card-actions {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 24rpx;
  margin-top: 20rpx;
  padding-top: 20rpx;
  border-top: 2rpx solid #F2F3F5;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 6rpx;
  padding: 8rpx 16rpx;
  border-radius: 8rpx;
  font-size: 24rpx;

  &.edit {
    color: #3D6DF7;
    background: #E8F0FE;
  }

  &.download {
    color: #00B42A;
    background: #E8FFEA;
  }

  &.delete {
    color: #F53F3F;
    background: #FEE2E2;
  }
}

.fab-btn {
  position: fixed;
  right: 32rpx;
  bottom: 48rpx;
  width: 96rpx;
  height: 96rpx;
  border-radius: 50%;
  background: #3D6DF7;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4rpx 20rpx rgba(61, 109, 247, 0.4);
  z-index: 100;

  &:active {
    opacity: 0.9;
    transform: scale(0.96);
  }
}
</style>
