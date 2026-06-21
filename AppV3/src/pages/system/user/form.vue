<template>
  <view class="form-container">
    <view class="form-section">
      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="account-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.nickName" placeholder="* 用户姓名" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field" @click="mode !== 'view' && (showDeptPicker = true)">
        <view class="field-input-box">
          <u-icon name="folder" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="selectedDeptName" placeholder="* 归属部门" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="phone" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="number" v-model="form.phonenumber" placeholder="* 手机号码" placeholder-class="field-placeholder" maxlength="11" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="email" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.email" placeholder="邮箱" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view v-if="mode === 'add'" class="form-field">
        <view class="field-input-box">
          <u-icon name="account" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.userName" placeholder="* 用户名称" placeholder-class="field-placeholder" maxlength="30" />
        </view>
      </view>

      <view v-if="mode === 'add'" class="form-field">
        <view class="field-input-box">
          <u-icon name="lock" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.password" placeholder="* 用户密码" placeholder-class="field-placeholder" password maxlength="20" />
        </view>
      </view>

      <view class="form-field" @click="mode !== 'view' && (showSexPicker = true)">
        <view class="field-input-box">
          <u-icon name="man" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="sexName" placeholder="性别" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field status-field">
        <view class="status-options">
          <view
            class="status-item"
            :class="{ active: form.status === '0', disabled: mode === 'view' }"
            @click="mode !== 'view' && (form.status = '0')"
          >
            <view class="status-radio" :class="{ checked: form.status === '0' }"></view>
            <text>正常</text>
          </view>
          <view
            class="status-item"
            :class="{ active: form.status === '1', disabled: mode === 'view' }"
            @click="mode !== 'view' && (form.status = '1')"
          >
            <view class="status-radio" :class="{ checked: form.status === '1' }"></view>
            <text>停用</text>
          </view>
        </view>
      </view>

      <view class="form-field" @click="mode !== 'view' && (showPostPicker = true)">
        <view class="field-input-box">
          <u-icon name="coupon-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="selectedPostNames" placeholder="岗位（可多选）" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="mode !== 'view' && (showRolePicker = true)">
        <view class="field-input-box">
          <u-icon name="account" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="selectedRoleNames" placeholder="角色（可多选）" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field">
        <view class="field-textarea-box">
          <view class="textarea-prefix"><u-icon name="edit-pen" size="18" color="#86909C"></u-icon><text class="prefix-text">备注</text></view>
          <textarea class="field-textarea" v-model="form.remark" placeholder="请输入备注信息" placeholder-class="field-placeholder" :maxlength="500" auto-height></textarea>
        </view>
      </view>
    </view>

    <view v-if="mode === 'edit'" class="form-section">
      <view class="section-title">扩展信息</view>
      <view class="link-item" @click="goDetailEdit">
        <view class="link-content">
          <u-icon name="file-text-fill" size="18" color="#3D6DF7"></u-icon>
          <text class="link-text">员工详情</text>
        </view>
        <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
      </view>
    </view>

    <u-picker :show="showSexPicker" :columns="[sexColumns]" keyName="label" title="选择性别" @confirm="onSexConfirm" @cancel="showSexPicker = false" @close="showSexPicker = false"></u-picker>

    <u-popup :show="showDeptPicker" mode="bottom" round="16" @close="showDeptPicker = false">
      <view class="picker-popup-content">
        <view class="picker-popup-header">
          <text class="picker-popup-title">选择部门</text>
          <view class="picker-popup-close" @click="showDeptPicker = false">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <scroll-view scroll-y class="picker-popup-scroll">
          <view v-if="deptOptions.length > 0" class="dept-tree">
            <template v-for="dept in deptOptions" :key="dept.id">
              <view class="dept-node" @click="selectDept(dept)">
                <view class="dept-node-content" :class="{ active: form.deptId === dept.id }">
                  <u-icon :name="dept.children && dept.children.length ? 'folder' : 'file-text-fill'" size="18" :color="form.deptId === dept.id ? '#3D6DF7' : '#86909C'"></u-icon>
                  <text class="dept-node-label">{{ dept.label }}</text>
                  <u-icon v-if="form.deptId === dept.id" name="checkmark" size="16" color="#3D6DF7"></u-icon>
                </view>
                <template v-if="dept.children && dept.children.length">
                  <view v-for="child in dept.children" :key="child.id" class="dept-node child-node" @click="selectDept(child)">
                    <view class="dept-node-content" :class="{ active: form.deptId === child.id }">
                      <u-icon name="file-text-fill" size="16" :color="form.deptId === child.id ? '#3D6DF7' : '#86909C'"></u-icon>
                      <text class="dept-node-label">{{ child.label }}</text>
                      <u-icon v-if="form.deptId === child.id" name="checkmark" size="16" color="#3D6DF7"></u-icon>
                    </view>
                    <template v-if="child.children && child.children.length">
                      <view v-for="grandChild in child.children" :key="grandChild.id" class="dept-node grandchild-node" @click="selectDept(grandChild)">
                        <view class="dept-node-content" :class="{ active: form.deptId === grandChild.id }">
                          <u-icon name="file-text-fill" size="14" :color="form.deptId === grandChild.id ? '#3D6DF7' : '#86909C'"></u-icon>
                          <text class="dept-node-label">{{ grandChild.label }}</text>
                          <u-icon v-if="form.deptId === grandChild.id" name="checkmark" size="16" color="#3D6DF7"></u-icon>
                        </view>
                      </view>
                    </template>
                  </view>
                </template>
              </view>
            </template>
          </view>
          <u-empty v-else mode="data" text="暂无部门数据" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <u-popup :show="showPostPicker" mode="bottom" round="16" @close="showPostPicker = false">
      <view class="picker-popup-content">
        <view class="picker-popup-header">
          <text class="picker-popup-title">选择岗位</text>
          <view class="picker-popup-close" @click="showPostPicker = false">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <scroll-view scroll-y class="picker-popup-scroll">
          <view class="check-list">
            <view
              v-for="item in postOptions"
              :key="item.postId"
              class="check-item"
              :class="{ active: form.postIds.includes(item.postId), disabled: item.status === '1' }"
              @click="togglePost(item)"
            >
              <view class="check-box" :class="{ checked: form.postIds.includes(item.postId) }">
                <u-icon v-if="form.postIds.includes(item.postId)" name="checkmark" size="12" color="#fff"></u-icon>
              </view>
              <text class="check-label">{{ item.postName }}</text>
            </view>
          </view>
        </scroll-view>
        <view class="picker-popup-actions">
          <u-button type="info" plain text="取消" @click="showPostPicker = false"></u-button>
          <u-button type="primary" text="确定" @click="showPostPicker = false"></u-button>
        </view>
      </view>
    </u-popup>

    <u-popup :show="showRolePicker" mode="bottom" round="16" @close="showRolePicker = false">
      <view class="picker-popup-content">
        <view class="picker-popup-header">
          <text class="picker-popup-title">选择角色</text>
          <view class="picker-popup-close" @click="showRolePicker = false">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <scroll-view scroll-y class="picker-popup-scroll">
          <view class="check-list">
            <view
              v-for="item in roleOptions"
              :key="item.roleId"
              class="check-item"
              :class="{ active: form.roleIds.includes(item.roleId), disabled: item.status === '1' }"
              @click="toggleRole(item)"
            >
              <view class="check-box" :class="{ checked: form.roleIds.includes(item.roleId) }">
                <u-icon v-if="form.roleIds.includes(item.roleId)" name="checkmark" size="12" color="#fff"></u-icon>
              </view>
              <text class="check-label">{{ item.roleName }}</text>
            </view>
          </view>
        </scroll-view>
        <view class="picker-popup-actions">
          <u-button type="info" plain text="取消" @click="showRolePicker = false"></u-button>
          <u-button type="primary" text="确定" @click="showRolePicker = false"></u-button>
        </view>
      </view>
    </u-popup>

    <view class="form-actions" v-if="mode !== 'view'">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getUser, addUser, updateUser, deptTreeSelect } from '@/api/system/user'

