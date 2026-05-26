/**
 * @description 还款管理接口 - 欠款还款与审核
 * @description 提供还款记录查询、欠款套餐查询、新增还款、审核还款、取消还款等接口
 */
import request from '@/utils/request'

/** 查询还款记录列表 */
export function listRepayment(params) {
  return request({ url: '/business/repayment/list', method: 'get', params })
}

/** 根据还款ID查询还款详情 */
export function getRepayment(repaymentId) {
  return request({ url: '/business/repayment/' + repaymentId, method: 'get' })
}

/** 查询客户欠款套餐列表 */
export function getOwedPackages(customerId) {
  return request({ url: '/business/repayment/owedPackages', method: 'get', params: { customerId } })
}

/** 新增还款记录 */
export function addRepayment(data) {
  return request({ url: '/business/repayment/add', method: 'post', data })
}

/** 审核还款 */
export function auditRepayment(repaymentId) {
  return request({ url: '/business/repayment/audit', method: 'post', data: { repaymentId } })
}

/** 取消还款 */
export function cancelRepayment(repaymentId) {
  return request({ url: '/business/repayment/cancel', method: 'post', data: { repaymentId } })
}
