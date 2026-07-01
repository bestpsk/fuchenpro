import { ref, computed } from 'vue'
import { getUserWarehouses } from '@/api/wms/warehouse'

const currentWarehouseId = ref(null)
const warehouseList = ref([])
const loaded = ref(false)

export function useWarehouse() {
  const loadWarehouses = async () => {
    if (loaded.value) return
    try {
      const res = await getUserWarehouses()
      warehouseList.value = res.data || []
      // 从 localStorage 恢复选择
      const saved = localStorage.getItem('currentWarehouseId')
      if (saved && saved !== 'null' && warehouseList.value.some(w => w.warehouseId == saved)) {
        currentWarehouseId.value = parseInt(saved)
      } else {
        // 默认选中"全部仓库"
        currentWarehouseId.value = null
        localStorage.setItem('currentWarehouseId', 'null')
      }
      loaded.value = true
    } catch (e) {
      console.error('加载仓库列表失败', e)
    }
  }

  const setCurrentWarehouse = (warehouseId) => {
    currentWarehouseId.value = warehouseId
    localStorage.setItem('currentWarehouseId', String(warehouseId))
  }

  const currentWarehouse = computed(() => {
    return warehouseList.value.find(w => w.warehouseId === currentWarehouseId.value) || null
  })

  return {
    currentWarehouseId,
    warehouseList,
    currentWarehouse,
    loadWarehouses,
    setCurrentWarehouse
  }
}
