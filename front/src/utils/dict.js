/**
 * @description 字典工具 - 前端字典数据获取与解析
 * @description 从后端获取指定类型的字典数据，支持缓存避免重复请求，
 * 将字典数组解析为{label, value, el_tag_type}格式供DictTag组件使用
 */
import useDictStore from '@/store/modules/dict'
import { getDicts } from '@/api/system/dict/data'

/**
 * 获取字典数据
 */
export function useDict(...args) {
  const res = ref({})
  return (() => {
    args.forEach((dictType, index) => {
      res.value[dictType] = []
      const dicts = useDictStore().getDict(dictType)
      if (dicts) {
        res.value[dictType] = dicts
      } else {
        getDicts(dictType).then(resp => {
          res.value[dictType] = resp.data.map(p => ({ label: p.dictLabel, value: p.dictValue, elTagType: p.listClass, elTagClass: p.cssClass }))
          useDictStore().setDict(dictType, res.value[dictType])
        })
      }
    })
    return toRefs(res.value)
  })()
}

/** 将字典数组解析为{label, value, el_tag_type}格式，用于回显字典标签和类型 */
export function selectDictLabels(datas, value) {
  if (value === undefined || value === null || value === '') return ''
  const actions = []
  const values = Array.isArray(value) ? value : [String(value)]
  datas.forEach(item => {
    if (values.includes(String(item.value))) {
      actions.push(item.label)
    }
  })
  return actions.join(',')
}