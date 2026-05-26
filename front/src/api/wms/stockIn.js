/**
 * @description 入库管理接口 - 入库单CRUD与确认/取消确认
 * @description 提供入库单列表查询、详情获取、新增、修改、删除、确认入库、取消确认入库等接口
 */
import request from '@/utils/request'

/** 查询入库单列表，支持分页查询 */
export function listStockIn(query) {
  return request({ url: '/wms/stockIn/list', method: 'get', params: query })
}

/** 根据入库单ID获取入库单详细信息 */
export function getStockIn(stockInId) {
  return request({ url: '/wms/stockIn/' + stockInId, method: 'get' })
}

/** 新增入库单 */
export function addStockIn(data) {
  return request({ url: '/wms/stockIn', method: 'post', data: data })
}

/** 修改入库单信息 */
export function updateStockIn(data) {
  return request({ url: '/wms/stockIn', method: 'put', data: data })
}

/** 根据入库单ID删除入库单 */
export function delStockIn(stockInIds) {
  return request({ url: '/wms/stockIn', method: 'delete', params: { stockInIds } })
}

/** 确认入库，将入库数量计入库存 */
export function confirmStockIn(id) {
  return request({ url: '/wms/stockIn/confirm/' + id, method: 'put' })
}

/** 根据入库单ID确认入库（与confirmStockIn功能相同，参数名不同） */
export function confirmStockInById(stockInId) {
  return request({ url: '/wms/stockIn/confirm/' + stockInId, method: 'put' })
}

/** 取消确认入库，将已入库数量从库存中扣减 */
export function cancelConfirmStockIn(stockInId) {
  return request({ url: '/wms/stockIn/cancelConfirm/' + stockInId, method: 'put' })
}
