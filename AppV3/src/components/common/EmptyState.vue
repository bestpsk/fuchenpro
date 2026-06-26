<template>
  <view class="empty-state">
    <u-icon :name="icon" :size="iconSize" color="#C9CDD4" />
    <text class="empty-text">{{ text }}</text>
    <view v-if="$slots.default" class="empty-action">
      <slot />
    </view>
  </view>
</template>

<script setup>
/**
 * @description 统一空状态 - 全应用空数据/无网络/无权限场景
 * @description 钉钉/企业微信风：克制图标 + 居中文字 + 可选操作
 */
defineProps({
  /** 图标名称（uView-plus icon name） */
  icon: { type: String, default: 'file-text' },
  /** 图标大小 rpx */
  iconSize: { type: Number, default: 80 },
  /** 文案 */
  text: { type: String, default: '暂无数据' }
})
</script>

<style lang="scss" scoped>
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80rpx 32rpx;
  gap: 20rpx;
}

.empty-text {
  font-size: 26rpx;
  color: #86909C;
  line-height: 1.5;
}

.empty-action {
  margin-top: 16rpx;
}
</style>
