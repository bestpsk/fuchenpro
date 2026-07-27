/**
 * @description 企业小报接口 - 企业小报增删改查
 */
import request from '@/utils/request'

/** 查询企业小报列表 */
export function listAbout(query) {
  return request({
    url: '/admin/about/list',
    method: 'get',
    params: query
  })
}

/** 根据ID查询企业小报详情 */
export function getAbout(aboutId) {
  return request({
    url: '/admin/about/' + aboutId,
    method: 'get'
  })
}

/** 新增企业小报 */
export function addAbout(data) {
  return request({
    url: '/admin/about',
    method: 'post',
    data: data
  })
}

/** 修改企业小报 */
export function updateAbout(data) {
  return request({
    url: '/admin/about',
    method: 'put',
    data: data
  })
}

/** 删除企业小报 */
export function delAbout(aboutIds) {
  return request({
    url: '/admin/about',
    method: 'delete',
    params: { aboutIds }
  })
}
