<template>
  <view class="form-container">
    <view class="form-section">
      <view class="form-field" @click="showDeptPicker = true">
        <view class="field-input-box">
          <u-icon name="file-text-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="selectedParentName" placeholder="* 上级部门" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="file-text" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.deptName" placeholder="* 部门名称" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="order" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="number" v-model="form.orderNum" placeholder="* 显示排序" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="account-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.leader" placeholder="负责人" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="phone" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="number" v-model="form.phone" placeholder="联系电话" placeholder-class="field-placeholder" maxlength="11" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="email" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.email" placeholder="邮箱" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field status-field">
        <view class="status-label-row">
          <u-icon name="setting" size="18" color="#86909C"></u-icon>
          <text class="status-label">部门状态</text>
        </view>
        <view class="status-options">
          <view
            v-for="item in statusOptions"
            :key="item.dictValue"
            class="status-item"
            :class="{ active: form.status === item.dictValue }"
            @click="form.status = item.dictValue"
          >
            <view class="status-radio" :class="{ checked: form.status === item.dictValue }"></view>
            <text>{{ item.dictLabel }}</text>
          </view>
        </view>
      </view>
    </view>

    <u-popup :show="showDeptPicker" mode="bottom" round="16" @close="showDeptPicker = false">
      <view class="picker-popup-content">
        <view class="picker-popup-header">
          <text class="picker-popup-title">选择上级部门</text>
          <view class="picker-popup-close" @click="showDeptPicker = false">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <scroll-view scroll-y class="picker-popup-scroll">
          <view class="dept-tree">
            <view class="dept-node" @click="selectParentDept({ id: 0, label: '顶级部门' })">
              <view class="dept-node-content" :class="{ active: form.parentId === 0 }">
                <u-icon name="home" size="18" :color="form.parentId === 0 ? '#3D6DF7' : '#86909C'"></u-icon>
                <text class="dept-node-label">顶级部门</text>
                <u-icon v-if="form.parentId === 0" name="checkmark" size="16" color="#3D6DF7"></u-icon>
              </view>
            </view>
            <template v-for="dept in deptTreeOptions" :key="dept.id">
              <dept-tree-node :node="dept" :selected-id="form.parentId" @select="selectParentDept" :level="0" />
            </template>
          </view>
          <u-empty v-if="deptTreeOptions.length === 0" mode="data" text="暂无部门数据" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <view class="form-actions">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getDept, addDept, updateDept, getDeptTree, listDeptExcludeChild } from '@/api/system/dept'
import { getDicts } from '@/api/system/dictData'

const submitting = ref(false)
const showDeptPicker = ref(false)
const mode = ref('add')
const deptId = ref(null)
const deptTreeOptions = ref([])
const statusOptions = ref([])
const selectedParentName = ref('')

const form = reactive({
  deptId: undefined,
  parentId: 0,
  deptName: '',
  orderNum: 0,
  leader: '',
  phone: '',
  email: '',
  status: '0'
})