const submitting = ref(false)
const showSexPicker = ref(false)
const showDeptPicker = ref(false)
const showPostPicker = ref(false)
const showRolePicker = ref(false)
const mode = ref('add')
const userId = ref(null)
const deptOptions = ref([])
const postOptions = ref([])
const roleOptions = ref([])
const selectedDeptName = ref('')

const form = reactive({
  userId: undefined,
  deptId: undefined,
  userName: '',
  nickName: '',
  password: '',
  phonenumber: '',
  email: '',
  sex: '',
  status: '0',
  remark: '',
  postIds: [],
  roleIds: []
})

const sexColumns = ref([
  { label: '男', value: '0' },
  { label: '女', value: '1' },
  { label: '未知', value: '2' }
])

const sexName = computed(() => {
  const item = sexColumns.value.find(s => s.value === form.sex)
  return item ? item.label : ''
})

const selectedPostNames = computed(() => {
  return postOptions.value.filter(p => form.postIds.includes(p.postId)).map(p => p.postName).join('、') || ''
})

const selectedRoleNames = computed(() => {
  return roleOptions.value.filter(r => form.roleIds.includes(r.roleId)).map(r => r.roleName).join('、') || ''
})

function onSexConfirm(e) {
  const item = e.value[0]
  form.sex = item.value
  showSexPicker.value = false
}

