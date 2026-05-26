/**
 * @description 库存管理接口 - 库存查询与预警
 * @description 提供库存列表查询、库存预警查询、按产品ID查询库存详情等接口
 */
import request from '@/utils/request'

/** 查询库存列表，支持分页查询 */
export function listInventory(query) {
  return request({ url: '/wms/inventory/list', method: 'get', params: query })
}

/** 查询库存预警列表（低于安全库存的产品） */
export function listWarnInventory(query) {
  return request({ url: '/wms/inventory/warn', method: 'get', params: query })
}

/** 根据产品ID查询库存数量详情 */
export function getInventory(productId) {
  return request({ url: '/wms/inventory/' + productId, method: 'get' })
}
