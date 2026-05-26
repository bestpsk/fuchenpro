/**
 * @description 用户管理接口 - 用户CRUD/个人信息/角色授权/薪资配置
 * @description 提供用户增删改查、密码重置、状态变更、个人资料维护、头像上传、
 * 角色授权管理、部门树查询、员工详情维护、薪资配置等接口
 */
import request from '@/utils/request'
import { parseStrEmpty } from "@/utils/ruoyi";

/** 查询用户列表，支持分页查询 */
export function listUser(query) {
  return request({
    url: '/system/user/list',
    method: 'get',
    params: query
  })
}

/** 根据用户ID获取用户详细信息（空ID时获取新增表单默认值） */
export function getUser(userId) {
  return request({
    url: '/system/user/' + parseStrEmpty(userId),
    method: 'get'
  })
}

/** 新增用户 */
export function addUser(data) {
  return request({
    url: '/system/user',
    method: 'post',
    data: data
  })
}

/** 修改用户信息 */
export function updateUser(data) {
  return request({
    url: '/system/user',
    method: 'put',
    data: data
  })
}

/** 根据用户ID删除用户 */
export function delUser(userId) {
  return request({
    url: '/system/user',
    method: 'delete',
    params: { userId }
  })
}

/** 管理员重置指定用户的密码 */
export function resetUserPwd(userId, password) {
  const data = {
    userId,
    password
  }
  return request({
    url: '/system/user/resetPwd',
    method: 'put',
    data: data
  })
}

/** 切换用户启用/停用状态 */
export function changeUserStatus(userId, status) {
  const data = {
    userId,
    status
  }
  return request({
    url: '/system/user/changeStatus',
    method: 'put',
    data: data
  })
}

/** 获取当前登录用户的个人信息 */
export function getUserProfile() {
  return request({
    url: '/system/user/profile',
    method: 'get'
  })
}

/** 修改当前登录用户的个人信息 */
export function updateUserProfile(data) {
  return request({
    url: '/system/user/profile',
    method: 'put',
    data: data
  })
}

/** 用户自行修改密码（需验证旧密码） */
export function updateUserPwd(oldPassword, newPassword) {
  const data = {
    oldPassword,
    newPassword
  }
  return request({
    url: '/system/user/profile/updatePwd',
    method: 'put',
    data: data
  })
}

/** 上传用户头像 */
export function uploadAvatar(data) {
  return request({
    url: '/system/user/profile/avatar',
    method: 'post',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    data: data
  })
}

/** 查询用户已授权的角色信息 */
export function getAuthRole(userId) {
  return request({
    url: '/system/user/authRole/' + userId,
    method: 'get'
  })
}

/** 保存用户的角色授权关系 */
export function updateAuthRole(data) {
  return request({
    url: '/system/user/authRole',
    method: 'put',
    params: data
  })
}

/** 查询部门下拉树结构（用于用户管理左侧部门筛选） */
export function deptTreeSelect() {
  return request({
    url: '/system/user/deptTree',
    method: 'get'
  })
}

/** 根据用户ID查询员工扩展详情（含关联业务信息） */
export function getUserDetail(userId) {
  return request({
    url: '/system/user/detail/' + userId,
    method: 'get'
  })
}

/** 新增员工扩展详情 */
export function addUserDetail(data) {
  return request({
    url: '/system/user/detail',
    method: 'post',
    data: data
  })
}

/** 修改员工扩展详情 */
export function updateUserDetail(data) {
  return request({
    url: '/system/user/detail',
    method: 'put',
    data: data
  })
}

/** 查询薪资类型列表（如月薪/日薪/提成等） */
export function listSalaryType() {
  return request({
    url: '/hr/salary/type/list',
    method: 'get'
  })
}

/** 根据用户ID查询其薪资配置列表 */
export function listUserSalary(userId) {
  return request({
    url: '/hr/salary/user/' + userId,
    method: 'get'
  })
}

/** 根据薪资ID获取薪资配置详细信息 */
export function getSalary(salaryId) {
  return request({
    url: '/hr/salary/' + salaryId,
    method: 'get'
  })
}

/** 新增用户薪资配置 */
export function addSalary(data) {
  return request({
    url: '/hr/salary',
    method: 'post',
    data: data
  })
}

/** 修改用户薪资配置 */
export function updateSalary(data) {
  return request({
    url: '/hr/salary',
    method: 'put',
    data: data
  })
}

/** 根据薪资ID删除薪资配置 */
export function delSalary(salaryIds) {
  return request({
    url: '/hr/salary',
    method: 'delete',
    params: { salaryIds }
  })
}
