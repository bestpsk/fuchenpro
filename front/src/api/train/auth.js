import request from '@/utils/request'

// 获取材料授权配置
export function getMaterialAuth(materialId) {
  return request({ url: '/train/material/auth/' + materialId, method: 'get' })
}

// 保存材料授权配置
export function saveMaterialAuth(data) {
  return request({ url: '/train/material/auth', method: 'post', data })
}
