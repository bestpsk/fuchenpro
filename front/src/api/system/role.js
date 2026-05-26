/**
 * @description 角色管理接口 - 角色CRUD/权限分配/用户授权
 * @description 提供角色增删改查、数据权限设置、状态变更、已授权/未授权用户查询、
 * 用户授权/取消授权、部门树查询等接口
 */
import request from '@/utils/request'

/** 查询角色列表，支持分页查询 */
export function listRole(query) {
  return request({
    url: '/system/role/list',
    method: 'get',
    params: query
  })
}

/** 根据角色ID获取角色详细信息 */
export function getRole(roleId) {
  return request({
    url: '/system/role/' + roleId,
    method: 'get'
  })
}

/** 新增角色 */
export function addRole(data) {
  return request({
    url: '/system/role',
    method: 'post',
    data: data
  })
}

/** 修改角色信息 */
export function updateRole(data) {
  return request({
    url: '/system/role',
    method: 'put',
    data: data
  })
}

/** 设置角色数据权限范围（控制角色可访问的部门数据） */
export function dataScope(data) {
  return request({
    url: '/system/role/dataScope',
    method: 'put',
    data: data
  })
}

/** 切换角色启用/停用状态 */
export function changeRoleStatus(roleId, status) {
  const data = {
    roleId,
    status
  }
  return request({
    url: '/system/role/changeStatus',
    method: 'put',
    data: data
  })
}

/** 根据角色ID删除角色 */
export function delRole(roleId) {
  return request({
    url: '/system/role',
    method: 'delete',
    params: { roleId }
  })
}

/** 查询已分配该角色的用户列表 */
export function allocatedUserList(query) {
  return request({
    url: '/system/role/authUser/allocatedList',
    method: 'get',
    params: query
  })
}

/** 查询未分配该角色的用户列表（用于添加授权） */
export function unallocatedUserList(query) {
  return request({
    url: '/system/role/authUser/unallocatedList',
    method: 'get',
    params: query
  })
}

/** 取消单个用户的角色授权 */
export function authUserCancel(data) {
  return request({
    url: '/system/role/authUser/cancel',
    method: 'put',
    data: data
  })
}

/** 批量取消用户的角色授权 */
export function authUserCancelAll(data) {
  return request({
    url: '/system/role/authUser/cancelAll',
    method: 'put',
    params: data
  })
}

/** 批量选择用户授权给角色 */
export function authUserSelectAll(data) {
  return request({
    url: '/system/role/authUser/selectAll',
    method: 'put',
    params: data
  })
}

/** 根据角色ID查询部门树结构（用于数据权限分配） */
export function deptTreeSelect(roleId) {
  return request({
    url: '/system/role/deptTree/' + roleId,
    method: 'get'
  })
}
