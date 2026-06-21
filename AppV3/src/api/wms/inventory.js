import request from '@/utils/request'

export function listInventory(query) {
  return request({ url: '/wms/inventory/list', method: 'get', params: query })
}

export function listWarnInventory(query) {
  return request({ url: '/wms/inventory/warn', method: 'get', params: query })
}

export function getInventory(productId, query) {
  return request({ url: '/wms/inventory/' + productId, method: 'get', params: query })
}
