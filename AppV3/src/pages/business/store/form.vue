<template>
  <view class="form-container">
    <view class="form-section">
      <view class="form-field" @click="showEnterprisePicker = mode !== 'view'">
        <view class="field-input-box">
          <u-icon name="home-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.enterpriseName" placeholder="* 所属企业" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="home-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.storeName" placeholder="* 门店名称" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="account" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.managerName" placeholder="负责人" placeholder-class="field-placeholder" />
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
          <u-icon name="chat" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.wechat" placeholder="微信号" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-row">
        <view class="form-field half-width">
          <view class="field-input-box">
            <u-icon name="clock" size="16" color="#86909C"></u-icon>
            <input class="field-input" v-model="form.businessStart" placeholder="开始时间" placeholder-class="field-placeholder" />
          </view>
        </view>
        <view class="form-field half-width">
          <view class="field-input-box">
            <u-icon name="clock" size="16" color="#86909C"></u-icon>
            <input class="field-input" v-model="form.businessEnd" placeholder="结束时间" placeholder-class="field-placeholder" />
          </view>
        </view>
      </view>

      <view class="form-field">
        <view class="field-textarea-box">
          <view class="textarea-prefix"><u-icon name="map" size="18" color="#86909C"></u-icon><text class="prefix-text">地址</text></view>
          <textarea class="field-textarea" v-model="form.address" placeholder="请输入地址" placeholder-class="field-placeholder" :maxlength="200" auto-height></textarea>
        </view>
      </view>

      <view class="form-row">
        <view class="form-field half-width">
          <view class="field-input-box">
            <u-icon name="red-packet-fill" size="16" color="#86909C"></u-icon>
            <input class="field-input" type="digit" v-model="form.annualPerformance" placeholder="年业绩(万)" placeholder-class="field-placeholder" />
          </view>
        </view>
        <view class="form-field half-width">
          <view class="field-input-box">
            <u-icon name="account-fill" size="16" color="#86909C"></u-icon>
            <input class="field-input" type="number" v-model="form.regularCustomers" placeholder="常来顾客数" placeholder-class="field-placeholder" />
          </view>
        </view>
      </view>

      <view class="form-field" @click="mode !== 'view' && (showUserPicker = true)">
        <view class="field-input-box">
          <u-icon name="man-add" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="selectedUsersText" placeholder="服务员工（可多选）" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
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

      <view class="form-field">
        <view class="field-textarea-box">
          <view class="textarea-prefix"><u-icon name="edit-pen" size="18" color="#86909C"></u-icon><text class="prefix-text">备注</text></view>
          <textarea class="field-textarea" v-model="form.remark" placeholder="请输入备注信息" placeholder-class="field-placeholder" :maxlength="500" auto-height></textarea>
        </view>
      </view>
    </view>

    <u-popup :show="showEnterprisePicker" mode="bottom" round="16" @close="showEnterprisePicker = false">
      <view class="picker-popup">
        <view class="picker-header">
          <text class="picker-title">选择企业</text>
          <view class="picker-close" @click="showEnterprisePicker = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <view class="picker-search">
          <u-icon name="search" size="14" color="#86909C"></u-icon>
          <input class="picker-search-input" v-model="enterpriseSearchKeyword" placeholder="搜索企业名称" placeholder-class="field-placeholder" confirm-type="search" @input="onEnterpriseSearchInput" @confirm="searchEnterpriseList" />
        </view>
        <scroll-view scroll-y class="picker-list">
          <view v-for="item in enterpriseSearchResults" :key="item.enterpriseId" class="picker-item" @click="onEnterpriseSelect(item)">
            <text class="picker-item-text">{{ item.enterpriseName }}</text>
          </view>
          <u-empty v-if="enterpriseSearchResults.length === 0 && enterpriseSearchKeyword" mode="search" text="未找到匹配企业" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <!-- 服务员工多选弹窗 -->
    <u-popup :show="showUserPicker" mode="bottom" round="16" @close="showUserPicker = false">
      <view class="picker-popup">
        <view class="picker-header">
          <text class="picker-title">选择服务员工</text>
          <view class="picker-close" @click="showUserPicker = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <view class="picker-search">
          <u-icon name="search" size="16" color="#86909C"></u-icon>
          <input class="picker-search-input" v-model="userSearchKeyword" placeholder="搜索员工姓名" placeholder-class="field-placeholder" @input="filterUserList" />
        </view>
        <scroll-view scroll-y class="picker-list">
          <view v-for="item in filteredUserList" :key="item.userId" class="picker-item" :class="{ 'picker-item-selected': isUserSelected(item.userId) }" @click="onUserToggle(item)">
            <view class="picker-item-content">
              <view class="picker-checkbox" :class="{ checked: isUserSelected(item.userId) }">
                <u-icon v-if="isUserSelected(item.userId)" name="checkmark" size="14" color="#fff"></u-icon>
              </view>
              <text class="picker-item-text">{{ item.nickName || item.userName }}</text>
            </view>
          </view>
          <u-empty v-if="filteredUserList.length === 0" mode="data" text="暂无员工数据" :marginTop="40"></u-empty>
        </scroll-view>
        <view class="picker-footer">
          <text class="picker-footer-text">已选 {{ selectedUsers.length }} 人</text>
          <view class="picker-footer-btn"><u-button type="primary" text="确认" size="small" @click="confirmUserSelect" :disabled="selectedUsers.length === 0"></u-button></view>
        </view>
      </view>
    </u-popup>

    <view class="form-actions" v-if="mode !== 'view'">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>
    <view class="form-actions" v-else>
      <u-button v-if="checkPermi('business:store:edit')" type="primary" plain text="编辑" @click="goEdit"></u-button>
      <u-button v-if="checkPermi('business:store:remove')" type="error" plain text="删除" @click="handleDelete"></u-button>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 门店表单页 - 新增/编辑/查看门店
 * @description 需先选择所属企业，包含门店名称、负责人、营业时间（拆分开始/结束）、
 * 微信号、常来顾客数等字段，提交时将开始/结束时间合并为businessHours
 */
