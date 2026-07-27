/**
 * @description 休假管理接口 - 休假类型/休息日配置/请假管理/假期日历
 */
import request from '@/utils/request'

// ===================== 休假类型 =====================

/** 查询休假类型列表 */
export function listLeaveType(query) {
  return request({ url: '/business/leave/type/list', method: 'get', params: query })
}

/** 查询全部启用的休假类型（下拉用） */
export function listAllLeaveType() {
  return request({ url: '/business/leave/type/listAll', method: 'get' })
}

/** 查询休假类型详情 */
export function getLeaveType(typeId) {
  return request({ url: '/business/leave/type/' + typeId, method: 'get' })
}

/** 新增休假类型 */
export function addLeaveType(data) {
  return request({ url: '/business/leave/type', method: 'post', data })
}

/** 修改休假类型 */
export function updateLeaveType(data) {
  return request({ url: '/business/leave/type', method: 'put', data })
}

/** 删除休假类型 */
export function delLeaveType(typeIds) {
  return request({ url: '/business/leave/type', method: 'delete', data: { typeIds } })
}

// ===================== 休息日方案（方案模式） =====================

/** 查询休息日方案列表 */
export function listRestPlan(query) {
  return request({ url: '/business/leave/restPlan/list', method: 'get', params: query })
}

/** 查询休息日方案详情（含关联员工和日期） */
export function getRestPlan(planId) {
  return request({ url: '/business/leave/restPlan/' + planId, method: 'get' })
}

/** 获取部门树+员工列表（供员工选择弹窗用） */
export function getDeptTreeWithUsers() {
  return request({ url: '/business/leave/restPlan/deptTreeWithUsers', method: 'get' })
}

/** 获取部门下员工 */
export function getDeptUsers(deptId) {
  return request({ url: '/business/leave/restPlan/deptUsers/' + deptId, method: 'get' })
}

/** 新增休息日方案 */
export function addRestPlan(data) {
  return request({ url: '/business/leave/restPlan', method: 'post', data })
}

/** 修改休息日方案 */
export function updateRestPlan(data) {
  return request({ url: '/business/leave/restPlan', method: 'put', data })
}

/** 删除休息日方案 */
export function delRestPlan(planIds) {
  return request({ url: '/business/leave/restPlan', method: 'delete', data: { planIds } })
}

/** 批量获取员工某月休息日（供行程安排日历使用） */
export function getRestCalendar(query) {
  return request({
    url: '/business/leave/restPlan/restCalendar',
    method: 'get',
    params: query
  })
}

// ===================== 请假管理 =====================

/** 查询请假单列表 */
export function listLeave(query) {
  return request({ url: '/business/leave/list', method: 'get', params: query })
}

/** 查询请假单详情 */
export function getLeave(leaveId) {
  return request({ url: '/business/leave/' + leaveId, method: 'get' })
}

/** 新增请假单 */
export function addLeave(data) {
  return request({ url: '/business/leave', method: 'post', data })
}

/** 审核通过 */
export function approveLeave(data) {
  return request({ url: '/business/leave/approve', method: 'put', data })
}

/** 审核驳回 */
export function rejectLeave(data) {
  return request({ url: '/business/leave/reject', method: 'put', data })
}

/** 撤销请假单 */
export function cancelLeave(data) {
  return request({ url: '/business/leave/cancel', method: 'put', data })
}

/** 删除请假单 */
export function delLeave(leaveIds) {
  return request({ url: '/business/leave', method: 'delete', data: { leaveIds } })
}

/** 获取员工某月休假日期（供行程安排日历使用） */
export function getLeaveCalendar(query) {
  return request({ url: '/business/leave/calendar', method: 'get', params: query })
}

// ===================== 假期日历 =====================

/** 查询假期列表 */
export function listHoliday(query) {
  return request({ url: '/business/leave/holiday/list', method: 'get', params: query })
}

/** 查询假期详情 */
export function getHoliday(holidayId) {
  return request({ url: '/business/leave/holiday/' + holidayId, method: 'get' })
}

/** 新增假期 */
export function addHoliday(data) {
  return request({ url: '/business/leave/holiday', method: 'post', data })
}

/** 修改假期 */
export function updateHoliday(data) {
  return request({ url: '/business/leave/holiday', method: 'put', data })
}

/** 删除假期 */
export function delHoliday(holidayIds) {
  return request({ url: '/business/leave/holiday', method: 'delete', data: { holidayIds } })
}
