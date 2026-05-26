/**
 * @description 缓存操作插件 - SessionStorage与LocalStorage封装
 * @description 提供会话级缓存（sessionStorage）和本地缓存（localStorage）的统一操作接口，
 * 支持字符串存取和JSON对象存取，以及按key删除
 */
const sessionCache = {
  /** 存储字符串值到会话缓存 */
  set (key, value) {
    if (!sessionStorage) {
      return
    }
    if (key != null && value != null) {
      sessionStorage.setItem(key, value)
    }
  },
  /** 从会话缓存获取字符串值 */
  get (key) {
    if (!sessionStorage) {
      return null
    }
    if (key == null) {
      return null
    }
    return sessionStorage.getItem(key)
  },
  /** 存储JSON对象到会话缓存（自动序列化） */
  setJSON (key, jsonValue) {
    if (jsonValue != null) {
      this.set(key, JSON.stringify(jsonValue))
    }
  },
  /** 从会话缓存获取JSON对象（自动反序列化） */
  getJSON (key) {
    const value = this.get(key)
    if (value != null) {
      return JSON.parse(value)
    }
    return null
  },
  /** 删除会话缓存中指定key */
  remove (key) {
    sessionStorage.removeItem(key)
  }
}
const localCache = {
  /** 存储字符串值到本地缓存 */
  set (key, value) {
    if (!localStorage) {
      return
    }
    if (key != null && value != null) {
      localStorage.setItem(key, value)
    }
  },
  /** 从本地缓存获取字符串值 */
  get (key) {
    if (!localStorage) {
      return null
    }
    if (key == null) {
      return null
    }
    return localStorage.getItem(key)
  },
  /** 存储JSON对象到本地缓存（自动序列化） */
  setJSON (key, jsonValue) {
    if (jsonValue != null) {
      this.set(key, JSON.stringify(jsonValue))
    }
  },
  /** 从本地缓存获取JSON对象（自动反序列化） */
  getJSON (key) {
    const value = this.get(key)
    if (value != null) {
      return JSON.parse(value)
    }
    return null
  },
  /** 删除本地缓存中指定key */
  remove (key) {
    localStorage.removeItem(key)
  }
}

export default {
  /** 会话级缓存（浏览器关闭后清除） */
  session: sessionCache,
  /** 本地缓存（持久化存储） */
  local: localCache
}
