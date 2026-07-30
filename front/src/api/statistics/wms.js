import request from '@/utils/request'

// 库存金额汇总
export function inventorySummary() {
  return request({
    url: '/statistics/wms/inventorySummary',
    method: 'get'
  })
}

// 滞销货品预警
export function slowMoving(params) {
  return request({
    url: '/statistics/wms/slowMoving',
    method: 'get',
    params
  })
}

// 库存预警
export function inventoryWarning() {
  return request({
    url: '/statistics/wms/inventoryWarning',
    method: 'get'
  })
}

// 库存周转率
export function turnover(params) {
  return request({
    url: '/statistics/wms/turnover',
    method: 'get',
    params
  })
}
