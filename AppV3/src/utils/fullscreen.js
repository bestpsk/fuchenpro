import { ref } from 'vue'

const isFullscreen = ref(false)
const GUARD_KEY = '__fullscreen_guard__'
let isExitingByUser = false  // 标记是否用户主动退出全屏

// #ifdef H5
import fullscreen from 'licia/fullscreen'

// 全屏状态变化监听
fullscreen.on('change', () => {
  const active = fullscreen.isActive()
  isFullscreen.value = active

  if (!active && !isExitingByUser) {
    // 非主动退出（滑动返回或 Esc 键），尝试重新进入全屏
    // 注意：非用户手势下 requestFullscreen 可能被浏览器拒绝
    // 但在 hash 模式 + pushState 拦截下，滑动返回不应触发页面导航，全屏应保持
    // 此处作为降级保护：如果全屏确实退出了，尝试重新进入
    try {
      fullscreen.request()
    } catch (e) {
      // 重新全屏失败（非用户手势），清理 guard 状态
      removeGuard()
    }
  } else if (!active && isExitingByUser) {
    // 用户主动退出，清理 guard
    removeGuard()
  }

  setTimeout(() => {
    uni.$emit('fullscreenChange', isFullscreen.value)
  }, 300)
})

// popstate 监听：拦截滑动返回
window.addEventListener('popstate', () => {
  if (isExitingByUser) return
  // 全屏状态下滑动返回，重新推入 guard，阻止页面返回
  if (isFullscreen.value) {
    history.pushState({ [GUARD_KEY]: true }, '')
  }
})

function pushGuard() {
  history.pushState({ [GUARD_KEY]: true }, '')
}

function removeGuard() {
  if (history.state && history.state[GUARD_KEY]) {
    isExitingByUser = true
    history.back()
    setTimeout(() => { isExitingByUser = false }, 300)
  }
}
// #endif

export function useFullscreen() {
  function toggleFullscreen() {
    // #ifdef H5
    if (!fullscreen.isEnabled()) {
      uni.showToast({ title: '当前浏览器不支持全屏', icon: 'none' })
      return
    }
    if (fullscreen.isActive()) {
      // 用户主动退出全屏
      isExitingByUser = true
      removeGuard()
      fullscreen.exit()
      setTimeout(() => { isExitingByUser = false }, 300)
    } else {
      // 进入全屏
      fullscreen.request()
      pushGuard()
    }
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
      pushGuard()
    }
    // #endif
  }

  function exitFullscreen() {
    // #ifdef H5
    if (fullscreen.isActive()) {
      isExitingByUser = true
      removeGuard()
      fullscreen.exit()
      setTimeout(() => { isExitingByUser = false }, 300)
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
