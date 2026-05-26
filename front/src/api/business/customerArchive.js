/**
 * @description 客户档案管理接口 - 档案查询与维护
 * @description 提供客户档案列表查询、新增档案、删除档案等接口
 */
import request from '@/utils/request'

/** 查询客户档案列表 */
export function listArchive(params) {
  return request({ url: '/business/archive/list', method: 'get', params })
}

/** 新增客户档案 */
export function addArchive(data) {
  return request({ url: '/business/archive/add', method: 'post', data })
}

/** 删除客户档案 */
export function deleteArchive(archiveIds) {
  return request({ url: '/business/archive', method: 'delete', params: { archiveIds } })
}
