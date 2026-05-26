/**
 * @description 岗位管理接口 - 岗位增删改查
 * @description 提供岗位列表查询、详情获取、新增、修改、删除等接口
 */
import request from '@/utils/request'

/** 查询岗位列表，支持分页查询 */
export function listPost(query) {
  return request({
    url: '/system/post/list',
    method: 'get',
    params: query
  })
}

/** 根据岗位ID获取岗位详细信息 */
export function getPost(postId) {
  return request({
    url: '/system/post/' + postId,
    method: 'get'
  })
}

/** 新增岗位 */
export function addPost(data) {
  return request({
    url: '/system/post',
    method: 'post',
    data: data
  })
}

/** 修改岗位信息 */
export function updatePost(data) {
  return request({
    url: '/system/post',
    method: 'put',
    data: data
  })
}

/** 根据岗位ID删除岗位 */
export function delPost(postId) {
  return request({
    url: '/system/post',
    method: 'delete',
    params: { postId }
  })
}
