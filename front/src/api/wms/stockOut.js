/**
 * @description 出库管理接口 - 出库单CRUD与确认/取消确认
 * @description 提供出库单列表查询、详情获取、新增、修改、删除、确认出库、取消确认出库等接口
 */
import request from '@/utils/request'

/** 查询出库单列表，支持分页查询 */
export function listStockOut(query) {
  return request({ url: '/wms/stockOut/list', method: 'get', params: query })
}

/** 根据出库单ID获取出库单详细信息 */
export function getStockOut(stockOutId) {
  return request({ url: '/wms/stockOut/' + stockOutId, method: 'get' })
}

/** 新增出库单 */
export function addStockOut(data) {
  return request({ url: '/wms/stockOut', method: 'post', data: data })
}

/** 修改出库单信息 */
export function updateStockOut(data) {
  return request({ url: '/wms/stockOut', method: 'put', data: data })
}

/** 根据出库单ID删除出库单 */
export function delStockOut(stockOutIds) {
  return request({ url: '/wms/stockOut', method: 'delete', params: { stockOutIds } })
}

/** 确认出库，将出库数量从库存中扣减 */
export function confirmStockOut(id, warehouseId) {
  return request({ url: '/wms/stockOut/confirm/' + id, method: 'put', data: { warehouseId } })
}

/** 根据出库单ID确认出库（与confirmStockOut功能相同，参数名不同） */
export function confirmStockOutById(stockOutId) {
  return request({ url: '/wms/stockOut/confirm/' + stockOutId, method: 'put' })
}

/** 取消确认出库，将已出库数量归还库存 */
export function cancelConfirmStockOut(stockOutId) {
  return request({ url: '/wms/stockOut/cancelConfirm/' + stockOutId, method: 'put' })
}

/** 发货 */
export function shipStockOut(id, data) {
  return request({ url: '/wms/stockOut/ship/' + id, method: 'put', data: data })
}

/** 确认收货 */
export function confirmReceiptStockOut(id) {
  return request({ url: '/wms/stockOut/confirmReceipt/' + id, method: 'put' })
}
