<template>
  <view class="form-container">
    <view class="form-section">
      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="account-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.roleName" placeholder="* 角色名称" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="lock" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.roleKey" placeholder="* 权限字符" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="order" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="number" v-model="form.roleSort" placeholder="* 角色顺序" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field status-field">
        <view class="field-label-row">
          <u-icon name="level" size="18" color="#86909C"></u-icon>
          <text class="field-label-text">状态</text>
        </view>
        <view class="status-options">
          <view
            v-for="dict in statusOptions"
            :key="dict.dictValue"
            class="status-item"
            :class="{ active: form.status === dict.dictValue }"
            @click="form.status = dict.dictValue"
          >
            <view class="status-radio" :class="{ checked: form.status === dict.dictValue }"></view>
            <text>{{ dict.dictLabel }}</text>
          </view>
        </view>
      </view>

      <view class="form-field">
        <view class="field-textarea-box">
          <view class="textarea-prefix"><u-icon name="edit-pen" size="18" color="#86909C"></u-icon><text class="prefix-text">备注</text></view>
          <textarea class="field-textarea" v-model="form.remark" placeholder="请输入备注信息" placeholder-class="field-placeholder" :maxlength="500" auto-height></textarea>
        </view>
      </view>
    </view>

    <view class="form-section">
      <view class="section-title">菜单权限</view>
      <view class="menu-tree-toolbar">
        <view class="toolbar-btn" @click="toggleExpandAll">
          <u-icon :name="isExpandAll ? 'fold' : 'unfold'" size="14" color="#3D6DF7"></u-icon>
          <text>{{ isExpandAll ? '全部折叠' : '全部展开' }}</text>
        </view>
        <view class="toolbar-btn" @click="toggleCheckAll">
          <u-icon :name="isCheckAll ? 'checkbox-mark' : 'square'" size="14" color="#3D6DF7"></u-icon>
          <text>{{ isCheckAll ? '取消全选' : '全选' }}</text>
        </view>
      </view>
      <scroll-view scroll-y class="menu-tree-scroll">
        <view v-if="flatMenuList.length > 0" class="menu-tree">
          <view
            v-for="item in flatMenuList"
            :key="item.id"
            class="tree-node-content"
            :style="{ paddingLeft: (item.depth * 40 + 16) + 'rpx' }"
          >
            <view v-if="item.hasChildren" class="expand-icon" @click="toggleExpand(item.id)">
              <u-icon :name="item.expanded ? 'arrow-down' : 'arrow-right'" size="12" color="#86909C"></u-icon>
            </view>
            <view v-else class="expand-placeholder"></view>
            <view class="check-box" :class="{ checked: form.menuIds.includes(item.id) }" @click="toggleCheck(item.id)">
              <u-icon v-if="form.menuIds.includes(item.id)" name="checkmark" size="12" color="#fff"></u-icon>
            </view>
            <text class="node-label">{{ item.label }}</text>
          </view>
        </view>
        <u-empty v-else mode="data" text="暂无菜单数据" :marginTop="40"></u-empty>
      </scroll-view>
    </view>

    <view class="form-actions">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getRole, addRole, updateRole, roleMenuTreeselect, menuTreeselect } from '@/api/system/role'
import { getDicts } from '@/api/system/dictData'

const submitting = ref(false)
const mode = ref('add')
const roleId = ref(null)
const statusOptions = ref([])
const menuOptions = ref([])
const expandedIds = ref([])
const isExpandAll = ref(false)

const form = reactive({
  roleId: undefined,
  roleName: '',
  roleKey: '',
  roleSort: 0,
  status: '0',
  remark: '',
  menuIds: []
})

const isCheckAll = computed(() => {
  const allIds = collectAllIds(menuOptions.value)
  return allIds.length > 0 && allIds.every(id => form.menuIds.includes(id))
})

const flatMenuList = computed(() => {
  return flattenTree(menuOptions.value, 0)
})

