import request from '@/utils/request'

export function listFeedback(query) {
  return request({ url: '/admin/feedback/list', method: 'get', params: query })
}

export function getFeedback(feedbackId) {
  return request({ url: '/admin/feedback/' + feedbackId, method: 'get' })
}

export function addFeedback(data) {
  return request({ url: '/admin/feedback', method: 'post', data: data })
}

export function updateFeedback(data) {
  return request({ url: '/admin/feedback', method: 'put', data: data })
}

export function delFeedback(feedbackIds) {
  return request({ url: '/admin/feedback', method: 'delete', params: { feedbackIds } })
}

export function handleFeedback(data) {
  return request({ url: '/admin/feedback/handle', method: 'put', data: data })
}

export function replyFeedback(data) {
  return request({ url: '/admin/feedback/reply', method: 'post', data: data })
}

export function listReply(feedbackId) {
  return request({ url: '/admin/feedback/replyList', method: 'get', params: { feedbackId } })
}
