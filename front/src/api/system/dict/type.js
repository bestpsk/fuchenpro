/**
 * @description 字典类型接口 - 字典类型增删改查与缓存管理
 * @description 提供字典类型列表查询、详情获取、新增、修改、删除、刷新缓存、下拉选择列表等接口
 */
import request from '@/utils/request'

/** 查询字典类型列表，支持分页查询 */
export function listType(query) {
  return request({
    url: '/system/dict/type/list',
    method: 'get',
    params: query
  })
}

/** 根据字典ID获取字典类型详细信息 */
export function getType(dictId) {
  return request({
    url: '/system/dict/type/' + dictId,
    method: 'get'
  })
}

/** 新增字典类型 */
export function addType(data) {
  return request({
    url: '/system/dict/type',
    method: 'post',
    data: data
  })
}

/** 修改字典类型信息 */
export function updateType(data) {
  return request({
    url: '/system/dict/type',
    method: 'put',
    data: data
  })
}

/** 根据字典ID删除字典类型 */
export function delType(dictId) {
  return request({
    url: '/system/dict/type',
    method: 'delete',
    params: { dictId }
  })
}

/** 刷新字典缓存，清除Redis中缓存的字典数据 */
export function refreshCache() {
  return request({
    url: '/system/dict/type/refreshCache',
    method: 'delete'
  })
}

/** 获取所有字典类型的下拉选择列表（用于字典类型切换） */
export function optionselect() {
  return request({
    url: '/system/dict/type/optionselect',
    method: 'get'
  })
}