function flattenTree(nodes, depth) {
  const result = []
  if (!nodes || !nodes.length) return result
  for (const node of nodes) {
    const hasChildren = node.children && node.children.length > 0
    const expanded = expandedIds.value.includes(node.id)
    result.push({
      id: node.id,
      label: node.label,
      depth,
      hasChildren,
      expanded
    })
    if (hasChildren && expanded) {
      result.push(...flattenTree(node.children, depth + 1))
    }
  }
  return result
}

function collectAllIds(nodes) {
  let ids = []
  for (const node of nodes) {
    ids.push(node.id)
    if (node.children && node.children.length) {
      ids = ids.concat(collectAllIds(node.children))
    }
  }
  return ids
}

function collectParentIds(nodes) {
  let ids = []
  for (const node of nodes) {
    if (node.children && node.children.length) {
      ids.push(node.id)
      ids = ids.concat(collectParentIds(node.children))
    }
  }
  return ids
}

async function loadDicts() {
  try {
    const res = await getDicts('sys_normal_disable')
    statusOptions.value = res.data || []
  } catch (e) {
    console.error('加载字典失败:', e)
    statusOptions.value = [
      { dictValue: '0', dictLabel: '正常' },
      { dictValue: '1', dictLabel: '停用' }
    ]
  }
}

async function loadMenuTree() {
  try {
    const res = await menuTreeselect()
    menuOptions.value = res.data || []
    expandedIds.value = collectParentIds(menuOptions.value)
    isExpandAll.value = true
  } catch (e) {
    console.error('加载菜单树失败:', e)
  }
}

