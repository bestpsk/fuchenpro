import request from '@/utils/request'

export function listLogininfor(query) {
  return request({ url: '/monitor/logininfor/list', method: 'get', params: query })
}

export function delLogininfor(infoIds) {
  return request({ url: '/monitor/logininfor', method: 'delete', params: { infoIds } })
}

export function cleanLogininfor() {
  return request({ url: '/monitor/logininfor/clean', method: 'delete' })
}

export function unlockLogininfor(userName) {
  return request({ url: '/monitor/logininfor/unlock/' + userName, method: 'get' })
}
