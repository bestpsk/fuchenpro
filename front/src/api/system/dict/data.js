/**
 * @description 字典数据接口 - 字典项增删改查与按类型查询
 * @description 提供字典数据列表查询、详情获取、按字典类型查询字典项、新增、修改、删除等接口
 */
import request from '@/utils/request'

/** 查询字典数据列表，支持分页查询 */
export function listData(query) {
  return request({
    url: '/system/dict/data/list',
    method: 'get',
    params: query
  })
}

/** 根据字典编码获取字典数据详细信息 */
export function getData(dictCode) {
  return request({
    url: '/system/dict/data/' + dictCode,
    method: 'get'
  })
}

/** 根据字典类型查询该类型下的所有字典项（前端下拉框/标签常用） */
export function getDicts(dictType) {
  return request({
    url: '/system/dict/data/type/' + dictType,
    method: 'get'
  })
}

/** 新增字典数据项 */
export function addData(data) {
  return request({
    url: '/system/dict/data',
    method: 'post',
    data: data
  })
}

/** 修改字典数据项 */
export function updateData(data) {
  return request({
    url: '/system/dict/data',
    method: 'put',
    data: data
  })
}

/** 根据字典编码删除字典数据项 */
export function delData(dictCode) {
  return request({
    url: '/system/dict/data',
    method: 'delete',
    params: { dictCode }
  })
}
