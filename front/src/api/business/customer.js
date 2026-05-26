/**
 * @description 客户管理接口 - 客户CRUD与多条件搜索
 * @description 提供客户列表查询、详情获取、多条件搜索（关键词/企业/门店/成交状态/满意度）、新增、修改、删除等接口
 */
import request from '@/utils/request'

/** 查询客户列表，支持分页查询 */
export function listCustomer(query) {
  return request({ url: '/business/customer/list', method: 'get', params: query })
}

/** 根据客户ID获取客户详细信息 */
export function getCustomer(customerId) {
  return request({ url: '/business/customer/' + customerId, method: 'get' })
}

/** 多条件搜索客户，支持关键词/企业/门店/成交状态/满意度筛选 */
export function searchCustomer(keyword, enterpriseId, storeId, hasDeal, satisfaction) {
  return request({ url: '/business/customer/search', method: 'get', params: { keyword, enterpriseId, storeId, hasDeal, satisfaction } })
}

/** 新增客户信息 */
export function addCustomer(data) {
  return request({ url: '/business/customer', method: 'post', data })
}

/** 修改客户信息 */
export function updateCustomer(data) {
  return request({ url: '/business/customer', method: 'put', data })
}

/** 根据客户ID删除客户 */
export function delCustomer(customerIds) {
  return request({
    url: '/business/customer',
    method: 'delete',
    params: { customerIds }
  })
}

export function uploadCustomerAvatar(customerId, file) {
  const formData = new FormData()
  formData.append('avatarfile', file)
  formData.append('customer_id', customerId)
  return request({ url: '/business/customer/avatar', method: 'post', data: formData, headers: { 'Content-Type': 'multipart/form-data' } })
}
