<template>
  <view class="about-container">
    <view class="header-section uni-text-center">
      <view class="logo-wrap">
        <image class="logo-img" src="/static/logo.png" mode="aspectFit" />
      </view>
      <view class="app-name">{{ appName }}</view>
      <view class="app-slogan">企业数字化管理平台</view>
    </view>

    <view class="content-section">
      <view class="info-card">
        <view class="info-item">
          <view class="info-icon" style="background-color: #EBF0FF">
            <u-icon name="info-circle" size="18" color="#3D6DF7" />
          </view>
          <view class="info-label">版本信息</view>
          <view class="info-value">v{{ version }}</view>
        </view>
        <view class="info-item" @click="copyEmail">
          <view class="info-icon" style="background-color: #EAF1FF">
            <u-icon name="email" size="18" color="#5B8FF9" />
          </view>
          <view class="info-label">官方邮箱</view>
          <view class="info-value link">{{ email }}</view>
          <u-icon class="arrow-icon" name="arrow-right" size="14" color="#c0c4cc" />
        </view>
        <view class="info-item" @click="copyUrl">
          <view class="info-icon" style="background-color: #E6F7F7">
            <u-icon name="home" size="18" color="#2DA8A8" />
          </view>
          <view class="info-label">公司网站</view>
          <view class="info-value link">{{ url }}</view>
          <u-icon class="arrow-icon" name="arrow-right" size="14" color="#c0c4cc" />
        </view>
      </view>
    </view>

    <view class="copyright">
      <view class="copyright-line"></view>
      <view>{{ copyright }}</view>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 关于我们页 - 应用信息展示
 * @description 展示应用Logo、名称、版本号、官方邮箱和公司网站
 * @description 名称/邮箱/版权从 sys_config 动态加载，版本号和网站URL从全局配置读取
 */
import { ref, onMounted } from 'vue'
import { getConfigKey } from '@/api/system/config'

/** 公司网站地址，从全局配置获取 */
const url = ref(getApp().globalData.config.appInfo.site_url)
/** 应用版本号，从全局配置获取 */
const version = ref(getApp().globalData.config.appInfo.version)

/** 应用名称，从 sys_config（app.about.name）加载，默认"赛诺美生" */
const appName = ref('赛诺美生')
/** 官方邮箱，从 sys_config（app.about.email）加载 */
const email = ref('contact@fuchenpro.com')
/** 版权信息，从 sys_config（app.about.copyright）加载 */
const copyright = ref('Copyright © 2025 fuchenpro.com All Rights Reserved.')

onMounted(async () => {
  try {
    const [nameRes, emailRes, copyrightRes] = await Promise.all([
      getConfigKey('app.about.name'),
      getConfigKey('app.about.email'),
      getConfigKey('app.about.copyright')
    ])
    if (nameRes.data) appName.value = nameRes.data
    if (emailRes.data) email.value = emailRes.data
    if (copyrightRes.data) copyright.value = copyrightRes.data
  } catch (e) {
    console.error('获取关于我们配置失败:', e)
  }
})

/** 复制邮箱到剪贴板 */
function copyEmail() {
  uni.setClipboardData({
    data: email.value,
    success: () => {
      uni.showToast({ title: '邮箱已复制', icon: 'success' })
    },
    fail: () => {
      uni.showToast({ title: '复制失败', icon: 'none' })
    }
  })
}

/** 复制公司网站到剪贴板 */
function copyUrl() {
  uni.setClipboardData({
    data: url.value,
    success: () => {
      uni.showToast({ title: '网址已复制', icon: 'success' })
    },
    fail: () => {
      uni.showToast({ title: '复制失败', icon: 'none' })
    }
  })
}
</script>

<style lang="scss" scoped>
page {
  background-color: #f5f7fa;
}

.about-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.header-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  background: linear-gradient(180deg, #5B8FF9 0%, #3D6DF7 100%);
  padding: 80rpx 0 100rpx;
  border-radius: 0 0 40rpx 40rpx;
}

.logo-wrap {
  width: 160rpx;
  height: 160rpx;
  border-radius: 50%;
  background-color: rgba(255, 255, 255, 0.25);
  border: 2rpx solid rgba(255, 255, 255, 0.4);
  box-shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo-img {
  width: 120rpx;
  height: 120rpx;
}

.app-name {
  font-size: 36rpx;
  font-weight: bold;
  color: #fff;
  margin-top: 24rpx;
}

.app-slogan {
  font-size: 26rpx;
  color: rgba(255, 255, 255, 0.9);
  margin-top: 8rpx;
}

.content-section {
  margin-top: -40px;
  padding: 0 24rpx;
}

.info-card {
  background-color: #fff;
  border-radius: 16rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.06);
  overflow: hidden;
}

.info-item {
  display: flex;
  align-items: center;
  padding: 28rpx 30rpx;
  border-bottom: 1rpx solid #f2f3f5;

  &:last-child {
    border-bottom: none;
  }

  &:active {
    background-color: #f8f8f8;
  }
}

.info-icon {
  width: 56rpx;
  height: 56rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 20rpx;
  flex-shrink: 0;
}

.info-label {
  font-size: 30rpx;
  color: #1D2129;
}

.info-value {
  flex: 1;
  font-size: 28rpx;
  color: #86909C;
  text-align: right;
  margin-right: 12rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;

  &.link {
    color: #3D6DF7;
  }
}

.arrow-icon {
  flex-shrink: 0;
}

.copyright {
  margin-top: 60rpx;
  padding: 0 30rpx 60rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  font-size: 24rpx;
  color: #86909C;
  line-height: 1.6;
}

.copyright-line {
  width: 60rpx;
  height: 1rpx;
  background-color: #e5e6eb;
  margin-bottom: 20rpx;
}
</style>
