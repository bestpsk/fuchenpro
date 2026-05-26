/**
 * @description 盘点管理接口 - 盘点单CRUD与确认/加载库存
 * @description 提供盘点单列表查询、详情获取、新增、修改、删除、确认盘点、加载当前库存数据等接口
 */
import request from '@/utils/request'

/** 查询盘点单列表，支持分页查询 */
export function listStockCheck(query) {
  return request({ url: '/wms/stockCheck/list', method: 'get', params: query })
}

/** 根据盘点单ID获取盘点单详细信息 */
export function getStockCheck(stockCheckId) {
  return request({ url: '/wms/stockCheck/' + stockCheckId, method: 'get' })
}

/** 新增盘点单 */
export function addStockCheck(data) {
  return request({ url: '/wms/stockCheck', method: 'post', data: data })
}

/** 修改盘点单信息 */
export function updateStockCheck(data) {
  return request({ url: '/wms/stockCheck', method: 'put', data: data })
}

/** 根据盘点单ID删除盘点单 */
export function delStockCheck(stockCheckIds) {
  return request({ url: '/wms/stockCheck', method: 'delete', params: { stockCheckIds } })
}

/** 确认盘点，将盘点差异调整到库存 */
export function confirmStockCheck(id) {
  return request({ url: '/wms/stockCheck/confirm/' + id, method: 'put' })
}

/** 加载当前库存数据到盘点单（用于新建盘点时自动填充当前库存） */
export function loadInventoryData() {
  return request({ url: '/wms/stockCheck/loadInventory', method: 'get' })
}
