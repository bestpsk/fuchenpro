<template>
  <view class="config-container">
    <view class="type-tabs">
      <view class="type-tab" :class="{ 'tab-active': activeType === 0 }" @click="activeType = 0; getList()">
        <text class="tab-text" :class="{ 'tab-text-active': activeType === 0 }">全部</text>
      </view>
      <view class="type-tab" :class="{ 'tab-active': activeType === 1 }" @click="activeType = 1; getList()">
        <text class="tab-text" :class="{ 'tab-text-active': activeType === 1 }">用户级</text>
      </view>
      <view class="type-tab" :class="{ 'tab-active': activeType === 2 }" @click="activeType = 2; getList()">
        <text class="tab-text" :class="{ 'tab-text-active': activeType === 2 }">部门级</text>
      </view>
    </view>

    <scroll-view scroll-y class="config-list" @scrolltolower="loadMore">
      <view v-if="list.length === 0 && !loading" class="empty-tip">
        <u-icon name="list" size="48" color="#c0c4cc" />
        <text class="empty-text">暂无考勤配置</text>
      </view>
      <view v-for="item in list" :key="item.configId" class="config-card" @click="handleEdit(item)">
        <view class="card-header">
          <text class="card-name">{{ item.configName }}</text>
          <view class="card-tags">
            <text class="type-tag" :class="item.configType === 1 ? 'tag-user' : 'tag-dept'">
              {{ item.configType === 1 ? '用户级' : '部门级' }}
            </text>
            <text class="status-tag" :class="item.status === '0' ? 'tag-normal' : 'tag-disabled'">
              {{ item.status === '0' ? '正常' : '停用' }}
            </text>
          </view>
        </view>
        <view class="card-row">
          <text class="row-label">考勤规则</text>
          <text class="row-value">{{ item.rule?.ruleName || '-' }}</text>
        </view>
        <view class="card-row" v-if="item.configType === 1">
          <text class="row-label">关联用户</text>
          <text class="row-value">{{ getUserNames(item.userIds) }}</text>
        </view>
        <view class="card-row" v-if="item.configType === 2">
          <text class="row-label">关联部门</text>
          <text class="row-value">{{ getDeptNames(item.deptIds) }}</text>
        </view>
        <view class="card-actions">
          <view class="action-btn action-edit" v-if="checkPermi('business:attendance:config:edit')" @click.stop="handleEdit(item)">
            <u-icon name="edit-pen" size="14" color="#3D6DF7" />
            <text>编辑</text>
          </view>
          <view class="action-btn action-delete" v-if="checkPermi('business:attendance:config:remove')" @click.stop="handleDelete(item)">
            <u-icon name="trash" size="14" color="#f5222d" />
            <text>删除</text>
          </view>
        </view>
      </view>
      <view v-if="loading" class="loading-tip">
        <u-icon name="loading" size="20" color="#3D6DF7" />
        <text>加载中...</text>
      </view>
    </scroll-view>

    <view class="fab-btn" v-if="checkPermi('business:attendance:config:add')" @click="handleAdd">
      <u-icon name="plus" size="28" color="#fff" />
    </view>

    <u-popup :show="showForm" mode="bottom" round="20" @close="showForm = false">
      <view class="form-container">
        <view class="form-header">
          <text class="form-title">{{ isEdit ? '编辑配置' : '新增配置' }}</text>
          <view class="form-close" @click="showForm = false">
            <u-icon name="close" size="20" color="#86909C" />
          </view>
        </view>
        <scroll-view scroll-y class="form-scroll">
          <view class="form-item">
            <text class="form-label">配置名称</text>
            <input class="form-input" v-model="form.configName" placeholder="请输入配置名称" />
          </view>
          <view class="form-item">
            <text class="form-label">配置类型</text>
            <view class="radio-group">
              <view class="radio-item" :class="{ 'radio-active': form.configType === 1 }" @click="changeConfigType(1)">
                <text>用户级</text>
              </view>
              <view class="radio-item" :class="{ 'radio-active': form.configType === 2 }" @click="changeConfigType(2)">
                <text>部门级</text>
              </view>
            </view>
          </view>
          <view class="form-item">
            <text class="form-label">考勤规则</text>
            <picker :range="ruleOptions" range-key="ruleName" @change="onRuleChange">
              <view class="form-picker">
                <text :class="{ 'picker-placeholder': !form.ruleId }">
                  {{ selectedRuleName || '请选择考勤规则' }}
                </text>
                <u-icon name="arrow-right" size="14" color="#86909C" />
              </view>
            </picker>
          </view>
          <view class="form-item" v-if="form.configType === 1">
            <text class="form-label">关联用户</text>
            <view class="selected-tags" v-if="form.userIds.length > 0">
              <view class="sel-tag" v-for="uid in form.userIds" :key="uid">
                <text>{{ getUserNameById(uid) }}</text>
                <u-icon name="close" size="10" color="#86909C" @click="removeUser(uid)" />
              </view>
            </view>
            <view class="form-picker" @click="showUserPicker = true">
              <text :class="{ 'picker-placeholder': form.userIds.length === 0 }">
                {{ form.userIds.length > 0 ? '继续添加' : '请选择用户' }}
              </text>
              <u-icon name="arrow-right" size="14" color="#86909C" />
            </view>
          </view>
          <view class="form-item" v-if="form.configType === 2">
            <text class="form-label">关联部门</text>
            <view class="selected-tags" v-if="form.deptIds.length > 0">
              <view class="sel-tag" v-for="did in form.deptIds" :key="did">
                <text>{{ getDeptNameById(did) }}</text>
                <u-icon name="close" size="10" color="#86909C" @click="removeDept(did)" />
              </view>
            </view>
            <view class="form-picker" @click="showDeptPicker = true">
              <text :class="{ 'picker-placeholder': form.deptIds.length === 0 }">
                {{ form.deptIds.length > 0 ? '继续添加' : '请选择部门' }}
              </text>
              <u-icon name="arrow-right" size="14" color="#86909C" />
            </view>
          </view>
          <view class="form-item">
            <text class="form-label">状态</text>
            <view class="radio-group">
              <view class="radio-item" :class="{ 'radio-active': form.status === '0' }" @click="form.status = '0'">
                <text>正常</text>
              </view>
              <view class="radio-item" :class="{ 'radio-active': form.status === '1' }" @click="form.status = '1'">
                <text>停用</text>
              </view>
            </view>
          </view>
          <view class="form-item">
            <text class="form-label">备注</text>
            <textarea class="form-textarea" v-model="form.remark" placeholder="请输入备注" maxlength="200" />
          </view>
        </scroll-view>
        <view class="form-footer">
          <view class="btn-cancel" @click="showForm = false">
            <text>取消</text>
          </view>
          <view class="btn-confirm" @click="submitForm">
            <text>确定</text>
          </view>
        </view>
      </view>
    </u-popup>

    <u-popup :show="showUserPicker" mode="bottom" round="20" @close="showUserPicker = false">
      <view class="picker-container">
        <view class="picker-header">
          <text class="picker-title">选择用户</text>
          <view class="picker-done" @click="showUserPicker = false">
            <text>完成</text>
          </view>
        </view>
        <scroll-view scroll-y class="picker-list">
          <view
            v-for="user in userOptions"
            :key="user.userId"
            class="picker-item"
            :class="{ 'picker-item-active': form.userIds.includes(user.userId) }"
            @click="toggleUser(user.userId)"
          >
            <text>{{ user.nickName || user.userName }}</text>
            <u-icon v-if="form.userIds.includes(user.userId)" name="checkmark" size="16" color="#3D6DF7" />
          </view>
        </scroll-view>
      </view>
    </u-popup>

    <u-popup :show="showDeptPicker" mode="bottom" round="20" @close="showDeptPicker = false">
      <view class="picker-container">
        <view class="picker-header">
          <text class="picker-title">选择部门</text>
          <view class="picker-done" @click="showDeptPicker = false">
            <text>完成</text>
          </view>
        </view>
        <scroll-view scroll-y class="picker-list">
          <view
            v-for="dept in flatDeptList"
            :key="dept.id"
            class="picker-item"
            :class="{ 'picker-item-active': form.deptIds.includes(dept.id) }"
            :style="{ paddingLeft: (dept.level || 0) * 30 + 24 + 'rpx' }"
            @click="toggleDept(dept.id)"
          >
            <text>{{ dept.label }}</text>
            <u-icon v-if="form.deptIds.includes(dept.id)" name="checkmark" size="16" color="#3D6DF7" />
          </view>
        </scroll-view>
      </view>
    </u-popup>
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { listAttendanceConfig, getAttendanceConfig, addAttendanceConfig, updateAttendanceConfig, delAttendanceConfig, listAttendanceRule } from '@/api/attendance'
import { listUser } from '@/api/system/user'
import { getDeptTree } from '@/api/system/dept'
import { checkPermi } from '@/utils/permission'

