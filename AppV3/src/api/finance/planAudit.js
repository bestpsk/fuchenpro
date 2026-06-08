import request from '@/utils/request'

export function listPlanAudit(params) {
  return request({ url: '/finance/planAudit/list', method: 'get', params })
}

export function getPlanAudit(id) {
  return request({ url: '/finance/planAudit/' + id, method: 'get' })
}

export function auditPlan(data) {
  return request({ url: '/finance/planAudit/audit', method: 'post', data })
}
