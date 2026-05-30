/**
 * @description 存储键名常量 - 用户数据本地存储的键名映射
 * @description 定义用户相关数据在聚合存储中使用的键名常量，
 * 与storage.js配合使用，确保键名一致性和可维护性
 */
const constant = {
  avatar: 'user_avatar',
  id: 'user_id',
  name: 'user_name',
  nickName: 'user_nick_name',
  deptName: 'user_dept_name',
  postName: 'user_post_name',
  roles: 'user_roles',
  permissions: 'user_permissions'
}

export default constant