import { ref, reactive, onMounted, computed } from 'vue'
import { getStore, addStore, updateStore, delStore } from '@/api/business/store'
import { searchEnterprise } from '@/api/business/enterprise'
import { listUser } from '@/api/system/user'
import { checkPermi } from '@/utils/permission'

const submitting = ref(false)
const showEnterprisePicker = ref(false)
const showUserPicker = ref(false)
const userSearchKeyword = ref('')
const userList = ref([])
const filteredUserList = ref([])
const selectedUsers = ref([])
/** 页面模式：add/edit/view */
const mode = ref('add')
const storeId = ref(null)
const enterpriseSearchKeyword = ref('')
const enterpriseSearchResults = ref([])

const form = reactive({
  storeId: undefined,
  enterpriseId: '',
  enterpriseName: '',
  storeName: '',
  managerName: '',
  phone: '',
  wechat: '',
  address: '',
  businessStart: '',
  businessEnd: '',
  annualPerformance: '',
  regularCustomers: '',
  serverUserId: '',
  serverUserName: '',
  status: '0',
  remark: ''
})

/** 企业选择确认，更新表单中的企业ID和名称 */
function onEnterpriseSelect(item) {
  form.enterpriseId = item.enterpriseId
  form.enterpriseName = item.enterpriseName
  showEnterprisePicker.value = false
}

const selectedUsersText = computed(() => {
  if (selectedUsers.value.length === 0) return ''
  const names = selectedUsers.value.map(u => u.userName)
  if (names.length <= 3) return names.join('、')
  return `${names.slice(0, 3).join('、')} 等${names.length}人`
})

function isUserSelected(userId) {
  return selectedUsers.value.some(u => u.userId === userId)
}

function onUserToggle(item) {
  const idx = selectedUsers.value.findIndex(u => u.userId === item.userId)
  if (idx >= 0) {
    selectedUsers.value.splice(idx, 1)
  } else {
    selectedUsers.value.push({ userId: item.userId, userName: item.nickName || item.userName })
  }
}

function confirmUserSelect() {
  showUserPicker.value = false
}

function filterUserList() {
  const keyword = userSearchKeyword.value.toLowerCase()
  filteredUserList.value = userList.value.filter(u => (u.nickName || u.userName || '').toLowerCase().includes(keyword))
}

async function loadUserList() {
  try {
    const response = await listUser({ pageNum: 1, pageSize: 1000, status: '0' })
    const data = response.data || response
    userList.value = data.rows || []
    filteredUserList.value = userList.value
  } catch (e) { console.error('加载员工列表失败:', e) }
}

let enterpriseSearchTimer = null

function onEnterpriseSearchInput() {
  if (enterpriseSearchTimer) clearTimeout(enterpriseSearchTimer)
  enterpriseSearchTimer = setTimeout(() => searchEnterpriseList(), 500)
}

