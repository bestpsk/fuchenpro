import request from '@/utils/request'

export function getDeptTree() {
  return request({ url: '/system/dept/treeselect', method: 'get' })
}
