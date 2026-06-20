<template>
  <div class="warehouse-selector" v-if="warehouseList.length > 1">
    <span class="warehouse-label">当前仓库：</span>
    <el-select v-model="currentWarehouseId" @change="handleChange" size="small" style="width: 160px">
      <el-option v-for="w in warehouseList" :key="w.warehouseId" :label="w.warehouseName" :value="w.warehouseId" />
    </el-select>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useWarehouse } from '@/composables/useWarehouse'

const emit = defineEmits(['change'])

const { currentWarehouseId, warehouseList, loadWarehouses } = useWarehouse()

function handleChange(val) {
  localStorage.setItem('currentWarehouseId', String(val))
  emit('change', val)
}

onMounted(() => {
  loadWarehouses()
})
</script>

<style scoped>
.warehouse-selector {
  display: inline-flex;
  align-items: center;
  margin-bottom: 12px;
  margin-right: 16px;
}
.warehouse-label {
  font-size: 14px;
  color: #606266;
  margin-right: 8px;
  white-space: nowrap;
}
</style>
