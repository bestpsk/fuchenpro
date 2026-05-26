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

export function markNoticeRead(noticeId) {
  return request({ url: '/system/notice/markRead', method: 'post', data: { noticeId } })
}

export function markNoticeReadAll() {
  return request({ url: '/system/notice/markReadAll', method: 'post' })
}
