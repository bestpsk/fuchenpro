import request from '@/utils/request'

export function listAppMenu(query) {
  return request({ url: '/system/appMenu/list', method: 'get', params: query })
}

export function getAppMenu(menuId) {
  return request({ url: '/system/appMenu/' + menuId, method: 'get' })
}

export function addAppMenu(data) {
  return request({ url: '/system/appMenu', method: 'post', data: data })
}

export function updateAppMenu(data) {
  return request({ url: '/system/appMenu', method: 'put', data: data })
}

export function delAppMenu(appMenuId) {
  return request({ url: '/system/appMenu', method: 'delete', params: { appMenuId } })
}
