import request from '@/utils/request'
import upload from '@/utils/upload'

export function listUser(params) {
  return request({ url: '/system/user/list', method: 'get', params })
}

export function getUser(userId) {
  return request({ url: '/system/user/' + (userId || ''), method: 'get' })
}

export function addUser(data) {
  return request({ url: '/system/user', method: 'post', data })
}

export function updateUser(data) {
  return request({ url: '/system/user', method: 'put', data })
}

export function delUser(userId) {
  return request({ url: '/system/user', method: 'delete', params: { userId } })
}

export function resetUserPwd(userId, password) {
  return request({ url: '/system/user/resetPwd', method: 'put', data: { userId, password } })
}

export function changeUserStatus(userId, status) {
  return request({ url: '/system/user/changeStatus', method: 'put', data: { userId, status } })
}

export function updateUserPwd(oldPassword, newPassword) {
  return request({ url: '/system/user/profile/updatePwd', method: 'put', params: { oldPassword, newPassword } })
}

export function getUserProfile() {
  return request({ url: '/system/user/profile', method: 'get' })
}

export function updateUserProfile(data) {
  return request({ url: '/system/user/profile', method: 'put', data })
}

export function uploadAvatar(data) {
  return upload({ url: '/system/user/profile/avatar', name: 'avatarfile', filePath: data.filePath })
}

export function getAuthRole(userId) {
  return request({ url: '/system/user/authRole/' + userId, method: 'get' })
}

export function updateAuthRole(data) {
  return request({ url: '/system/user/authRole', method: 'put', params: data })
}

export function deptTreeSelect() {
  return request({ url: '/system/user/deptTree', method: 'get' })
}

export function getUserDetail(userId) {
  return request({ url: '/system/user/detail/' + userId, method: 'get' })
}

export function addUserDetail(data) {
  return request({ url: '/system/user/detail', method: 'post', data })
}

export function updateUserDetail(data) {
  return request({ url: '/system/user/detail', method: 'put', data })
}
