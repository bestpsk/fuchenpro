import request from '@/utils/request'

export function listOperlog(query) {
  return request({ url: '/monitor/operlog/list', method: 'get', params: query })
}

export function delOperlog(operId) {
  return request({ url: '/monitor/operlog', method: 'delete', params: { operId } })
}

export function cleanOperlog() {
  return request({ url: '/monitor/operlog/clean', method: 'delete' })
}
