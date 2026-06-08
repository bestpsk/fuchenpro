<template>
  <view class="form-container">
    <view class="form-section">
      <view class="form-field">
        <view class="field-label"><text class="required">*</text> 供货商名称</view>
        <view class="field-input-box">
          <input class="field-input" type="text" v-model="form.supplierName" placeholder="请输入供货商名称" placeholder-class="field-placeholder" :disabled="mode === 'view'" />
        </view>
      </view>

      <view class="form-row">
        <view class="form-field half">
          <view class="field-label">联系人</view>
          <view class="field-input-box">
            <input class="field-input" type="text" v-model="form.contactPerson" placeholder="请输入联系人" placeholder-class="field-placeholder" :disabled="mode === 'view'" />
          </view>
        </view>
        <view class="form-field half">
          <view class="field-label">联系电话</view>
          <view class="field-input-box">
            <input class="field-input" type="number" v-model="form.contactPhone" placeholder="请输入联系电话" placeholder-class="field-placeholder" :disabled="mode === 'view'" maxlength="11" />
          </view>
        </view>
      </view>

      <view class="form-field">
        <view class="field-label">地址</view>
        <view class="field-input-box">
          <input class="field-input" type="text" v-model="form.address" placeholder="请输入地址" placeholder-class="field-placeholder" :disabled="mode === 'view'" />
        </view>
      </view>

      <view class="form-row">
        <view class="form-field half" @click="mode !== 'view' && (showDatePicker = true)">
          <view class="field-label">合作起始日期</view>
          <view class="field-input-box picker-field">
            <input class="field-input" :value="form.cooperationStartDate" placeholder="请选择日期" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
            <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>
        <view class="form-field half">
          <view class="field-label">状态</view>
          <view class="field-input-box radio-field" v-if="mode !== 'view'">
            <view class="radio-group">
              <view class="radio-item" :class="{ active: form.status === '0' }" @click="form.status = '0'">
                <view class="radio-dot"></view>
                <text>正常</text>
              </view>
              <view class="radio-item" :class="{ active: form.status === '1' }" @click="form.status = '1'">
                <view class="radio-dot"></view>
                <text>停用</text>
              </view>
            </view>
          </view>
          <view class="field-input-box" v-else>
            <input class="field-input" :value="form.status === '0' ? '正常' : '停用'" disabled :disabledColor="'transparent'" />
          </view>
        </view>
      </view>

      <view class="form-field">
        <view class="field-label">备注</view>
        <view class="field-textarea-box">
          <textarea class="field-textarea" v-model="form.remark" placeholder="请输入备注信息" placeholder-class="field-placeholder" :maxlength="500" auto-height :disabled="mode === 'view'"></textarea>
        </view>
      </view>
    </view>

    <u-datetime-picker :show="showDatePicker" mode="date" @confirm="onDateConfirm" @cancel="showDatePicker = false" @close="showDatePicker = false"></u-datetime-picker>

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
import { getSupplier, addSupplier, updateSupplier } from '@/api/wms/supplier'
import { checkPermi } from '@/utils/permission'

const submitting = ref(false)
const mode = ref('add')
const supplierId = ref(null)
const showDatePicker = ref(false)

const form = reactive({
  supplierId: undefined,
  supplierName: '',
  contactPerson: '',
  contactPhone: '',
  address: '',
  cooperationStartDate: '',
  status: '0',
  remark: ''
})

