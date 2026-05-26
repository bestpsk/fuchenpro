/**
 * @description 部门管理接口 - 部门增删改查与树形结构
 * @description 提供部门列表查询、详情获取、新增、修改、排序、删除、下拉树结构等接口
 */
import request from '@/utils/request'

/** 查询部门列表 */
export function listDept(query) {
  return request({
    url: '/system/dept/list',
    method: 'get',
    params: query
  })
}

/** 查询部门列表（排除指定节点及其子节点，编辑时防止将部门设为自身的子部门） */
export function listDeptExcludeChild(deptId) {
  return request({
    url: '/system/dept/list/exclude/' + deptId,
    method: 'get'
  })
}

/** 根据部门ID查询部门详情 */
export function getDept(deptId) {
  return request({
    url: '/system/dept/' + deptId,
    method: 'get'
  })
}

/** 新增部门 */
export function addDept(data) {
  return request({
    url: '/system/dept',
    method: 'post',
    data: data
  })
}

/** 修改部门 */
export function updateDept(data) {
  return request({
    url: '/system/dept',
    method: 'put',
    data: data
  })
}

/** 保存部门排序 */
export function updateDeptSort(data) {
  return request({
    url: '/system/dept/updateSort',
    method: 'put',
    data: data
  })
}

/** 删除部门 */
export function delDept(deptId) {
  return request({
    url: '/system/dept',
    method: 'delete',
    params: { deptId }
  })
}

/** 查询部门下拉树结构，用于表单中的上级部门选择 */
export function treeselect() {
  return request({
    url: '/system/dept/treeselect',
    method: 'get'
  })
}
