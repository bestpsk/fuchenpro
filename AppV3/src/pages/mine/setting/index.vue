<template>
  <view class="setting-container" :style="{ height: `${windowHeight}px` }">
    <view class="menu-list">
      <view class="list-cell list-cell-arrow" @click="handleWelcomeSlogan">
        <view class="menu-item-box">
          <u-icon name="chat" size="18" color="#3c96f3" style="margin-right: 10px" />
          <view class="menu-item-content">
            <text>首页问候语</text>
            <text class="menu-item-desc">{{ welcomeSlogan }}</text>
          </view>
        </view>
      </view>
      <view class="list-cell list-cell-arrow" @click="handleToPwd">
        <view class="menu-item-box">
          <u-icon name="lock" size="18" color="#3c96f3" style="margin-right: 10px" />
          <view>修改密码</view>
        </view>
      </view>
      <view class="list-cell list-cell-arrow" @click="handleToUpgrade">
        <view class="menu-item-box">
          <u-icon name="reload" size="18" color="#3c96f3" style="margin-right: 10px" />
          <view>检查更新</view>
        </view>
      </view>
      <view class="list-cell list-cell-arrow" @click="handleCleanTmp">
        <view class="menu-item-box">
          <u-icon name="trash" size="18" color="#3c96f3" style="margin-right: 10px" />
          <view>清理缓存</view>
        </view>
      </view>
    </view>
    <view class="item-box" @click="handleLogout">
      <text>退出登录</text>
    </view>

    <u-popup :show="showSloganPopup" mode="center" round="16" @close="showSloganPopup = false">
      <view class="slogan-popup">
        <view class="slogan-popup-title">修改首页问候语</view>
        <input class="slogan-input" v-model="sloganInput" placeholder="请输入问候语" maxlength="20" />
        <view class="slogan-popup-btns">
          <view class="slogan-btn slogan-btn-cancel" @click="showSloganPopup = false">取消</view>
          <view class="slogan-btn slogan-btn-confirm" @click="saveSlogan">保存</view>
        </view>
      </view>
    </u-popup>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { useUserStore } from '@/store/modules/user'
import { getConfigKey, getWelcomeSlogan, setWelcomeSlogan } from '@/api/system/config'

const userStore = useUserStore()
const windowHeight = ref(uni.getSystemInfoSync().windowHeight)
const welcomeSlogan = ref(uni.getStorageSync('welcome_slogan') || '开启美好的一天')
const showSloganPopup = ref(false)
const sloganInput = ref('')

loadSlogan()

function loadSlogan() {
  getWelcomeSlogan().then(res => {
    if (res.data) {
      welcomeSlogan.value = res.data
      uni.setStorageSync('welcome_slogan', res.data)
    }
  }).catch(() => {})
}

function handleWelcomeSlogan() {
  sloganInput.value = welcomeSlogan.value
  showSloganPopup.value = true
}

function saveSlogan() {
  if (!sloganInput.value.trim()) {
    uni.showToast({ title: '问候语不能为空', icon: 'none' })
    return
  }
  setWelcomeSlogan(sloganInput.value.trim()).then(() => {
    welcomeSlogan.value = sloganInput.value.trim()
    uni.setStorageSync('welcome_slogan', sloganInput.value.trim())
    uni.$emit('welcomeSloganChanged')
    showSloganPopup.value = false
    uni.showToast({ title: '保存成功', icon: 'success' })
  }).catch(() => {
    uni.showToast({ title: '保存失败', icon: 'none' })
  })
}

function handleToPwd() {
  uni.navigateTo({ url: '/pages/mine/pwd/index' })
}

function handleToUpgrade() {
  uni.showToast({ title: '模块建设中~', icon: 'none' })
}

function handleCleanTmp() {
  uni.showToast({ title: '模块建设中~', icon: 'none' })
}

function handleLogout() {
  uni.showModal({
    title: '系统提示',
    content: '确定注销并退出系统吗？',
    success: function (res) {
      if (res.confirm) {
        userStore.logOut().finally(() => {
          uni.reLaunch({ url: '/pages/login' })
        })
      }
    }
  })
}
</script>

<style lang="scss" scoped>
page { background-color: #f8f8f8; }

.menu-list { margin: 20rpx 30rpx; background: #fff; border-radius: 16rpx; overflow: hidden; }

.list-cell {
  display: flex; align-items: center; padding: 28rpx 30rpx;
  border-bottom: 1rpx solid #f2f3f5;
  &:last-child { border-bottom: none; }
  &:active { background-color: #f8f8f8; }
}

.list-cell-arrow { position: relative;
  &::after { content: ''; position: absolute; right: 30rpx; top: 50%; transform: translateY(-50%);
    width: 16rpx; height: 16rpx; border-top: 2rpx solid #c0c4cc; border-right: 2rpx solid #c0c4cc; transform: translateY(-50%) rotate(45deg); }
}

.menu-item-box { display: flex; align-items: center; flex: 1; }

.menu-item-content { display: flex; align-items: center; justify-content: space-between; flex: 1; }

.menu-item-desc { font-size: 24rpx; color: #86909C; margin-right: 30rpx; }

.item-box { background-color: #ffffff; margin: 30rpx; display: flex; justify-content: center; align-items: center;
  padding: 10rpx; border-radius: 8rpx; color: #303133; font-size: 32rpx; }

.slogan-popup { width: 580rpx; padding: 40rpx; }
.slogan-popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; text-align: center; margin-bottom: 30rpx; }
.slogan-input { width: 100%; height: 80rpx; border: 1rpx solid #e5e6eb; border-radius: 8rpx; padding: 0 20rpx; font-size: 28rpx; }
.slogan-popup-btns { display: flex; gap: 20rpx; margin-top: 30rpx; }
.slogan-btn { flex: 1; height: 76rpx; display: flex; align-items: center; justify-content: center; border-radius: 8rpx; font-size: 28rpx; }
.slogan-btn-cancel { background: #f2f3f5; color: #4E5969; }
.slogan-btn-confirm { background: #3D6DF7; color: #fff; }
</style>
