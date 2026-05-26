/**
 * @description 登录日志接口 - 登录记录查询与管理
 * @description 提供登录日志列表查询、删除日志、清空日志、解锁用户登录状态等接口
 */
import request from '@/utils/request'

/** 查询登录日志列表 */
export function list(query) {
  return request({
    url: '/monitor/logininfor/list',
    method: 'get',
    params: query
  })
}

/** 删除登录日志 */
export function delLogininfor(infoId) {
  return request({
    url: '/monitor/logininfor',
    method: 'delete',
    params: { infoId }
  })
}

/** 解锁用户登录状态，清除登录失败锁定 */
export function unlockLogininfor(userName) {
  return request({
    url: '/monitor/logininfor/unlock/' + userName,
    method: 'get'
  })
}

/** 清空登录日志 */
export function cleanLogininfor() {
  return request({
    url: '/monitor/logininfor/clean',
    method: 'delete'
  })
}