function selectDept(dept) {
  form.deptId = dept.id
  selectedDeptName.value = dept.label
  showDeptPicker.value = false
}

function togglePost(item) {
  if (item.status === '1') return
  const idx = form.postIds.indexOf(item.postId)
  if (idx > -1) {
    form.postIds.splice(idx, 1)
  } else {
    form.postIds.push(item.postId)
  }
}

function toggleRole(item) {
  if (item.status === '1') return
  const idx = form.roleIds.indexOf(item.roleId)
  if (idx > -1) {
    form.roleIds.splice(idx, 1)
  } else {
    form.roleIds.push(item.roleId)
  }
}

async function loadDetail() {
  if (!userId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const res = await getUser(userId.value)
    const data = res.data || {}
    Object.assign(form, {
      userId: data.userId,
      deptId: data.deptId,
      userName: data.userName || '',
      nickName: data.nickName || '',
      password: '',
      phonenumber: data.phonenumber || '',
      email: data.email || '',
      sex: data.sex || '',
      status: String(data.status ?? '0'),
      remark: data.remark || '',
      postIds: res.postIds || [],
      roleIds: res.roleIds || []
    })
    postOptions.value = res.posts || []
    roleOptions.value = res.roles || []
    if (data.dept && data.dept.deptName) {
      selectedDeptName.value = data.dept.deptName
    }
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

async function loadAddDefaults() {
  try {
    const res = await getUser()
    postOptions.value = res.posts || []
    roleOptions.value = res.roles || []
  } catch (e) {
    console.error('加载默认数据失败:', e)
  }
}

async function getDeptTree() {
  try {
    const res = await deptTreeSelect()
    deptOptions.value = res.data || []
  } catch (e) {
    console.error('获取部门树失败:', e)
  }
}

async function submitForm() {
  if (!form.nickName) { uni.showToast({ title: '请输入用户姓名', icon: 'none' }); return }
  if (!form.deptId) { uni.showToast({ title: '请选择归属部门', icon: 'none' }); return }
  if (!form.phonenumber) { uni.showToast({ title: '请输入手机号码', icon: 'none' }); return }
  if (!/^1[3-9]\d{9}$/.test(form.phonenumber)) { uni.showToast({ title: '手机号格式不正确', icon: 'none' }); return }
  if (form.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) { uni.showToast({ title: '邮箱格式不正确', icon: 'none' }); return }

  if (mode.value === 'add') {
    if (!form.userName) { uni.showToast({ title: '请输入用户名称', icon: 'none' }); return }
    if (!form.password) { uni.showToast({ title: '请输入用户密码', icon: 'none' }); return }
  }

  submitting.value = true
  try {
    const formData = { ...form }
    delete formData.dept
    if (formData.userId) {
      await updateUser(formData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      delete formData.userId
      await addUser(formData)
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

function goDetailEdit() {
  uni.navigateTo({ url: `/pages/system/user/detail-edit?userId=${userId.value}` })
}

function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.redirectTo({ url: '/pages/system/user/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  mode.value = options.mode || 'add'
  userId.value = options.id ? parseInt(options.id) : null

  getDeptTree()

  if (mode.value === 'add') {
    uni.setNavigationBarTitle({ title: '新增用户' })
    loadAddDefaults()
  } else if (mode.value === 'edit') {
    uni.setNavigationBarTitle({ title: '编辑用户' })
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

.status-field { margin-top: 8rpx; margin-bottom: 24rpx; }
.status-options { display: flex; gap: 48rpx; padding: 8rpx 4rpx; }
.status-item {
  display: flex; align-items: center; gap: 12rpx; font-size: 28rpx; color: #4E5969;
  &.active { color: #1D2129; font-weight: 500; }
  &.disabled { opacity: 0.5; }
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

.link-item {
  display: flex; justify-content: space-between; align-items: center;
  padding: 24rpx 0; border-bottom: 1rpx solid #F2F3F5;
  &:last-child { border-bottom: none; }
}
.link-content { display: flex; align-items: center; gap: 12rpx; }
.link-text { font-size: 28rpx; color: #3D6DF7; font-weight: 500; }

.picker-popup-content { background: #fff; max-height: 70vh; }
.picker-popup-header {
  display: flex; justify-content: space-between; align-items: center;
  padding: 30rpx; border-bottom: 1rpx solid #F2F3F5;
}
.picker-popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.picker-popup-close { padding: 8rpx; }
.picker-popup-scroll { max-height: 50vh; padding: 20rpx 30rpx; }
.picker-popup-actions {
  display: flex; gap: 20rpx; padding: 20rpx 30rpx 30rpx; border-top: 1rpx solid #F2F3F5;
  .u-button { flex: 1; }
}

.dept-tree { display: flex; flex-direction: column; }
.dept-node { margin-bottom: 4rpx; }
.dept-node-content {
  display: flex; align-items: center; gap: 12rpx; padding: 20rpx 16rpx;
  border-radius: 8rpx; transition: background 0.2s;
  &.active { background: #E8F0FE; }
}
.dept-node-label { flex: 1; font-size: 28rpx; color: #1D2129; }
.child-node { padding-left: 40rpx; }
.grandchild-node { padding-left: 80rpx; }

.check-list { display: flex; flex-direction: column; gap: 8rpx; }
.check-item {
  display: flex; align-items: center; gap: 16rpx; padding: 20rpx 16rpx;
  border-radius: 8rpx; transition: background 0.2s;
  &.active { background: #E8F0FE; }
  &.disabled { opacity: 0.5; }
}
.check-box {
  width: 36rpx; height: 36rpx; border-radius: 6rpx; border: 3rpx solid #C9CDD4;
  display: flex; align-items: center; justify-content: center; transition: all 0.2s;
  &.checked { background: #3D6DF7; border-color: #3D6DF7; }
}
.check-label { font-size: 28rpx; color: #1D2129; }

.form-actions {
  position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx;
  display: flex; gap: 20rpx; z-index: 100;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
