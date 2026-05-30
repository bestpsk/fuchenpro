import request from '@/utils/request'

export function getTodayStats(params) {
  return request({
    url: '/home/stats',
    method: 'get',
    params
  })
}

export function getEnterpriseStats(params) {
  return request({
    url: '/home/enterprise-stats',
    method: 'get',
    params
  })
}

export function listArchive(params) {
  return request({
    url: '/business/archive/list',
    method: 'get',
    params
  })
}
