import request from '@/utils/request'

// 货品销售排行
export function salesRanking(params) {
  return request({
    url: '/statistics/product/salesRanking',
    method: 'get',
    params
  })
}

// 货品取消率
export function cancelRate(params) {
  return request({
    url: '/statistics/product/cancelRate',
    method: 'get',
    params
  })
}

// 货品利润分析（双利润率）
export function profitAnalysis(params) {
  return request({
    url: '/statistics/product/profit',
    method: 'get',
    params
  })
}
