/**
 * @description 考勤管理接口 - 考勤记录/规则/配置/打卡
 * @description 提供考勤记录查询、考勤规则CRUD、考勤配置CRUD、月度统计、
 * 打卡流水查询、获取用户考勤规则等接口
 */
import request from '@/utils/request'

/** 查询考勤记录列表 */
export function listAttendanceRecord(query) {
  return request({ url: '/business/attendance/record/list', method: 'get', params: query })
}

/** 根据记录ID查询考勤记录详情 */
export function getAttendanceRecord(recordId) {
  return request({ url: '/business/attendance/record/' + recordId, method: 'get' })
}

/** 查询考勤规则列表 */
export function listAttendanceRule(query) {
  return request({ url: '/business/attendance/rule/list', method: 'get', params: query })
}

/** 根据规则ID查询考勤规则详情 */
export function getAttendanceRule(ruleId) {
  return request({ url: '/business/attendance/rule/' + ruleId, method: 'get' })
}

/** 新增考勤规则 */
export function addAttendanceRule(data) {
  return request({ url: '/business/attendance/rule', method: 'post', data })
}

/** 修改考勤规则 */
export function updateAttendanceRule(data) {
  return request({ url: '/business/attendance/rule', method: 'put', data })
}

/** 删除考勤规则 */
export function delAttendanceRule(ruleIds) {
  return request({ url: '/business/attendance/rule', method: 'delete', params: { ruleIds } })
}

/** 获取考勤月度统计数据 */
export function getAttendanceMonthStats(query) {
  return request({ url: '/business/attendance/monthStats', method: 'get', params: query })
}

/** 根据考勤记录ID查询打卡流水明细 */
export function getClockListByRecordId(recordId) {
  return request({ url: '/business/attendance/clockList', method: 'get', params: { record_id: recordId } })
}

/** 查询考勤配置列表 */
export function listAttendanceConfig(query) {
  return request({ url: '/business/attendance/config/list', method: 'get', params: query })
}

/** 根据配置ID查询考勤配置详情 */
export function getAttendanceConfig(configId) {
  return request({ url: '/business/attendance/config/' + configId, method: 'get' })
}

/** 新增考勤配置 */
export function addAttendanceConfig(data) {
  return request({ url: '/business/attendance/config', method: 'post', data })
}

/** 修改考勤配置 */
export function updateAttendanceConfig(data) {
  return request({ url: '/business/attendance/config', method: 'put', data })
}

/** 删除考勤配置 */
export function delAttendanceConfig(configIds) {
  return request({ url: '/business/attendance/config', method: 'delete', params: { configIds } })
}

/** 获取当前用户的考勤规则（含工作地点坐标） */
export function getUserAttendanceRule(clockType = '0') {
  return request({ url: '/business/attendance/config/userRule', method: 'get', params: { clock_type: clockType } })
}