async function searchEnterpriseList() {
  if (!enterpriseSearchKeyword.value) {
    enterpriseSearchResults.value = []
    return
  }
  try {
    const response = await searchEnterprise(enterpriseSearchKeyword.value)
    const data = response.data || response
    enterpriseSearchResults.value = Array.isArray(data) ? data : (data.rows || [])
  } catch (e) {
    console.error('搜索企业失败:', e)
    enterpriseSearchResults.value = []
  }
}

async function loadDetail() {
  if (!storeId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getStore(storeId.value)
    const data = response.data || response
    let businessStart = '', businessEnd = ''
    if (data.businessHours) {
      const times = data.businessHours.split(' - ')
      if (times.length === 2) { businessStart = times[0]; businessEnd = times[1] }
    }
    Object.assign(form, {
      storeId: data.storeId,
      enterpriseId: data.enterpriseId || '',
      enterpriseName: data.enterpriseName || '',
      storeName: data.storeName || '',
      managerName: data.managerName || '',
      phone: data.phone || '',
      wechat: data.wechat || '',
      address: data.address || '',
      businessStart,
      businessEnd,
      annualPerformance: data.annualPerformance ? String(data.annualPerformance) : '',
      regularCustomers: data.regularCustomers ? String(data.regularCustomers) : '',
      serverUserId: data.serverUserId || '',
      serverUserName: data.serverUserName || '',
      status: String(data.status ?? '0'),
      remark: data.remark || ''
    })
    if (data.serverUserId && typeof data.serverUserId === 'string') {
      const ids = data.serverUserId.split(',').map(id => parseInt(id))
      const names = data.serverUserName ? data.serverUserName.split('、') : []
      selectedUsers.value = ids.map((id, i) => ({ userId: id, userName: names[i] || '' }))
    } else {
      selectedUsers.value = []
    }
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

/** 提交门店表单，校验必填项后将开始/结束时间合并为businessHours，根据是否有ID区分新增和修改 */
async function submitForm() {
  if (!form.enterpriseId) { uni.showToast({ title: '请选择所属企业', icon: 'none' }); return }
  if (!form.storeName) { uni.showToast({ title: '请输入门店名称', icon: 'none' }); return }

  submitting.value = true
  try {
    const formData = {
      storeId: form.storeId || undefined,
      enterpriseId: form.enterpriseId,
      storeName: form.storeName,
      managerName: form.managerName || null,
      phone: form.phone || null,
      wechat: form.wechat || null,
      address: form.address || null,
      businessHours: (form.businessStart && form.businessEnd)
        ? `${form.businessStart} - ${form.businessEnd}` : null,
      annualPerformance: form.annualPerformance ? parseFloat(form.annualPerformance) : 0,
      regularCustomers: form.regularCustomers ? parseInt(form.regularCustomers) : 0,
      serverUserId: selectedUsers.value.map(u => u.userId),
      serverUserName: selectedUsers.value.map(u => u.userName),
      status: form.status,
      remark: form.remark || null
    }

    if (formData.storeId) {
      await updateStore(formData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      delete formData.storeId
      await addStore(formData)
      uni.showToast({ title: '新增成功', icon: 'success' })
    }
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('提交失败:', e)
    const msg = e?.msg || e?.message || '操作失败，请重试'
    uni.showToast({ title: msg, icon: 'none', duration: 2000 })
  } finally { submitting.value = false }
}

/** 删除门店，弹出确认框后调用删除接口，成功后返回列表页 */
function handleDelete() {
  if (!storeId.value) return
  uni.showModal({
    title: '提示', content: '确认删除该门店?',
    success: async (res) => {
      if (res.confirm) {
        try {
          await delStore(storeId.value)
          uni.showToast({ title: '删除成功', icon: 'success' })
          setTimeout(() => goBack(), 1500)
        } catch (e) { console.error('删除失败:', e) }
      }
    }
  })
}

function goEdit() { mode.value = 'edit'; uni.setNavigationBarTitle({ title: '编辑门店' }) }

function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.redirectTo({ url: '/pages/business/store/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const options = pages[pages.length - 1].options || {}
  mode.value = options.mode || 'add'
  storeId.value = options.id ? parseInt(options.id) : null

  loadUserList()
  if (mode.value === 'view') { uni.setNavigationBarTitle({ title: '门店详情' }); loadDetail() }
  else if (mode.value === 'edit') { uni.setNavigationBarTitle({ title: '编辑门店' }); loadDetail() }
  else { uni.setNavigationBarTitle({ title: '新增门店' }) }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }

.form-container { min-height: 100vh; padding-bottom: 140rpx; }

.form-section {
  margin: 24rpx;
  background: #fff;
  border-radius: 20rpx;
  padding: 32rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05);
}

.form-field { margin-bottom: 20rpx; &:last-child { margin-bottom: 0; } }

.field-input-box {
  display: flex;
  align-items: center;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 0 20rpx;
  height: 88rpx;
  gap: 16rpx;
  border: 2rpx solid transparent;
  transition: all 0.2s;

  &:active { background: #EFF0F1; }
}

.field-input {
  flex: 1;
  font-size: 30rpx;
  color: #1D2129;
  height: 88rpx;
  line-height: 88rpx;
}

.field-placeholder { color: #C9CDD4; font-size: 30rpx; }

.field-textarea-box {
  display: flex;
  flex-direction: column;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 16rpx 20rpx;
  gap: 8rpx;
  border: 2rpx solid transparent;
}

.textarea-prefix {
  display: flex;
  align-items: center;
  gap: 10rpx;
}

.prefix-text {
  font-size: 26rpx;
  color: #86909C;
  font-weight: 500;
}

.field-textarea {
  width: 100%;
  min-height: 120rpx;
  font-size: 28rpx;
  color: #1D2129;
  line-height: 1.6;
}

.form-row { display: flex; gap: 20rpx; }

.half-width { flex: 1; min-width: 0;

  .field-input-box { height: 80rpx; }
  .field-input { height: 80rpx; line-height: 80rpx; font-size: 28rpx; }
}

.status-field { margin-top: 8rpx; margin-bottom: 24rpx; }

.status-options {
  display: flex;
  gap: 48rpx;
  padding: 8rpx 4rpx;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 12rpx;
  font-size: 28rpx;
  color: #4E5969;

  &.active { color: #1D2129; font-weight: 500; }
  &.disabled { opacity: 0.5; }
}

.status-radio {
  width: 36rpx;
  height: 36rpx;
  border-radius: 50%;
  border: 3rpx solid #C9CDD4;
  transition: all 0.2s;

  &.checked {
    background: #3D6DF7;
    border-color: #3D6DF7;
    position: relative;

    &::after {
      content: '';
      position: absolute;
      top: 50%; left: 50%;
      transform: translate(-50%, -50%);
      width: 14rpx;
      height: 14rpx;
      border-radius: 50%;
      background: #fff;
    }
  }
}

.form-actions {
  position: fixed;
  left: 24rpx;
  right: 24rpx;
  bottom: 40rpx;
  display: flex;
  gap: 20rpx;
  z-index: 100;

  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}

.picker-popup { max-height: 70vh; display: flex; flex-direction: column; }
.picker-header { display: flex; justify-content: space-between; align-items: center; padding: 30rpx; border-bottom: 1rpx solid #F2F3F5; }
.picker-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.picker-close { padding: 8rpx; }
.picker-search { display: flex; align-items: center; gap: 12rpx; margin: 20rpx 30rpx; padding: 0 20rpx; height: 72rpx; background: #F5F7FA; border-radius: 36rpx; }
.picker-search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; }
.picker-list { flex: 1; padding: 0 30rpx; max-height: 50vh; }
.picker-item { display: flex; justify-content: space-between; align-items: center; padding: 28rpx 0; border-bottom: 1rpx solid #F2F3F5;
  &:last-child { border-bottom: none; }
  &:active { background: #F5F7FA; }
}
.picker-item-selected {
  background: #F5F7FA;
}
.picker-item-content {
  display: flex;
  align-items: center;
  gap: 16rpx;
}
.picker-checkbox {
  width: 36rpx;
  height: 36rpx;
  border-radius: 6rpx;
  border: 2rpx solid #C9CDD4;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all 0.2s;

  &.checked {
    background: #3D6DF7;
    border-color: #3D6DF7;
  }
}
.picker-item-text { font-size: 28rpx; color: #1D2129; }
.picker-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 32rpx;
  border-top: 1rpx solid #F2F3F5;
  background: #fff;
}
.picker-footer-text {
  font-size: 26rpx;
  color: #86909C;
  white-space: nowrap;
  flex-shrink: 0;
}
.picker-footer-btn {
  flex-shrink: 0;
  width: auto;
}
</style>
