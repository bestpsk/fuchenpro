<template>
  <view
    :class="['card-container', `card-pad-${padding}`, `card-shadow-${shadow}`, { 'card-no-margin': noMargin }]"
    :style="customStyle"
  >
    <slot />
  </view>
</template>

<script setup>
/**
 * @description 统一卡片容器 - 取代所有 background:#fff;border-radius:20rpx;padding:24rpx 模式
 * @description 支持 padding/shadow/radius 三个维度的标准化
 */
defineProps({
  /** 内边距: sm=16rpx / md=24rpx / lg=32rpx */
  padding: { type: String, default: 'md' },
  /** 阴影强度: none / sm / md / lg */
  shadow: { type: String, default: 'sm' },
  /** 圆角: sm=12rpx / md=16rpx / lg=24rpx */
  radius: { type: String, default: 'md' },
  /** 是否不加外边距（用于栅格内） */
  noMargin: { type: Boolean, default: false },
  /** 自定义样式 */
  customStyle: { type: String, default: '' }
})
</script>

<style lang="scss" scoped>
.card-container {
  background: #FFFFFF;
  box-sizing: border-box;
  transition: box-shadow 240ms cubic-bezier(0.16, 1, 0.3, 1);
}

/* 内边距 */
.card-pad-sm { padding: 16rpx; }
.card-pad-md { padding: 24rpx; }
.card-pad-lg { padding: 32rpx; }

/* 圆角 */
.card-container { border-radius: 16rpx; }
.card-container[style*="radius-sm"] { border-radius: 12rpx; }
.card-container[style*="radius-lg"] { border-radius: 24rpx; }

/* 阴影 */
.card-shadow-none { box-shadow: none; }
.card-shadow-sm { box-shadow: 0 2rpx 8rpx rgba(61, 109, 247, 0.06); }
.card-shadow-md { box-shadow: 0 4rpx 16rpx rgba(61, 109, 247, 0.10); }
.card-shadow-lg { box-shadow: 0 8rpx 24rpx rgba(61, 109, 247, 0.14); }

/* 外边距（默认有 16rpx 上下） */
.card-container:not(.card-no-margin) {
  margin: 16rpx 24rpx;
}
</style>
