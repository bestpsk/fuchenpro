<template>
  <div class="app-container app-menu-config">
    <el-row :gutter="20">
      <el-col :span="17">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>菜单配置</span>
              <el-button type="primary" icon="Plus" @click="handleAdd">新增菜单项</el-button>
            </div>
          </template>

          <el-tabs v-model="activeGroup" @tab-change="handleGroupChange">
            <el-tab-pane
              v-for="group in groupList"
              :key="group.key"
              :label="group.name"
              :name="group.key"
            />
          </el-tabs>

          <el-table :data="currentMenuList" row-key="id" v-loading="loading">
            <el-table-column label="排序" prop="sortOrder" width="80" align="center">
              <template #default="scope">
                <el-input-number v-model="scope.row.sortOrder" controls-position="right" :min="0" size="small" style="width: 70px" />
              </template>
            </el-table-column>
            <el-table-column label="图标" width="70" align="center">
              <template #default="scope">
                <div class="icon-preview" :style="{ backgroundColor: scope.row.bgColor }">
                  <span :style="{ color: scope.row.iconColor }">{{ scope.row.icon }}</span>
                </div>
              </template>
            </el-table-column>
            <el-table-column label="标题" prop="title" width="120" />
            <el-table-column label="跳转路径" prop="path" show-overflow-tooltip>
              <template #default="scope">
                <span v-if="scope.row.path">{{ scope.row.path }}</span>
                <el-tag v-else type="info" size="small">建设中</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="权限标识" prop="perms" width="160" show-overflow-tooltip>
              <template #default="scope">
                <el-tag v-if="scope.row.perms" type="success" size="small">{{ scope.row.perms }}</el-tag>
                <span v-else style="color: #909399">不控制</span>
              </template>
            </el-table-column>
            <el-table-column label="图标色" width="90" align="center">
              <template #default="scope">
                <el-color-picker v-model="scope.row.iconColor" size="small" />
              </template>
            </el-table-column>
            <el-table-column label="背景色" width="90" align="center">
              <template #default="scope">
                <el-color-picker v-model="scope.row.bgColor" size="small" />
              </template>
            </el-table-column>
            <el-table-column label="显示" width="70" align="center">
              <template #default="scope">
                <el-switch
                  v-model="scope.row.visible"
                  :active-value="1"
                  :inactive-value="0"
                  @change="handleVisibleChange(scope.row)"
                />
              </template>
            </el-table-column>
            <el-table-column label="操作" width="120" align="center">
              <template #default="scope">
                <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)">修改</el-button>
                <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>

          <div style="margin-top: 16px; text-align: right;">
            <el-button type="warning" icon="Check" @click="handleSaveSort">保存排序</el-button>
          </div>
        </el-card>
      </el-col>

      <el-col :span="7">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>手机预览</span>
              <el-radio-group v-model="previewPage" size="small">
                <el-radio-button value="home">首页</el-radio-button>
                <el-radio-button value="work">工作台</el-radio-button>
                <el-radio-button value="mine">我的</el-radio-button>
              </el-radio-group>
            </div>
          </template>

          <div class="phone-frame">
            <div class="phone-status-bar">
              <span>9:41</span>
              <span>馥辰国际</span>
              <span>100%</span>
            </div>
            <div class="phone-content">
              <template v-if="previewPage === 'home'">
                <div class="preview-quick-menu">
                  <div class="preview-section-title">快捷菜单</div>
                  <div class="preview-menu-grid">
                    <div
                      v-for="item in previewQuickMenus"
                      :key="item.id"
                      class="preview-menu-item"
                    >
                      <div class="preview-icon-circle" :style="{ backgroundColor: item.bgColor }">
                        <span :style="{ color: item.iconColor, fontSize: '14px' }">{{ getIconText(item.icon) }}</span>
                      </div>
                      <span class="preview-menu-text">{{ item.title }}</span>
                    </div>
                    <div class="preview-menu-item">
                      <div class="preview-icon-circle" style="background-color: #E8F0FE">
                        <span style="color: #3D6DF7; font-size: 14px">+</span>
                      </div>
                      <span class="preview-menu-text">更多</span>
                    </div>
                  </div>
                </div>
              </template>

              <template v-if="previewPage === 'work'">
                <div class="preview-search">
                  <div class="preview-search-box">🔍 搜索功能</div>
                </div>
                <div v-for="group in previewWorkGroups" :key="group.key" class="preview-section">
                  <div class="preview-section-title">{{ group.name }}</div>
                  <div class="preview-grid">
                    <div
                      v-for="item in group.items"
                      :key="item.id"
                      class="preview-grid-item"
                    >
                      <div class="preview-icon-circle" :style="{ backgroundColor: item.bgColor }">
                        <span :style="{ color: item.iconColor, fontSize: '14px' }">{{ getIconText(item.icon) }}</span>
                      </div>
                      <span class="preview-grid-text">{{ item.title }}</span>
                    </div>
                  </div>
                </div>
              </template>

              <template v-if="previewPage === 'mine'">
                <div class="preview-mine-header">
                  <div class="preview-avatar">U</div>
                  <span class="preview-username">用户名</span>
                </div>
                <div class="preview-section">
                  <div class="preview-section-title">快捷操作</div>
                  <div class="preview-action-row">
                    <div
                      v-for="item in previewMineActions"
                      :key="item.id"
                      class="preview-action-item"
                    >
                      <div class="preview-action-icon" :style="{ backgroundColor: item.bgColor }">
                        <span :style="{ color: item.iconColor, fontSize: '12px' }">{{ getIconText(item.icon) }}</span>
                      </div>
                      <span class="preview-action-text">{{ item.title }}</span>
                    </div>
                  </div>
                </div>
                <div class="preview-section">
                  <div class="preview-section-title">个人菜单</div>
                  <div class="preview-menu-list">
                    <div
                      v-for="item in previewMineMenus"
                      :key="item.id"
                      class="preview-menu-list-item"
                    >
                      <span>{{ item.title }}</span>
                      <span style="color: #ccc">></span>
                    </div>
                  </div>
                </div>
              </template>
            </div>

            <div class="phone-tabbar">
              <div :class="['tabbar-item', { active: previewPage === 'home' }]">
                <span>🏠</span><span>首页</span>
              </div>
              <div :class="['tabbar-item', { active: previewPage === 'work' }]">
                <span>💼</span><span>工作台</span>
              </div>
              <div :class="['tabbar-item', { active: previewPage === 'mine' }]">
                <span>👤</span><span>我的</span>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="600px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="分组" prop="groupKey">
              <el-select v-model="form.groupKey" placeholder="选择分组" style="width: 100%">
                <el-option
                  v-for="group in groupList"
                  :key="group.key"
                  :label="group.name"
                  :value="group.key"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="排序" prop="sortOrder">
              <el-input-number v-model="form.sortOrder" controls-position="right" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="菜单标题" prop="title">
              <el-input v-model="form.title" placeholder="请输入菜单标题" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="图标" prop="icon">
              <el-popover placement="bottom-start" :width="400" trigger="click">
                <template #reference>
                  <el-input v-model="form.icon" placeholder="点击选择图标" readonly />
                </template>
                <uview-icon-select ref="iconSelectRef" :active-icon="form.icon" @selected="selectedIcon" />
              </el-popover>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="跳转路径" prop="path">
              <el-input v-model="form.path" placeholder="留空表示建设中" />
            </el-form-item>
            <el-form-item label="权限标识" prop="perms">
              <el-input v-model="form.perms" placeholder="如 business:sales:list，留空不控制权限" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="图标颜色">
              <el-color-picker v-model="form.iconColor" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="背景颜色">
              <el-color-picker v-model="form.bgColor" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="是否显示">
              <el-radio-group v-model="form.visible">
                <el-radio :value="1">显示</el-radio>
                <el-radio :value="0">隐藏</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="备注">
              <el-input v-model="form.remark" type="textarea" placeholder="请输入备注" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="dialogVisible = false">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="AppMenu">
