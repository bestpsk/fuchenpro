<template>
   <div class="app-container">
      <el-row :gutter="20">
         <el-col :span="8">
            <div class="head-container">
               <el-input v-model="menuName" placeholder="请输入菜单名称" clearable prefix-icon="Search" style="margin-bottom: 20px" />
            </div>
            <el-tree ref="menuTreeRef" :data="menuOptions" :props="{ label: 'menuName', children: 'children' }" :expand-on-click-node="false" :filter-node-method="filterNode" node-key="menuId" highlight-current @node-click="handleNodeClick">
               <template #default="{ node, data }">
                  <span style="display: flex; align-items: center; gap: 4px; font-size: 14px">
                     <span>{{ node.label }}</span>
                     <el-tag v-if="data.clientType === 'app'" type="warning" size="small" style="transform: scale(0.8)">App</el-tag>
                  </span>
               </template>
            </el-tree>
         </el-col>
         <el-col :span="16">
            <div v-if="selectedMenu">
               <el-card shadow="never">
                  <template #header>
                     <div style="display: flex; justify-content: space-between; align-items: center;">
                        <span>{{ selectedMenu.menuName }} - App配置</span>
                        <el-tag v-if="appMenuForm.appMenuId" type="success" size="small">已配置</el-tag>
                        <el-tag v-else type="info" size="small">未配置</el-tag>
                     </div>
                  </template>
                  <el-form ref="appMenuRef" :model="appMenuForm" :rules="appMenuRules" label-width="100px">
                     <el-form-item label="菜单名称">
                        <span>{{ selectedMenu.menuName }}</span>
                     </el-form-item>
                     <el-form-item label="App路径" prop="appPath">
                        <el-input v-model="appMenuForm.appPath" placeholder="如 /pages/wms/supplier/index" />
                     </el-form-item>
                     <el-form-item label="App图标" prop="appIcon">
                        <el-input v-model="appMenuForm.appIcon" placeholder="uView图标名，如 clock、list" />
                     </el-form-item>
                     <el-form-item label="图标背景色" prop="bgColor">
                        <el-color-picker v-model="appMenuForm.bgColor" />
                     </el-form-item>
                     <el-form-item label="图标颜色" prop="iconColor">
                        <el-color-picker v-model="appMenuForm.iconColor" />
                     </el-form-item>
                     <el-form-item label="排序" prop="sortOrder">
                        <el-input-number v-model="appMenuForm.sortOrder" :min="0" :max="999" />
                     </el-form-item>
                     <el-form-item label="是否显示" prop="visible">
                        <el-switch v-model="appMenuForm.visible" :active-value="1" :inactive-value="0" />
                     </el-form-item>
                     <el-form-item>
                        <el-button type="primary" @click="submitForm">{{ appMenuForm.appMenuId ? '修改' : '新增' }}</el-button>
                        <el-button v-if="appMenuForm.appMenuId" type="danger" @click="handleDelete">删除配置</el-button>
                        <el-button @click="resetForm">重置</el-button>
                     </el-form-item>
                  </el-form>
               </el-card>
            </div>
            <el-empty v-else description="请在左侧选择一个菜单" />
         </el-col>
      </el-row>
   </div>
</template>

<script setup name="AppMenu">
import { ref, watch, getCurrentInstance } from 'vue'
import { listMenu } from '@/api/system/menu'
import { getAppMenu, addAppMenu, updateAppMenu, delAppMenu } from '@/api/system/appMenu'

const { proxy } = getCurrentInstance()

const menuName = ref('')
const menuOptions = ref([])
const selectedMenu = ref(null)
const menuTreeRef = ref(null)

const appMenuForm = ref({
   appMenuId: null,
   menuId: null,
   appPath: '',
   appIcon: '',
   bgColor: '#3D6DF7',
   iconColor: '#fff',
   sortOrder: 0,
   visible: 1
})

const appMenuRules = {
   appPath: [{ required: true, message: '请输入App页面路径', trigger: 'blur' }]
}

watch(menuName, (val) => {
   menuTreeRef.value?.filter(val)
})

function filterNode(value, data) {
   if (!value) return true
   return data.menuName.indexOf(value) !== -1
}

function getMenuTree() {
   listMenu({ menuType: '' }).then(response => {
      const menus = response.data || []
      const filtered = menus.filter(m => m.menuType === 'M' || m.menuType === 'C')
      menuOptions.value = buildTree(filtered, 0)
   })
}

function buildTree(items, parentId) {
   return items.filter(item => item.parentId === parentId).map(item => ({
      menuId: item.menuId,
      menuName: item.menuName,
      menuType: item.menuType,
      path: item.path,
      icon: item.icon,
      clientType: item.clientType || 'all',
      children: buildTree(items, item.menuId)
   })).filter(item => item.menuType === 'M' || item.menuType === 'C' || (item.children && item.children.length > 0))
}

async function handleNodeClick(data) {
   if (data.menuType === 'F') return
   selectedMenu.value = data
   try {
      const res = await getAppMenu(data.menuId)
      const appMenu = res.data
      if (appMenu) {
         appMenuForm.value = {
            appMenuId: appMenu.appMenuId,
            menuId: data.menuId,
            appPath: appMenu.appPath || '',
            appIcon: appMenu.appIcon || '',
            bgColor: appMenu.bgColor || '#3D6DF7',
            iconColor: appMenu.iconColor || '#fff',
            sortOrder: appMenu.sortOrder || 0,
            visible: appMenu.visible !== undefined ? appMenu.visible : 1
         }
      } else {
         appMenuForm.value = {
            appMenuId: null,
            menuId: data.menuId,
            appPath: '',
            appIcon: '',
            bgColor: '#3D6DF7',
            iconColor: '#fff',
            sortOrder: 0,
            visible: 1
         }
      }
   } catch (e) {
      appMenuForm.value = { appMenuId: null, menuId: data.menuId, appPath: '', appIcon: '', bgColor: '#3D6DF7', iconColor: '#fff', sortOrder: 0, visible: 1 }
   }
}

function submitForm() {
   proxy.$refs['appMenuRef'].validate(valid => {
      if (valid) {
         const data = { ...appMenuForm.value }
         if (data.appMenuId) {
            updateAppMenu(data).then(() => {
               proxy.$modal.msgSuccess('修改成功')
            })
         } else {
            addAppMenu(data).then(() => {
               proxy.$modal.msgSuccess('新增成功')
               handleNodeClick(selectedMenu.value)
            })
         }
      }
   })
}

function handleDelete() {
   proxy.$modal.confirm('是否确认删除该App菜单配置？').then(() => {
      return delAppMenu(appMenuForm.value.appMenuId)
   }).then(() => {
      proxy.$modal.msgSuccess('删除成功')
      handleNodeClick(selectedMenu.value)
   }).catch(() => {})
}

function resetForm() {
   if (selectedMenu.value) handleNodeClick(selectedMenu.value)
}

getMenuTree()
</script>
