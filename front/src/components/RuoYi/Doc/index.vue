<template>
  <div>
    <svg-icon icon-class="question" @click="goto" />
  </div>
</template>

<script setup>
/**
 * @description 文档链接组件 - 外链到项目文档
 * @description 在新窗口打开项目文档URL
 */
const url = ref('http://doc.ruoyi.vip/ruoyi-vue')

function goto() {
  window.open(url.value)
}
</script>