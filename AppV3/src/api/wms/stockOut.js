import request from '@/utils/request'

export function listStockOut(query) {
  return request({ url: '/wms/stockOut/list', method: 'get', params: query })
}

export function getStockOut(id) {
  return request({ url: '/wms/stockOut/' + id, method: 'get' })
}

export function addStockOut(data) {
  return request({ url: '/wms/stockOut', method: 'post', data })
}

export function updateStockOut(data) {
  return request({ url: '/wms/stockOut', method: 'put', data })
}

export function delStockOut(ids) {
  return request({ url: '/wms/stockOut', method: 'delete', params: { stockOutIds: ids } })
}

export function confirmStockOut(id, warehouseId) {
  return request({ url: '/wms/stockOut/confirm/' + id, method: 'put', data: { warehouseId } })
}

export function cancelConfirmStockOut(id) {
  return request({ url: '/wms/stockOut/cancelConfirm/' + id, method: 'put' })
}

export function shipStockOut(id, data) {
  return request({ url: '/wms/stockOut/ship/' + id, method: 'put', data })
}

export function confirmReceipt(id) {
  return request({ url: '/wms/stockOut/confirmReceipt/' + id, method: 'put' })
}
