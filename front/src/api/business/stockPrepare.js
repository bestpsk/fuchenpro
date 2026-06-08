import request from '@/utils/request'

export function listStockPrepare(query) {
  return request({ url: '/business/stockPrepare/list', method: 'get', params: query })
}

export function getStockPrepare(prepareId) {
  return request({ url: '/business/stockPrepare/' + prepareId, method: 'get' })
}

export function createStockOutFromPrepare(data) {
  return request({ url: '/business/stockPrepare/createStockOut', method: 'post', data: data })
}
