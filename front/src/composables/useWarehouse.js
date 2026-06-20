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
      if (saved && warehouseList.value.some(w => w.warehouseId == saved)) {
        currentWarehouseId.value = parseInt(saved)
      } else if (warehouseList.value.length > 0) {
        currentWarehouseId.value = warehouseList.value[0].warehouseId
        localStorage.setItem('currentWarehouseId', String(currentWarehouseId.value))
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
