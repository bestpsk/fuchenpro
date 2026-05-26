/**
 * @description 菜单管理接口 - 菜单增删改查与树形结构
 * @description 提供菜单列表查询、详情获取、新增、修改、排序、删除、下拉树结构等接口
 */
import request from '@/utils/request'

/** 查询菜单列表 */
export function listMenu(query) {
  return request({
    url: '/system/menu/list',
    method: 'get',
    params: query
  })
}

/** 根据菜单ID查询菜单详情 */
export function getMenu(menuId) {
  return request({
    url: '/system/menu/' + menuId,
    method: 'get'
  })
}

/** 查询菜单下拉树结构，用于表单中的上级菜单选择 */
export function treeselect() {
  return request({
    url: '/system/menu/treeselect',
    method: 'get'
  })
}

/** 根据角色ID查询菜单下拉树结构（权限分配时回显已选菜单） */
export function roleMenuTreeselect(roleId) {
  return request({
    url: '/system/menu/roleMenuTreeselect/' + roleId,
    method: 'get'
  })
}

/** 新增菜单 */
export function addMenu(data) {
  return request({
    url: '/system/menu',
    method: 'post',
    data: data
  })
}

/** 修改菜单 */
export function updateMenu(data) {
  return request({
    url: '/system/menu',
    method: 'put',
    data: data
  })
}

/** 保存菜单排序 */
export function updateMenuSort(data) {
  return request({
    url: '/system/menu/updateSort',
    method: 'put',
    data: data
  })
}

/** 删除菜单 */
export function delMenu(menuId) {
  return request({
    url: '/system/menu',
    method: 'delete',
    params: { menuId }
  })
}
