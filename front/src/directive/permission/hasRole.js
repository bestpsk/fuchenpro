/**
 * @description 角色权限指令 - 根据角色标识控制元素显示
 * @description 使用方式：v-hasRole="['admin']"
 * 当用户不拥有指定角色时，直接移除DOM元素；admin角色拥有全部权限
 */
import useUserStore from '@/store/modules/user'

export default {
  mounted(el, binding, vnode) {
    const { value } = binding
    const super_admin = "admin"
    const roles = useUserStore().roles

    if (value && value instanceof Array && value.length > 0) {
      const roleFlag = value

      const hasRole = roles.some(role => {
        return super_admin === role || roleFlag.includes(role)
      })

      if (!hasRole) {
        el.parentNode && el.parentNode.removeChild(el)
      }
    } else {
      throw new Error(`请设置角色权限标签值`)
    }
  }
}