const activeType = ref(0)
const list = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(20)
const total = ref(0)

const ruleOptions = ref([])
const userOptions = ref([])
const deptTreeData = ref([])

const showForm = ref(false)
const isEdit = ref(false)
const form = ref({
  configId: undefined,
  configName: '',
  configType: 1,
  ruleId: undefined,
  userIds: [],
  deptIds: [],
  status: '0',
  remark: ''
})

const showUserPicker = ref(false)
const showDeptPicker = ref(false)

const selectedRuleName = computed(() => {
  if (!form.value.ruleId) return ''
  const rule = ruleOptions.value.find(r => r.ruleId === form.value.ruleId)
  return rule ? rule.ruleName : ''
})

const flatDeptList = computed(() => {
  const result = []
  function flatten(nodes, level = 0) {
    for (const node of nodes) {
      result.push({ id: node.id, label: node.label, level })
      if (node.children && node.children.length > 0) {
        flatten(node.children, level + 1)
      }
    }
  }
  flatten(deptTreeData.value)
  return result
})

function getList() {
  loading.value = true
  const params = { pageNum: pageNum.value, pageSize: pageSize.value }
  if (activeType.value > 0) {
    params.configType = activeType.value
  }
  listAttendanceConfig(params).then(res => {
    list.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => {
    loading.value = false
  })
}

function loadMore() {
  if (list.value.length >= total.value) return
  pageNum.value++
  const params = { pageNum: pageNum.value, pageSize: pageSize.value }
  if (activeType.value > 0) params.configType = activeType.value
  loading.value = true
  listAttendanceConfig(params).then(res => {
    list.value = [...list.value, ...(res.rows || [])]
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function loadRuleOptions() {
  listAttendanceRule({ pageSize: 100 }).then(res => { ruleOptions.value = res.rows || [] })
}

function loadUserOptions() {
  listUser({ pageSize: 1000 }).then(res => { userOptions.value = res.rows || [] })
}

function loadDeptTree() {
  getDeptTree().then(res => { deptTreeData.value = res.data || [] })
}

function getUserNames(userIds) {
  if (!userIds) return '-'
  const ids = userIds.split(',').map(id => parseInt(id))
  return ids.map(id => getUserNameById(id)).join(', ')
}

function getUserNameById(uid) {
  const user = userOptions.value.find(u => u.userId === uid)
  return user ? (user.nickName || user.userName) : uid
}

function getDeptNames(deptIds) {
  if (!deptIds) return '-'
  const ids = deptIds.split(',').map(id => parseInt(id))
  return ids.map(id => getDeptNameById(id)).join(', ')
}

function getDeptNameById(did) {
  const dept = flatDeptList.value.find(d => d.id === did)
  return dept ? dept.label : did
}

function resetForm() {
  form.value = {
    configId: undefined,
    configName: '',
    configType: 1,
    ruleId: undefined,
    userIds: [],
    deptIds: [],
    status: '0',
    remark: ''
  }
}

function changeConfigType(type) {
  form.value.configType = type
  form.value.userIds = []
  form.value.deptIds = []
}

function onRuleChange(e) {
  const idx = e.detail.value
  if (idx >= 0 && idx < ruleOptions.value.length) {
    form.value.ruleId = ruleOptions.value[idx].ruleId
  }
}

function toggleUser(uid) {
  const idx = form.value.userIds.indexOf(uid)
  if (idx >= 0) {
    form.value.userIds.splice(idx, 1)
  } else {
    form.value.userIds.push(uid)
  }
}

function removeUser(uid) {
  const idx = form.value.userIds.indexOf(uid)
  if (idx >= 0) form.value.userIds.splice(idx, 1)
}

function toggleDept(did) {
  const idx = form.value.deptIds.indexOf(did)
  if (idx >= 0) {
    form.value.deptIds.splice(idx, 1)
  } else {
    form.value.deptIds.push(did)
  }
}

function removeDept(did) {
  const idx = form.value.deptIds.indexOf(did)
  if (idx >= 0) form.value.deptIds.splice(idx, 1)
}

function handleAdd() {
  resetForm()
  isEdit.value = false
  showForm.value = true
}

function handleEdit(item) {
  getAttendanceConfig(item.configId).then(res => {
    const data = res.data || {}
    form.value = {
      configId: data.configId,
      configName: data.configName || '',
      configType: data.configType || 1,
      ruleId: data.ruleId,
      userIds: data.userIds && typeof data.userIds === 'string' ? data.userIds.split(',').map(id => parseInt(id)) : [],
      deptIds: data.deptIds && typeof data.deptIds === 'string' ? data.deptIds.split(',').map(id => parseInt(id)) : [],
      status: data.status || '0',
      remark: data.remark || ''
    }
    isEdit.value = true
    showForm.value = true
  })
}

function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: '是否确认删除该配置？',
    success: (res) => {
      if (res.confirm) {
        delAttendanceConfig(item.configId).then(() => {
          uni.showToast({ title: '删除成功', icon: 'success' })
          getList()
        })
      }
    }
  })
}

function submitForm() {
  if (!form.value.configName) {
    uni.showToast({ title: '请输入配置名称', icon: 'none' })
    return
  }
  if (!form.value.ruleId) {
    uni.showToast({ title: '请选择考勤规则', icon: 'none' })
    return
  }

  const submitData = { ...form.value }

  const request = isEdit.value ? updateAttendanceConfig(submitData) : addAttendanceConfig(submitData)
  request.then(() => {
    uni.showToast({ title: isEdit.value ? '修改成功' : '新增成功', icon: 'success' })
    showForm.value = false
    getList()
  }).catch(err => {
    uni.showToast({ title: err.message || '操作失败', icon: 'none' })
  })
}

onMounted(() => {
  getList()
  loadRuleOptions()
  loadUserOptions()
  loadDeptTree()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }

.config-container {
  min-height: 100vh;
  padding: 24rpx;
  padding-bottom: 120rpx;
}

.type-tabs {
  display: flex;
  background: #fff;
  border-radius: 20rpx;
  padding: 8rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 4rpx 20rpx rgba(102, 126, 234, 0.08);
}

.type-tab {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 22rpx 0;
  border-radius: 16rpx;
  transition: all 0.25s ease;
}

.tab-active {
  background: linear-gradient(180deg, #5B8FF9 0%, #3D6DF7 100%);
  box-shadow: 0 4rpx 12rpx rgba(61, 109, 247, 0.25);
}

.tab-text { font-size: 26rpx; color: #86909C; font-weight: 500; }
.tab-text-active { color: #fff; font-weight: 600; }

.config-list { height: calc(100vh - 160rpx); }

.config-card {
  background: #fff;
  border-radius: 20rpx;
  padding: 28rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.04);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.card-name { font-size: 30rpx; font-weight: 600; color: #1D2129; flex: 1; }

.card-tags { display: flex; gap: 12rpx; }

.type-tag, .status-tag {
  padding: 4rpx 14rpx;
  border-radius: 8rpx;
  font-size: 22rpx;
  font-weight: 500;
}

.tag-user { background: #e6f7ff; color: #1890ff; }
.tag-dept { background: #f6ffed; color: #52c41a; }
.tag-normal { background: #f6ffed; color: #52c41a; }
.tag-disabled { background: #fff1f0; color: #f5222d; }

.card-row {
  display: flex;
  align-items: center;
  padding: 10rpx 0;
}

.row-label { font-size: 24rpx; color: #86909C; width: 140rpx; flex-shrink: 0; }
.row-value { font-size: 24rpx; color: #1D2129; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

.card-actions {
  display: flex;
  gap: 24rpx;
  margin-top: 20rpx;
  padding-top: 20rpx;
  border-top: 1rpx solid #F0F0F0;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 6rpx;
  font-size: 24rpx;
  padding: 8rpx 20rpx;
  border-radius: 8rpx;
}

.action-edit { color: #3D6DF7; background: #F0F5FF; }
.action-delete { color: #f5222d; background: #fff1f0; }

.empty-tip {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
  padding: 120rpx 0;
}

.empty-text { font-size: 26rpx; color: #c0c4cc; }

.loading-tip {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
  padding: 24rpx 0;
  font-size: 24rpx;
  color: #86909C;
}

.fab-btn {
  position: fixed;
  right: 40rpx;
  bottom: 120rpx;
  width: 100rpx;
  height: 100rpx;
  border-radius: 50%;
  background: linear-gradient(145deg, #5B8FF9 0%, #3D6DF7 100%);
  box-shadow: 0 8rpx 24rpx rgba(61, 109, 247, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
  transition: all 0.2s ease;

  &:active { transform: scale(0.92); }
}

.form-container {
  max-height: 80vh;
  display: flex;
  flex-direction: column;
}

.form-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28rpx 32rpx;
  border-bottom: 1rpx solid #F0F0F0;
}

.form-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.form-close { padding: 8rpx; }

.form-scroll { flex: 1; padding: 24rpx 32rpx; }

.form-item {
  margin-bottom: 28rpx;
}

.form-label {
  font-size: 26rpx;
  color: #4E5969;
  font-weight: 500;
  margin-bottom: 12rpx;
  display: block;
}

.form-input {
  width: 100%;
  height: 76rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 0 20rpx;
  font-size: 26rpx;
  color: #1D2129;
  border: 2rpx solid #E5E6EB;
  box-sizing: border-box;

  &:focus { border-color: #3D6DF7; background: #fff; }
}

.form-textarea {
  width: 100%;
  height: 140rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 20rpx;
  font-size: 26rpx;
  color: #1D2129;
  border: 2rpx solid #E5E6EB;
  box-sizing: border-box;
}

.radio-group { display: flex; gap: 16rpx; }

.radio-item {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 18rpx 0;
  border-radius: 12rpx;
  background: #F7F8FA;
  border: 2rpx solid #E5E6EB;
  font-size: 26rpx;
  color: #4E5969;
  transition: all 0.2s ease;
}

.radio-active {
  background: #F0F5FF;
  border-color: #3D6DF7;
  color: #3D6DF7;
  font-weight: 500;
}

.form-picker {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 76rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 0 20rpx;
  font-size: 26rpx;
  color: #1D2129;
  border: 2rpx solid #E5E6EB;
}

.picker-placeholder { color: #c0c4cc; }

.selected-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10rpx;
  margin-bottom: 12rpx;
}

.sel-tag {
  display: flex;
  align-items: center;
  gap: 6rpx;
  padding: 6rpx 16rpx;
  background: #F0F5FF;
  border-radius: 8rpx;
  font-size: 22rpx;
  color: #3D6DF7;
}

.form-footer {
  display: flex;
  gap: 20rpx;
  padding: 24rpx 32rpx;
  border-top: 1rpx solid #F0F0F0;
}

.btn-cancel, .btn-confirm {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 22rpx 0;
  border-radius: 12rpx;
  font-size: 28rpx;
  font-weight: 500;
}

.btn-cancel { background: #F7F8FA; color: #4E5969; border: 1rpx solid #E5E6EB; }
.btn-confirm { background: linear-gradient(180deg, #5B8FF9 0%, #3D6DF7 100%); color: #fff; }

.picker-container { max-height: 60vh; display: flex; flex-direction: column; }

.picker-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28rpx 32rpx;
  border-bottom: 1rpx solid #F0F0F0;
}

.picker-title { font-size: 30rpx; font-weight: 600; color: #1D2129; }
.picker-done { font-size: 28rpx; color: #3D6DF7; font-weight: 500; padding: 8rpx; }

.picker-list { flex: 1; max-height: 50vh; }

.picker-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24rpx 32rpx;
  border-bottom: 1rpx solid #F7F8FA;
  font-size: 26rpx;
  color: #1D2129;
}

.picker-item-active { color: #3D6DF7; background: #F0F5FF; }
</style>
