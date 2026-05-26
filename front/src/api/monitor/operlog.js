/**
 * @description 操作日志接口 - 操作记录查询与管理
 * @description 提供操作日志列表查询、删除日志、清空日志等接口
 */
import request from '@/utils/request'

/** 查询操作日志列表 */
export function list(query) {
  return request({
    url: '/monitor/operlog/list',
    method: 'get',
    params: query
  })
}

/** 删除操作日志 */
export function delOperlog(operId) {
  return request({
    url: '/monitor/operlog',
    method: 'delete',
    params: { operId }
  })
}

/** 清空操作日志 */
export function cleanOperlog() {
  return request({
    url: '/monitor/operlog/clean',
    method: 'delete'
  })
}
