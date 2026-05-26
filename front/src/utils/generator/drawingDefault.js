/**
 * @description 绘图默认值 - 表单设计器默认组件配置
 * @description 提供表单设计器画布的默认组件（手机号输入框），
 * 包含手机号正则校验规则，用于初始化和重置画布
 */

/** 默认画布组件列表 */
export const drawingDefaultValue = []

/** 初始化画布默认值，添加手机号输入框组件 */
export function initDrawingDefaultValue() {
  if (drawingDefaultValue.length === 0) {
    drawingDefaultValue.push({
      layout: 'colFormItem',
      tagIcon: 'input',
      label: '手机号',
      vModel: 'mobile',
      formId: 6,
      tag: 'el-input',
      placeholder: '请输入手机号',
      defaultValue: '',
      span: 24,
      style: {width: '100%'},
      clearable: true,
      prepend: '',
      append: '',
      'prefix-icon': 'Cellphone',
      'suffix-icon': '',
      maxlength: 11,
      'show-word-limit': true,
      readonly: false,
      disabled: false,
      required: true,
      changeTag: true,
      regList: [{
        pattern: '/^1(3|4|5|7|8|9)\\d{9}$/',
        message: '手机号格式错误'
      }]
    })
  }
}

/** 清空画布默认组件列表 */
export function cleanDrawingDefaultValue() {
  drawingDefaultValue.splice(0, drawingDefaultValue.length)
}
