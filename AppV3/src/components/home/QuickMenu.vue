<template>
  <view class="quick-menu">
    <view class="card-header">
      <view class="header-left">
        <view class="title-bar"></view>
        <text class="card-title">常用功能</text>
      </view>
      <view class="more-btn" @click="handleMore">
        <text class="more-text">更多</text>
        <u-icon name="arrow-right" size="12" color="#86909C" />
      </view>
    </view>
    <view class="menu-grid">
      <view
        v-for="(item, index) in displayMenus"
        :key="index"
        class="menu-item"
        @click="handleMenuClick(item)"
      >
        <view class="icon-wrapper" :style="{ background: getIconBg(item, index) }">
          <u-icon :name="item.icon" size="20" color="#FFFFFF" />
        </view>
        <text class="menu-text">{{ item.title }}</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import { useMenuStore } from '@/store/modules/menu'

const menuStore = useMenuStore()

const displayMenus = computed(() => {
  return menuStore.quickMenus.slice(0, 5)
})

/** 4 色循环渐变（钉钉/企业微信风：增强品牌识别度） */
const colorPalette = [
  'linear-gradient(135deg, #3D6DF7 0%, #5B8FF9 100%)',  // 蓝
  'linear-gradient(135deg, #00B42A 0%, #4ECB3D 100%)',  // 绿
  'linear-gradient(135deg, #FF7D00 0%, #FFA940 100%)',  // 橙
  'linear-gradient(135deg, #722ED1 0%, #B36EFF 100%)',  // 紫
  'linear-gradient(135deg, #0FC6C2 0%, #2BD4D0 100%)'   // 青
]

function getIconBg(item, index) {
  if (item.bgColor) return item.bgColor
  return colorPalette[index % colorPalette.length]
}

function handleMenuClick(item) {
  menuStore.recordMenuClick(item.id)
  if (item.path) {
    uni.navigateTo({ url: item.path })
  } else {
    uni.showToast({
      title: `${item.title}功能开发中`,
      icon: 'none'
    })
  }
}

function handleMore() {
  uni.switchTab({ url: '/pages/work/index' })
}
</script>

<style lang="scss" scoped>
.quick-menu {
  background: #fff;
  border-radius: 20rpx;
  padding: 20rpx 20rpx 20rpx;
  box-shadow: 0 2rpx 12rpx rgba(61, 109, 247, 0.06);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
  padding: 0 4rpx;

  .header-left {
    display: flex;
    align-items: center;
    gap: 12rpx;

    .title-bar {
      width: 6rpx;
      height: 28rpx;
      background: linear-gradient(180deg, #3D6DF7 0%, #5B8FF9 100%);
      border-radius: 4rpx;
    }

    .card-title {
      font-size: 30rpx;
      font-weight: 600;
      color: #1D2129;
      letter-spacing: 0.5rpx;
    }
  }

  .more-btn {
    display: flex;
    align-items: center;
    gap: 4rpx;
    padding: 4rpx 12rpx;
    border-radius: 24rpx;
    transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

    &:active {
      background: #F5F7FA;
    }

    .more-text {
      font-size: 24rpx;
      color: #86909C;
    }
  }
}

.menu-grid {
  display: flex;
  justify-content: space-between;
  gap: 8rpx;
}

.menu-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

  &:active {
    transform: scale(0.92);
    opacity: 0.85;
  }

  .icon-wrapper {
    width: 88rpx;
    height: 88rpx;
    border-radius: 24rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);
    box-shadow: 0 4rpx 12rpx rgba(61, 109, 247, 0.20);

    &:active {
      box-shadow: 0 2rpx 6rpx rgba(61, 109, 247, 0.30);
    }
  }

  .menu-text {
    font-size: 24rpx;
    color: #1D2129;
    font-weight: 500;
  }
}
</style>
