/**
 * @description 供应商管理接口 - 供应商CRUD与搜索
 * @description 提供供应商列表查询、详情获取、新增、修改、删除、关键词搜索等接口
 */
import request from '@/utils/request'

/** 查询供应商列表，支持分页查询 */
export function listSupplier(query) {
  return request({ url: '/wms/supplier/list', method: 'get', params: query })
}

/** 根据供应商ID获取供应商详细信息 */
export function getSupplier(supplierId) {
  return request({ url: '/wms/supplier/' + supplierId, method: 'get' })
}

/** 新增供应商 */
export function addSupplier(data) {
  return request({ url: '/wms/supplier', method: 'post', data: data })
}

/** 修改供应商信息 */
export function updateSupplier(data) {
  return request({ url: '/wms/supplier', method: 'put', data: data })
}

/** 根据供应商ID删除供应商 */
export function delSupplier(supplierIds) {
  return request({ url: '/wms/supplier', method: 'delete', params: { supplierIds } })
}

/** 按关键词搜索供应商（用于下拉选择等场景） */
export function searchSupplier(keyword) {
  return request({ url: '/wms/supplier/search', method: 'get', params: { keyword } })
}
