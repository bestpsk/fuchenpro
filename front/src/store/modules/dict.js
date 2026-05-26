/**
 * @description 字典状态管理 - 数据字典缓存
 * @description 缓存后端字典数据到前端，避免重复请求。提供按key获取/设置/删除/清空字典的操作
 */
const useDictStore = defineStore(
  'dict',
  {
    state: () => ({
      /** 字典缓存数组，每项包含key和value */
      dict: new Array()
    }),
    actions: {
      /** 根据字典类型key获取缓存的字典数据 */
      getDict(_key) {
        if (_key == null && _key == "") {
          return null
        }
        try {
          for (let i = 0; i < this.dict.length; i++) {
            if (this.dict[i].key == _key) {
              return this.dict[i].value
            }
          }
        } catch (e) {
          return null
        }
      },
      /** 缓存字典数据，按key-value对存入数组 */
      setDict(_key, value) {
        if (_key !== null && _key !== "") {
          this.dict.push({
            key: _key,
            value: value
          })
        }
      },
      /** 根据key删除指定字典缓存 */
      removeDict(_key) {
        var bln = false
        try {
          for (let i = 0; i < this.dict.length; i++) {
            if (this.dict[i].key == _key) {
              this.dict.splice(i, 1)
              return true
            }
          }
        } catch (e) {
          bln = false
        }
        return bln
      },
      /** 清空所有字典缓存 */
      cleanDict() {
        this.dict = new Array()
      },
      /** 初始化字典（预留） */
      initDict() {
      }
    }
  })

export default useDictStore
