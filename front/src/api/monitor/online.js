/**
 * @description 在线用户监控接口 - 在线用户查看与强退
 * @description 提供在线用户列表查询和强制退出用户接口
 */
import request from '@/utils/request'

/** 查询在线用户列表 */
export function list(query) {
  return request({
    url: '/monitor/online/list',
    method: 'get',
    params: query
  })
}

/** 强制退出指定在线用户 */
export function forceLogout(tokenId) {
  return request({
    url: '/monitor/online',
    method: 'delete',
    params: { tokenId }
  })
}
