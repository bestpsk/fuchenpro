/**
 * @description 权限判断工具 - 角色与权限标识校验
 * @description 提供checkPermi（权限标识校验）和checkRole（角色校验）两个工具函数，
 * 用于模板中v-hasPermi/v-hasRole指令或JS中的权限判断
 */
import useUserStore from '@/store/modules/user'

/**
 * 字符权限校验
 * @param {Array} value 校验值
 * @returns {Boolean}
 */
/** 校验当前用户是否拥有指定权限标识，value为权限字符串或数组（数组时满足任一即可） */
export function checkPermi(value) {
  if (value && value instanceof Array && value.length > 0) {
    const permissions = useUserStore().permissions
    const permissionDatas = value
    const all_permission = "*:*:*"

    const hasPermission = permissions.some(permission => {
      return all_permission === permission || permissionDatas.includes(permission)
    })

    if (!hasPermission) {
      return false
    }
    return true
  } else {
    console.error(`need roles! Like checkPermi="['system:user:add','system:user:edit']"`)
    return false
  }
}

/**
 * 角色权限校验
 * @param {Array} value 校验值
 * @returns {Boolean}
 */
/** 校验当前用户是否拥有指定角色，value为角色key或数组（数组时满足任一即可） */
export function checkRole(value) {
  if (value && value instanceof Array && value.length > 0) {
    const roles = useUserStore().roles
    const permissionRoles = value
    const super_admin = "admin"

    const hasRole = roles.some(role => {
      return super_admin === role || permissionRoles.includes(role)
    })

    if (!hasRole) {
      return false
    }
    return true
  } else {
    console.error(`need roles! Like checkRole="['admin','editor']"`)
    return false
  }
}