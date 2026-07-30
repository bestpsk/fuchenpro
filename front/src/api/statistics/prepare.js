import request from '@/utils/request'

// 备货金额统计（按状态）
export function prepareAmountStats() {
  return request({
    url: '/statistics/prepare/amountStats',
    method: 'get'
  })
}

// 方案执行统计
export function planExecution() {
  return request({
    url: '/statistics/prepare/planExecution',
    method: 'get'
  })
}

// 备货出库率（按企业）
export function shipmentRate(params) {
  return request({
    url: '/statistics/prepare/shipmentRate',
    method: 'get',
    params
  })
}
