<template>
  <view class="warehouse-selector" v-if="warehouseList.length > 1">
    <text class="warehouse-label">当前仓库：</text>
    <picker :range="warehouseNames" @change="handleChange" :value="selectedIndex">
      <view class="warehouse-picker">
        {{ currentWarehouseName }}
        <uni-icons type="arrowdown" size="14" />
      </view>
    </picker>
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useWarehouse } from '@/composables/useWarehouse'

const emit = defineEmits(['change'])

const { currentWarehouseId, warehouseList, loadWarehouses, setCurrentWarehouse } = useWarehouse()

const warehouseNames = computed(() => warehouseList.value.map(w => w.warehouseName))

const selectedIndex = computed(() => {
  const idx = warehouseList.value.findIndex(w => w.warehouseId === currentWarehouseId.value)
  return idx >= 0 ? idx : 0
})

const currentWarehouseName = computed(() => {
  const w = warehouseList.value.find(w => w.warehouseId === currentWarehouseId.value)
  return w ? w.warehouseName : '请选择'
})

function handleChange(e) {
  const idx = e.detail.value
  const warehouse = warehouseList.value[idx]
  if (warehouse) {
    setCurrentWarehouse(warehouse.warehouseId)
    emit('change', warehouse.warehouseId)
  }
}

onMounted(() => {
  loadWarehouses()
})
</script>

<style scoped>
.warehouse-selector {
  display: inline-flex;
  align-items: center;
  padding: 0;
  background: transparent;
}
.warehouse-label {
  font-size: 28rpx;
  color: #606266;
  margin-right: 16rpx;
  white-space: nowrap;
}
.warehouse-picker {
  display: flex;
  align-items: center;
  font-size: 28rpx;
  color: #303133;
  padding: 8rpx 16rpx;
  border: 1rpx solid #dcdfe6;
  border-radius: 8rpx;
}
</style>
