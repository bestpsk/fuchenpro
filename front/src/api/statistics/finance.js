import request from '@/utils/request'

// 应收账款统计（按企业/门店/业务员分组）
export function receivableStats(params) {
  return request({
    url: '/statistics/finance/receivable',
    method: 'get',
    params
  })
}

// 账龄分析（30/60/90/90+天）
export function agingAnalysis(params) {
  return request({
    url: '/statistics/finance/aging',
    method: 'get',
    params
  })
}

// 支付方式占比
export function paymentMethodStats(params) {
  return request({
    url: '/statistics/finance/paymentMethod',
    method: 'get',
    params
  })
}

// 回款率统计
export function collectionRate(params) {
  return request({
    url: '/statistics/finance/collectionRate',
    method: 'get',
    params
  })
}
