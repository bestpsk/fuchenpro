import request from '@/utils/request'

export function listProduct(query) {
  return request({ url: '/wms/product/list', method: 'get', params: query })
}

export function searchProduct(keyword) {
  return request({ url: '/wms/product/search', method: 'get', params: { keyword } })
}

export function getProduct(id) {
  return request({ url: '/wms/product/' + id, method: 'get' })
}

export function addProduct(data) {
  return request({ url: '/wms/product', method: 'post', data })
}

export function updateProduct(data) {
  return request({ url: '/wms/product', method: 'put', data })
}

export function delProduct(ids) {
  return request({ url: '/wms/product', method: 'delete', params: { productIds: ids } })
}
