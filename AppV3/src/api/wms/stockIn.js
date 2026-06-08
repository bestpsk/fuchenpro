import request from '@/utils/request'

export function listStockIn(query) {
  return request({ url: '/wms/stockIn/list', method: 'get', params: query })
}

export function getStockIn(id) {
  return request({ url: '/wms/stockIn/' + id, method: 'get' })
}

export function addStockIn(data) {
  return request({ url: '/wms/stockIn', method: 'post', data })
}

export function updateStockIn(data) {
  return request({ url: '/wms/stockIn', method: 'put', data })
}

export function delStockIn(ids) {
  return request({ url: '/wms/stockIn', method: 'delete', params: { stockInIds: ids } })
}

export function confirmStockIn(id) {
  return request({ url: '/wms/stockIn/confirm/' + id, method: 'put' })
}

export function cancelConfirmStockIn(id) {
  return request({ url: '/wms/stockIn/cancelConfirm/' + id, method: 'put' })
}
