/**
 * @description 弹窗操作插件 - Element Plus消息/确认/通知/加载封装
 * @description 统一封装ElMessage消息提示、ElMessageBox确认/输入弹窗、
 * ElNotification通知提示、ElLoading加载遮罩，提供简洁的调用接口
 */
import { ElMessage, ElMessageBox, ElNotification, ElLoading } from 'element-plus'

let loadingInstance

export default {
  /** 显示信息类型消息提示 */
  msg(content) {
    ElMessage.info(content)
  },
  /** 显示错误类型消息提示 */
  msgError(content) {
    ElMessage.error(content)
  },
  /** 显示成功类型消息提示 */
  msgSuccess(content) {
    ElMessage.success(content)
  },
  /** 显示警告类型消息提示 */
  msgWarning(content) {
    ElMessage.warning(content)
  },
  /** 弹出信息类型的确认弹窗（仅确定按钮） */
  alert(content) {
    ElMessageBox.alert(content, "系统提示")
  },
  /** 弹出错误类型的确认弹窗 */
  alertError(content) {
    ElMessageBox.alert(content, "系统提示", { type: 'error' })
  },
  /** 弹出成功类型的确认弹窗 */
  alertSuccess(content) {
    ElMessageBox.alert(content, "系统提示", { type: 'success' })
  },
  /** 弹出警告类型的确认弹窗 */
  alertWarning(content) {
    ElMessageBox.alert(content, "系统提示", { type: 'warning' })
  },
  /** 显示信息类型的通知提示（右上角弹出） */
  notify(content) {
    ElNotification.info(content)
  },
  /** 显示错误类型的通知提示 */
  notifyError(content) {
    ElNotification.error(content)
  },
  /** 显示成功类型的通知提示 */
  notifySuccess(content) {
    ElNotification.success(content)
  },
  /** 显示警告类型的通知提示 */
  notifyWarning(content) {
    ElNotification.warning(content)
  },
  /** 弹出确认对话框（含确定/取消按钮），返回Promise */
  confirm(content) {
    return ElMessageBox.confirm(content, "系统提示", {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: "warning",
    })
  },
  /** 弹出输入对话框（含输入框和确定/取消按钮），返回Promise */
  prompt(content) {
    return ElMessageBox.prompt(content, "系统提示", {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: "warning",
    })
  },
  /** 打开全屏加载遮罩层 */
  loading(content) {
    loadingInstance = ElLoading.service({
      lock: true,
      text: content,
      background: "rgba(0, 0, 0, 0.7)",
    })
  },
  /** 关闭全屏加载遮罩层 */
  closeLoading() {
    loadingInstance.close()
  }
}
