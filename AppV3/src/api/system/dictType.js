import request from '@/utils/request'

export function listType(query) {
  return request({ url: '/system/dict/type/list', method: 'get', params: query })
}

export function getType(dictId) {
  return request({ url: '/system/dict/type/' + dictId, method: 'get' })
}

export function addType(data) {
  return request({ url: '/system/dict/type', method: 'post', data })
}

export function updateType(data) {
  return request({ url: '/system/dict/type', method: 'put', data })
}

export function delType(dictId) {
  return request({ url: '/system/dict/type', method: 'delete', params: { dictId } })
}

export function refreshCache() {
  return request({ url: '/system/dict/type/refreshCache', method: 'delete' })
}

export function optionselect() {
  return request({ url: '/system/dict/type/optionselect', method: 'get' })
}
