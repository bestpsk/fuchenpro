<template>
  <view class="user-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input
          class="search-input"
          type="text"
          v-model="queryParams.keyword"
          placeholder="搜索用户名/姓名/手机号"
          placeholder-class="search-placeholder"
          confirm-type="search"
          @input="onSearchInput"
          @confirm="handleSearch"
        />
        <view v-if="queryParams.keyword" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
        <view class="filter-btn" @click="toggleFilter">
          <text>筛选</text>
          <u-icon name="arrow-down" size="12" :class="{ 'icon-rotate': showFilter }"></u-icon>
        </view>
      </view>
    </view>

    <view v-if="hasActiveFilters" class="active-filters">
      <scroll-view scroll-x class="filter-scroll">
        <view class="filter-tags">
          <view
            v-if="queryParams.status !== '' && queryParams.status !== undefined"
            class="filter-tag active"
            @click="clearFilter('status')"
          >
            <text>{{ queryParams.status === '0' ? '正常' : '停用' }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
          <view
            v-if="selectedDeptName"
            class="filter-tag active"
            @click="clearFilter('deptId')"
          >
            <text>{{ selectedDeptName }}</text>
            <u-icon name="close" size="12"></u-icon>
          </view>
        </view>
      </scroll-view>
    </view>

    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <view class="form-label">用户状态</view>
          <view class="form-options">
            <view
              class="option-tag"
              :class="{ active: queryParams.status === '0' }"
              @click="queryParams.status = queryParams.status === '0' ? '' : '0'"
            >正常</view>
            <view
              class="option-tag"
              :class="{ active: queryParams.status === '1' }"
              @click="queryParams.status = queryParams.status === '1' ? '' : '1'"
            >停用</view>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">归属部门</view>
          <view class="dept-select" @click="showDeptPicker = true">
            <text :class="{ 'dept-placeholder': !selectedDeptName }">{{ selectedDeptName || '请选择部门' }}</text>
            <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
      </view>
    </u-popup>

    <u-popup :show="showDeptPicker" mode="bottom" round="16" @close="showDeptPicker = false">
      <view class="dept-picker-content">
        <view class="dept-picker-header">
          <text class="dept-picker-title">选择部门</text>
          <view class="dept-picker-close" @click="showDeptPicker = false">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <scroll-view scroll-y class="dept-tree-scroll">
          <view v-if="deptOptions.length > 0" class="dept-tree">
            <template v-for="dept in deptOptions" :key="dept.id">
              <view class="dept-node" @click="selectDept(dept)">
                <view class="dept-node-content" :class="{ active: queryParams.deptId === dept.id }">
                  <u-icon :name="dept.children && dept.children.length ? 'file-folder-fill' : 'file-text-fill'" size="18" :color="queryParams.deptId === dept.id ? '#3D6DF7' : '#86909C'"></u-icon>
                  <text class="dept-node-label">{{ dept.label }}</text>
                  <u-icon v-if="queryParams.deptId === dept.id" name="checkmark" size="16" color="#3D6DF7"></u-icon>
                </view>
                <template v-if="dept.children && dept.children.length">
                  <view v-for="child in dept.children" :key="child.id" class="dept-node child-node" @click="selectDept(child)">
                    <view class="dept-node-content" :class="{ active: queryParams.deptId === child.id }">
                      <u-icon name="file-text-fill" size="16" :color="queryParams.deptId === child.id ? '#3D6DF7' : '#86909C'"></u-icon>
                      <text class="dept-node-label">{{ child.label }}</text>
                      <u-icon v-if="queryParams.deptId === child.id" name="checkmark" size="16" color="#3D6DF7"></u-icon>
                    </view>
                    <template v-if="child.children && child.children.length">
                      <view v-for="grandChild in child.children" :key="grandChild.id" class="dept-node grandchild-node" @click="selectDept(grandChild)">
                        <view class="dept-node-content" :class="{ active: queryParams.deptId === grandChild.id }">
                          <u-icon name="file-text-fill" size="14" :color="queryParams.deptId === grandChild.id ? '#3D6DF7' : '#86909C'"></u-icon>
                          <text class="dept-node-label">{{ grandChild.label }}</text>
                          <u-icon v-if="queryParams.deptId === grandChild.id" name="checkmark" size="16" color="#3D6DF7"></u-icon>
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

    <scroll-view
      scroll-y
      class="list-scroll"
      @scrolltolower="loadMore"
      refresher-enabled
      :refresher-triggered="refreshing"
      @refresherrefresh="onPullDownRefresh"
    >
      <view v-if="userList.length > 0" class="card-list">
        <view
          v-for="item in userList"
          :key="item.userId"
          class="user-card"
          @click="goDetail(item)"
        >
          <view class="card-header">
            <view class="user-name">
              <u-icon name="account-fill" size="18" color="#3D6DF7"></u-icon>
              <text class="name-text">{{ item.nickName }}</text>
            </view>
            <view class="status-tag" :class="item.status === '0' ? 'status-normal' : 'status-stop'">
              {{ item.status === '0' ? '正常' : '停用' }}
            </view>
          </view>

          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="label">账号</text>
                <text class="value">{{ item.userName || '-' }}</text>
              </view>
              <view class="info-item">
                <text class="label">部门</text>
                <text class="value dept-text">{{ item.dept ? item.dept.deptName : '-' }}</text>
              </view>
            </view>
            <view class="info-row">
              <view class="info-item">
                <text class="label">手机</text>
                <text class="value" @click.stop="callPhone(item.phonenumber)">{{ item.phonenumber || '-' }}</text>
              </view>
              <view class="info-item">
                <text class="label">创建</text>
                <text class="value">{{ formatTime(item.createTime) }}</text>
              </view>
            </view>
          </view>

          <view class="card-footer">
            <view class="time-text">编号: {{ item.userId }}</view>
            <view class="action-btns">
              <view v-if="item.userId !== 1 && checkPermi('system:user:edit')" class="action-btn edit" @click.stop="goEdit(item)">
                <u-icon name="edit-pen" size="14"></u-icon>
                <text>编辑</text>
              </view>
              <view v-if="item.userId !== 1 && checkPermi('system:user:remove')" class="action-btn delete" @click.stop="handleDelete(item)">
                <u-icon name="trash" size="14"></u-icon>
                <text>删除</text>
              </view>
              <view v-if="item.userId !== 1 && (checkPermi('system:user:resetPwd') || checkPermi('system:user:edit'))" class="action-btn more" @click.stop="showMoreActions(item)">
                <u-icon name="more-dot-fill" size="14"></u-icon>
                <text>更多</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <u-empty
        v-else-if="!loading"
        mode="data"
        text="暂无用户数据"
        :marginTop="100"
      ></u-empty>

      <u-loadmore
        :status="loadStatus"
        :loading-text="'加载中...'"
        :loadmore-text="'上拉加载更多'"
        :nomore-text="'没有更多了'"
        :marginTop="20"
      />
    </scroll-view>

    <u-action-sheet
      :show="showActionSheet"
      :actions="actionSheetActions"
      @close="showActionSheet = false"
      @select="onActionSelect"
    ></u-action-sheet>

    <view v-if="checkPermi('system:user:add')" class="fab-btn" @click="goAdd">
      <u-icon name="plus" size="24" color="#fff"></u-icon>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { listUser, delUser, resetUserPwd, changeUserStatus, deptTreeSelect } from '@/api/system/user'
import { checkPermi } from '@/utils/permission'


const userList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)
const showDeptPicker = ref(false)
const showActionSheet = ref(false)
const currentUser = ref(null)
const deptOptions = ref([])
const selectedDeptName = ref('')

