/**
 * @description 方案管理接口 - 方案CRUD与审核
 * @description 提供方案增删改查、提交审核、审核、状态变更等接口
 */
import request from '@/utils/request'

/** 查询企业列表（方案关联用） */
export function listEnterprise(query) {
  return request({ url: '/business/plan/enterpriseList', method: 'get', params: query })
}

/** 查询方案列表 */
export function listPlan(query) {
  return request({ url: '/business/plan/list', method: 'get', params: query })
}

/** 根据方案ID查询方案详情 */
export function getPlan(planId) {
  return request({ url: '/business/plan/' + planId, method: 'get' })
}

/** 新增方案 */
export function addPlan(data) {
  return request({ url: '/business/plan', method: 'post', data })
}

/** 修改方案 */
export function updatePlan(data) {
  return request({ url: '/business/plan', method: 'put', data })
}

/** 删除方案 */
export function delPlan(planIds) {
  return request({ url: '/business/plan', method: 'delete', params: { planIds } })
}

/** 提交方案审核 */
export function submitAuditPlan(planId) {
  return request({ url: '/business/plan/submitAudit/' + planId, method: 'put' })
}

/** 审核方案 */
export function auditPlan(data) {
  return request({ url: '/business/plan/audit', method: 'put', data })
}

/** 变更方案状态 */
export function changePlanStatus(planId, status) {
  return request({ url: '/business/plan/changeStatus', method: 'put', data: { planId, status } })
}
