<template>
  <view class="skeleton-wrap" :style="{ width: width, height: heightRpx }">
    <view v-if="type === 'text'" class="skeleton-bar" :style="{ width: '100%', height: heightRpx }"></view>
    <view v-else-if="type === 'circle'" class="skeleton-circle" :style="{ width: heightRpx, height: heightRpx }"></view>
    <view v-else class="skeleton-block" :style="{ width: '100%', height: heightRpx }"></view>
  </view>
</template>

<script setup>
import { computed } from 'vue'

/**
 * @description 骨架屏 - 列表加载占位
 * @description 使用 opacity 闪烁动画，1200ms 周期
 */
const props = defineProps({
  /** 类型: text/text-block/circle */
  type: { type: String, default: 'text' },
  /** 高度 rpx */
  height: { type: [Number, String], default: 32 },
  /** 宽度 rpx 或百分比（仅 type=text-block） */
  width: { type: [Number, String], default: '100%' }
})

const heightRpx = computed(() => {
  return typeof props.height === 'number' ? `${props.height}rpx` : props.height
})
</script>

<style lang="scss" scoped>
.skeleton-wrap {
  display: block;
}

.skeleton-bar,
.skeleton-block,
.skeleton-circle {
  background: linear-gradient(90deg, #F2F3F5 0%, #E8EAED 50%, #F2F3F5 100%);
  background-size: 200% 100%;
  animation: skeleton-shimmer 1.2s ease-in-out infinite;
}

.skeleton-bar {
  border-radius: 4rpx;
}

.skeleton-block {
  border-radius: 8rpx;
}

.skeleton-circle {
  border-radius: 50%;
}

@keyframes skeleton-shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
</style>
