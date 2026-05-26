/**
 * @description 复制文本指令 - 点击元素复制文本到剪贴板
 * @description 使用方式：v-copyText="要复制的文本" 或 v-copyText:callback="回调函数"
 * 通过创建隐藏textarea并调用document.execCommand('copy')实现复制
 */
export default {
  beforeMount(el, { value, arg }) {
    if (arg === "callback") {
      el.$copyCallback = value
    } else {
      el.$copyValue = value
      const handler = () => {
        copyTextToClipboard(el.$copyValue)
        if (el.$copyCallback) {
          el.$copyCallback(el.$copyValue)
        }
      }
      el.addEventListener("click", handler)
      el.$destroyCopy = () => el.removeEventListener("click", handler)
    }
  }
}

/** 将文本复制到剪贴板，通过创建临时textarea并执行copy命令实现 */
function copyTextToClipboard(input, { target = document.body } = {}) {
  const element = document.createElement('textarea')
  const previouslyFocusedElement = document.activeElement

  element.value = input

  element.setAttribute('readonly', '')

  element.style.contain = 'strict'
  element.style.position = 'absolute'
  element.style.left = '-9999px'
  element.style.fontSize = '12pt'

  const selection = document.getSelection()
  const originalRange = selection.rangeCount > 0 && selection.getRangeAt(0)

  target.append(element)
  element.select()

  element.selectionStart = 0
  element.selectionEnd = input.length

  let isSuccess = false
  try {
    isSuccess = document.execCommand('copy')
  } catch { }

  element.remove()

  if (originalRange) {
    selection.removeAllRanges()
    selection.addRange(originalRange)
  }

  if (previouslyFocusedElement) {
    previouslyFocusedElement.focus()
  }

  return isSuccess
}
