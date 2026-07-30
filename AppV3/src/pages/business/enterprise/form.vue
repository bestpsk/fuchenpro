<template>
  <view class="form-container">
    <view class="form-section">
      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="home-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.enterpriseName" placeholder="* 企业名称" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="account" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.bossName" placeholder="* 老板姓名" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="phone" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="number" v-model="form.phone" placeholder="* 联系电话" placeholder-class="field-placeholder" maxlength="11" />
        </view>
      </view>

      <view class="form-field" @click="showTypePicker = mode !== 'view'">
        <view class="field-input-box">
          <u-icon name="grid" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.typeName" placeholder="* 企业类型" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
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
            <u-icon name="grid" size="16" color="#86909C"></u-icon>
            <input class="field-input" type="number" v-model.number="form.storeCount" placeholder="门店数" placeholder-class="field-placeholder" />
          </view>
        </view>
        <view class="form-field half-width">
          <view class="field-input-box">
            <u-icon name="red-packet-fill" size="16" color="#86909C"></u-icon>
            <input class="field-input" type="digit" v-model="form.annualPerformance" placeholder="年业绩(万)" placeholder-class="field-placeholder" />
          </view>
        </view>
      </view>

      <view class="form-field" @click="showLevelPicker = mode !== 'view'">
        <view class="field-input-box">
          <u-icon name="star-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.levelName" placeholder="* 企业级别" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="mode !== 'view' && (showUserPicker = true)">
        <view class="field-input-box">
          <u-icon name="man-add" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="selectedUsersText" placeholder="服务人（可多选）" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field status-field">
        <view class="status-options">
          <view
            class="status-item"
            :class="{ active: form.contractStatus === '0', disabled: mode === 'view' }"
            @click="mode !== 'view' && (form.contractStatus = '0')"
          >
            <view class="status-radio" :class="{ checked: form.contractStatus === '0' }"></view>
            <text>未签约</text>
          </view>
          <view
            class="status-item"
            :class="{ active: form.contractStatus === '1', disabled: mode === 'view' }"
            @click="mode !== 'view' && (form.contractStatus = '1')"
          >
            <view class="status-radio" :class="{ checked: form.contractStatus === '1' }"></view>
            <text>已签约</text>
          </view>
        </view>
      </view>

      <view class="form-field" @click="mode !== 'view' && openStartDatePicker()">
        <view class="field-input-box">
          <u-icon name="calendar" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.cooperationStartDate" placeholder="开始合作日期" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="mode !== 'view' && openEndDatePicker()">
        <view class="field-input-box">
          <u-icon name="calendar" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.cooperationEndDate" placeholder="结束合作日期" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" v-if="form.contractStatus === '1' || form.contractFiles">
        <view class="upload-section">
          <view class="upload-header">
            <u-icon name="file-text" size="18" color="#86909C"></u-icon>
            <text class="upload-title">合同文件</text>
          </view>
          <view class="upload-grid" v-if="mode !== 'view'">
            <view v-for="(file, idx) in contractFileList" :key="idx" class="upload-image-item">
              <image :src="getFilePreviewUrl(file)" class="preview-image" mode="aspectFill" @click="previewContractFile(file)" />
              <view class="delete-btn" @click.stop="removeContractFile(idx)">
                <u-icon name="close" size="10" color="#fff"></u-icon>
              </view>
            </view>
            <view class="upload-add-btn" @click="chooseContractFile" v-if="contractFileList.length < 10">
              <u-icon name="plus" size="24" color="#86909C"></u-icon>
            </view>
          </view>
          <view class="upload-grid" v-else>
            <view v-for="(file, idx) in contractFileList" :key="idx" class="upload-image-item" @click="previewContractFile(file)">
              <image :src="getFilePreviewUrl(file)" class="preview-image" mode="aspectFill" />
            </view>
          </view>
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

    <u-picker
      :show="showTypePicker"
      :columns="[typeColumns]"
      keyName="label"
      title="选择企业类型"
      @confirm="onTypeConfirm"
      @cancel="showTypePicker = false"
      @close="showTypePicker = false"
    ></u-picker>

    <u-picker
      :show="showLevelPicker"
      :columns="[levelColumns]"
      keyName="label"
      title="选择企业级别"
      @confirm="onLevelConfirm"
      @cancel="showLevelPicker = false"
      @close="showLevelPicker = false"
    ></u-picker>

    <u-datetime-picker
      :show="showStartDatePicker"
      mode="date"
      v-model="startDatePickerModel"
      @confirm="onStartDateConfirm"
      @cancel="showStartDatePicker = false"
      @close="showStartDatePicker = false"
    ></u-datetime-picker>

    <u-datetime-picker
      :show="showEndDatePicker"
      mode="date"
      v-model="endDatePickerModel"
      @confirm="onEndDateConfirm"
      @cancel="showEndDatePicker = false"
      @close="showEndDatePicker = false"
    ></u-datetime-picker>

    <!-- 服务人多选弹窗 -->
    <u-popup :show="showUserPicker" mode="bottom" round="16" @close="showUserPicker = false">
      <view class="picker-popup">
        <view class="picker-header">
          <text class="picker-title">选择服务人</text>
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
      <u-button v-if="checkPermi('business:enterprise:edit')" type="primary" plain text="编辑" @click="goEdit"></u-button>
      <u-button v-if="checkPermi('business:enterprise:remove')" type="error" plain text="删除" @click="handleDelete"></u-button>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 企业表单页 - 新增/编辑/查看企业
 * @description 支持三种模式（add/edit/view），包含企业名称、老板、手机号（格式校验）、
 * 企业类型/级别选择、年业绩等字段，提交时区分新增和修改
 */
