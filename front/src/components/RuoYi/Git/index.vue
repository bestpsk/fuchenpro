<template>
  <div>
    <svg-icon icon-class="github" @click="goto" />
  </div>
</template>

<script setup>
/**
 * @description Git链接组件 - 外链到项目仓库
 * @description 在新窗口打开项目Git仓库URL
 */
const url = ref('https://gitee.com/y_project/RuoYi-Vue')

function goto() {
  window.open(url.value)
}
</script>