let searchTimer = null

const hasActiveFilters = computed(() => {
  return (queryParams.status !== '' && queryParams.status !== undefined) || queryParams.deptId
})

const actionSheetActions = ref([
  { name: '重置密码', type: 'resetPwd' },
  { name: '分配角色', type: 'authRole' },
  { name: item => item.status === '0' ? '停用账号' : '启用账号', type: 'toggleStatus' }
])

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: '',
  userName: '',
  phonenumber: '',
  status: '',
  deptId: ''
})

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) {
    queryParams.pageNum = 1
    loadStatus.value = 'loadmore'
  }
  try {
    const params = { ...queryParams }
    if (params.keyword) {
      params.userName = params.keyword
      params.phonenumber = params.keyword
    }
    delete params.keyword
    const response = await listUser(params)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0
    userList.value = isRefresh ? list : [...userList.value, ...list]
    loadStatus.value = userList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) {
    console.error('获取用户列表失败:', e)
    loadStatus.value = 'error'
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

function loadMore() {
  if (loading.value || loadStatus.value === 'nomore') return
  loadStatus.value = 'loading'
  queryParams.pageNum++
  getList()
}

function onPullDownRefresh() {
  refreshing.value = true
  getList(true)
}

function handleSearch() {
  getList(true)
}

function onSearchInput() {
  if (searchTimer) clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    handleSearch()
  }, 500)
}

function clearKeyword() {
  queryParams.keyword = ''
  handleSearch()
}

