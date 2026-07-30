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
          <view v-if="name" @click="handleToInfo" class="user-detail">
            <text class="user-nick-name">{{ nickName || name }}</text>
            <text v-if="deptAndPost" class="user-dept-post">{{ deptAndPost }}</text>
          </view>
        </view>
        <view @click="handleToInfo" class="profile-link">
          <text>个人信息 ></text>
        </view>
      </view>
    </view>

    <view class="content-section">
      <view class="quick-actions">
        <!-- #ifdef H5 -->
        <view class="action-item" @click="handleFullscreen">
          <view class="action-icon" style="background-color: #EBF0FF">
            <u-icon :name="fullscreenIcon" size="22" color="#3D6DF7" />
          </view>
          <text class="action-label">{{ fullscreenLabel }}</text>
        </view>
        <!-- #endif -->
        <view
          v-for="(item, index) in actionList"
          :key="'action-' + index"
          class="action-item"
          @click="handleActionClick(item)"
        >
          <view class="action-icon" :style="{ backgroundColor: item.bgColor || '#f5f5f5' }">
            <u-icon :name="item.icon" size="22" :color="item.iconColor || '#666'" />
          </view>
          <text class="action-label">{{ item.title }}</text>
        </view>
      </view>

      <view class="menu-list">
        <view
          v-for="(item, index) in menuList"
          v-show="!item.permi || checkPermi(item.permi)"
          :key="'menu-' + index"
          class="menu-item"
          @click="handleMenuClick(item)"
        >
          <view class="menu-icon" :style="{ backgroundColor: item.bgColor || '#e8f2ff' }">
            <u-icon :name="item.icon" size="18" :color="item.iconColor || '#3c96f3'" />
          </view>
          <text class="menu-text">{{ item.title }}</text>
          <u-icon name="arrow-right" size="14" color="#c0c4cc" />
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import { useUserStore } from '@/store/modules/user'
import { useFullscreen } from '@/utils/fullscreen'
import { checkPermi } from '@/utils/permission'

const userStore = useUserStore()
const { isFullscreen, toggleFullscreen } = useFullscreen()

const name = computed(() => userStore.name)
const avatar = computed(() => userStore.avatar)
const nickName = computed(() => userStore.getNickName)
const deptAndPost = computed(() => {
  const dept = userStore.getDeptName
  const post = userStore.getPostName
  return [dept, post].filter(Boolean).join('·') || ''
})

const fullscreenIcon = computed(() => isFullscreen.value ? 'list' : 'grid')
const fullscreenLabel = computed(() => isFullscreen.value ? '退出全屏' : '全屏模式')

const actionList = [
  { title: '在线客服', icon: 'chat', path: '', iconColor: '#3D6DF7', bgColor: '#EBF0FF' },
  { title: '问题反馈', icon: 'edit-pen', path: '/pages/admin/feedback/index', iconColor: '#5B8FF9', bgColor: '#EAF1FF' },
  { title: '专业资料', icon: 'file-text', path: '/pages/train/index', iconColor: '#2DA8A8', bgColor: '#E6F7F7' },
  { title: '企业小报', icon: 'home', path: '/pages/admin/about/index', iconColor: '#6C5CE7', bgColor: '#EDE8FF' }
]

const menuList = [
  { title: '编辑资料', icon: 'account', path: '/pages/mine/info/edit', iconColor: '#3D6DF7', bgColor: '#EBF0FF' },
  { title: '常见问题', icon: 'question-circle', path: '/pages/mine/help/index', iconColor: '#5B8FF9', bgColor: '#EAF1FF' },
  { title: '关于我们', icon: 'info-circle', path: '/pages/mine/about/index', iconColor: '#2DA8A8', bgColor: '#E6F7F7' },
  { title: '应用设置', icon: 'setting', path: '/pages/mine/setting/index', iconColor: '#6C5CE7', bgColor: '#EDE8FF' },
  { title: '登录日志', icon: 'file-text', path: '/pages/monitor/logininfor/index', iconColor: '#3D6DF7', bgColor: '#EBF0FF', permi: 'monitor:logininfor:list' },
  { title: '操作日志', icon: 'edit-pen', path: '/pages/monitor/operlog/index', iconColor: '#5B8FF9', bgColor: '#EAF1FF', permi: 'monitor:operlog:list' }
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
function handleFullscreen() {
  toggleFullscreen()
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
  background: linear-gradient(180deg, #3D6DF7 0%, #5B8FF9 100%);
  padding: 60rpx 30rpx 110rpx;
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
  background-color: rgba(255, 255, 255, 0.3);
  border: 2rpx solid rgba(255, 255, 255, 0.4);
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

.user-detail {
  display: flex;
  flex-direction: column;
  margin-left: 24rpx;
  gap: 6rpx;
}

.user-nick-name {
  font-size: 32rpx;
  font-weight: 600;
}

.user-dept-post {
  font-size: 24rpx;
  opacity: 0.85;
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
</style>
