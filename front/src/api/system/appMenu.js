import request from '@/utils/request'

export function listAppMenu(query) {
  return request({
    url: '/system/appMenu/list',
    method: 'get',
    params: query
  })
}

export function getGroupedAppMenu() {
  return request({
    url: '/system/appMenu/grouped',
    method: 'get'
  })
}

export function getAppMenu(id) {
  return request({
    url: '/system/appMenu/' + id,
    method: 'get'
  })
}

export function addAppMenu(data) {
  return request({
    url: '/system/appMenu',
    method: 'post',
    data: data
  })
}

export function updateAppMenu(data) {
  return request({
    url: '/system/appMenu',
    method: 'put',
    data: data
  })
}

export function delAppMenu(id) {
  return request({
    url: '/system/appMenu',
    method: 'delete',
    params: { id }
  })
}

export function updateAppMenuSort(data) {
  return request({
    url: '/system/appMenu/updateSort',
    method: 'put',
    data: data
  })
}

export function changeAppMenuStatus(id, visible) {
  return request({
    url: '/system/appMenu/changeStatus',
    method: 'put',
    data: { id, visible }
  })
}
