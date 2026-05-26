/**
 * @description 操作记录管理接口 - 持卡操作记录
 * @description 提供操作记录列表查询、新增操作记录、删除操作记录等接口
 */
import request from '@/utils/request'

/** 查询操作记录列表 */
export function listOperation(query) {
  return request({ url: '/business/operation/list', method: 'get', params: query })
}

/** 新增操作记录 */
export function addOperation(data) {
  return request({ url: '/business/operation', method: 'post', data })
}

/** 删除操作记录 */
export function delOperation(recordId) {
  return request({ url: '/business/operation', method: 'delete', params: { recordId } })
}
