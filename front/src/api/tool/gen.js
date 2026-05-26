/**
 * @description 代码生成接口 - 表导入/代码预览/生成/同步
 * @description 提供代码生成表列表查询、数据库表列表查询、表详情获取、代码生成配置修改、
 * 导入数据库表、创建表、预览生成代码、删除表、生成代码到自定义路径、同步表结构等接口
 */
import request from '@/utils/request'

/** 查询已导入的代码生成表列表 */
export function listTable(query) {
  return request({
    url: '/tool/gen/list',
    method: 'get',
    params: query
  })
}
/** 查询数据库中可导入的表列表（未导入的表） */
export function listDbTable(query) {
  return request({
    url: '/tool/gen/db/list',
    method: 'get',
    params: query
  })
}

/** 根据表ID获取代码生成配置详情（含字段信息和生成选项） */
export function getGenTable(tableId) {
  return request({
    url: '/tool/gen/' + tableId,
    method: 'get'
  })
}

/** 修改代码生成配置（基本信息、字段信息、生成选项） */
export function updateGenTable(data) {
  return request({
    url: '/tool/gen',
    method: 'put',
    data: data
  })
}

/** 从数据库导入表结构到代码生成器 */
export function importTable(data) {
  return request({
    url: '/tool/gen/importTable',
    method: 'post',
    params: data
  })
}

/** 通过SQL语句创建表并导入代码生成器 */
export function createTable(data) {
  return request({
    url: '/tool/gen/createTable',
    method: 'post',
    params: data
  })
}

/** 预览代码生成结果（返回各模板的代码内容） */
export function previewTable(tableId) {
  return request({
    url: '/tool/gen/preview/' + tableId,
    method: 'get'
  })
}

/** 根据表ID删除代码生成配置 */
export function delTable(tableId) {
  return request({
    url: '/tool/gen',
    method: 'delete',
    params: { tableId }
  })
}

/** 生成代码并下载到自定义路径 */
export function genCode(tableName) {
  return request({
    url: '/tool/gen/genCode/' + tableName,
    method: 'get'
  })
}

/** 同步数据库表结构到代码生成配置（表结构变更后使用） */
export function synchDb(tableName) {
  return request({
    url: '/tool/gen/synchDb/' + tableName,
    method: 'get'
  })
}