async function loadStatusDict() {
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

async function loadDeptTree() {
  try {
    if (mode.value === 'edit' && deptId.value) {
      const res = await listDeptExcludeChild(deptId.value)
      deptTreeOptions.value = res.data || []
    } else {
      const res = await getDeptTree()
      deptTreeOptions.value = res.data || []
    }
  } catch (e) {
    console.error('获取部门树失败:', e)
  }
}

async function loadDetail() {
  if (!deptId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const res = await getDept(deptId.value)
    const data = res.data || {}
    Object.assign(form, {
      deptId: data.deptId,
      parentId: data.parentId ?? 0,
      deptName: data.deptName || '',
      orderNum: data.orderNum ?? 0,
      leader: data.leader || '',
      phone: data.phone || '',
      email: data.email || '',
      status: String(data.status ?? '0')
    })
    if (data.parentName) {
      selectedParentName.value = data.parentName
    } else if (data.parentId === 0) {
      selectedParentName.value = '顶级部门'
    }
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

function selectParentDept(dept) {
  form.parentId = dept.id
  selectedParentName.value = dept.label
  showDeptPicker.value = false
}

async function submitForm() {
  if (!form.deptName) { uni.showToast({ title: '请输入部门名称', icon: 'none' }); return }
  if (form.orderNum === '' || form.orderNum === undefined || form.orderNum === null) {
    uni.showToast({ title: '请输入显示排序', icon: 'none' }); return
  }
  if (form.phone && !/^1[3-9]\d{9}$/.test(form.phone)) {
    uni.showToast({ title: '联系电话格式不正确', icon: 'none' }); return
  }
  if (form.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) {
    uni.showToast({ title: '邮箱格式不正确', icon: 'none' }); return
  }

  submitting.value = true
  try {
    const formData = { ...form }
    if (formData.deptId) {
      await updateDept(formData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      delete formData.deptId
      await addDept(formData)
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
  else uni.redirectTo({ url: '/pages/system/dept/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  mode.value = options.mode || 'add'
  deptId.value = options.id ? parseInt(options.id) : null

  loadStatusDict()
  loadDeptTree()

  if (mode.value === 'add') {
    uni.setNavigationBarTitle({ title: '新增部门' })
    if (options.parentId) {
      form.parentId = parseInt(options.parentId)
    }
  } else if (mode.value === 'edit') {
    uni.setNavigationBarTitle({ title: '编辑部门' })
    loadDetail()
  }
})
</script>

<script>
export default {
  components: {
    DeptTreeNode: {
      name: 'DeptTreeNode',
      props: {
        node: { type: Object, required: true },
        selectedId: { type: [Number, String], default: 0 },
        level: { type: Number, default: 0 }
      },
      emits: ['select'],
      template: `
        <view>
          <view class="dept-node" :style="{ paddingLeft: level * 40 + 'rpx' }" @click="$emit('select', node)">
            <view class="dept-node-content" :class="{ active: selectedId === node.id }">
              <u-icon :name="node.children && node.children.length ? 'file-text-fill' : 'file-text'" size="18" :color="selectedId === node.id ? '#3D6DF7' : '#86909C'"></u-icon>
              <text class="dept-node-label">{{ node.label }}</text>
              <u-icon v-if="selectedId === node.id" name="checkmark" size="16" color="#3D6DF7"></u-icon>
            </view>
          </view>
          <template v-if="node.children && node.children.length">
            <dept-tree-node
              v-for="child in node.children"
              :key="child.id"
              :node="child"
              :selected-id="selectedId"
              :level="level + 1"
              @select="$emit('select', $event)"
            />
          </template>
        </view>
      `
    }
  }
}
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.form-container { min-height: 100vh; padding-bottom: 140rpx; }

.form-section {
  margin: 24rpx; background: #fff; border-radius: 20rpx; padding: 32rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05);
}
.form-field { margin-bottom: 20rpx; &:last-child { margin-bottom: 0; } }
.field-input-box {
  display: flex; align-items: center; background: #F7F8FA; border-radius: 12rpx;
  padding: 0 20rpx; height: 88rpx; gap: 16rpx; border: 2rpx solid transparent; transition: all 0.2s;
  &:active { background: #EFF0F1; }
}
.field-input { flex: 1; font-size: 30rpx; color: #1D2129; height: 88rpx; line-height: 88rpx; }
.field-placeholder { color: #C9CDD4; font-size: 30rpx; }

.status-field { margin-top: 8rpx; margin-bottom: 24rpx; }
.status-label-row {
  display: flex; align-items: center; gap: 10rpx; margin-bottom: 20rpx;
}
.status-label { font-size: 28rpx; color: #86909C; font-weight: 500; }
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

.picker-popup-content { background: #fff; max-height: 70vh; }
.picker-popup-header {
  display: flex; justify-content: space-between; align-items: center;
  padding: 30rpx; border-bottom: 1rpx solid #F2F3F5;
}
.picker-popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.picker-popup-close { padding: 8rpx; }
.picker-popup-scroll { max-height: 60vh; padding: 20rpx 30rpx; }

.dept-tree { display: flex; flex-direction: column; }
.dept-node { margin-bottom: 4rpx; }
.dept-node-content {
  display: flex; align-items: center; gap: 12rpx; padding: 20rpx 16rpx;
  border-radius: 8rpx; transition: background 0.2s;
  &.active { background: #E8F0FE; }
}
.dept-node-label { flex: 1; font-size: 28rpx; color: #1D2129; }

.form-actions {
  position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx;
  display: flex; gap: 20rpx; z-index: 100;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
