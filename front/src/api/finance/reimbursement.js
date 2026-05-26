import request from '@/utils/request'

export function listReimbursement(query) {
  return request({
    url: '/finance/reimbursement/list',
    method: 'get',
    params: query
  })
}

export function getReimbursement(id) {
  return request({
    url: '/finance/reimbursement/' + id,
    method: 'get'
  })
}

export function addReimbursement(data) {
  return request({
    url: '/finance/reimbursement',
    method: 'post',
    data: data
  })
}

export function updateReimbursement(data) {
  return request({
    url: '/finance/reimbursement',
    method: 'put',
    data: data
  })
}

export function delReimbursement(ids) {
  return request({
    url: '/finance/reimbursement',
    method: 'delete',
    params: { ids }
  })
}

export function auditReimbursement(data) {
  return request({
    url: '/finance/reimbursement/audit',
    method: 'post',
    data: data
  })
}

export function payReimbursement(data) {
  return request({
    url: '/finance/reimbursement/pay',
    method: 'post',
    data: data
  })
}

export function reportByMonth(query) {
  return request({
    url: '/finance/reimbursement/report/byMonth',
    method: 'get',
    params: query
  })
}

export function reportByCategory(query) {
  return request({
    url: '/finance/reimbursement/report/byCategory',
    method: 'get',
    params: query
  })
}

export function reportByDept(query) {
  return request({
    url: '/finance/reimbursement/report/byDept',
    method: 'get',
    params: query
  })
}

export function reportByUser(query) {
  return request({
    url: '/finance/reimbursement/report/byUser',
    method: 'get',
    params: query
  })
}

export function reportByExpenseType(query) {
  return request({
    url: '/finance/reimbursement/report/byExpenseType',
    method: 'get',
    params: query
  })
}