function toggleFilter() {
  showFilter.value = !showFilter.value
}

function resetFilter() {
  queryParams.status = ''
  queryParams.deptId = ''
  selectedDeptName.value = ''
}

function confirmFilter() {
  showFilter.value = false
  getList(true)
}

function clearFilter(field) {
  if (field === 'status') {
    queryParams.status = ''
  } else if (field === 'deptId') {
    queryParams.deptId = ''
    selectedDeptName.value = ''
  }
  getList(true)
}

async function getDeptTree() {
  try {
    const response = await deptTreeSelect()
    deptOptions.value = response.data || []
  } catch (e) {
    console.error('获取部门树失败:', e)
  }
}

function selectDept(dept) {
  if (queryParams.deptId === dept.id) {
    queryParams.deptId = ''
    selectedDeptName.value = ''
  } else {
    queryParams.deptId = dept.id
    selectedDeptName.value = dept.label
  }
  showDeptPicker.value = false
}

function goDetail(item) {
  uni.navigateTo({ url: `/pages/system/user/detail?userId=${item.userId}` })
}

function goEdit(item) {
  uni.navigateTo({ url: `/pages/system/user/form?id=${item.userId}&mode=edit` })
}

function goAdd() {
  uni.navigateTo({ url: '/pages/system/user/form?mode=add' })
}

function callPhone(phone) {
  if (!phone) return
  uni.makePhoneCall({ phoneNumber: phone })
}

function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: `是否确认删除用户"${item.nickName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delUser(item.userId)
          uni.showToast({ title: '删除成功', icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('删除失败:', e)
        }
      }
    }
  })
}

function showMoreActions(item) {
  currentUser.value = item
  const actionName = item.status === '0' ? '停用账号' : '启用账号'
  const actions = []
  if (checkPermi('system:user:resetPwd')) {
    actions.push({ name: '重置密码', type: 'resetPwd' })
  }
  if (checkPermi('system:user:edit')) {
    actions.push({ name: '分配角色', type: 'authRole' })
    actions.push({ name: actionName, type: 'toggleStatus' })
  }
  actionSheetActions.value = actions
  showActionSheet.value = true
}

async function onActionSelect(action) {
  if (!currentUser.value) return
  const item = currentUser.value
  if (action.type === 'resetPwd') {
    handleResetPwd(item)
  } else if (action.type === 'authRole') {
    goAuthRole(item)
  } else if (action.type === 'toggleStatus') {
    handleToggleStatus(item)
  }
}

function handleResetPwd(item) {
  uni.showModal({
    title: '重置密码',
    editable: true,
    placeholderText: `请输入「${item.userName}」的新密码`,
    success: async (res) => {
      if (res.confirm && res.content) {
        try {
          await resetUserPwd(item.userId, res.content)
          uni.showToast({ title: '重置成功', icon: 'success' })
        } catch (e) {
          console.error('重置密码失败:', e)
        }
      }
    }
  })
}

function goAuthRole(item) {
  uni.navigateTo({ url: `/pages/system/user/authRole?userId=${item.userId}` })
}

async function handleToggleStatus(item) {
  const newStatus = item.status === '0' ? '1' : '0'
  const text = newStatus === '0' ? '启用' : '停用'
  uni.showModal({
    title: '提示',
    content: `确认要${text}用户"${item.userName}"吗?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await changeUserStatus(item.userId, newStatus)
          uni.showToast({ title: `${text}成功`, icon: 'success' })
          getList(true)
        } catch (e) {
          console.error('状态变更失败:', e)
        }
      }
    }
  })
}

function formatTime(time) {
  if (!time) return ''
  return time.substring(0, 10)
}

