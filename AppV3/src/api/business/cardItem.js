import request from '@/utils/request'

export function listCardItem(params) {
  return request({ url: '/business/cardItem/list', method: 'get', params })
}

export function getCardItem(id) {
  return request({ url: '/business/cardItem/' + id, method: 'get' })
}

export function addCardItem(data) {
  return request({ url: '/business/cardItem', method: 'post', data })
}

export function updateCardItem(data) {
  return request({ url: '/business/cardItem', method: 'put', data })
}

export function delCardItem(id) {
  return request({ url: '/business/cardItem/' + id, method: 'delete' })
}

export function searchCardItem(keyword) {
  return request({ url: '/business/cardItem/search', method: 'get', params: { keyword } })
}
