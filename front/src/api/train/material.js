import request from '@/utils/request'

// 分页查询学习材料列表
export function listMaterial(query) {
  return request({ url: '/train/material/list', method: 'get', params: query })
}

// 根据ID获取学习材料详情
export function getMaterial(materialId) {
  return request({ url: '/train/material/' + materialId, method: 'get' })
}

// 新增学习材料
export function addMaterial(data) {
  return request({ url: '/train/material', method: 'post', data: data })
}

// 修改学习材料
export function updateMaterial(data) {
  return request({ url: '/train/material', method: 'put', data: data })
}

// 删除学习材料
export function delMaterial(materialIds) {
  return request({ url: '/train/material', method: 'delete', params: { materialIds } })
}

// 导出学习材料
export function exportMaterial(data) {
  return request({ url: '/train/material/export', method: 'post', data: data })
}

// 分页查询学习记录
export function listStudyLog(query) {
  return request({ url: '/train/studyLog/list', method: 'get', params: query })
}
