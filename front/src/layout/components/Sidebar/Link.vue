<template>
  <component :is="type" v-bind="linkProps()">
    <slot />
  </component>
</template>

<script setup>
/**
 * @description 链接组件 - 内链路由与外链跳转
 * @description 根据URL判断是内链（router-link）还是外链（a标签新窗口打开）
 */
import { isExternal } from '@/utils/validate'

const props = defineProps({
  to: {
    type: [String, Object],
    required: true
  }
})

const isExt = computed(() => {
  return isExternal(props.to)
})

const type = computed(() => {
  if (isExt.value) {
    return 'a'
  }
  return 'router-link'
})

function linkProps() {
  if (isExt.value) {
    return {
      href: props.to,
      target: '_blank',
      rel: 'noopener'
    }
  }
  return {
    to: props.to
  }
}
</script>
