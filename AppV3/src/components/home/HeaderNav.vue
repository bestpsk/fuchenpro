<template>
  <view class="header-section">
    <view class="header-nav" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-content">
        <view class="nav-left" @click="handleUserInfo">
          <u-avatar :src="userInfo.avatar" size="80" />
          <view class="user-info">
            <view class="user-name">{{ userInfo.name || '用户' }}</view>
            <view class="user-role">{{ userInfo.role || '美容顾问' }}</view>
          </view>
        </view>

        <view class="nav-right">
          <!-- #ifdef H5 -->
          <view class="icon-btn" @click="handleFullscreen">
            <u-icon :name="isFullscreen ? 'list' : 'grid'" size="24" color="#fff" />
          </view>
          <!-- #endif -->
          <view class="icon-btn" @click="handleMessage">
            <u-icon name="bell" size="24" color="#fff" />
            <u-badge v-if="messageCount > 0" :value="messageCount" :absolute="true" type="error"></u-badge>
          </view>
          <view class="icon-btn" @click="handleSetting">
            <u-icon name="setting" size="24" color="#fff" />
          </view>
        </view>
      </view>

      <view class="welcome-text">
        <text>{{ greeting }}，{{ welcomeSlogan }}！</text>
      </view>
    </view>

    <!-- QuickMenu 嵌入 HeaderNav 底部，消除缝隙 -->
    <view class="quick-menu-wrapper">
      <QuickMenu />
    </view>
  </view>
</template>

<script setup>
/**
 * @description 首页头部导航组件 - 用户信息与快捷操作
 * @description 展示用户头像、昵称、问候语，提供个人信息、消息中心、设置三个快捷入口
 */
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useUserStore } from '@/store/modules/user'
import { listNoticeTop } from '@/api/system/notice'
import { getConfigKey, getWelcomeSlogan } from '@/api/system/config'
import { useFullscreen } from '@/utils/fullscreen'
import QuickMenu from './QuickMenu.vue'

const userStore = useUserStore()
const { isFullscreen, toggleFullscreen } = useFullscreen()

const statusBarHeight = ref(44)
const messageCount = ref(0)
const welcomeSlogan = ref('开启美好的一天')

/** 用户信息：头像（默认占位图）、昵称（默认"用户"）、角色 */
const userInfo = computed(() => ({
  avatar: userStore.getAvatar || '/static/images/profile.jpg',
  name: userStore.getNickName || userStore.getName || '用户',
  role: [userStore.getDeptName, userStore.getPostName].filter(Boolean).join('·') || '美容顾问'
}))

/** 根据当前时间自动生成问候语（早上好/下午好/晚上好） */
const greeting = computed(() => {
  const hour = new Date().getHours()
  if (hour < 12) return '早上好'
  if (hour < 18) return '下午好'
  return '晚上好'
})

uni.getSystemInfoSync({
  success: (res) => {
    statusBarHeight.value = res.statusBarHeight
  }
})

function loadUnreadCount() {
  listNoticeTop().then(res => {
    messageCount.value = res.data?.unreadCount ?? res.unreadCount ?? 0
  }).catch(() => {})
}

function handleSloganChange() {
  loadWelcomeSlogan()
}

onMounted(() => {
  loadUnreadCount()
  loadWelcomeSlogan()
  uni.$on('welcomeSloganChanged', handleSloganChange)
})

onUnmounted(() => {
  uni.$off('welcomeSloganChanged', handleSloganChange)
})

function loadWelcomeSlogan() {
  const cached = uni.getStorageSync('welcome_slogan')
  if (cached) welcomeSlogan.value = cached
  getWelcomeSlogan().then(res => {
    const slogan = res.data || ''
    if (slogan) {
      welcomeSlogan.value = slogan
      uni.setStorageSync('welcome_slogan', slogan)
    }
  }).catch(() => {})
}

function handleUserInfo() {
  uni.navigateTo({ url: '/pages/mine/info/index' })
}

function handleMessage() {
  uni.navigateTo({ url: '/pages/system/notice/index' })
}

function handleSetting() {
  uni.navigateTo({ url: '/pages/mine/setting/index' })
}

function handleFullscreen() {
  toggleFullscreen()
}

defineExpose({ loadUnreadCount })
</script>

<style lang="scss" scoped>
.header-section {
  background: $gradient-hero;
  padding-bottom: 26rpx;
  position: relative;
  overflow: hidden;

  /* 装饰光晕（克制使用） */
  &::before {
    content: '';
    position: absolute;
    top: -100rpx;
    right: -100rpx;
    width: 360rpx;
    height: 360rpx;
    background: radial-gradient(circle, rgba(255, 255, 255, 0.18) 0%, transparent 70%);
    pointer-events: none;
  }

  &::after {
    content: '';
    position: absolute;
    bottom: -150rpx;
    left: -80rpx;
    width: 280rpx;
    height: 280rpx;
    background: radial-gradient(circle, rgba(91, 143, 249, 0.25) 0%, transparent 70%);
    pointer-events: none;
  }
}

.header-nav {
  padding: 20rpx 30rpx 24rpx;
  color: #fff;
  position: relative;
  z-index: 1;
}

.nav-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.nav-left {
  display: flex;
  align-items: center;
  gap: 20rpx;
  transition: opacity 150ms cubic-bezier(0.16, 1, 0.3, 1);

  &:active {
    opacity: 0.75;
  }

  .user-info {
    display: flex;
    flex-direction: column;
    gap: 6rpx;

    .user-name {
      font-size: 32rpx;
      font-weight: 600;
      letter-spacing: 0.5rpx;
    }

    .user-role {
      font-size: 24rpx;
      opacity: 0.9;
    }
  }
}

.nav-right {
  display: flex;
  align-items: center;
  gap: 16rpx;

  .icon-btn {
    position: relative;
    width: 64rpx;
    height: 64rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: visible;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.15);
    backdrop-filter: blur(10rpx);
    -webkit-backdrop-filter: blur(10rpx);
    transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

    :deep(.u-badge) {
      top: -4rpx !important;
      right: -4rpx !important;
    }

    &:active {
      background: rgba(255, 255, 255, 0.25);
      transform: scale(0.92);
    }
  }
}

.welcome-text {
  margin-top: 24rpx;
  font-size: 28rpx;
  opacity: 0.95;
  font-weight: 500;
  letter-spacing: 0.5rpx;
}

.quick-menu-wrapper {
  margin: 0 24rpx;
  position: relative;
  z-index: 1;
}
</style>
