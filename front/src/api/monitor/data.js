import request from '@/utils/request'

export function getDataMonitor() {
  return request({
    url: '/monitor/data',
    method: 'get'
  })
}