import {
  listAppMenu, addAppMenu, updateAppMenu, delAppMenu,
  updateAppMenuSort, changeAppMenuStatus
} from '@/api/system/appMenu'
import UviewIconSelect from '@/components/UviewIconSelect'

const { proxy } = getCurrentInstance()

const groupList = [
  { key: 'quick', name: '常用功能', sort: 1 },
  { key: 'business', name: '业务管理', sort: 2 },
  { key: 'system', name: '系统管理', sort: 3 },
  { key: 'mine_action', name: '快捷操作', sort: 4 },
  { key: 'mine_menu', name: '个人菜单', sort: 5 }
]

const loading = ref(false)
const allMenus = ref([])
const activeGroup = ref('quick')
const previewPage = ref('home')
const dialogVisible = ref(false)
const dialogTitle = ref('')
const iconSelectRef = ref(null)

const data = reactive({
  form: {},
  rules: {
    groupKey: [{ required: true, message: '请选择分组', trigger: 'change' }],
    title: [{ required: true, message: '请输入菜单标题', trigger: 'blur' }],
    icon: [{ required: true, message: '请选择图标', trigger: 'change' }],
    sortOrder: [{ required: true, message: '请输入排序', trigger: 'blur' }]
  }
})
const { form, rules } = toRefs(data)

