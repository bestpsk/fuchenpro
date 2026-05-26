/**
 * @description 参数配置接口 - 系统参数增删改查与缓存刷新
 * @description 提供系统参数列表查询、详情获取、按键名查询、新增、修改、删除、刷新缓存等接口
 */
import request from '@/utils/request'

/** 查询参数列表 */
export function listConfig(query) {
  return request({
    url: '/system/config/list',
    method: 'get',
    params: query
  })
}

/** 根据参数ID查询参数详情 */
export function getConfig(configId) {
  return request({
    url: '/system/config/' + configId,
    method: 'get'
  })
}

/** 根据参数键名查询参数值 */
export function getConfigKey(configKey) {
  return request({
    url: '/system/config/configKey/' + configKey,
    method: 'get'
  })
}

/** 新增参数配置 */
export function addConfig(data) {
  return request({
    url: '/system/config',
    method: 'post',
    data: data
  })
}

/** 修改参数配置 */
export function updateConfig(data) {
  return request({
    url: '/system/config',
    method: 'put',
    data: data
  })
}

/** 删除参数配置 */
export function delConfig(configId) {
  return request({
    url: '/system/config',
    method: 'delete',
    params: { configId }
  })
}

/** 刷新参数缓存，清除Redis中的参数缓存 */
export function refreshCache() {
  return request({
    url: '/system/config/refreshCache',
    method: 'delete'
  })
}
