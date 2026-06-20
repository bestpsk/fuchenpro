/**
 * @description 备货管理API - 备货列表查询、详情获取与出库接口
 * @description 提供备货列表查询、详情获取和从备货创建出库单接口
 */
import request from '@/utils/request'

/**
 * 分页查询备货列表
 * @param {object} params - 查询参数 { pageNum, pageSize, enterpriseId, storeId, prepareNo, status }
 * @returns {Promise<object>} 备货分页列表
 */
export function listStockPrepare(params) {
  return request({
    url: '/business/stockPrepare/list',
    method: 'get',
    params
  })
}

/**
 * 根据ID获取备货详细信息
 * @param {string|number} id - 备货ID
 * @returns {Promise<object>} 备货详情（含items和orders）
 */
export function getStockPrepare(id) {
  return request({
    url: '/business/stockPrepare/' + id,
    method: 'get'
  })
}

/**
 * 从备货创建出库单
 * @param {object} data - 出库数据 { prepareId, items: [{ prepareItemId, productId, unitType, quantity, price, amount }] }
 * @returns {Promise<void>}
 */
export function createStockOutFromPrepare(data) {
  return request({
    url: '/business/stockPrepare/createStockOut',
    method: 'post',
    data
  })
}

// 从方案创建备货记录
export function createFromPlan(planId, items) {
  return request({ url: '/business/stockPrepare/createFromPlan', method: 'post', data: { planId, items } })
}

// 获取方案活跃备货金额
export function getActivePreparedAmount(planId) {
  return request({ url: '/business/stockPrepare/getActivePreparedAmount', method: 'get', params: { planId } })
}
