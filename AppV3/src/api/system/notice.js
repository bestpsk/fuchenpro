import request from '@/utils/request'

export function listNoticeTop() {
  return request({ url: '/system/notice/listTop', method: 'get' })
}

export function listNotice(query) {
  return request({ url: '/system/notice/list', method: 'get', params: query })
}

export function getNotice(noticeId) {
  return request({ url: '/system/notice/' + noticeId, method: 'get' })
}

export function addNotice(data) {
  return request({ url: '/system/notice', method: 'post', data })
}

export function updateNotice(data) {
  return request({ url: '/system/notice', method: 'put', data })
}

export function delNotice(noticeId) {
  return request({ url: '/system/notice', method: 'delete', params: { noticeId } })
}

export function markNoticeRead(noticeId) {
  return request({ url: '/system/notice/markRead', method: 'post', data: { noticeId } })
}

export function markNoticeReadAll() {
  return request({ url: '/system/notice/markReadAll', method: 'post' })
}

export function listNoticeReadUsers(query) {
  return request({ url: '/system/notice/readUsers/list', method: 'get', params: query })
}
