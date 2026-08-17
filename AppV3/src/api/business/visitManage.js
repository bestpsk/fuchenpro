/**
 * @description 满意度回访管理接口 - 登录态，回访任务与问卷模板管理
 * @description 业务管理子模块，权限标识 business:visit:*
 * @description 注意：与 visit.js（H5公共免登录接口）区分，本文件为登录态管理接口
 */
import request from '@/utils/request'

// ==================== 回访任务管理 ====================

/** 查询回访任务列表 */
export function listVisit(query) {
  return request({ url: '/business/visit/list', method: 'get', params: query })
}

/** 回访任务详情（含题目+答案） */
export function getVisit(visitId) {
  return request({ url: '/business/visit/' + visitId, method: 'get' })
}

/** 新增回访任务 */
export function addVisit(data) {
  return request({ url: '/business/visit', method: 'post', data })
}

/** 修改回访任务 */
export function updateVisit(data) {
  return request({ url: '/business/visit', method: 'put', data })
}

/** 删除回访任务 */
export function delVisit(visitIds) {
  return request({ url: '/business/visit', method: 'delete', params: { visitIds } })
}

/** 生成/刷新H5链接 */
export function generateVisitLink(visitId) {
  return request({ url: '/business/visit/generateLink', method: 'post', data: { visitId } })
}

/** 满意度统计（按企业汇总） */
export function getVisitStats(query) {
  return request({ url: '/business/visit/stats', method: 'post', data: query })
}

// ==================== 问卷模板管理 ====================

/** 查询模板列表 */
export function listVisitTemplate(query) {
  return request({ url: '/business/visit/templateList', method: 'get', params: query })
}

/** 模板详情（含题目） */
export function getVisitTemplate(templateId) {
  return request({ url: '/business/visit/template/' + templateId, method: 'get' })
}

/** 新增模板 */
export function addVisitTemplate(data) {
  return request({ url: '/business/visit/template', method: 'post', data })
}

/** 修改模板 */
export function updateVisitTemplate(data) {
  return request({ url: '/business/visit/template', method: 'put', data })
}

/** 删除模板 */
export function delVisitTemplate(templateIds) {
  return request({ url: '/business/visit/template', method: 'delete', params: { templateIds } })
}