const currentMenuList = computed(() => {
  return allMenus.value
    .filter(item => item.groupKey === activeGroup.value)
    .sort((a, b) => a.sortOrder - b.sortOrder)
})

const previewQuickMenus = computed(() => {
  return allMenus.value
    .filter(item => item.groupKey === 'quick' && item.visible === 1)
    .sort((a, b) => a.sortOrder - b.sortOrder)
    .slice(0, 4)
})

const previewWorkGroups = computed(() => {
  const groups = ['quick', 'business', 'system']
  return groups.map(key => {
    const groupInfo = groupList.find(g => g.key === key)
    return {
      key,
      name: groupInfo ? groupInfo.name : key,
      items: allMenus.value
        .filter(item => item.groupKey === key && item.visible === 1)
        .sort((a, b) => a.sortOrder - b.sortOrder)
    }
  }).filter(g => g.items.length > 0)
})

const previewMineActions = computed(() => {
  return allMenus.value
    .filter(item => item.groupKey === 'mine_action' && item.visible === 1)
    .sort((a, b) => a.sortOrder - b.sortOrder)
})

const previewMineMenus = computed(() => {
  return allMenus.value
    .filter(item => item.groupKey === 'mine_menu' && item.visible === 1)
    .sort((a, b) => a.sortOrder - b.sortOrder)
})

function getIconText(icon) {
  if (!icon) return '?'
  const nameMap = {
    'clock': '⏰', 'file-text': '📄', 'calendar': '📅', 'list': '📋',
    'account-fill': '👤', 'lock-fill': '🔒', 'setting': '⚙️', 'home-fill': '🏠',
    'shop': '🏪', 'edit-pen': '✏️', 'grid': '▦', 'account': '👤',
    'man-add': '➕', 'home': '🏠', 'bookmark': '🔖', 'chat': '💬',
    'info-circle': 'ℹ️', 'thumb-up': '👍', 'question-circle': '❓',
    'search': '🔍', 'star': '⭐', 'heart': '❤️', 'notification': '🔔'
  }
  return nameMap[icon] || icon.substring(0, 2)
}

function getList() {
  loading.value = true
  listAppMenu().then(response => {
    allMenus.value = response.data.map(item => ({
      ...item,
      groupKey: item.groupKey || item.group_key,
      groupName: item.groupName || item.group_name,
      groupSort: item.groupSort || item.group_sort || 0,
      sortOrder: item.sortOrder || item.sort_order || 0,
      iconColor: item.iconColor || item.icon_color || '#3D6DF7',
      bgColor: item.bgColor || item.bg_color || '#E8F0FE'
    }))
    loading.value = false
  })
}

function handleGroupChange() {}

function handleAdd() {
  resetForm()
  form.value.groupKey = activeGroup.value
  dialogTitle.value = '新增菜单项'
  dialogVisible.value = true
}

function handleUpdate(row) {
  resetForm()
  form.value = { ...row }
  dialogTitle.value = '修改菜单项'
  dialogVisible.value = true
}

function handleDelete(row) {
  proxy.$modal.confirm('是否确认删除菜单项"' + row.title + '"?').then(() => {
    return delAppMenu(row.id)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess('删除成功')
  }).catch(() => {})
}

function handleVisibleChange(row) {
  changeAppMenuStatus(row.id, row.visible).then(() => {
    proxy.$modal.msgSuccess(row.visible === 1 ? '已显示' : '已隐藏')
  })
}

