/**
 * @description 企业管理接口 - 企业CRUD与状态管理
 * @description 提供企业列表查询、详情获取、新增、修改、删除、搜索（支持拼音）、状态变更等接口
 */
import request from '@/utils/request'

/** 查询企业列表，支持按名称/类型/状态分页查询 */
export function listEnterprise(query) {
  return request({
    url: '/business/enterprise/list',
    method: 'get',
    params: query
  })
}

/** 根据企业ID查询企业详细信息 */
export function getEnterprise(enterpriseId) {
  return request({
    url: '/business/enterprise/' + enterpriseId,
    method: 'get'
  })
}

/** 新增企业 */
export function addEnterprise(data) {
  return request({
    url: '/business/enterprise',
    method: 'post',
    data: data
  })
}

/** 修改企业信息 */
export function updateEnterprise(data) {
  return request({
    url: '/business/enterprise',
    method: 'put',
    data: data
  })
}

/** 删除企业 */
export function delEnterprise(enterpriseIds) {
  return request({
    url: '/business/enterprise',
    method: 'delete',
    params: { enterpriseIds }
  })
}

/** 搜索企业，支持拼音首字母模糊搜索 */
export function searchEnterprise(keyword) {
  return request({
    url: '/business/enterprise/search',
    method: 'get',
    params: { keyword }
  })
}

/** 修改企业状态（启用/停用） */
export function changeEnterpriseStatus(enterpriseId, status) {
  return request({
    url: '/business/enterprise/status',
    method: 'put',
    data: { enterpriseId, status }
  })
}