import { ref, reactive, computed, onMounted } from 'vue'
import { getEnterprise, addEnterprise, updateEnterprise, delEnterprise } from '@/api/business/enterprise'
import { listUser } from '@/api/system/user'
import { checkPermi } from '@/utils/permission'
import upload from '@/utils/upload'
import config from '@/config'

const submitting = ref(false)
const showTypePicker = ref(false)
const showLevelPicker = ref(false)
const showStartDatePicker = ref(false)
const showEndDatePicker = ref(false)
const showUserPicker = ref(false)
const userSearchKeyword = ref('')
const userList = ref([])
const filteredUserList = ref([])
const selectedUsers = ref([])
const contractFileList = ref([])
/** 页面模式：add/edit/view */
const mode = ref('add')
const enterpriseId = ref(null)

const form = reactive({
  enterpriseId: undefined,
  enterpriseName: '',
  bossName: '',
  phone: '',
  address: '',
  enterpriseType: '',
  typeName: '',
  storeCount: '',
  annualPerformance: '',
  enterpriseLevel: '',
  levelName: '',
  serverUserId: '',
  serverUserName: '',
  contractStatus: '0',
  contractFiles: '',
  cooperationStartDate: '',
  cooperationEndDate: '',
  status: '0',
  remark: ''
})

const typeColumns = ref([
  { label: '直营店', value: '1' },
  { label: '加盟店', value: '2' },
  { label: '合作店', value: '3' }
])

const levelColumns = ref([
  { label: 'A级', value: '1' },
  { label: 'B级', value: '2' },
  { label: 'C级', value: '3' },
  { label: 'D级', value: '4' }
])

const startDatePickerModel = ref(Date.now())
const endDatePickerModel = ref(Date.now())

function openStartDatePicker() {
  startDatePickerModel.value = form.cooperationStartDate ? new Date(form.cooperationStartDate).getTime() : Date.now()
  showStartDatePicker.value = true
}

