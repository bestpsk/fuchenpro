import request from '@/utils/request'

export function listStockCheck(query) {
  return request({ url: '/wms/stockCheck/list', method: 'get', params: query })
}

export function getStockCheck(id) {
  return request({ url: '/wms/stockCheck/' + id, method: 'get' })
}

export function addStockCheck(data) {
  return request({ url: '/wms/stockCheck', method: 'post', data })
}

export function updateStockCheck(data) {
  return request({ url: '/wms/stockCheck', method: 'put', data })
}

export function delStockCheck(ids) {
  return request({ url: '/wms/stockCheck', method: 'delete', params: { stockCheckIds: ids } })
}

export function confirmStockCheck(id) {
  return request({ url: '/wms/stockCheck/confirm/' + id, method: 'put' })
}

export function loadInventoryData() {
  return request({ url: '/wms/stockCheck/loadInventory', method: 'get' })
}
