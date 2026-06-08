import request from '@/utils/request'

export function listRole(query) {
  return request({ url: '/system/role/list', method: 'get', params: query })
}

export function getRole(roleId) {
  return request({ url: '/system/role/' + roleId, method: 'get' })
}

export function addRole(data) {
  return request({ url: '/system/role', method: 'post', data })
}

export function updateRole(data) {
  return request({ url: '/system/role', method: 'put', data })
}

export function delRole(roleId) {
  return request({ url: '/system/role', method: 'delete', params: { roleId } })
}

export function changeRoleStatus(roleId, status) {
  return request({ url: '/system/role/changeStatus', method: 'put', data: { roleId, status } })
}

export function dataScope(data) {
  return request({ url: '/system/role/dataScope', method: 'put', data })
}

export function deptTreeSelect(roleId) {
  return request({ url: '/system/role/deptTree/' + roleId, method: 'get' })
}

export function roleMenuTreeselect(roleId) {
  return request({ url: '/system/menu/roleMenuTreeselect/' + roleId, method: 'get' })
}

export function menuTreeselect() {
  return request({ url: '/system/menu/treeselect', method: 'get' })
}

export function allocatedUserList(query) {
  return request({ url: '/system/role/authUser/allocatedList', method: 'get', params: query })
}

export function unallocatedUserList(query) {
  return request({ url: '/system/role/authUser/unallocatedList', method: 'get', params: query })
}

export function authUserCancel(data) {
  return request({ url: '/system/role/authUser/cancel', method: 'put', data })
}

export function authUserCancelAll(data) {
  return request({ url: '/system/role/authUser/cancelAll', method: 'put', params: data })
}

export function authUserSelectAll(data) {
  return request({ url: '/system/role/authUser/selectAll', method: 'put', params: data })
}
