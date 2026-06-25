<template>
  <view class="form-container">
    <view class="form-section">
      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="account" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.applicantName" placeholder="申请人" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="list" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.deptName" placeholder="所属部门" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
        </view>
      </view>

      <view class="form-field" @click="mode !== 'view' && (showDatePicker = true)">
        <view class="field-input-box">
          <u-icon name="calendar" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.applyDate" placeholder="* 申请日期" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="mode !== 'view' && (showCategoryPicker = true)">
        <view class="field-input-box">
          <u-icon name="grid" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="categoryName" placeholder="* 分类" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-row">
        <view class="form-field half-width">
          <view class="field-input-box">
            <u-icon name="rmb-circle" size="16" color="#86909C"></u-icon>
            <input class="field-input" type="digit" v-model="form.expenseAmount" placeholder="* 支出金额" placeholder-class="field-placeholder" :disabled="mode === 'view'" :disabledColor="'#fff'" />
          </view>
        </view>
        <view class="form-field half-width">
          <view class="field-input-box">
            <u-icon name="red-packet-fill" size="16" color="#86909C"></u-icon>
            <input class="field-input" type="digit" v-model="form.incomeAmount" placeholder="收入金额" placeholder-class="field-placeholder" :disabled="mode === 'view'" :disabledColor="'#fff'" />
          </view>
        </view>
      </view>

      <view class="form-field" @click="mode !== 'view' && (showExpenseTypePicker = true)">
        <view class="field-input-box">
          <u-icon name="tags" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="expenseTypeName" placeholder="* 支出类型" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" v-if="mode !== 'view'">
        <view class="field-upload-box">
          <view class="upload-label">
            <u-icon name="camera" size="18" color="#86909C"></u-icon>
            <text class="label-text">凭证图片</text>
          </view>
          <view class="upload-area">
            <view class="image-list">
              <view v-for="(img, idx) in imageList" :key="idx" class="image-item">
                <image :src="getFullUrl(img.url)" class="preview-img" mode="aspectFill" @click="previewImage(idx)"></image>
                <view class="remove-btn" @click="removeImage(idx)">
                  <u-icon name="close" size="12" color="#fff"></u-icon>
                </view>
              </view>
              <view class="add-image" @click="chooseImage" v-if="imageList.length < 9">
                <u-icon name="plus" size="24" color="#C9CDD4"></u-icon>
              </view>
            </view>
          </view>
        </view>
      </view>

      <view class="form-field" v-else-if="imageList.length > 0">
        <view class="field-upload-box">
          <view class="upload-label">
            <u-icon name="camera" size="18" color="#86909C"></u-icon>
            <text class="label-text">凭证图片</text>
          </view>
          <view class="upload-area">
            <view class="image-list">
              <view v-for="(img, idx) in imageList" :key="idx" class="image-item">
                <image :src="getFullUrl(img.url)" class="preview-img" mode="aspectFill" @click="previewImage(idx)"></image>
              </view>
            </view>
          </view>
        </view>
      </view>

      <view class="form-field">
        <view class="field-textarea-box">
          <view class="textarea-prefix"><u-icon name="edit-pen" size="18" color="#86909C"></u-icon><text class="prefix-text">备注</text></view>
          <textarea class="field-textarea" v-model="form.remark" placeholder="请输入备注信息" placeholder-class="field-placeholder" :maxlength="500" auto-height :disabled="mode === 'view'"></textarea>
        </view>
      </view>
    </view>

    <u-datetime-picker
      :show="showDatePicker"
      mode="date"
      v-model="datePickerValue"
      @confirm="onDateConfirm"
      @cancel="showDatePicker = false"
      @close="showDatePicker = false"
    ></u-datetime-picker>

    <u-picker
      :show="showCategoryPicker"
      :columns="[categoryColumns]"
      keyName="label"
      title="选择分类"
      @confirm="onCategoryConfirm"
      @cancel="showCategoryPicker = false"
      @close="showCategoryPicker = false"
    ></u-picker>

    <u-picker
      :show="showExpenseTypePicker"
      :columns="[expenseTypeColumns]"
      keyName="label"
      title="选择支出类型"
      @confirm="onExpenseTypeConfirm"
      @cancel="showExpenseTypePicker = false"
      @close="showExpenseTypePicker = false"
    ></u-picker>

    <view class="form-actions" v-if="mode !== 'view'">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>

    <view class="form-actions" v-else>
      <u-button type="primary" plain text="编辑" @click="goEdit"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getReimbursement, addReimbursement, updateReimbursement } from '@/api/finance/reimbursement'
