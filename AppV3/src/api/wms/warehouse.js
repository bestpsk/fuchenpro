/**
 * @description 仓库管理接口 - 仓库CRUD与用户授权
 * @description 提供仓库增删改查、获取当前用户授权仓库、分配用户到仓库、获取仓库下用户等接口
 */
import request from '@/utils/request'

/** 获取当前用户授权仓库 */
export function getUserWarehouses() {
  return request({ url: '/wms/warehouse/getUserWarehouses', method: 'get' })
}

/** 查询仓库列表 */
export function listWarehouse(params) {
  return request({ url: '/wms/warehouse/list', method: 'get', params })
}

/** 根据仓库ID获取仓库详细信息 */
export function getWarehouse(warehouseId) {
  return request({ url: '/wms/warehouse/' + warehouseId, method: 'get' })
}

/** 新增仓库 */
export function addWarehouse(data) {
  return request({ url: '/wms/warehouse', method: 'post', data })
}

/** 修改仓库信息 */
export function updateWarehouse(data) {
  return request({ url: '/wms/warehouse', method: 'put', data })
}

/** 根据仓库ID删除仓库 */
export function delWarehouse(warehouseIds) {
  return request({ url: '/wms/warehouse', method: 'delete', params: { warehouseIds } })
}

/** 分配用户到仓库 */
export function assignUsers(data) {
  return request({ url: '/wms/warehouse/assignUsers', method: 'post', data })
}

/** 获取仓库下的用户 */
export function getWarehouseUsers(warehouseId) {
  return request({ url: '/wms/warehouse/' + warehouseId + '/users', method: 'get' })
}
