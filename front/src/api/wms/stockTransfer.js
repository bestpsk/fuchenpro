/**
 * @description 调拨管理接口 - 调拨单CRUD与确认/取消确认
 * @description 提供调拨单列表查询、详情获取、新增、修改、删除、确认调拨、取消确认调拨等接口
 */
import request from '@/utils/request'

/** 查询调拨单列表，支持分页查询 */
export function listStockTransfer(query) {
  return request({ url: '/wms/stockTransfer/list', method: 'get', params: query })
}

/** 根据调拨单ID获取调拨单详细信息 */
export function getStockTransfer(transferId) {
  return request({ url: '/wms/stockTransfer/' + transferId, method: 'get' })
}

/** 新增调拨单 */
export function addStockTransfer(data) {
  return request({ url: '/wms/stockTransfer', method: 'post', data })
}

/** 修改调拨单信息 */
export function updateStockTransfer(data) {
  return request({ url: '/wms/stockTransfer', method: 'put', data })
}

/** 根据调拨单ID删除调拨单 */
export function delStockTransfer(transferIds) {
  return request({ url: '/wms/stockTransfer', method: 'delete', params: { transferIds } })
}

/** 确认调拨，将调拨数量从源仓库扣减并计入目标仓库库存 */
export function confirmStockTransfer(transferId) {
  return request({ url: '/wms/stockTransfer/confirm/' + transferId, method: 'put' })
}

/** 取消确认调拨，将已调拨数量从目标仓库扣减并归还源仓库库存 */
export function cancelConfirmStockTransfer(transferId) {
  return request({ url: '/wms/stockTransfer/cancelConfirm/' + transferId, method: 'put' })
}
