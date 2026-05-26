import request from '@/utils/request'

export function listBanner(query) {
  return request({ url: '/system/banner/list', method: 'get', params: query })
}

export function getBanner(bannerId) {
  return request({ url: '/system/banner/' + bannerId, method: 'get' })
}

export function addBanner(data) {
  return request({ url: '/system/banner', method: 'post', data: data })
}

export function updateBanner(data) {
  return request({ url: '/system/banner', method: 'put', data: data })
}

export function delBanner(bannerIds) {
  return request({ url: '/system/banner', method: 'delete', params: { bannerIds } })
}
