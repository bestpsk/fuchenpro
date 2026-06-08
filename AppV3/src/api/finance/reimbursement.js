import request from '@/utils/request'

export function listReimbursement(params) {
  return request({ url: '/finance/reimbursement/list', method: 'get', params })
}
export function getReimbursement(id) {
  return request({ url: '/finance/reimbursement/' + id, method: 'get' })
}
export function addReimbursement(data) {
  return request({ url: '/finance/reimbursement', method: 'post', data })
}
export function updateReimbursement(data) {
  return request({ url: '/finance/reimbursement', method: 'put', data })
}
export function delReimbursement(ids) {
  return request({ url: '/finance/reimbursement', method: 'delete', data: { ids } })
}
export function auditReimbursement(data) {
  return request({ url: '/finance/reimbursement/audit', method: 'post', data })
}
export function payReimbursement(data) {
  return request({ url: '/finance/reimbursement/pay', method: 'post', data })
}
export function reportByMonth(params) {
  return request({ url: '/finance/reimbursement/report/byMonth', method: 'get', params })
}
export function reportByCategory(params) {
  return request({ url: '/finance/reimbursement/report/byCategory', method: 'get', params })
}
export function reportByDept(params) {
  return request({ url: '/finance/reimbursement/report/byDept', method: 'get', params })
}
export function reportByUser(params) {
  return request({ url: '/finance/reimbursement/report/byUser', method: 'get', params })
}
export function reportByExpenseType(params) {
  return request({ url: '/finance/reimbursement/report/byExpenseType', method: 'get', params })
}
