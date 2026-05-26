/**
 * @description 服务器监控接口 - 服务器运行信息
 * @description 提供服务器CPU、内存、JVM、磁盘等运行信息查询接口
 */
import request from '@/utils/request'

/** 获取服务器运行信息 */
export function getServer() {
  return request({
    url: '/monitor/server',
    method: 'get'
  })
}
