/**
 * @description 排班管理接口 - 行程排班与日历视图
 * @description 提供排班增删改查、日历视图、员工排班、企业排班、批量新增等接口
 */
import request from '@/utils/request'

/** 查询排班列表 */
export function listSchedule(query) {
  return request({
    url: '/business/schedule/list',
    method: 'get',
    params: query
  })
}

/** 根据排班ID查询排班详情 */
export function getSchedule(scheduleId) {
  return request({
    url: '/business/schedule/' + scheduleId,
    method: 'get'
  })
}

/** 日历视图查询排班数据 */
export function getScheduleCalendar(query) {
  return request({
    url: '/business/schedule/calendar',
    method: 'get',
    params: query
  })
}

/** 按员工查询排班 */
export function getEmployeeSchedule(query) {
  return request({
    url: '/business/schedule/employee',
    method: 'get',
    params: query
  })
}

/** 按企业查询排班 */
export function getEnterpriseSchedule(query) {
  return request({
    url: '/business/schedule/enterprise',
    method: 'get',
    params: query
  })
}

/** 新增排班 */
export function addSchedule(data) {
  return request({
    url: '/business/schedule',
    method: 'post',
    data: data
  })
}

/** 批量新增排班（多天） */
export function addScheduleBatch(data) {
  return request({
    url: '/business/schedule/batch',
    method: 'post',
    data: data
  })
}

/** 修改排班 */
export function updateSchedule(data) {
  return request({
    url: '/business/schedule',
    method: 'put',
    data: data
  })
}

/** 删除排班 */
export function delSchedule(scheduleIds) {
  return request({
    url: '/business/schedule',
    method: 'delete',
    params: { scheduleIds }
  })
}
