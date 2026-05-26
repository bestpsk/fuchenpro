<template>
  <view class="work-container">
    <view class="swiper-section" v-if="bannerList.length > 0">
      <swiper class="swiper" :indicator-dots="bannerList.length > 1" :autoplay="true" :interval="3000" :duration="500" circular>
        <swiper-item v-for="(item, index) in bannerList" :key="index">
          <image :src="item.image" mode="aspectFill" class="banner-img" @click="clickBannerItem(item)" />
        </swiper-item>
      </swiper>
    </view>

    <view class="search-card">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C" />
        <input
          class="search-input"
          type="text"
          placeholder="搜索功能"
          placeholder-class="search-placeholder"
          v-model="searchKeyword"
          confirm-type="search"
        />
        <view v-if="searchKeyword" class="search-clear" @click="searchKeyword = ''">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4" />
        </view>
      </view>
    </view>

    <view class="quick-card">
      <view class="card-header">
        <text class="card-title">常用功能</text>
      </view>
      <view class="quick-grid">
        <view
          v-for="(item, index) in quickDisplayList"
          :key="'q-' + index"
          class="quick-item"
          @click="handleGridClick(item)"
        >
          <view class="quick-icon" :style="{ backgroundColor: item.bgColor || '#E8F0FE' }">
            <u-icon :name="item.icon" size="18" :color="item.iconColor || '#3D6DF7'" />
          </view>
          <text class="quick-text">{{ item.title }}</text>
        </view>
      </view>
    </view>

    <view v-for="group in menuGroups" :key="group.groupKey" class="grid-card">
      <view class="card-header">
        <text class="card-title">{{ group.groupName }}</text>
      </view>
      <view class="divider"></view>
      <view v-if="getFilteredItems(group.items).length > 0" class="grid-body">
        <view class="grid-row">
          <view v-for="item in getFilteredItems(group.items)" :key="item.id" class="grid-item" @click="handleGridClick(item)">
            <view class="icon-wrapper" :style="{ backgroundColor: item.bgColor || '#3D6DF7' }">
              <u-icon :name="item.icon" size="22" :color="item.iconColor || '#fff'" />
            </view>
            <text class="grid-text">{{ item.title }}</text>
          </view>
        </view>
      </view>
      <view v-else class="empty-state">
        <u-icon name="search" size="40" color="#C9CDD4" />
        <text class="empty-text">未找到相关功能</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useMenuStore } from '@/store/modules/menu'
import { getBannerList as fetchBannerList } from '@/api/home'
import config from '@/config'

const BASE_URL = config.baseUrl || ''

const menuStore = useMenuStore()
const searchKeyword = ref('')

onShow(() => {
  if (!menuStore.loaded) {
    menuStore.loadMenus()
  }
})

const defaultBanners = [
  { image: '/static/images/banner/banner01.jpg', title: '', linkUrl: '' },
  { image: '/static/images/banner/banner02.jpg', title: '', linkUrl: '' },
  { image: '/static/images/banner/banner03.jpg', title: '', linkUrl: '' }
]

const bannerList = ref([])

async function loadBanners() {
  try {
    const res = await fetchBannerList()
    const list = res.data || []
    if (list.length > 0) {
      bannerList.value = list.map(item => ({
        ...item,
        image: item.image && !item.image.startsWith('http') ? BASE_URL + item.image : item.image
      }))
    } else {
      bannerList.value = defaultBanners
    }
  } catch (e) {
    console.warn('获取轮播图失败，使用默认图片', e)
    bannerList.value = defaultBanners
  }
}

loadBanners()

const quickDisplayList = computed(() => {
  return menuStore.quickMenus.slice(0, 5)
})

const menuGroups = computed(() => {
  if (!menuStore.menus || Object.keys(menuStore.menus).length === 0) return []
  return Object.values(menuStore.menus).filter(g => g && g.groupKey && g.groupKey !== 'quick' && g.groupKey !== 'mine_action' && g.groupKey !== 'mine_menu' && g.items && g.items.length > 0)
})

function getFilteredItems(items) {
  if (!items) return []
  if (!searchKeyword.value.trim()) return items
  const keyword = searchKeyword.value.trim().toLowerCase()
  return items.filter(item => item.title.toLowerCase().includes(keyword))
}

function clickBannerItem(item) {
  if (item.linkUrl) {
    if (item.linkUrl.startsWith('/pages/')) {
      uni.navigateTo({ url: item.linkUrl })
    } else if (item.linkUrl.startsWith('http')) {
      uni.navigateTo({ url: `/pages/webview/index?url=${encodeURIComponent(item.linkUrl)}` })
    }
  }
}

function handleGridClick(item) {
  menuStore.recordMenuClick(item.id)
  if (item.path) {
    uni.navigateTo({ url: item.path })
  } else {
    uni.showToast({ title: `${item.title}模块建设中~`, icon: 'none' })
  }
}
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
}

.work-container {
  min-height: 100vh;
  padding-bottom: 30rpx;
}

.swiper-section {
  margin-bottom: 20rpx;
}

.swiper {
  height: 320rpx;
}

.banner-img {
  width: 100%;
  height: 100%;
}

.search-card {
  margin: 0 24rpx 20rpx;
  background: #fff;
  border-radius: 20rpx;
  padding: 20rpx 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(61, 109, 247, 0.06);
}

.search-box {
  display: flex;
  align-items: center;
  background: #F5F7FA;
  border-radius: 36rpx;
  padding: 0 24rpx;
  height: 72rpx;
  gap: 16rpx;
}

.search-input {
  flex: 1;
  font-size: 26rpx;
  color: #1D2129;
  height: 72rpx;
}

.search-placeholder {
  color: #86909C;
  font-size: 26rpx;
}

.search-clear {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 8rpx;
}

.quick-card {
  margin: 0 24rpx 20rpx;
  background: #fff;
  border-radius: 20rpx;
  padding: 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(61, 109, 247, 0.06);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}

.card-title {
  font-size: 28rpx;
  font-weight: 600;
  color: #1D2129;
}

.quick-grid {
  display: flex;
  justify-content: space-between;
}

.quick-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;

  &:active {
    transform: scale(0.95);
    opacity: 0.8;
  }

  .quick-icon {
    width: 72rpx;
    height: 72rpx;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s ease;
  }

  .quick-text {
    font-size: 22rpx;
    color: #1D2129;
    font-weight: 500;
  }
}

.grid-card {
  margin: 0 24rpx;
  background: #fff;
  border-radius: 20rpx;
  padding: 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(61, 109, 247, 0.06);
  margin-bottom: 20rpx;
}

.divider {
  height: 1rpx;
  background: #E5E6EB;
  margin-bottom: 20rpx;
}

.grid-body {
  padding: 10rpx 0;
}

.grid-row {
  display: flex;
  flex-wrap: wrap;
}

.grid-item {
  width: 25%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20rpx 0;

  &:active {
    transform: scale(0.95);
    opacity: 0.8;
  }

  transition: all 0.2s ease;
}

.icon-wrapper {
  width: 90rpx;
  height: 90rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 14rpx;
  transition: all 0.2s ease;

  &:active {
    opacity: 0.8;
    transform: scale(0.95);
  }
}

.grid-text {
  font-size: 24rpx;
  color: #1D2129;
  text-align: center;
  font-weight: 500;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60rpx 0;
  gap: 20rpx;
}

.empty-text {
  font-size: 26rpx;
  color: #86909C;
}
</style>
