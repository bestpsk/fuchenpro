import request from '@/utils/request'

export function getGroupedMenus() {
  return request({
    url: '/system/appMenu/grouped',
    method: 'get'
  })
}
