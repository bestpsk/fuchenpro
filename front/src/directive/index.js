/**
 * @description 自定义指令注册入口 - 注册全局自定义指令
 * @description 注册v-hasRole（角色权限）、v-hasPermi（操作权限）、v-copyText（复制文本）三个自定义指令
 */
import hasRole from './permission/hasRole'
import hasPermi from './permission/hasPermi'
import copyText from './common/copyText'

export default function directive(app){
  /** 角色权限指令，无权限时移除DOM元素 */
  app.directive('hasRole', hasRole)
  /** 操作权限指令，无权限时移除DOM元素 */
  app.directive('hasPermi', hasPermi)
  /** 复制文本指令，点击元素时复制文本到剪贴板 */
  app.directive('copyText', copyText)
}