onMounted(() => {
  getDeptTree()
  getList(true)
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.user-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx;
  :deep(.u-popup) { flex: none !important; }
}

.search-section {
  flex-shrink: 0;
  padding: 20rpx 24rpx; margin-left: -24rpx; margin-right: -24rpx;
  background: linear-gradient(180deg, #3D6DF7 0%, #4A7AEF 100%);
}
.search-box {
  display: flex; align-items: center; background: #fff; border-radius: 36rpx;
  padding: 0 8rpx 0 28rpx; height: 72rpx; gap: 12rpx; box-sizing: border-box;
}
.search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; min-width: 0; }
.search-placeholder { color: #86909C; font-size: 28rpx; }
.clear-btn { flex-shrink: 0; padding: 8rpx; display: flex; align-items: center; }
.filter-btn {
  flex-shrink: 0; display: flex; align-items: center; justify-content: center;
  gap: 4rpx; height: 56rpx; padding: 0 22rpx; background: #E8F0FE; border-radius: 28rpx;
  text { font-size: 26rpx; color: #3D6DF7; font-weight: 500; white-space: nowrap; }
  .icon-rotate { transform: rotate(180deg); transition: transform 0.3s ease; }
}

.active-filters {
  flex-shrink: 0;
  padding: 12rpx 24rpx 16rpx; margin-left: -24rpx; margin-right: -24rpx;
  background: linear-gradient(180deg, #4A7AEF 0%, #F5F7FA 100%);
}
.filter-scroll { white-space: nowrap; }
.filter-tags { display: inline-flex; gap: 16rpx; padding: 16rpx 0; }
.filter-tag {
  display: inline-flex; align-items: center; gap: 8rpx; padding: 10rpx 20rpx;
  background: rgba(255, 255, 255, 0.2); border-radius: 28rpx; font-size: 24rpx; color: #fff;
  &.active { background: #fff; color: #3D6DF7; }
}

.popup-content { padding: 30rpx; background: #fff; }
.popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; margin-bottom: 30rpx; }
.form-item { margin-bottom: 30rpx; }
.form-label { font-size: 28rpx; color: #1D2129; font-weight: 500; margin-bottom: 16rpx; }
.form-options { display: flex; flex-wrap: wrap; gap: 16rpx; }
.option-tag {
  padding: 14rpx 28rpx; background: #F5F7FA; border-radius: 8rpx; font-size: 26rpx;
  color: #4E5969; border: 2rpx solid transparent;
  &.active { background: #E8F0FE; color: #3D6DF7; border-color: #3D6DF7; }
}
.dept-select {
  display: flex; align-items: center; justify-content: space-between;
  padding: 20rpx 24rpx; background: #F5F7FA; border-radius: 8rpx;
  text { font-size: 26rpx; color: #1D2129; }
  .dept-placeholder { color: #C9CDD4; }
}
.popup-actions {
  display: flex; gap: 20rpx; margin-top: 40rpx; padding-top: 30rpx; border-top: 1rpx solid #E5E6EB;
  .u-button { flex: 1; }
}

.dept-picker-content { background: #fff; max-height: 70vh; }
.dept-picker-header {
  display: flex; justify-content: space-between; align-items: center;
  padding: 30rpx; border-bottom: 1rpx solid #F2F3F5;
}
.dept-picker-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.dept-picker-close { padding: 8rpx; }
.dept-tree-scroll { max-height: 60vh; padding: 20rpx 30rpx; }
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

.list-scroll { flex: 1; overflow: hidden; padding: 20rpx 0; }
.card-list { display: flex; flex-direction: column; gap: 20rpx; }
.user-card {
  background: #fff; border-radius: 16rpx; padding: 28rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
  &:active { transform: scale(0.98); opacity: 0.9; }
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.user-name {
  display: flex; align-items: center; gap: 12rpx;
  .name-text { font-size: 30rpx; font-weight: 600; color: #1D2129; }
}
.status-tag {
  padding: 6rpx 16rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500;
  &.status-normal { background: #E8FFEA; color: #00B42A; }
  &.status-stop { background: #FFF1F0; color: #F53F3F; }
}
.card-body { padding: 20rpx 0; border-top: 1rpx solid #F2F3F5; border-bottom: 1rpx solid #F2F3F5; }
.info-row { display: flex; margin-bottom: 16rpx; &:last-child { margin-bottom: 0; } }
.info-item {
  flex: 1; display: flex; align-items: center; gap: 12rpx;
  .label { font-size: 24rpx; color: #86909C; min-width: 60rpx; }
  .value { font-size: 26rpx; color: #1D2129; &.dept-text { color: #3D6DF7; } }
}
.card-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 20rpx; padding-top: 16rpx; }
.time-text { font-size: 22rpx; color: #C9CDD4; }
.action-btns { display: flex; gap: 16rpx; }
.action-btn {
  display: flex; align-items: center; gap: 6rpx; font-size: 24rpx;
  padding: 8rpx 14rpx; border-radius: 8rpx;
  &.edit { color: #3D6DF7; background: #E8F0FE; }
  &.delete { color: #F53F3F; background: #FFF1F0; }
  &.more { color: #FF7D00; background: #FFF7E8; }
}
.fab-btn {
  position: fixed; right: 32rpx; bottom: 120rpx; width: 100rpx; height: 100rpx;
  border-radius: 50%; background: linear-gradient(135deg, #3D6DF7, #5B8DEF);
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 8rpx 24rpx rgba(61, 109, 247, 0.4);
  &:active { transform: scale(0.95); opacity: 0.9; }
}
</style>
