import request from '@/utils/request'

// 按部门统计业绩
export function deptPerformance(query) {
  return request({ url: '/statistics/performance/dept', method: 'get', params: query })
}

// 按个人统计业绩
export function userPerformance(query) {
  return request({ url: '/statistics/performance/user', method: 'get', params: query })
}

// 按企业统计业绩
export function enterprisePerformance(query) {
  return request({ url: '/statistics/performance/enterprise', method: 'get', params: query })
}

// 按门店统计业绩
export function storePerformance(query) {
  return request({ url: '/statistics/performance/store', method: 'get', params: query })
}
