/**
 * @description 目标管理接口 - 目标CRUD、进度看板、排名、拆解、调整
 * @description 独立顶级模块，权限标识 goal:*，数据范围以角色 data_scope 为依据
 */
import request from '@/utils/request'

/** 查询目标列表 */
export function listGoal(query) {
  return request({ url: '/goal/list', method: 'get', params: query })
}

/** 根据ID查询目标详情 */
export function getGoal(goalId) {
  return request({ url: '/goal/' + goalId, method: 'get' })
}

/** 新增目标 */
export function addGoal(data) {
  return request({ url: '/goal', method: 'post', data })
}

/** 修改目标 */
export function updateGoal(data) {
  return request({ url: '/goal', method: 'put', data })
}

/** 删除目标 */
export function delGoal(goalIds) {
  return request({ url: '/goal', method: 'delete', params: { goalIds } })
}

/** 获取目标进度（单个 goalId 或批量看板） */
export function getGoalProgress(query) {
  return request({ url: '/goal/progress', method: 'get', params: query })
}

/** 目标排名（按完成率排序） */
export function getGoalRanking(query) {
  return request({ url: '/goal/ranking', method: 'get', params: query })
}

/** 个人日视图（AppV3 用） */
export function getDailyView() {
  return request({ url: '/goal/dailyView', method: 'get' })
}

/** 目标调整（留痕） */
export function adjustGoal(data) {
  return request({ url: '/goal/adjust', method: 'post', data })
}

/** 目标拆解 */
export function splitGoal(data) {
  return request({ url: '/goal/split', method: 'post', data })
}

/** 查询父目标已拆解的子目标列表（拆解弹窗回显用） */
export function getSplitChildren(parentGoalId) {
  return request({ url: '/goal/splitChildren', method: 'get', params: { parentGoalId } })
}

/** 手动生成日目标 */
export function generateDaily(goalId) {
  return request({ url: '/goal/generateDaily', method: 'post', data: { goalId } })
}

/** 获取我的目标列表（含进度，PC端） */
export function getMyGoals(query) {
  return request({ url: '/goal/myGoals', method: 'get', params: query })
}

/** 获取当前用户可见部门的团队目标进度（部门负责人"团队目标"用） */
export function getTeamGoals(query) {
  return request({ url: '/goal/teamGoals', method: 'get', params: query })
}

/** 目标调整记录列表（分页） */
export function listAdjustLog(query) {
  return request({ url: '/goal/adjustLog', method: 'get', params: query })
}

/** 日目标明细 */
export function getDailyDetail(goalId) {
  return request({ url: '/goal/dailyDetail', method: 'get', params: { goalId } })
}