async function loadDetail() {
  if (!roleId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const [roleRes, menuRes] = await Promise.all([
      getRole(roleId.value),
      roleMenuTreeselect(roleId.value)
    ])
    const data = roleRes.data || {}
    Object.assign(form, {
      roleId: data.roleId,
      roleName: data.roleName || '',
      roleKey: data.roleKey || '',
      roleSort: data.roleSort ?? 0,
      status: String(data.status ?? '0'),
      remark: data.remark || '',
      menuIds: []
    })
    const checkedKeys = menuRes.data?.checkedKeys || []
    form.menuIds = [...checkedKeys]
    menuOptions.value = menuRes.data?.menus || []
    expandedIds.value = collectParentIds(menuOptions.value)
    isExpandAll.value = true
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

function toggleExpand(menuId) {
  const idx = expandedIds.value.indexOf(menuId)
  if (idx > -1) {
    expandedIds.value.splice(idx, 1)
  } else {
    expandedIds.value.push(menuId)
  }
}

function toggleCheck(menuId) {
  const idx = form.menuIds.indexOf(menuId)
  if (idx > -1) {
    form.menuIds.splice(idx, 1)
  } else {
    form.menuIds.push(menuId)
  }
}

function toggleExpandAll() {
  isExpandAll.value = !isExpandAll.value
  if (isExpandAll.value) {
    expandedIds.value = collectParentIds(menuOptions.value)
  } else {
    expandedIds.value = []
  }
}

function toggleCheckAll() {
  if (isCheckAll.value) {
    form.menuIds = []
  } else {
    form.menuIds = collectAllIds(menuOptions.value)
  }
}

async function submitForm() {
  if (!form.roleName) { uni.showToast({ title: '请输入角色名称', icon: 'none' }); return }
  if (!form.roleKey) { uni.showToast({ title: '请输入权限字符', icon: 'none' }); return }
  if (form.roleSort === '' || form.roleSort === null || form.roleSort === undefined) {
    uni.showToast({ title: '请输入角色顺序', icon: 'none' }); return
  }

  submitting.value = true
  try {
    const formData = { ...form }
    if (formData.roleId) {
      await updateRole(formData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      delete formData.roleId
      await addRole(formData)
      uni.showToast({ title: '新增成功', icon: 'success' })
    }
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('提交失败:', e)
    const msg = e?.msg || e?.message || '操作失败，请重试'
    uni.showToast({ title: msg, icon: 'none', duration: 2000 })
  } finally {
    submitting.value = false
  }
}

function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.redirectTo({ url: '/pages/system/role/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  mode.value = options.mode || 'add'
  roleId.value = options.id ? parseInt(options.id) : null

  loadDicts()

  if (mode.value === 'add') {
    uni.setNavigationBarTitle({ title: '新增角色' })
    loadMenuTree()
  } else if (mode.value === 'edit') {
    uni.setNavigationBarTitle({ title: '编辑角色' })
    loadDetail()
  }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.form-container { min-height: 100vh; padding-bottom: 140rpx; }

.form-section {
  margin: 24rpx; background: #fff; border-radius: 20rpx; padding: 32rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05);
}
.section-title {
  font-size: 30rpx; font-weight: 600; color: #1D2129; margin-bottom: 24rpx;
  padding-bottom: 16rpx; border-bottom: 1rpx solid #F2F3F5;
}
.form-field { margin-bottom: 20rpx; &:last-child { margin-bottom: 0; } }
.field-input-box {
  display: flex; align-items: center; background: #F7F8FA; border-radius: 12rpx;
  padding: 0 20rpx; height: 88rpx; gap: 16rpx; border: 2rpx solid transparent; transition: all 0.2s;
  &:active { background: #EFF0F1; }
}
.field-input { flex: 1; font-size: 30rpx; color: #1D2129; height: 88rpx; line-height: 88rpx; }
.field-placeholder { color: #C9CDD4; font-size: 30rpx; }
.field-textarea-box {
  display: flex; flex-direction: column; background: #F7F8FA; border-radius: 12rpx;
  padding: 16rpx 20rpx; gap: 8rpx; border: 2rpx solid transparent;
}
.textarea-prefix { display: flex; align-items: center; gap: 10rpx; }
.prefix-text { font-size: 26rpx; color: #86909C; font-weight: 500; }
.field-textarea { width: 100%; min-height: 120rpx; font-size: 28rpx; color: #1D2129; line-height: 1.6; }

.field-label-row {
  display: flex; align-items: center; gap: 10rpx; margin-bottom: 16rpx;
}
.field-label-text { font-size: 26rpx; color: #86909C; font-weight: 500; }

.status-field { margin-top: 8rpx; margin-bottom: 24rpx; }
.status-options { display: flex; gap: 48rpx; padding: 8rpx 4rpx; }
.status-item {
  display: flex; align-items: center; gap: 12rpx; font-size: 28rpx; color: #4E5969;
  &.active { color: #1D2129; font-weight: 500; }
}
.status-radio {
  width: 36rpx; height: 36rpx; border-radius: 50%; border: 3rpx solid #C9CDD4; transition: all 0.2s;
  &.checked {
    background: #3D6DF7; border-color: #3D6DF7; position: relative;
    &::after {
      content: ''; position: absolute; top: 50%; left: 50%;
      transform: translate(-50%, -50%); width: 14rpx; height: 14rpx;
      border-radius: 50%; background: #fff;
    }
  }
}

.menu-tree-toolbar {
  display: flex; gap: 24rpx; margin-bottom: 20rpx;
}
.toolbar-btn {
  display: flex; align-items: center; gap: 8rpx; font-size: 26rpx; color: #3D6DF7;
  padding: 8rpx 16rpx; background: #E8F0FE; border-radius: 8rpx;
}
.menu-tree-scroll { max-height: 600rpx; }
.menu-tree { display: flex; flex-direction: column; }

.tree-node-content {
  display: flex; align-items: center; gap: 12rpx; padding: 16rpx 16rpx;
  min-height: 72rpx;
}
.expand-icon {
  width: 32rpx; height: 32rpx; display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.expand-placeholder { width: 32rpx; flex-shrink: 0; }
.check-box {
  width: 36rpx; height: 36rpx; border-radius: 6rpx; border: 3rpx solid #C9CDD4;
  display: flex; align-items: center; justify-content: center; transition: all 0.2s;
  flex-shrink: 0;
  &.checked { background: #3D6DF7; border-color: #3D6DF7; }
}
.node-label { font-size: 28rpx; color: #1D2129; flex: 1; }

.form-actions {
  position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx;
  display: flex; gap: 20rpx; z-index: 100;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
