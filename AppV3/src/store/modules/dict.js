import { defineStore } from 'pinia'
import { getDicts } from '@/api/system/dictData'

const DEFAULT_SOURCE_TYPE_MAP = {
  '0': { label: '开单', type: 'primary' },
  '1': { label: '操作', type: 'success' },
  '2': { label: '还款', type: 'warning' },
  '3': { label: '手动', type: 'info' }
}

export const useDictStore = defineStore('dict', {
  state: () => ({
    dicts: {}
  }),

  actions: {
    async loadDict(dictType) {
      if (this.dicts[dictType]) return
      try {
        const res = await getDicts(dictType)
        if (res.code === 200 && res.data) {
          const map = {}
          for (const item of res.data) {
            map[item.dictValue] = {
              label: item.dictLabel,
              type: item.cssClass || item.listClass || 'info'
            }
          }
          this.dicts[dictType] = map
        }
      } catch (e) {
        console.warn('加载字典失败: ' + dictType, e)
      }
    },

    getDictLabel(dictType, value) {
      const dict = this.dicts[dictType]
      if (dict && dict[value]) return dict[value].label
      const fallback = DEFAULT_SOURCE_TYPE_MAP[dictType]?.[value] || DEFAULT_SOURCE_TYPE_MAP['biz_source_type']?.[value]
      return fallback?.label || value || ''
    },

    getDictTagType(dictType, value) {
      const dict = this.dicts[dictType]
      if (dict && dict[value]) return dict[value].type
      const fallback = DEFAULT_SOURCE_TYPE_MAP[dictType]?.[value] || DEFAULT_SOURCE_TYPE_MAP['biz_source_type']?.[value]
      return fallback?.type || 'info'
    }
  }
})
