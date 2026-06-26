<template>
  <view class="warehouse-selector" v-if="warehouseList.length > 1">
    <text class="warehouse-label">当前仓库：</text>
    <picker :range="warehouseNames" @change="handleChange" :value="selectedIndex">
      <view class="warehouse-picker">
        <text class="warehouse-name">{{ currentWarehouseName }}</text>
        <uni-icons type="arrowdown" size="14" color="#3D6DF7" />
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
  display: flex;
  align-items: center;
  margin-top: 20rpx;
  padding: 0 4rpx;
  background: transparent;
}
.warehouse-label {
  font-size: 28rpx;
  color: #4E5969;
  margin-right: 16rpx;
  white-space: nowrap;
  font-weight: 500;
}
.warehouse-picker {
  display: flex;
  align-items: center;
  gap: 8rpx;
  font-size: 28rpx;
  color: #1D2129;
  padding: 12rpx 20rpx;
  background: #fff;
  border: 2rpx solid #E5E6EB;
  border-radius: 12rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.04);
}
.warehouse-name {
  font-size: 28rpx;
  color: #1D2129;
  font-weight: 500;
}
</style>
