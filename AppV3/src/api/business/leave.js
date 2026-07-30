/**
 * @description 请假管理API - 请假申请、审批、撤销等接口
 * @description 提供请假列表查询、详情获取、新增、审核通过/驳回、撤销及休假类型查询接口
 */
import request from '@/utils/request'

/**
 * 分页查询请假列表
 * @param {object} params - 查询参数 { pageNum, pageSize, keyword, status }
 * @returns {Promise<object>} 请假分页列表
 */
// 请假列表
export function listLeave(params) {
  return request({
    url: '/business/leave/list',
    method: 'get',
    params
  })
}

/**
 * 根据ID获取请假详细信息
 * @param {string|number} id - 请假ID
 * @returns {Promise<object>} 请假详情
 */
// 请假详情
export function getLeave(id) {
  return request({
    url: '/business/leave/' + id,
    method: 'get'
  })
}

/**
 * 新增请假申请
 * @param {object} data - 请假数据 { leaveType, typeName, startDate, endDate, startTimeType, endTimeType, leaveDays, reason }
 * @returns {Promise<void>}
 */
// 新增请假
export function addLeave(data) {
  return request({
    url: '/business/leave',
    method: 'post',
    data
  })
}

/**
 * 审核通过
 * @param {object} data - { leaveId }
 * @returns {Promise<void>}
 */
// 审核通过
export function approveLeave(data) {
  return request({
    url: '/business/leave/approve',
    method: 'put',
    data
  })
}

/**
 * 审核驳回
 * @param {object} data - { leaveId, approveRemark }
 * @returns {Promise<void>}
 */
// 审核驳回
export function rejectLeave(data) {
  return request({
    url: '/business/leave/reject',
    method: 'put',
    data
  })
}

/**
 * 撤销请假申请
 * @param {object} data - { leaveId }
 * @returns {Promise<void>}
 */
// 撤销请假
export function cancelLeave(data) {
  return request({
    url: '/business/leave/cancel',
    method: 'put',
    data
  })
}

/**
 * 获取启用的休假类型列表
 * @returns {Promise<Array>} 休假类型列表
 */
// 获取启用的休假类型
export function listAllLeaveType() {
  return request({
    url: '/business/leave/type/listAll',
    method: 'get'
  })
}

/**
 * 获取当前员工某月的休息日和假期（供考勤日历标注用）
 * @param {object} params - { yearMonth: 'YYYY-MM' }
 * @returns {Promise<{restDates: string[], holidays: Array<{holidayName, startDate, endDate}>}>}
 */
export function getMyRestCalendar(params) {
  return request({
    url: '/business/leave/restPlan/myRestCalendar',
    method: 'get',
    params
  })
}

/**
 * 获取当前员工某月的休息日和假期（带类型信息，供"我的休息日"页面用）
 * @param {object} params - { yearMonth: 'YYYY-MM' }
 * @returns {Promise<{dates: Array<{date, type, typeName, color}>, typeList: Array<{type, name, color, count}>}>}
 */
export function getMyRestCalendarDetailed(params) {
  return request({
    url: '/business/leave/restPlan/myRestCalendarDetailed',
    method: 'get',
    params
  })
}

/**
 * 获取当前员工的有效休息日方案
 * @returns {Promise<object|null>} 休息日方案详情
 */
export function getMyRestPlan() {
  return request({
    url: '/business/leave/restPlan/myPlan',
    method: 'get'
  })
}

/**
 * 批量获取员工某月休息日（供行程安排日历使用）
 * @param {object} params - { yearMonth: 'YYYY-MM', userIds: '1,2,3' }
 * @returns {Promise<Array<{userId, restDates}>>}
 */
export function getRestCalendar(params) {
  return request({
    url: '/business/leave/restPlan/restCalendar',
    method: 'get',
    params
  })
}

/**
 * 批量获取员工某月请假日期（供行程安排日历使用）
 * @param {object} params - { yearMonth: 'YYYY-MM', userIds: '1,2,3' }
 * @returns {Promise<object>} {userId: [{date, label, color}]}
 */
export function getLeaveCalendar(params) {
  return request({
    url: '/business/leave/calendar',
    method: 'get',
    params
  })
}