import { getDicts } from '@/api/system/dictData'
import { useUserStore } from '@/store/modules/user'
import upload from '@/utils/upload'
import config from '@/config'

const baseUrl = config.baseUrl
const userStore = useUserStore()

const submitting = ref(false)
const showDatePicker = ref(false)
const showCategoryPicker = ref(false)
const showExpenseTypePicker = ref(false)
const mode = ref('add')
const reimbursementId = ref(null)
const datePickerValue = ref(new Date().getTime())

const categoryColumns = ref([])
const expenseTypeColumns = ref([])
const categoryName = ref('')
const expenseTypeName = ref('')
const imageList = ref([])

const form = reactive({
  reimbursementId: undefined,
  applicantName: '',
  deptName: '',
  applyDate: '',
  category: '4',
  expenseAmount: '',
  incomeAmount: '',
  expenseType: '1',
  voucherImages: '',
  remark: ''
})

function getFullUrl(url) {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return baseUrl + url
}

function parseImages(jsonStr) {
  if (!jsonStr) return []
  try {
    const parsed = JSON.parse(jsonStr)
    if (Array.isArray(parsed)) {
      return parsed.filter(url => url && typeof url === 'string').map(url => ({ url }))
    }
    return []
  } catch (e) {
    if (typeof jsonStr === 'string' && (jsonStr.startsWith('http') || jsonStr.startsWith('/'))) {
      return [{ url: jsonStr }]
    }
    return []
  }
}

