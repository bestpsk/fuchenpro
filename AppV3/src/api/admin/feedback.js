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
