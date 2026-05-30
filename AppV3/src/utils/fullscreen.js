import { ref } from 'vue'

const isFullscreen = ref(false)

// #ifdef H5
import fullscreen from 'licia/fullscreen'

fullscreen.on('change', () => {
  isFullscreen.value = fullscreen.isActive()
  setTimeout(() => {
    uni.$emit('fullscreenChange', isFullscreen.value)
  }, 300)
})
// #endif

export function useFullscreen() {
  function toggleFullscreen() {
    // #ifdef H5
    if (!fullscreen.isEnabled()) {
      uni.showToast({ title: '当前浏览器不支持全屏', icon: 'none' })
      return
    }
    fullscreen.toggle()
    // #endif
    // #ifndef H5
    uni.showToast({ title: '仅支持在浏览器中使用全屏', icon: 'none' })
    // #endif
  }

  function requestFullscreen() {
    // #ifdef H5
    if (!fullscreen.isEnabled()) {
      uni.showToast({ title: '当前浏览器不支持全屏', icon: 'none' })
      return
    }
    if (!fullscreen.isActive()) {
      fullscreen.request()
    }
    // #endif
  }

  function exitFullscreen() {
    // #ifdef H5
    if (fullscreen.isActive()) {
      fullscreen.exit()
    }
    // #endif
  }

  function checkFullscreen() {
    // #ifdef H5
    return fullscreen.isActive()
    // #endif
    // #ifndef H5
    return false
    // #endif
  }

  function isFullscreenSupported() {
    // #ifdef H5
    return fullscreen.isEnabled()
    // #endif
    // #ifndef H5
    return false
    // #endif
  }

  return {
    isFullscreen,
    toggleFullscreen,
    requestFullscreen,
    exitFullscreen,
    checkFullscreen,
    isFullscreenSupported
  }
}
