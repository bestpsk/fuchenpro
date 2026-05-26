import request from '@/utils/request'

export function listSupplier(query) {
  return request({ url: '/wms/supplier/list', method: 'get', params: query })
}

export function searchSupplier(keyword) {
  return request({ url: '/wms/supplier/search', method: 'get', params: { keyword } })
}

export function getSupplier(supplierId) {
  return request({ url: '/wms/supplier/' + supplierId, method: 'get' })
}

export function addSupplier(data) {
  return request({ url: '/wms/supplier', method: 'post', data })
}

export function updateSupplier(data) {
  return request({ url: '/wms/supplier', method: 'put', data })
}

export function delSupplier(supplierIds) {
  return request({ url: '/wms/supplier', method: 'delete', params: { supplierIds } })
}
