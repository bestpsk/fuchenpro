/**
 * @description 员工配置管理接口 - 员工CRUD与排班配置
 * @description 提供员工配置增删改查、排班可用状态设置、员工搜索等接口
 * @description 休息日管理已迁移至 api/business/leave.js（getRestCalendar）
 */
import request from '@/utils/request'

/** 查询员工配置列表 */
export function listEmployeeConfig(query) {
  return request({
    url: '/business/employeeConfig/list',
    method: 'get',
    params: query
  })
}

/** 根据配置ID查询员工配置详情 */
export function getEmployeeConfig(configId) {
  return request({
    url: '/business/employeeConfig/' + configId,
    method: 'get'
  })
}

/** 新增员工配置 */
export function addEmployeeConfig(data) {
  return request({
    url: '/business/employeeConfig',
    method: 'post',
    data: data
  })
}

/** 修改员工配置 */
export function updateEmployeeConfig(data) {
  return request({
    url: '/business/employeeConfig',
    method: 'put',
    data: data
  })
}

/** 设置员工是否可排班 */
export function updateSchedulable(userId, isSchedulable) {
  return request({
    url: '/business/employeeConfig/updateSchedulable',
    method: 'put',
    data: { userId, isSchedulable }
  })
}

/** 删除员工配置 */
export function delEmployeeConfig(configIds) {
  return request({
    url: '/business/employeeConfig',
    method: 'delete',
    params: { configIds }
  })
}

/** 搜索员工，支持关键词模糊搜索 */
export function searchEmployee(keyword) {
  return request({
    url: '/business/employeeConfig/search',
    method: 'get',
    params: { keyword }
  })
}

/** 保存员工休息日期 */
export function saveRestDates(userId, restDates) {
  return request({
    url: '/business/employeeConfig/saveRestDates',
    method: 'post',
    data: { userId, restDates }
  })
}

/** 获取员工休息日期 */
export function getRestDates(userId) {
  return request({
    url: '/business/employeeConfig/getRestDates',
    method: 'get',
    params: { userId }
  })
}

/** 获取员工某月所有休息相关日期（含轮休、请假、自定义、法定假日），带类型信息 */
export function getAllRestDates(userId, yearMonth) {
  return request({
    url: '/business/employeeConfig/getAllRestDates',
    method: 'get',
    params: { userId, yearMonth }
  })
}

/** 获取员工全部休息日（不限月份，2年前~1年后），供配置弹窗跨月查看和回显已存日期 */
export function getAllRestDatesAll(userId) {
  return request({
    url: '/business/employeeConfig/getAllRestDatesAll',
    method: 'get',
    params: { userId }
  })
}

/** 批量获取多员工某月所有休息日期（带类型信息，供行程格子批量显示） */
export function getAllRestDatesBatch(userIds, yearMonth) {
  return request({
    url: '/business/employeeConfig/getAllRestDatesBatch',
    method: 'get',
    params: { userIds: Array.isArray(userIds) ? userIds.join(',') : userIds, yearMonth }
  })
}
