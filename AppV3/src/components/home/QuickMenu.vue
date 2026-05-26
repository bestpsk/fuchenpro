<template>
  <view class="quick-menu">
    <view class="menu-grid">
      <view
        v-for="(item, index) in displayMenus"
        :key="index"
        class="menu-item"
        @click="handleMenuClick(item)"
      >
        <view class="icon-wrapper" :style="{ backgroundColor: item.bgColor || '#E8F0FE' }">
          <u-icon :name="item.icon" size="20" :color="item.iconColor || '#3D6DF7'" />
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
</script>

<style lang="scss" scoped>
.quick-menu {
  background: #fff;
  border-radius: 20rpx;
  padding: 28rpx 20rpx 20rpx;
  box-shadow: 0 2rpx 12rpx rgba(61, 109, 247, 0.06);
  opacity: 0.9;
}

.menu-grid {
  display: flex;
  justify-content: space-between;
}

.menu-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;

  &:active {
    transform: scale(0.95);
    opacity: 0.8;
  }

  .icon-wrapper {
    width: 88rpx;
    height: 88rpx;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s ease;

    &:active {
      background: #d4e8ff;
    }
  }

  .menu-text {
    font-size: 24rpx;
    color: #1D2129;
    font-weight: 500;
  }
}
</style>
