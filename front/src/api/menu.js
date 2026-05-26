/**
 * @description 菜单路由接口 - 获取动态路由
 * @description 获取当前用户权限范围内的菜单路由数据，用于动态生成侧边栏菜单
 */
import request from '@/utils/request'

/** 获取当前用户的路由菜单数据 */
export const getRouters = () => {
  return request({
    url: '/getRouters',
    method: 'get'
  })
}