function openEndDatePicker() {
  endDatePickerModel.value = form.cooperationEndDate ? new Date(form.cooperationEndDate).getTime() : Date.now()
  showEndDatePicker.value = true
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

/** 企业类型选择确认，更新表单中的类型编码和名称 */
function onTypeConfirm(e) {
  const item = e.value[0]
  form.enterpriseType = item.value
  form.typeName = item.label
  showTypePicker.value = false
}

/** 企业级别选择确认，更新表单中的级别编码和名称 */
function onLevelConfirm(e) {
  const item = e.value[0]
  form.enterpriseLevel = item.value
  form.levelName = item.label
  showLevelPicker.value = false
}

// 选择并上传合同文件
function chooseContractFile() {
  uni.chooseImage({
    count: 10 - contractFileList.value.length,
    extension: ['.jpg', '.jpeg', '.png'],
    success: async (res) => {
      for (const path of res.tempFilePaths) {
        try {
          uni.showLoading({ title: '上传中...' })
          const uploadRes = await upload({ url: '/common/upload', filePath: path, name: 'file' })
          if (uploadRes.code === 200) {
            contractFileList.value.push({
              name: uploadRes.originalFilename || uploadRes.newFileName,
              url: uploadRes.url || uploadRes.fileName,
              tempUrl: path
            })
            form.contractFiles = contractFileList.value.map(f => f.url).join(',')
          }
        } catch (e) {
          uni.showToast({ title: '上传失败', icon: 'none' })
        } finally { uni.hideLoading() }
      }
    }
  })
}

function getFilePreviewUrl(file) {
  if (file.tempUrl) return file.tempUrl
  if (!file.url) return ''
  // 已经是完整 URL（以 http 开头）
  if (/^https?:\/\//.test(file.url)) return file.url
  // 本地相对路径，拼接完整访问路径
  const baseUrl = config.baseUrl.replace(/\/$/, '')
  const filePath = file.url.startsWith('/profile/upload/') ? file.url : '/profile/upload/' + file.url
  return baseUrl + filePath
}

function removeContractFile(idx) {
  contractFileList.value.splice(idx, 1)
  form.contractFiles = contractFileList.value.map(f => f.url).join(',')
}

function previewContractFile(file) {
  const url = getFilePreviewUrl(file)
  if (!url) return
  // #ifdef H5
  window.open(url, '_blank')
  // #endif
  // #ifndef H5
  uni.downloadFile({
    url: url,
    success: (res) => { uni.openDocument({ filePath: res.tempFilePath }) }
  })
  // #endif
}

/** 加载企业详情数据并填充到表单，用于编辑和查看模式 */
async function loadDetail() {
  if (!enterpriseId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getEnterprise(enterpriseId.value)
    const data = response.data || response
    Object.assign(form, {
      enterpriseId: data.enterpriseId,
      enterpriseName: data.enterpriseName || '',
      bossName: data.bossName || '',
      phone: data.phone || '',
      address: data.address || '',
      enterpriseType: String(data.enterpriseType || ''),
      typeName: getTypeName(data.enterpriseType),
      storeCount: data.storeCount ? String(data.storeCount) : '',
      annualPerformance: data.annualPerformance ? String(data.annualPerformance) : '',
      enterpriseLevel: String(data.enterpriseLevel || ''),
      levelName: getLevelName(data.enterpriseLevel),
      serverUserId: data.serverUserId || '',
      serverUserName: data.serverUserName || '',
      contractStatus: String(data.contractStatus ?? '0'),
      contractFiles: data.contractFiles || '',
      cooperationStartDate: isValidDate(data.cooperationStartDate) ? data.cooperationStartDate : '',
      cooperationEndDate: isValidDate(data.cooperationEndDate) ? data.cooperationEndDate : '',
      status: String(data.status ?? '0'),
      remark: data.remark || ''
    })
    if (data.contractFiles) {
      contractFileList.value = data.contractFiles.split(',').map((url, idx) => ({
        name: url.split('/').pop() || '合同' + (idx + 1),
        url: url
      }))
    } else {
      contractFileList.value = []
    }
    if (form.serverUserId && typeof form.serverUserId === 'string') {
      const ids = form.serverUserId.split(',').map(id => parseInt(id))
      const names = form.serverUserName ? form.serverUserName.split('、') : []
      selectedUsers.value = ids.map((id, i) => ({ userId: id, userName: names[i] || '' }))
    } else {
      selectedUsers.value = []
    }
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

function getTypeName(value) {
  if (value === null || value === undefined) return ''
  const item = typeColumns.value.find(t => t.value === String(value))
  return item ? item.label : ''
}

function getLevelName(value) {
  if (value === null || value === undefined) return ''
  const item = levelColumns.value.find(l => l.value === String(value))
  return item ? item.label : ''
}

function isValidDate(str) {
  if (!str || str === '0000-00-00') return false
  const d = new Date(str)
  return !isNaN(d.getTime())
}

function formatDate(value) {
  if (!value) return ''
  let d
  if (value instanceof Date) {
    d = value
  } else if (typeof value === 'number' || /^\d+$/.test(String(value))) {
    d = new Date(Number(value))
  } else {
    d = new Date(value)
  }
  if (isNaN(d.getTime())) return ''
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

function onStartDateConfirm(e) {
  form.cooperationStartDate = formatDate(e.value)
  showStartDatePicker.value = false
}

function onEndDateConfirm(e) {
  form.cooperationEndDate = formatDate(e.value)
  showEndDatePicker.value = false
}

/** 提交企业表单，校验必填项和手机号格式后，根据是否有ID区分新增和修改 */
async function submitForm() {
  if (!form.enterpriseName) { uni.showToast({ title: '请输入企业名称', icon: 'none' }); return }
  if (!form.bossName) { uni.showToast({ title: '请输入老板姓名', icon: 'none' }); return }
  if (!form.phone) { uni.showToast({ title: '请输入联系电话', icon: 'none' }); return }
  if (!/^1[3-9]\d{9}$/.test(form.phone)) { uni.showToast({ title: '手机号格式不正确', icon: 'none' }); return }
  if (!form.enterpriseType) { uni.showToast({ title: '请选择企业类型', icon: 'none' }); return }
  if (!form.enterpriseLevel) { uni.showToast({ title: '请选择企业级别', icon: 'none' }); return }

  submitting.value = true
  try {
    const formData = {
      enterpriseId: form.enterpriseId || undefined,
      enterpriseName: form.enterpriseName,
      bossName: form.bossName,
      phone: form.phone,
      address: form.address || null,
      enterpriseType: form.enterpriseType,
      storeCount: form.storeCount ? parseInt(form.storeCount) : 0,
      annualPerformance: form.annualPerformance ? parseFloat(form.annualPerformance) : 0,
      enterpriseLevel: form.enterpriseLevel,
      serverUserId: selectedUsers.value.map(u => u.userId),
      serverUserName: selectedUsers.value.map(u => u.userName),
      contractStatus: form.contractStatus,
      contractFiles: form.contractFiles || null,
      cooperationStartDate: form.cooperationStartDate || null,
      cooperationEndDate: form.cooperationEndDate || null,
      status: form.status,
      remark: form.remark || null
    }

    if (formData.enterpriseId) {
      await updateEnterprise(formData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      delete formData.enterpriseId
      await addEnterprise(formData)
      uni.showToast({ title: '新增成功', icon: 'success' })
    }
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('提交失败:', e)
    const msg = e?.msg || e?.message || '操作失败，请重试'
    uni.showToast({ title: msg, icon: 'none', duration: 2000 })
  } finally { submitting.value = false }
}

/** 删除企业，弹出确认框后调用删除接口，成功后返回列表页 */
function handleDelete() {
  if (!enterpriseId.value) return
  uni.showModal({
    title: '提示',
    content: '确认删除该企业数据?',
    success: async (res) => {
      if (res.confirm) {
        try {
          await delEnterprise(enterpriseId.value)
          uni.showToast({ title: '删除成功', icon: 'success' })
          setTimeout(() => goBack(), 1500)
        } catch (e) { console.error('删除失败:', e) }
      }
    }
  })
}

function goEdit() { mode.value = 'edit'; uni.setNavigationBarTitle({ title: '编辑企业' }) }

function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.redirectTo({ url: '/pages/business/enterprise/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  mode.value = options.mode || 'add'
  enterpriseId.value = options.id ? parseInt(options.id) : null

  loadUserList()

  if (mode.value === 'view') { uni.setNavigationBarTitle({ title: '企业详情' }); loadDetail() }
  else if (mode.value === 'edit') { uni.setNavigationBarTitle({ title: '编辑企业' }); loadDetail() }
  else { uni.setNavigationBarTitle({ title: '新增企业' }) }
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

.picker-popup {
  background: #fff;
  border-radius: 24rpx 24rpx 0 0;
  max-height: 70vh;
  display: flex;
  flex-direction: column;
}

.picker-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28rpx 32rpx;
  border-bottom: 1rpx solid #F2F3F5;
}

.picker-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #1D2129;
}

.picker-close { padding: 8rpx; }

.picker-search {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin: 20rpx 32rpx;
  padding: 0 20rpx;
  background: #F7F8FA;
  border-radius: 36rpx;
  height: 72rpx;
}

.picker-search-input {
  flex: 1;
  font-size: 28rpx;
  color: #1D2129;
  height: 72rpx;
}

.picker-list {
  flex: 1;
  padding: 0 32rpx 32rpx;
  max-height: 50vh;
}

.picker-item {
  padding: 24rpx 0;
  border-bottom: 1rpx solid #F2F3F5;

  &:last-child { border-bottom: none; }
  &:active { background: #F7F8FA; }
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

.picker-item-text {
  font-size: 28rpx;
  color: #1D2129;
}

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

.upload-section {
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 16rpx 20rpx;
}

.upload-header {
  display: flex;
  align-items: center;
  gap: 8rpx;
  margin-bottom: 16rpx;
}

.upload-title {
  font-size: 26rpx;
  color: #86909C;
  font-weight: 500;
}

.upload-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.upload-image-item {
  position: relative;
  width: 160rpx;
  height: 160rpx;
  border-radius: 8rpx;
  overflow: hidden;
  border: 2rpx solid #E5E6EB;

  .preview-image {
    width: 100%;
    height: 100%;
  }

  .delete-btn {
    position: absolute;
    top: 4rpx;
    right: 4rpx;
    width: 32rpx;
    height: 32rpx;
    border-radius: 50%;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
  }
}

.upload-add-btn {
  width: 160rpx;
  height: 160rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2rpx dashed #C9CDD4;
  border-radius: 8rpx;
  background: #FAFAFA;
}

.clickable { cursor: pointer; }
</style>
