/**
 * @description 定时任务调度接口 - 任务CRUD与执行控制
 * @description 提供定时任务增删改查、任务状态修改（暂停/恢复）、立即执行一次等接口
 */
import request from '@/utils/request'

/** 查询定时任务列表 */
export function listJob(query) {
  return request({
    url: '/monitor/job/list',
    method: 'get',
    params: query
  })
}

/** 根据任务ID查询定时任务详情 */
export function getJob(jobId) {
  return request({
    url: '/monitor/job/' + jobId,
    method: 'get'
  })
}

/** 新增定时任务 */
export function addJob(data) {
  return request({
    url: '/monitor/job',
    method: 'post',
    data: data
  })
}

/** 修改定时任务 */
export function updateJob(data) {
  return request({
    url: '/monitor/job',
    method: 'put',
    data: data
  })
}

/** 删除定时任务 */
export function delJob(jobId) {
  return request({
    url: '/monitor/job',
    method: 'delete',
    params: { jobId }
  })
}

/** 修改定时任务状态（0-正常/1-暂停） */
export function changeJobStatus(jobId, status) {
  const data = {
    jobId,
    status
  }
  return request({
    url: '/monitor/job/changeStatus',
    method: 'put',
    data: data
  })
}

/** 定时任务立即执行一次 */
export function runJob(jobId, jobGroup) {
  const data = {
    jobId,
    jobGroup
  }
  return request({
    url: '/monitor/job/run',
    method: 'put',
    data: data
  })
}
