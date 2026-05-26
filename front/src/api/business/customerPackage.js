/**
 * @description 客户套餐管理接口 - 套餐查询与客户关联
 * @description 提供套餐列表查询、套餐详情获取、按客户ID查询已购套餐等接口
 */
import request from '@/utils/request'

/** 查询套餐列表 */
export function listPackage(query) {
  return request({ url: '/business/package/list', method: 'get', params: query })
}

/** 根据套餐ID查询套餐详情 */
export function getPackage(packageId) {
  return request({ url: '/business/package/' + packageId, method: 'get' })
}

/** 按客户ID查询已购套餐，可按状态筛选 */
export function getPackageByCustomer(customerId, status) {
  return request({ url: '/business/package/byCustomer', method: 'get', params: { customerId, status } })
}
