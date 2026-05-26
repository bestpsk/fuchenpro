/**
 * @description 产品管理接口 - 产品CRUD与搜索
 * @description 提供产品列表查询、详情获取、新增、修改、删除、关键词搜索等接口
 */
import request from '@/utils/request'

/** 查询产品列表，支持分页查询 */
export function listProduct(query) {
  return request({ url: '/wms/product/list', method: 'get', params: query })
}

/** 根据产品ID获取产品详细信息 */
export function getProduct(productId) {
  return request({ url: '/wms/product/' + productId, method: 'get' })
}

/** 新增产品 */
export function addProduct(data) {
  return request({ url: '/wms/product', method: 'post', data: data })
}

/** 修改产品信息 */
export function updateProduct(data) {
  return request({ url: '/wms/product', method: 'put', data: data })
}

/** 根据产品ID删除产品 */
export function delProduct(productIds) {
  return request({ url: '/wms/product', method: 'delete', params: { productIds } })
}

/** 按关键词搜索产品（用于下拉选择等场景） */
export function searchProduct(keyword) {
  return request({ url: '/wms/product/search', method: 'get', params: { keyword } })
}
