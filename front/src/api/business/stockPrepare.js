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

// 从方案创建备货记录
export function createFromPlan(planId, items) {
  return request({ url: '/business/stockPrepare/createFromPlan', method: 'post', data: { planId, items } })
}

// 获取方案活跃备货金额
export function getActivePreparedAmount(planId) {
  return request({ url: '/business/stockPrepare/getActivePreparedAmount', method: 'get', params: { planId } })
}
