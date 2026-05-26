/**
 * @description 缓存监控接口 - Redis缓存查看与清理
 * @description 提供缓存信息查询、缓存键名列表、缓存内容查看、按名称/键名/全部清理缓存等接口
 */
import request from '@/utils/request'

/** 查询缓存详细信息（Redis基本信息） */
export function getCache() {
  return request({
    url: '/monitor/cache',
    method: 'get'
  })
}

/** 查询缓存名称列表 */
export function listCacheName() {
  return request({
    url: '/monitor/cache/getNames',
    method: 'get'
  })
}

/** 根据缓存名称查询键名列表 */
export function listCacheKey(cacheName) {
  return request({
    url: '/monitor/cache/getKeys/' + cacheName,
    method: 'get'
  })
}

/** 根据缓存名称和键名查询缓存内容 */
export function getCacheValue(cacheName, cacheKey) {
  return request({
    url: '/monitor/cache/getValue/' + cacheName + '/' + cacheKey,
    method: 'get'
  })
}

/** 清理指定名称下的所有缓存 */
export function clearCacheName(cacheName) {
  return request({
    url: '/monitor/cache/clearCacheName',
    method: 'delete',
    params: { cacheName }
  })
}

export function clearCacheKey(cacheKey) {
  return request({
    url: '/monitor/cache/clearCacheKey',
    method: 'delete',
    params: { cacheKey }
  })
}

/** 清理全部缓存 */
export function clearCacheAll() {
  return request({
    url: '/monitor/cache/clearCacheAll',
    method: 'delete'
  })
}
