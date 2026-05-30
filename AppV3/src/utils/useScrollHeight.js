import { ref, onMounted, onUnmounted } from 'vue'

export function useScrollHeight(offsetOrCalcFn = 120) {
  const scrollHeight = ref(0)

  function calc() {
    if (typeof offsetOrCalcFn === 'function') {
      scrollHeight.value = offsetOrCalcFn()
    } else {
      const systemInfo = uni.getSystemInfoSync()
      scrollHeight.value = systemInfo.windowHeight - offsetOrCalcFn
    }
  }

  // #ifdef H5
  function onResize() { setTimeout(calc, 300) }
  // #endif

  onMounted(() => {
    calc()
    uni.$on('fullscreenChange', () => setTimeout(calc, 300))
    // #ifdef H5
    window.addEventListener('resize', onResize)
    // #endif
  })

  onUnmounted(() => {
    uni.$off('fullscreenChange')
    // #ifdef H5
    window.removeEventListener('resize', onResize)
    // #endif
  })

  return { scrollHeight, recalc: calc }
}
