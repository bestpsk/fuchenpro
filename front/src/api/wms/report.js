/**
 * @description 仓储报表接口 - 入库/出库/周转/流水统计
 * @description 提供入库汇总统计、出库汇总统计、库存周转率统计、产品出入库流水统计等接口
 */
import request from '@/utils/request'

/** 入库汇总统计，按时间范围统计入库数量和金额 */
export function stockInSummary(query) {
  return request({ url: '/wms/report/stockInSummary', method: 'get', params: query })
}

/** 出库汇总统计，按时间范围统计出库数量和金额 */
export function stockOutSummary(query) {
  return request({ url: '/wms/report/stockOutSummary', method: 'get', params: query })
}

/** 库存周转率统计，计算产品库存周转天数和周转率 */
export function inventoryTurnover(query) {
  return request({ url: '/wms/report/inventoryTurnover', method: 'get', params: query })
}

/** 产品出入库流水明细，记录每个产品的入库和出库流水 */
export function productFlow(query) {
  return request({ url: '/wms/report/productFlow', method: 'get', params: query })
}
