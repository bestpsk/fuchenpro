/**
 * @description CSS生成器 - 表单设计器样式代码生成
 * @description 根据表单组件配置生成所需的CSS样式代码，
 * 目前仅处理评分组件和上传组件的特殊样式
 */
const styles = {
  'el-rate': '.el-rate{display: inline-block; vertical-align: text-top;}',
  'el-upload': '.el-upload__tip{line-height: 1.2;}'
}

/** 递归收集组件及其子组件所需的CSS样式 */
function addCss(cssList, el) {
  const css = styles[el.tag]
  css && cssList.indexOf(css) === -1 && cssList.push(css)
  if (el.children) {
    el.children.forEach(el2 => addCss(cssList, el2))
  }
}

/** 根据表单配置生成完整的CSS样式字符串 */
export function makeUpCss(conf) {
  const cssList = []
  conf.fields.forEach(el => addCss(cssList, el))
  return cssList.join('\n')
}
