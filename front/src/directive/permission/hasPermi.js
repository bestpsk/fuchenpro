/**
 * @description 操作权限指令 - 根据权限标识控制元素显示
 * @description 使用方式：v-hasPermi="['system:user:add']"
 * 当用户不拥有指定权限时，直接移除DOM元素；支持超管通配符 *:*:*
 */
import useUserStore from '@/store/modules/user'

export default {
  mounted(el, binding, vnode) {
    const { value } = binding
    const all_permission = "*:*:*"
    const permissions = useUserStore().permissions

    if (value && value instanceof Array && value.length > 0) {
      const permissionFlag = value

      const hasPermissions = permissions.some(permission => {
        return all_permission === permission || permissionFlag.includes(permission)
      })

      if (!hasPermissions) {
        el.parentNode && el.parentNode.removeChild(el)
      }
    } else {
      throw new Error(`请设置操作权限标签值`)
    }
  }
}
