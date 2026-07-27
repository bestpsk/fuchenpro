import request from '@/utils/request'

// 分页查询学习统计列表
export function listStudyStats(query) {
  return request({ url: '/train/stats/list', method: 'get', params: query })
}

// 获取学习统计汇总
export function getStudyStatsSummary(query) {
  return request({ url: '/train/stats/summary', method: 'get', params: query })
}

// 导出学习统计
export function exportStudyStats(query) {
  return request({ url: '/train/stats/export', method: 'post', params: query, responseType: 'blob' })
}