async function loadDetail() {
  if (!supplierId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getSupplier(supplierId.value)
    const data = response.data || response
    Object.assign(form, {
      supplierId: data.supplierId,
      supplierName: data.supplierName || '',
      contactPerson: data.contactPerson || '',
      contactPhone: data.contactPhone || '',
      address: data.address || '',
      cooperationStartDate: data.cooperationStartDate || '',
      status: data.status || '0',
      remark: data.remark || ''
    })
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

function onDateConfirm(e) {
  const date = new Date(e.value)
  form.cooperationStartDate = date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0')
  showDatePicker.value = false
}

async function submitForm() {
  if (!form.supplierName.trim()) { uni.showToast({ title: '请输入供货商名称', icon: 'none' }); return }
  if (form.contactPhone && !/^1[3-9]\d{9}$/.test(form.contactPhone)) { uni.showToast({ title: '请输入正确的手机号', icon: 'none' }); return }

  submitting.value = true
  try {
    const formData = {
      supplierName: form.supplierName.trim(),
      contactPerson: form.contactPerson.trim() || null,
      contactPhone: form.contactPhone.trim() || null,
      address: form.address.trim() || null,
      cooperationStartDate: form.cooperationStartDate || null,
      status: form.status,
      remark: form.remark.trim() || null
    }

    if (form.supplierId) {
      formData.supplierId = form.supplierId
      await updateSupplier(formData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      await addSupplier(formData)
      uni.showToast({ title: '新增成功', icon: 'success' })
    }
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('提交失败:', e)
    const msg = e?.msg || e?.message || '操作失败，请重试'
    uni.showToast({ title: msg, icon: 'none', duration: 2000 })
  } finally { submitting.value = false }
}

function goEdit() { mode.value = 'edit'; uni.setNavigationBarTitle({ title: '编辑供货商' }) }

function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.redirectTo({ url: '/pages/wms/supplier/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  mode.value = options.mode || 'add'
  supplierId.value = options.id ? parseInt(options.id) : null

  // 权限检查
  if (mode.value === 'add' && !checkPermi('wms:supplier:add')) {
    uni.showToast({ title: '无新增权限', icon: 'none' })
    setTimeout(() => {
      const pages = getCurrentPages()
      if (pages.length > 1) uni.navigateBack()
      else uni.redirectTo({ url: '/pages/wms/supplier/index' })
    }, 1500)
    return
  }
  if ((mode.value === 'edit' || mode.value === 'view') && !checkPermi('wms:supplier:edit')) {
    uni.showToast({ title: '无编辑权限', icon: 'none' })
    setTimeout(() => {
      const pages = getCurrentPages()
      if (pages.length > 1) uni.navigateBack()
      else uni.redirectTo({ url: '/pages/wms/supplier/index' })
    }, 1500)
    return
  }

  if (mode.value === 'add') {
    uni.setNavigationBarTitle({ title: '新增供货商' })
  } else if (mode.value === 'edit') {
    uni.setNavigationBarTitle({ title: '编辑供货商' })
    loadDetail()
  } else {
    uni.setNavigationBarTitle({ title: '供货商详情' })
    loadDetail()
  }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.form-container { min-height: 100vh; padding-bottom: 140rpx; }

.form-section { margin: 24rpx; background: #fff; border-radius: 20rpx; padding: 32rpx; }

.form-field { margin-bottom: 28rpx; &:last-child { margin-bottom: 0; } }
.field-label { font-size: 26rpx; color: #4E5969; font-weight: 500; margin-bottom: 12rpx;
  .required { color: #F53F3F; margin-right: 4rpx; }
}
.field-input-box { display: flex; align-items: center; background: #F7F8FA; border-radius: 12rpx; padding: 0 24rpx; height: 84rpx; gap: 12rpx; transition: background 0.2s;
  &:focus-within { background: #EFF0F1; }
  &.picker-field { cursor: pointer; }
  &.radio-field { background: transparent; padding: 0; height: auto; }
}
.field-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 84rpx; line-height: 84rpx; background: transparent; }
.field-placeholder { color: #C9CDD4; font-size: 28rpx; }

.field-textarea-box { background: #F7F8FA; border-radius: 12rpx; padding: 20rpx 24rpx; }
.field-textarea { width: 100%; min-height: 120rpx; font-size: 28rpx; color: #1D2129; line-height: 1.6; background: transparent; }

.form-row { display: flex; gap: 24rpx; }
.half { flex: 1; min-width: 0; }

.radio-group { display: flex; gap: 40rpx; padding: 8rpx 0; }
.radio-item { display: flex; align-items: center; gap: 10rpx; font-size: 28rpx; color: #86909C; transition: color 0.2s;
  &.active { color: #1D2129; }
}
.radio-dot { width: 32rpx; height: 32rpx; border-radius: 50%; border: 4rpx solid #C9CDD4; position: relative; transition: border-color 0.2s;
  .radio-item.active & { border-color: #3D6DF7;
    &::after { content: ''; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 16rpx; height: 16rpx; border-radius: 50%; background: #3D6DF7; }
  }
}

.form-actions { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; display: flex; gap: 20rpx; z-index: 100;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
