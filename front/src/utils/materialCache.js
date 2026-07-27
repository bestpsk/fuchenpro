/**
 * 培训学习材料文件缓存（IndexedDB）
 * 以 materialId + updateTime 为缓存键，材料更新后自动失效
 * 总容量上限 100MB，超出按 LRU 淘汰；单文件上限 50MB
 */

const DB_NAME = 'train_material_cache'
const DB_VERSION = 1
const STORE_NAME = 'materials'
const MAX_CACHE_SIZE = 100 * 1024 * 1024
const MAX_FILE_SIZE = 50 * 1024 * 1024

let dbPromise = null

function openDB() {
  if (dbPromise) return dbPromise
  dbPromise = new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, DB_VERSION)
    req.onupgradeneeded = (e) => {
      const db = e.target.result
      if (!db.objectStoreNames.contains(STORE_NAME)) {
        const store = db.createObjectStore(STORE_NAME, { keyPath: 'key' })
        store.createIndex('timestamp', 'timestamp', { unique: false })
      }
    }
    req.onsuccess = () => resolve(req.result)
    req.onerror = () => reject(req.error)
  })
  return dbPromise
}

/**
 * 读取缓存
 * @param {string} key - 缓存键 train_${materialId}_${updateTime}
 * @returns {Promise<{arrayBuffer: ArrayBuffer, size: number, timestamp: number}|null>}
 */
export async function getCachedFile(key) {
  try {
    const db = await openDB()
    return new Promise((resolve) => {
      const tx = db.transaction(STORE_NAME, 'readonly')
      const store = tx.objectStore(STORE_NAME)
      const req = store.get(key)
      req.onsuccess = () => resolve(req.result || null)
      req.onerror = () => resolve(null)
    })
  } catch (e) {
    console.warn('[materialCache] getCachedFile error:', e)
    return null
  }
}

function getTotalSize(db) {
  return new Promise((resolve) => {
    const tx = db.transaction(STORE_NAME, 'readonly')
    const store = tx.objectStore(STORE_NAME)
    const req = store.getAll()
    req.onsuccess = () => {
      const total = (req.result || []).reduce((sum, r) => sum + (r.size || 0), 0)
      resolve(total)
    }
    req.onerror = () => resolve(0)
  })
}

function evictIfNeeded(db, incomingSize) {
  return getTotalSize(db).then((total) => {
    if (total + incomingSize <= MAX_CACHE_SIZE) return
    return new Promise((resolve) => {
      const tx = db.transaction(STORE_NAME, 'readwrite')
      const store = tx.objectStore(STORE_NAME)
      const idx = store.index('timestamp')
      const req = idx.openCursor()
      let freed = 0
      const need = total + incomingSize - MAX_CACHE_SIZE
      req.onsuccess = (e) => {
        const cursor = e.target.result
        if (cursor && freed < need) {
          freed += (cursor.value.size || 0)
          cursor.delete()
          cursor.continue()
        }
      }
      tx.oncomplete = () => resolve()
      tx.onerror = () => resolve()
    })
  })
}

/**
 * 写入缓存
 * @param {string} key - 缓存键
 * @param {string} materialId - 材料ID
 * @param {ArrayBuffer} arrayBuffer - 文件二进制数据
 */
export async function setCachedFile(key, materialId, arrayBuffer) {
  try {
    const size = arrayBuffer.byteLength
    if (size > MAX_FILE_SIZE) return
    const db = await openDB()
    await evictIfNeeded(db, size)
    return new Promise((resolve) => {
      const tx = db.transaction(STORE_NAME, 'readwrite')
      const store = tx.objectStore(STORE_NAME)
      store.put({ key, materialId, arrayBuffer, size, timestamp: Date.now() })
      tx.oncomplete = () => resolve()
      tx.onerror = () => resolve()
    })
  } catch (e) {
    console.warn('[materialCache] setCachedFile error:', e)
  }
}

/**
 * 构造缓存键
 * @param {string|number} materialId
 * @param {string} updateTime
 * @returns {string}
 */
export function buildCacheKey(materialId, updateTime) {
  return `train_${materialId}_${updateTime || ''}`
}
