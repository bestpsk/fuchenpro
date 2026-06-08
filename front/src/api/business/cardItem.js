import request from '@/utils/request'

export function listCardItem(query) {
  return request({ url: '/business/cardItem/list', method: 'get', params: query })
}

export function getCardItem(cardItemId) {
  return request({ url: '/business/cardItem/' + cardItemId, method: 'get' })
}

export function addCardItem(data) {
  return request({ url: '/business/cardItem', method: 'post', data: data })
}

export function updateCardItem(data) {
  return request({ url: '/business/cardItem', method: 'put', data: data })
}

export function delCardItem(cardItemIds) {
  return request({ url: '/business/cardItem', method: 'delete', params: { cardItemIds } })
}

export function searchCardItem(keyword) {
  return request({ url: '/business/cardItem/search', method: 'get', params: { keyword } })
}
