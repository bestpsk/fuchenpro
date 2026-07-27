/**
 * @description 考勤统计接口
 */
import request from '@/utils/request'

/** 查询考勤统计汇总 */
export function listAttendanceStats(query) {
  return request({ url: '/business/attendance/stats', method: 'get', params: query })
}

/** 查询考勤日历视图（每员工每天的状态） */
export function listAttendanceCalendar(query) {
  return request({ url: '/business/attendance/stats/calendar', method: 'get', params: query })
}
