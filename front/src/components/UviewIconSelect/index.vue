<template>
  <div class="uview-icon-body">
    <el-input
      v-model="iconName"
      class="icon-search"
      clearable
      placeholder="请输入图标名称"
      @clear="filterIcons"
      @input="filterIcons"
    >
      <template #suffix><el-icon><Search /></el-icon></template>
    </el-input>
    <div class="icon-list">
      <div class="list-container">
        <div
          v-for="item in iconList"
          :key="item"
          class="icon-item-wrapper"
          @click="selectedIcon(item)"
        >
          <div :class="['icon-item', { active: activeIcon === item }]">
            <span class="icon-name">{{ item }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
const uviewIcons = [
  'account', 'account-fill', 'arrow-down', 'arrow-down-fill', 'arrow-left',
  'arrow-left-fill', 'arrow-right', 'arrow-right-fill', 'arrow-up', 'arrow-up-fill',
  'attach', 'bookmark', 'bookmark-fill', 'calendar', 'calendar-fill',
  'camera', 'camera-fill', 'cart', 'chat', 'chat-fill',
  'checkmark', 'checkmark-circle', 'checkmark-circle-fill', 'clock', 'clock-fill',
  'close', 'close-circle', 'close-circle-fill', 'cloud', 'cloud-download',
  'cloud-upload', 'coupon', 'edit-pen', 'email', 'eye',
  'eye-fill', 'file-text', 'fire', 'flag', 'folder',
  'gift', 'grid', 'grid-fill', 'heart', 'heart-fill',
  'home', 'home-fill', 'info-circle', 'info-circle-fill', 'kefu-ermai',
  'label', 'link', 'list', 'lock', 'lock-fill',
  'man', 'man-add', 'map', 'map-fill', 'mic',
  'mic-fill', 'minus', 'minus-circle', 'minus-circle-fill', 'more-dot-fill',
  'more-circle', 'more-circle-fill', 'notification', 'notification-fill', 'order',
  'phone', 'phone-fill', 'photo', 'photo-fill', 'play-left',
  'play-right', 'plus', 'plus-circle', 'plus-circle-fill', 'pushpin',
  'question-circle', 'question-circle-fill', 'redo', 'reload', 'scan',
  'search', 'server', 'server-fill', 'setting', 'setting-fill',
  'share', 'share-fill', 'shop', 'shop-fill', 'shopping-cart',
  'star', 'star-fill', 'thumb-down', 'thumb-down-fill', 'thumb-up',
  'thumb-up-fill', 'trash', 'trash-fill', 'trophy', 'trophy-fill',
  'undo', 'volume', 'volume-fill', 'warning', 'warning-fill',
  'wifi', 'woman'
]

const props = defineProps({
  activeIcon: {
    type: String
  }
})

const iconName = ref('')
const iconList = ref(uviewIcons)
const emit = defineEmits(['selected'])

function filterIcons() {
  if (iconName.value) {
    iconList.value = uviewIcons.filter(item => item.indexOf(iconName.value) !== -1)
  } else {
    iconList.value = uviewIcons
  }
}

function selectedIcon(name) {
  emit('selected', name)
  document.body.click()
}

function reset() {
  iconName.value = ''
  iconList.value = uviewIcons
}

defineExpose({ reset })
</script>

<style lang="scss" scoped>
.uview-icon-body {
  width: 100%;
  padding: 10px;
  .icon-search {
    margin-bottom: 5px;
  }
  .icon-list {
    height: 200px;
    overflow: auto;
    .list-container {
      display: flex;
      flex-wrap: wrap;
      .icon-item-wrapper {
        width: calc(100% / 3);
        height: 30px;
        line-height: 30px;
        cursor: pointer;
        .icon-item {
          display: flex;
          align-items: center;
          height: 100%;
          padding: 0 8px;
          &:hover {
            background: #ececec;
            border-radius: 5px;
          }
          .icon-name {
            font-size: 12px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
          }
        }
        .icon-item.active {
          background: #e1f0ff;
          border-radius: 5px;
          color: #3D6DF7;
          font-weight: 600;
        }
      }
    }
  }
}
</style>
