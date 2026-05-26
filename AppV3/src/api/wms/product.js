import request from '@/utils/request'

export function listProduct(query) {
  return request({ url: '/wms/product/list', method: 'get', params: query })
}

export function searchProduct(keyword) {
  return request({ url: '/wms/product/search', method: 'get', params: { keyword } })
}
