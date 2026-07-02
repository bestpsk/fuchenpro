/**
 * @description 销售订单管理接口 - 订单CRUD与审核
 * @description 提供销售订单增删改查、企业审核、财务审核等接口
 */
import request from '@/utils/request'

/** 查询销售订单列表 */
export function listSalesOrder(query) {
  return request({ url: '/business/sales/list', method: 'get', params: query })
}

/** 根据订单ID查询订单详情 */
export function getSalesOrder(orderId) {
  return request({ url: '/business/sales/' + orderId, method: 'get' })
}

/** 新增销售订单 */
export function addSalesOrder(data) {
  return request({ url: '/business/sales', method: 'post', data })
}

/** 修改销售订单 */
export function updateSalesOrder(data) {
  return request({ url: '/business/sales', method: 'put', data })
}

/** 删除销售订单 */
export function delSalesOrder(orderIds) {
  return request({
    url: '/business/sales',
    method: 'delete',
    params: { orderIds }
  })
}

/** 企业审核（支持开启和关闭） */
export function enterpriseAudit(orderId, action = 'open') {
  return request({ url: '/business/sales/enterpriseAudit', method: 'post', data: { orderId, action } })
}

/** 财务审核通过 */
export function financeAudit(orderId) {
  return request({ url: '/business/sales/financeAudit', method: 'post', data: { orderId } })
}

export function cancelOrder(orderId) {
  return request({ url: '/business/sales/cancel', method: 'post', data: { orderId } })
}
