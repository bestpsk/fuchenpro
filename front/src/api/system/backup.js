import request from '@/utils/request'

// 查询备份记录列表
export function listBackup(query) {
  return request({ url: '/system/backup/list', method: 'get', params: query })
}

// 手动执行备份
export function executeBackup() {
  return request({ url: '/system/backup/execute', method: 'post' })
}

// 删除备份记录
export function delBackup(backupIds) {
  return request({ url: '/system/backup', method: 'delete', params: { backupIds } })
}

// 预览备份文件
export function previewBackup(backupId) {
  return request({ url: '/system/backup/preview/' + backupId, method: 'get' })
}

// 获取备份配置
export function getBackupConfig() {
  return request({ url: '/system/backup/config', method: 'get' })
}

// 更新备份配置
export function updateBackupConfig(data) {
  return request({ url: '/system/backup/config', method: 'put', data })
}
