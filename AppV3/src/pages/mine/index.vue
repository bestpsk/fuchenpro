<template>
  <view class="mine-container">
    <view class="header-section">
      <view class="header-content">
        <view class="user-info-area">
          <view v-if="!avatar" class="avatar-placeholder">
            <text class="avatar-text">U</text>
          </view>
          <image v-if="avatar" @click="handleToAvatar" :src="avatar" class="avatar-img" mode="aspectFill" />
          <view v-if="!name" @click="handleToLogin" class="login-tip">点击登录</view>
          <view v-if="name" @click="handleToInfo" class="username">用户名：{{ name }}</view>
        </view>
        <view @click="handleToInfo" class="profile-link">
          <text>个人信息 ></text>
        </view>
      </view>
    </view>

    <view class="content-section">
      <view class="quick-actions">
        <view
          v-for="(item, index) in actionList"
          :key="'action-' + index"
          class="action-item"
          @click="handleActionClick(item)"
        >
          <view class="action-icon" :style="{ backgroundColor: item.bgColor || '#f5f5f5' }">
            <u-icon :name="item.icon" size="20" :color="item.iconColor || '#666'" />
          </view>
          <text class="action-label">{{ item.title }}</text>
        </view>
      </view>

      <view class="menu-list">
        <view
          v-for="(item, index) in menuList"
          :key="'menu-' + index"
          class="menu-item"
          @click="handleMenuClick(item)"
        >
          <view class="menu-icon" :style="{ backgroundColor: item.bgColor || '#e8f2ff' }">
            <u-icon :name="item.icon" size="16" :color="item.iconColor || '#3c96f3'" />
          </view>
          <text class="menu-text">{{ item.title }}</text>
          <text class="menu-arrow">></text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import { useUserStore } from '@/store/modules/user'

const userStore = useUserStore()

const name = computed(() => userStore.name)
const avatar = computed(() => userStore.avatar)

const actionList = [
  { title: '在线客服', icon: 'chat', path: '', iconColor: '#666', bgColor: '#f5f5f5' },
  { title: '反馈社区', icon: 'edit-pen', path: '', iconColor: '#666', bgColor: '#f5f5f5' },
  { title: '点赞我们', icon: 'thumb-up', path: '', iconColor: '#666', bgColor: '#f5f5f5' },
  { title: '关于我们', icon: 'info-circle', path: '/pages/mine/about/index', iconColor: '#666', bgColor: '#f5f5f5' }
]

const menuList = [
  { title: '编辑资料', icon: 'edit-pen', path: '/pages/mine/info/edit', iconColor: '#3c96f3', bgColor: '#e8f2ff' },
  { title: '常见问题', icon: 'question-circle', path: '/pages/mine/help/index', iconColor: '#3c96f3', bgColor: '#e8f2ff' },
  { title: '关于我们', icon: 'info-circle', path: '/pages/mine/about/index', iconColor: '#3c96f3', bgColor: '#e8f2ff' },
  { title: '应用设置', icon: 'setting', path: '/pages/mine/setting/index', iconColor: '#3c96f3', bgColor: '#e8f2ff' }
]

function handleToInfo() {
  uni.navigateTo({ url: '/pages/mine/info/index' })
}
function handleToLogin() {
  uni.reLaunch({ url: '/pages/login' })
}
function handleToAvatar() {
  uni.navigateTo({ url: '/pages/mine/avatar/index' })
}
function handleActionClick(item) {
  if (item.path) {
    uni.navigateTo({ url: item.path })
  } else {
    uni.showToast({ title: '模块建设中~', icon: 'none' })
  }
}
function handleMenuClick(item) {
  if (item.path) {
    uni.navigateTo({ url: item.path })
  } else {
    uni.showToast({ title: '模块建设中~', icon: 'none' })
  }
}
</script>

<style lang="scss" scoped>
page {
  background-color: #f5f7fa;
}

.mine-container {
  min-height: 100vh;
}

.header-section {
  background-color: #3c96f3;
  padding: 60rpx 30rpx 80rpx;
  color: white;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.user-info-area {
  display: flex;
  align-items: center;
}

.avatar-placeholder, .avatar-img {
  width: 120rpx;
  height: 120rpx;
  border-radius: 50%;
  background-color: rgba(255, 255, 255, 0.25);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.avatar-text {
  font-size: 44rpx;
  font-weight: 600;
  color: #fff;
}

.login-tip {
  font-size: 34rpx;
  margin-left: 24rpx;
}

.username {
  font-size: 32rpx;
  margin-left: 24rpx;
  font-weight: 500;
}

.profile-link {
  font-size: 26rpx;
  opacity: 0.9;
}

.content-section {
  position: relative;
  margin-top: -40px;
  padding: 0 24rpx;
}

.quick-actions {
  background-color: #fff;
  border-radius: 12rpx;
  padding: 36rpx 20rpx;
  display: flex;
  justify-content: space-around;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.04);
  margin-bottom: 24rpx;
}

.action-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 14rpx;
}

.action-icon {
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.action-label {
  font-size: 24rpx;
  color: #333;
}

.menu-list {
  background-color: #fff;
  border-radius: 12rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.04);
  overflow: hidden;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 32rpx 28rpx;
  border-bottom: 1rpx solid #f5f5f5;

  &:last-child {
    border-bottom: none;
  }

  &:active {
    background-color: #f9f9f9;
  }
}

.menu-icon {
  width: 56rpx;
  height: 56rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 20rpx;
}

.menu-text {
  flex: 1;
  font-size: 30rpx;
  color: #333;
}

.menu-arrow {
  font-size: 28rpx;
  color: #ccc;
}
</style>
