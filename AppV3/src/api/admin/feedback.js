import request from '@/utils/request'

export function listFeedback(query) {
  return request({ url: '/admin/feedback/list', method: 'get', params: query })
}

export function getFeedback(feedbackId) {
  return request({ url: '/admin/feedback/' + feedbackId, method: 'get' })
}

export function addFeedback(data) {
  return request({ url: '/admin/feedback', method: 'post', data })
}

export function updateFeedback(data) {
  return request({ url: '/admin/feedback', method: 'put', data })
}

export function delFeedback(feedbackId) {
  return request({ url: '/admin/feedback', method: 'delete', params: { feedbackIds: feedbackId } })
}

export function handleFeedback(data) {
  return request({ url: '/admin/feedback/handle', method: 'put', data })
}

export function replyFeedback(data) {
  return request({ url: '/admin/feedback/reply', method: 'post', data })
}
