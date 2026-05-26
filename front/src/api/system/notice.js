/**
 * @description 通知公告接口 - 公告增删改查与已读管理
 * @description 提供公告列表查询、详情获取、新增、修改、删除、首页公告、已读标记、已读用户查询等接口
 */
import request from '@/utils/request'

/** 查询公告列表 */
export function listNotice(query) {
  return request({
    url: '/system/notice/list',
    method: 'get',
    params: query
  })
}

/** 根据公告ID查询公告详情 */
export function getNotice(noticeId) {
  return request({
    url: '/system/notice/' + noticeId,
    method: 'get'
  })
}

/** 新增公告 */
export function addNotice(data) {
  return request({
    url: '/system/notice',
    method: 'post',
    data: data
  })
}

/** 修改公告 */
export function updateNotice(data) {
  return request({
    url: '/system/notice',
    method: 'put',
    data: data
  })
}

/** 删除公告 */
export function delNotice(noticeIds) {
  return request({
    url: '/system/notice',
    method: 'delete',
    params: { noticeIds }
  })
}

/** 首页顶部公告列表（带已读状态） */
export function listNoticeTop() {
  return request({
    url: '/system/notice/listTop',
    method: 'get'
  })
}

/** 标记指定公告为已读 */
export function markNoticeRead(noticeId) {
  return request({
    url: '/system/notice/markRead',
    method: 'post',
    data: { noticeId }
  })
}

/** 批量标记公告为已读 */
export function markNoticeReadAll(ids) {
  return request({
    url: '/system/notice/markReadAll',
    method: 'post',
    params: { ids }
  })
}

/** 查询公告已读用户列表 */
export function listNoticeReadUsers(query) {
  return request({
    url: '/system/notice/readUsers/list',
    method: 'get',
    params: query
  })
}
