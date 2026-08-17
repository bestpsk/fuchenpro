/**
 * @description 满意度回访H5接口 - 企业负责人通过H5链接填写回访问卷
 * @description 公共接口免登录，使用token凭证（由员工在PC端生成H5链接时产生，默认7天过期）
 */
import request from '@/utils/request'

/**
 * 根据token获取H5回访问卷数据
 * 包含模板题目、企业名称、模板说明、企业负责人信息（无需登录）
 * @param {string} token - H5链接token
 * @returns {Promise<object>} 问卷数据 { visitId, enterpriseName, templateName, description, items, contactName, contactPhone }
 */
export function getPublicVisitForm(token) {
  return request({
    url: '/business/visit/public/form/' + token,
    method: 'get',
    headers: { isToken: false }
  })
}

/**
 * 提交H5回访问卷答案（无需登录）
 * @param {object} data - 提交数据
 * @param {string} data.token - H5链接token
 * @param {Array} data.answers - 答案列表 [{ item_id, answer_value, answer_text }]
 * @param {string} [data.contactName] - 企业负责人姓名
 * @param {string} [data.contactPhone] - 企业负责人手机
 * @returns {Promise<object>} 提交结果 { visitId }
 */
export function submitPublicVisitForm(data) {
  return request({
    url: '/business/visit/public/submit',
    method: 'post',
    data,
    headers: { isToken: false }
  })
}