function handleSaveSort() {
  const menus = currentMenuList.value.map(item => ({
    id: item.id,
    sortOrder: item.sortOrder
  }))
  updateAppMenuSort({ menus }).then(() => {
    proxy.$modal.msgSuccess('排序保存成功')
    getList()
  })
}

function selectedIcon(name) {
  form.value.icon = name
}

function resetForm() {
  form.value = {
    id: undefined,
    groupKey: 'quick',
    groupName: '常用功能',
    groupSort: 1,
    title: '',
    icon: '',
    path: '',
    perms: '',
    iconColor: '#3D6DF7',
    bgColor: '#E8F0FE',
    sortOrder: 0,
    visible: 1,
    remark: ''
  }
  proxy.resetForm('formRef')
}

function submitForm() {
  proxy.$refs['formRef'].validate(valid => {
    if (valid) {
      const groupInfo = groupList.find(g => g.key === form.value.groupKey)
      if (groupInfo) {
        form.value.groupName = groupInfo.name
        form.value.groupSort = groupInfo.sort
      }
      if (form.value.id) {
        updateAppMenu(form.value).then(() => {
          proxy.$modal.msgSuccess('修改成功')
          dialogVisible.value = false
          getList()
        })
      } else {
        addAppMenu(form.value).then(() => {
          proxy.$modal.msgSuccess('新增成功')
          dialogVisible.value = false
          getList()
        })
      }
    }
  })
}

getList()
</script>

<style lang="scss" scoped>
.app-menu-config {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .icon-preview {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto;
    span {
      font-size: 10px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      max-width: 24px;
    }
  }

  .phone-frame {
    width: 375px;
    height: 667px;
    margin: 0 auto;
    border: 2px solid #333;
    border-radius: 36px;
    overflow: hidden;
    background: #f5f7fa;
    display: flex;
    flex-direction: column;
    position: relative;

    .phone-status-bar {
      height: 40px;
      background: #fff;
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 20px;
      font-size: 12px;
      color: #333;
      border-bottom: 1px solid #eee;
    }

    .phone-content {
      flex: 1;
      overflow-y: auto;
      padding: 12px;
    }

    .phone-tabbar {
      height: 50px;
      background: #fff;
      display: flex;
      border-top: 1px solid #eee;
      .tabbar-item {
        flex: 1;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        font-size: 10px;
        color: #999;
        gap: 2px;
        &.active {
          color: #3c96f3;
        }
      }
    }
  }

  .preview-section-title {
    font-size: 14px;
    font-weight: 600;
    color: #1D2129;
    margin-bottom: 10px;
  }

  .preview-quick-menu,
  .preview-search,
  .preview-section {
    background: #fff;
    border-radius: 12px;
    padding: 12px;
    margin-bottom: 10px;
  }

  .preview-search-box {
    background: #f5f7fa;
    border-radius: 18px;
    padding: 8px 16px;
    font-size: 12px;
    color: #86909C;
  }

  .preview-menu-grid {
    display: flex;
    justify-content: space-between;
  }

  .preview-menu-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
  }

  .preview-icon-circle {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .preview-menu-text {
    font-size: 11px;
    color: #1D2129;
    font-weight: 500;
  }

  .preview-grid {
    display: flex;
    flex-wrap: wrap;
  }

  .preview-grid-item {
    width: 25%;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 6px 0;
    gap: 6px;
  }

  .preview-grid-text {
    font-size: 11px;
    color: #1D2129;
    font-weight: 500;
    text-align: center;
  }

  .preview-mine-header {
    background: #3c96f3;
    border-radius: 12px;
    padding: 20px 16px;
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 10px;
    .preview-avatar {
      width: 48px;
      height: 48px;
      border-radius: 50%;
      background: rgba(255,255,255,0.25);
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      font-size: 20px;
      font-weight: 600;
    }
    .preview-username {
      color: #fff;
      font-size: 14px;
    }
  }

  .preview-action-row {
    display: flex;
    justify-content: space-around;
  }

  .preview-action-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
  }

  .preview-action-icon {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .preview-action-text {
    font-size: 11px;
    color: #333;
  }

  .preview-menu-list {
    .preview-menu-list-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 10px 0;
      border-bottom: 1px solid #f5f5f5;
      font-size: 13px;
      color: #333;
      &:last-child {
        border-bottom: none;
      }
    }
  }
}
</style>
