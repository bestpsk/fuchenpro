/**
 * @description 门店管理接口 - 门店CRUD与搜索
 * @description 提供门店增删改查、按关键词和企业搜索门店等接口
 */
import request from '@/utils/request'

/** 查询门店列表 */
export function listStore(query) {
  return request({
    url: '/business/store/list',
    method: 'get',
    params: query
  })
}

/** 根据门店ID查询门店详情 */
export function getStore(storeId) {
  return request({
    url: '/business/store/' + storeId,
    method: 'get'
  })
}

/** 新增门店 */
export function addStore(data) {
  return request({
    url: '/business/store',
    method: 'post',
    data: data
  })
}

/** 修改门店 */
export function updateStore(data) {
  return request({
    url: '/business/store',
    method: 'put',
    data: data
  })
}

/** 删除门店 */
export function delStore(storeIds) {
  return request({
    url: '/business/store',
    method: 'delete',
    params: { storeIds }
  })
}

/** 搜索门店，支持关键词和企业ID筛选 */
export function searchStore(keyword, enterpriseId) {
  return request({
    url: '/business/store/search',
    method: 'get',
    params: { keyword, enterpriseId }
  })
}
