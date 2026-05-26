/**
 * @description 权限验证插件 - 权限和角色的判断工具
 * @description 提供权限验证（单个/或/且）和角色验证（单个/或/且）方法，
 * 用于在JS代码中判断当前用户是否拥有指定权限或角色
 */
import useUserStore from '@/store/modules/user'

/** 判断用户是否拥有指定权限（支持超管通配符 *:*:*） */
function authPermission(permission) {
  const all_permission = "*:*:*"
  const permissions = useUserStore().permissions
  if (permission && permission.length > 0) {
    return permissions.some(v => {
      return all_permission === v || v === permission
    })
  } else {
    return false
  }
}

/** 判断用户是否拥有指定角色（admin角色拥有全部权限） */
function authRole(role) {
  const super_admin = "admin"
  const roles = useUserStore().roles
  if (role && role.length > 0) {
    return roles.some(v => {
      return super_admin === v || v === role
    })
  } else {
    return false
  }
}

export default {
  /** 验证用户是否具备某权限 */
  hasPermi(permission) {
    return authPermission(permission)
  },
  /** 验证用户是否含有指定权限，只需包含其中一个 */
  hasPermiOr(permissions) {
    return permissions.some(item => {
      return authPermission(item)
    })
  },
  /** 验证用户是否含有指定权限，必须全部拥有 */
  hasPermiAnd(permissions) {
    return permissions.every(item => {
      return authPermission(item)
    })
  },
  /** 验证用户是否具备某角色 */
  hasRole(role) {
    return authRole(role)
  },
  /** 验证用户是否含有指定角色，只需包含其中一个 */
  hasRoleOr(roles) {
    return roles.some(item => {
      return authRole(item)
    })
  },
  /** 验证用户是否含有指定角色，必须全部拥有 */
  hasRoleAnd(roles) {
    return roles.every(item => {
      return authRole(item)
    })
  }
}
