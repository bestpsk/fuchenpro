/**
 * @description 发货管理接口 - 发货单CRUD与物流
 * @description 提供发货单增删改查、审核、发货、确认收货等接口
 */
import request from '@/utils/request'

/** 查询发货单列表 */
export function listShipment(query) {
  return request({ url: '/business/shipment/list', method: 'get', params: query })
}

/** 根据发货单ID查询详情 */
export function getShipment(shipmentId) {
  return request({ url: '/business/shipment/' + shipmentId, method: 'get' })
}

/** 新增发货单 */
export function addShipment(data) {
  return request({ url: '/business/shipment', method: 'post', data })
}

/** 修改发货单 */
export function updateShipment(data) {
  return request({ url: '/business/shipment', method: 'put', data })
}

/** 删除发货单 */
export function delShipment(shipmentIds) {
  return request({ url: '/business/shipment', method: 'delete', params: { shipmentIds } })
}

/** 审核发货单 */
export function auditShipment(data) {
  return request({ url: '/business/shipment/audit', method: 'put', data })
}

/** 发货操作 */
export function shipShipment(data) {
  return request({ url: '/business/shipment/ship', method: 'put', data })
}

/** 确认收货 */
export function confirmReceipt(shipmentId) {
  return request({ url: '/business/shipment/confirmReceipt/' + shipmentId, method: 'put' })
}
