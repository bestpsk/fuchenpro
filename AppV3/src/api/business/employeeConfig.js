/**
 * @description 员工配置API - 员工排班与休息日配置接口
 * @description 提供员工配置列表查询、排班开关更新、休息日保存和查询接口。
 * 排班开关控制员工是否可被排班系统分配班次
 */
import request from '@/utils/request'

/**
 * 分页查询员工配置列表，包含排班状态和休息日信息
 * @param {object} params - 查询参数 { pageNum, pageSize, enterpriseId, storeId }
 * @returns {Promise<object>} 员工配置分页列表
 */
export function listEmployeeConfig(params) {
  return request({ url: '/business/employeeConfig/list', method: 'get', params })
}

/**
 * 更新员工是否可排班状态，关闭后排班系统不会为该员工分配班次
 * @param {string|number} userId - 员工用户ID
 * @param {string} isSchedulable - 是否可排班，'0' 不可排班，'1' 可排班
 * @returns {Promise<void>}
 */
export function updateSchedulable(userId, isSchedulable) {
  return request({ url: '/business/employeeConfig/updateSchedulable', method: 'put', data: { userId, isSchedulable } })
}

/**
 * 批量保存员工休息日期，用于排班系统排除这些日期
 * @param {string|number} userId - 员工用户ID
 * @param {Array<string>} restDates - 休息日期数组，格式为'YYYY-MM-DD'
 * @returns {Promise<void>}
 */
export function saveRestDates(userId, restDates) {
  return request({ url: '/business/employeeConfig/saveRestDates', method: 'post', data: { userId, restDates } })
}

/**
 * 获取员工休息日期列表
 * @param {string|number} userId - 员工用户ID
 * @returns {Promise<Array<string>>} 休息日期数组
 */
export function getRestDates(userId) {
  return request({ url: '/business/employeeConfig/getRestDates', method: 'get', params: { userId } })
}

/**
 * 获取员工某月所有休息相关日期（含轮休、请假、自定义、法定假日），带类型信息
 * @param {string|number} userId - 员工用户ID
 * @param {string} yearMonth - 年月，格式 'YYYY-MM'
 * @returns {Promise<{dates: Array<{date, type, typeName, color, typeId?}>, typeList: Array<{type, name, color, count}>, yearMonth: string}>}
 */
export function getAllRestDates(userId, yearMonth) {
  return request({ url: '/business/employeeConfig/getAllRestDates', method: 'get', params: { userId, yearMonth } })
}

/**
 * 获取员工全部休息日（不限月份，2年前~1年后），供配置弹窗跨月查看和回显已存日期
 * @param {string|number} userId - 员工用户ID
 * @returns {Promise<{dates: Array<{date, type, typeName, color, typeId?}>, typeList: Array<{type, name, color, count}>}>}
 */
export function getAllRestDatesAll(userId) {
  return request({ url: '/business/employeeConfig/getAllRestDatesAll', method: 'get', params: { userId } })
}

/**
 * 批量获取多员工某月所有休息日期（带类型信息，供行程格子批量显示）
 * @param {Array<number>|string} userIds - 员工用户ID数组或逗号分隔字符串
 * @param {string} yearMonth - 年月，格式 'YYYY-MM'
 * @returns {Promise<Array<{userId, dates: Array<{date, type, typeName, color, typeId?}>, typeList: Array}>>}
 */
export function getAllRestDatesBatch(userIds, yearMonth) {
  const ids = Array.isArray(userIds) ? userIds.join(',') : userIds
  return request({ url: '/business/employeeConfig/getAllRestDatesBatch', method: 'get', params: { userIds: ids, yearMonth } })
}
