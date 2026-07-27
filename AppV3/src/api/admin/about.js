import request from '@/utils/request'

export function listAbout(query) {
  return request({ url: '/admin/about/list', method: 'get', params: query })
}

export function getAbout(aboutId) {
  return request({ url: '/admin/about/' + aboutId, method: 'get' })
}
