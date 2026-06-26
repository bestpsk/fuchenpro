<template>
  <view :class="['page-header', { 'page-header-hero': mode === 'hero', 'page-header-transparent': mode === 'transparent' }]">
    <view v-if="showBack || mode === 'hero'" class="back-btn" @click="handleBack">
      <u-icon :name="mode === 'hero' ? 'arrow-leftward' : 'arrow-left'" :size="22" :color="iconColor" />
    </view>
    <view class="header-content">
      <text :class="['header-title', `title-${mode}`]">{{ title }}</text>
      <text v-if="subtitle" class="header-subtitle">{{ subtitle }}</text>
    </view>
    <view v-if="$slots.right" class="header-right">
      <slot name="right" />
    </view>
    <view v-else class="header-right-placeholder"></view>
  </view>
  <view v-if="mode !== 'transparent' && showDivider" class="header-divider"></view>
</template>

<script setup>
/**
 * @description 统一页面头部 - 取代所有自定义 header
 * @description 三种模式: default(白底) / hero(品牌渐变) / transparent(透明)
 */
const props = defineProps({
  title: { type: String, required: true },
  subtitle: { type: String, default: '' },
  /** 显示返回按钮 */
  showBack: { type: Boolean, default: true },
  /** 模式: default / hero / transparent */
  mode: { type: String, default: 'default' },
  /** 是否显示底部分割线 */
  showDivider: { type: Boolean, default: true }
})

const emit = defineEmits(['back'])

const iconColor = computed(() => {
  return props.mode === 'hero' ? '#FFFFFF' : '#1D2129'
})

function handleBack() {
  emit('back')
  // 默认行为：返回上一页
  const pages = getCurrentPages()
  if (pages.length > 1) {
    uni.navigateBack()
  }
}

import { computed } from 'vue'
</script>

<style lang="scss" scoped>
.page-header {
  display: flex;
  align-items: center;
  height: 88rpx;
  padding: 0 16rpx;
  background: #FFFFFF;
  position: relative;
  z-index: 10;
}

.page-header-hero {
  background: linear-gradient(135deg, #3D6DF7 0%, #5B8FF9 100%);
  color: #FFFFFF;
}

.page-header-transparent {
  background: transparent;
}

.back-btn {
  width: 64rpx;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  flex-shrink: 0;
  transition: background 150ms cubic-bezier(0.16, 1, 0.3, 1);

  &:active {
    background: rgba(0, 0, 0, 0.05);
  }
}

.page-header-hero .back-btn:active {
  background: rgba(255, 255, 255, 0.15);
}

.header-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-width: 0;
}

.header-title {
  font-size: 30rpx;
  font-weight: 600;
  color: #1D2129;
  line-height: 1.3;
  text-align: center;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
}

.title-default {
  color: #1D2129;
}

.title-hero {
  color: #FFFFFF;
  font-size: 32rpx;
}

.title-transparent {
  color: #1D2129;
}

.header-subtitle {
  font-size: 22rpx;
  color: #86909C;
  line-height: 1.3;
  margin-top: 2rpx;
}

.page-header-hero .header-subtitle {
  color: rgba(255, 255, 255, 0.85);
}

.header-right {
  display: flex;
  align-items: center;
  gap: 8rpx;
  min-width: 64rpx;
  justify-content: flex-end;
}

.header-right-placeholder {
  width: 64rpx;
  height: 64rpx;
  flex-shrink: 0;
}

.header-divider {
  height: 1rpx;
  background: #F2F3F5;
  width: 100%;
}
</style>
