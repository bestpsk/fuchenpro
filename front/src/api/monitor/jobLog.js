/**
 * @description 调度日志接口 - 任务执行日志管理
 * @description 提供调度日志列表查询、删除日志、清空日志等接口
 */
import request from '@/utils/request'

/** 查询调度日志列表 */
export function listJobLog(query) {
  return request({
    url: '/monitor/jobLog/list',
    method: 'get',
    params: query
  })
}

/** 删除调度日志 */
export function delJobLog(jobLogId) {
  return request({
    url: '/monitor/jobLog',
    method: 'delete',
    params: { jobLogId }
  })
}

/** 清空调度日志 */
export function cleanJobLog() {
  return request({
    url: '/monitor/jobLog/clean',
    method: 'delete'
  })
}
