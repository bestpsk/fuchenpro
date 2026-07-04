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

// 查询可备货订单列表（已财务审核且未备货）
export function orderListForPrepare(query) {
  return request({ url: '/business/stockPrepare/orderListForPrepare', method: 'get', params: query })
}

// 根据订单创建备货
export function createFromOrder(orderId) {
  return request({ url: '/business/stockPrepare/createFromOrder', method: 'post', data: { orderId } })
}

// 批量根据订单创建备货
export function batchCreateFromOrder(orderIds) {
  return request({ url: '/business/stockPrepare/batchCreateFromOrder', method: 'post', data: { orderIds } })
}

// 取消备货（仅未出库可取消）
export function cancelPrepare(prepareId) {
  return request({ url: '/business/stockPrepare/cancel', method: 'put', data: { prepareId } })
}

// 删除备货（仅已取消状态可删除）
export function deleteStockPrepare(prepareId) {
  return request({ url: '/business/stockPrepare/' + prepareId, method: 'delete' })
}
