<template>
  <div class="app-container">
    <el-tabs v-model="activeTab" type="border-card" @tab-change="handleTabChange">
      <el-tab-pane label="休息日配置" name="restDay" lazy>
        <RestDay v-if="activeTab === 'restDay'" />
      </el-tab-pane>
      <el-tab-pane label="休假类型" name="type" lazy>
        <LeaveType v-if="activeTab === 'type'" />
      </el-tab-pane>
      <el-tab-pane label="假期日历" name="holiday" lazy>
        <Holiday v-if="activeTab === 'holiday'" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup name="LeaveMain">
import LeaveType from './type.vue'
import RestDay from './restDay.vue'
import Holiday from './holiday.vue'

const activeTab = ref('restDay')

function handleTabChange(tabName) {
  activeTab.value = tabName
}
</script>
