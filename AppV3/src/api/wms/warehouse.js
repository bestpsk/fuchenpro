import request from '@/utils/request'

/** 获取当前用户授权仓库 */
export function getUserWarehouses() {
  return request({ url: '/wms/warehouse/getUserWarehouses', method: 'get' })
}

/** 查询仓库列表 */
export function listWarehouse(params) {
  return request({ url: '/wms/warehouse/list', method: 'get', params })
}
