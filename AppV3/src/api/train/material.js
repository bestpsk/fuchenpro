/**
 * @description 培训学习API - 材料列表、学习会话、心跳上报
 */
import request from '@/utils/request'

/**
 * App端：获取材料详情（员工学习入口，无需管理权限）
 */
export function getMaterialInfo(materialId) {
  return request({ url: '/train/studyLog/materialInfo/' + materialId, method: 'get' })
}

/**
 * 分页查询可学习材料列表
 * @param {object} params - { pageNum, pageSize, keyword, category }
 */
export function listMaterial(params) {
  return request({ url: '/train/material/list', method: 'get', params })
}

/**
 * 获取材料详情
 */
export function getMaterial(materialId) {
  return request({ url: '/train/material/' + materialId, method: 'get' })
}

/**
 * 开始学习，返回会话ID和材料信息
 */
export function startStudy(materialId) {
  return request({ url: '/train/studyLog/start', method: 'post', data: { materialId } })
}

/**
 * 心跳上报（每15秒一次），累计切屏/暂停次数
 */
export function heartbeat(sessionId, data) {
  return request({ url: '/train/studyLog/heartbeat', method: 'post', data: { sessionId, ...data } })
}

/**
 * 结束学习，后端校验有效时长
 */
export function endStudy(sessionId, validDuration) {
  return request({ url: '/train/studyLog/end', method: 'post', data: { sessionId, validDuration } })
}

/**
 * 查询当前用户学习记录
 */
export function listMyStudyLog(params) {
  return request({ url: '/train/studyLog/myList', method: 'get', params })
}

/**
 * 新增学习材料
 */
export function addMaterial(data) {
  return request({ url: '/train/material', method: 'post', data })
}

/**
 * 修改学习材料
 */
export function updateMaterial(data) {
  return request({ url: '/train/material', method: 'put', data })
}

/**
 * 删除学习材料
 */
export function delMaterial(materialIds) {
  return request({ url: '/train/material', method: 'delete', params: { materialIds } })
}

/**
 * 查询学习统计列表
 */
export function listStudyStats(params) {
  return request({ url: '/train/stats/list', method: 'get', params })
}

/**
 * 查询学习统计汇总
 */
export function getStudyStatsSummary(params) {
  return request({ url: '/train/stats/summary', method: 'get', params })
}