async function loadDictData() {
  try {
    const [catRes, expRes] = await Promise.all([
      getDicts('fin_reimbursement_category'),
      getDicts('fin_reimbursement_expense_type')
    ])
    categoryColumns.value = (catRes.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
    expenseTypeColumns.value = (expRes.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
  } catch (e) {
    console.error('加载字典数据失败:', e)
  }
}

function getCategoryName(value) {
  if (!value) return ''
  const item = categoryColumns.value.find(t => t.value === String(value))
  return item ? item.label : ''
}

function getExpenseTypeName(value) {
  if (!value) return ''
  const item = expenseTypeColumns.value.find(t => t.value === String(value))
  return item ? item.label : ''
}

function onDateConfirm(e) {
  const d = new Date(Number(e.value))
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  form.applyDate = `${y}-${m}-${day}`
  showDatePicker.value = false
}

function onCategoryConfirm(e) {
  const item = e.value[0]
  form.category = item.value
  categoryName.value = item.label
  showCategoryPicker.value = false
}

function onExpenseTypeConfirm(e) {
  const item = e.value[0]
  form.expenseType = item.value
  expenseTypeName.value = item.label
  showExpenseTypePicker.value = false
}

function chooseImage() {
  const remaining = 9 - imageList.value.length
  if (remaining <= 0) return
  uni.chooseImage({
    count: remaining,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera'],
    success: async (res) => {
      for (const tempPath of res.tempFilePaths) {
        try {
          const uploadRes = await upload({ url: '/common/upload', name: 'file', filePath: tempPath })
          const url = uploadRes.url || uploadRes.fileName
          imageList.value.push({ url })
        } catch (err) {
          console.error('上传失败:', err)
          uni.showToast({ title: '图片上传失败', icon: 'none' })
        }
      }
    }
  })
}

function removeImage(idx) {
  imageList.value.splice(idx, 1)
}

function previewImage(idx) {
  const urls = imageList.value.map(img => getFullUrl(img.url))
  uni.previewImage({
    current: idx,
    urls: urls
  })
}

async function loadDetail() {
  if (!reimbursementId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getReimbursement(reimbursementId.value)
    const data = response.data || response
    Object.assign(form, {
      reimbursementId: data.reimbursementId,
      applicantName: data.applicantName || '',
      deptName: data.deptName || '',
      applyDate: data.applyDate || '',
      category: String(data.category || ''),
      expenseAmount: data.expenseAmount != null ? String(data.expenseAmount) : '',
      incomeAmount: data.incomeAmount != null ? String(data.incomeAmount) : '',
      expenseType: String(data.expenseType || ''),
      voucherImages: data.voucherImages || '',
      remark: data.remark || ''
    })
    categoryName.value = getCategoryName(data.category)
    expenseTypeName.value = getExpenseTypeName(data.expenseType)
    imageList.value = parseImages(data.voucherImages)
    if (data.applyDate) {
      datePickerValue.value = new Date(data.applyDate).getTime()
    }
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

async function submitForm() {
  if (!form.applyDate) { uni.showToast({ title: '请选择申请日期', icon: 'none' }); return }
  if (!form.category) { uni.showToast({ title: '请选择分类', icon: 'none' }); return }
  if (!form.expenseAmount && form.expenseAmount !== '0') { uni.showToast({ title: '请输入支出金额', icon: 'none' }); return }
  if (!form.expenseType) { uni.showToast({ title: '请选择支出类型', icon: 'none' }); return }

  submitting.value = true
  try {
    const voucherUrls = imageList.value.map(img => img.url).filter(url => url)
    const formData = {
      reimbursementId: form.reimbursementId || undefined,
      applicantName: form.applicantName,
      deptName: form.deptName,
      applyDate: form.applyDate,
      category: form.category,
      expenseAmount: parseFloat(form.expenseAmount) || 0,
      incomeAmount: parseFloat(form.incomeAmount) || 0,
      expenseType: form.expenseType,
      voucherImages: voucherUrls.length > 0 ? JSON.stringify(voucherUrls) : '',
      remark: form.remark || null
    }

    if (formData.reimbursementId) {
      await updateReimbursement(formData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      delete formData.reimbursementId
      await addReimbursement(formData)
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

function goEdit() {
  mode.value = 'edit'
  uni.setNavigationBarTitle({ title: '编辑报销' })
}

function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.redirectTo({ url: '/pages/finance/reimbursement/index' })
}

onLoad((options) => {
  mode.value = options.mode || 'add'
  reimbursementId.value = options.id ? parseInt(options.id) : null
  if (reimbursementId.value && mode.value !== 'add') {
    loadDetail()
  }
})

onMounted(async () => {
  await loadDictData()

  // 自动填充当前用户信息
  form.applicantName = userStore.nickName || userStore.name || ''
  form.deptName = userStore.deptName || ''

  if (mode.value === 'add') {
    const now = new Date()
    const y = now.getFullYear()
    const m = String(now.getMonth() + 1).padStart(2, '0')
    const d = String(now.getDate()).padStart(2, '0')
    form.applyDate = `${y}-${m}-${d}`
    uni.setNavigationBarTitle({ title: '新增报销' })
  } else if (mode.value === 'edit') {
    uni.setNavigationBarTitle({ title: '编辑报销' })
  } else {
    uni.setNavigationBarTitle({ title: '报销详情' })
  }
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

.half-width {
  flex: 1;
  min-width: 0;

  .field-input-box { height: 80rpx; }
  .field-input { height: 80rpx; line-height: 80rpx; font-size: 28rpx; }
}

// 图片上传
.field-upload-box {
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 20rpx;
}

.upload-label {
  display: flex;
  align-items: center;
  gap: 10rpx;
  margin-bottom: 16rpx;
}

.label-text {
  font-size: 26rpx;
  color: #86909C;
  font-weight: 500;
}

.upload-area {
  width: 100%;
}

.image-list {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.image-item {
  position: relative;
  width: 160rpx;
  height: 160rpx;
}

.preview-img {
  width: 160rpx;
  height: 160rpx;
  border-radius: 12rpx;
}

.remove-btn {
  position: absolute;
  top: -8rpx;
  right: -8rpx;
  width: 36rpx;
  height: 36rpx;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}

.add-image {
  width: 160rpx;
  height: 160rpx;
  border-radius: 12rpx;
  border: 2rpx dashed #C9CDD4;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
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
</style>
