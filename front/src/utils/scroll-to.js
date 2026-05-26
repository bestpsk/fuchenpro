/**
 * @description 平滑滚动工具 - 页面滚动到指定位置
 * @description 提供带缓动效果的页面滚动功能，使用二次缓入缓出算法实现平滑滚动动画
 */
Math.easeInOutQuad = function(t, b, c, d) {
  t /= d / 2
  if (t < 1) {
    return c / 2 * t * t + b
  }
  t--
  return -c / 2 * (t * (t - 2) - 1) + b
}

/** 兼容各浏览器的requestAnimationFrame */
const requestAnimFrame = (function() {
  return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || function(callback) { window.setTimeout(callback, 1000 / 60) }
})()

/** 同时设置所有可能的滚动容器scrollTop，确保跨浏览器兼容 */
function move(amount) {
  document.documentElement.scrollTop = amount
  document.body.parentNode.scrollTop = amount
  document.body.scrollTop = amount
}

/** 获取当前页面滚动位置 */
function position() {
  return document.documentElement.scrollTop || document.body.parentNode.scrollTop || document.body.scrollTop
}

/**
 * 平滑滚动到指定位置
 * @param {number} to - 目标滚动位置（像素）
 * @param {number} duration - 滚动动画时长（毫秒），默认500ms
 * @param {Function} callback - 滚动完成后的回调函数
 */
export function scrollTo(to, duration, callback) {
  const start = position()
  const change = to - start
  const increment = 20
  let currentTime = 0
  duration = (typeof (duration) === 'undefined') ? 500 : duration
  const animateScroll = function() {
    currentTime += increment
    const val = Math.easeInOutQuad(currentTime, start, change, duration)
    move(val)
    if (currentTime < duration) {
      requestAnimFrame(animateScroll)
    } else {
      if (callback && typeof (callback) === 'function') {
        callback()
      }
    }
  }
  animateScroll()
}
