import request from '@/utils/request'

// 客户新增趋势（按月）
export function newCustomerTrend(params) {
  return request({
    url: '/statistics/customer/newTrend',
    method: 'get',
    params
  })
}

// 客户价值分布
export function valueDistribution(params) {
  return request({
    url: '/statistics/customer/valueDistribution',
    method: 'get',
    params
  })
}

// 按价值层级获取客户明细列表（下钻查看）
export function customerListByLevel(params) {
  return request({
    url: '/statistics/customer/listByLevel',
    method: 'get',
    params
  })
}

// 客户流失预警
export function churnWarning(params) {
  return request({
    url: '/statistics/customer/churnWarning',
    method: 'get',
    params
  })
}

// 客户消费频次分布
export function orderFrequency(params) {
  return request({
    url: '/statistics/customer/orderFrequency',
    method: 'get',
    params
  })
}
