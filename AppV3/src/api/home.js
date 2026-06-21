/**
 * @description 首页数据API - 首页汇总数据与统计接口
 * @description 提供首页今日统计数据和企业统计数据接口
 */
import request from '@/utils/request'

/**
 * 获取今日统计数据，包括今日订单数、销售额等
 * @returns {Promise<object>} 今日统计数据
 */
export function getTodayStats(params) {
  return request({
    url: '/home/stats',
    method: 'get',
    params
  })
}

export function getEnterpriseStats(params) {
  return request({
    url: '/home/enterprise-stats',
    method: 'get',
    params
  })
}

export function getBannerList() {
  return request({
    url: '/app/banner/list',
    method: 'get'
  })
}
