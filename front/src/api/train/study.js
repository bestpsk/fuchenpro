import request from '@/utils/request'

// 在线学习：分页查询可学习材料列表（仅返回 status=0 的材料）
export function listStudyMaterial(query) {
  return request({ url: '/train/material/list', method: 'get', params: { ...query, status: '0' } })
}

// 获取材料详情
export function getStudyMaterial(materialId) {
  return request({ url: '/train/material/' + materialId, method: 'get' })
}

// 开始学习，返回会话ID和材料信息（DRM 临时授权）
export function startStudy(materialId) {
  return request({ url: '/train/studyLog/start', method: 'post', data: { materialId } })
}

// 结束学习，记录有效时长
export function endStudy(sessionId, validDuration) {
  return request({ url: '/train/studyLog/end', method: 'post', data: { sessionId, validDuration } })
}
