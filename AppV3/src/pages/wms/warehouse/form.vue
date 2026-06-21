<template>
  <view class="form-container">
    <view class="form-section">
      <view class="form-field">
        <view class="field-label"><text class="required">*</text> 仓库名称</view>
        <view class="field-input-box">
          <input class="field-input" type="text" v-model="form.warehouseName" placeholder="请输入仓库名称" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-label"><text class="required">*</text> 仓库编码</view>
        <view class="field-input-box">
          <input class="field-input" type="text" v-model="form.warehouseCode" placeholder="请输入仓库编码" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-row">
        <view class="form-field half">
          <view class="field-label">联系人</view>
          <view class="field-input-box">
            <input class="field-input" type="text" v-model="form.contactPerson" placeholder="请输入联系人" placeholder-class="field-placeholder" />
          </view>
        </view>
        <view class="form-field half">
          <view class="field-label">联系电话</view>
          <view class="field-input-box">
            <input class="field-input" type="number" v-model="form.contactPhone" placeholder="请输入联系电话" placeholder-class="field-placeholder" maxlength="11" />
          </view>
        </view>
      </view>

      <view class="form-field">
        <view class="field-label">地址</view>
        <view class="field-input-box">
          <input class="field-input" type="text" v-model="form.address" placeholder="请输入地址" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-label">状态</view>
        <view class="field-input-box switch-field">
          <u-switch v-model="form.status" activeValue="0" inactiveValue="1" activeColor="#3D6DF7" size="22"></u-switch>
          <text class="switch-text">{{ form.status === '0' ? '正常' : '停用' }}</text>
        </view>
      </view>

      <view class="form-field">
        <view class="field-label">备注</view>
        <view class="field-textarea-box">
          <textarea class="field-textarea" v-model="form.remark" placeholder="请输入备注信息" placeholder-class="field-placeholder" :maxlength="500" auto-height></textarea>
        </view>
      </view>
    </view>

    <view class="form-actions">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getWarehouse, addWarehouse, updateWarehouse } from '@/api/wms/warehouse'

const submitting = ref(false)
const mode = ref('add')
const warehouseId = ref(null)

const form = reactive({
  warehouseId: undefined,
  warehouseName: '',
  warehouseCode: '',
  address: '',
  contactPerson: '',
  contactPhone: '',
  status: '0',
  remark: ''
})

async function loadDetail() {
  if (!warehouseId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getWarehouse(warehouseId.value)
    const data = response.data || response
    Object.assign(form, {
      warehouseId: data.warehouseId,
      warehouseName: data.warehouseName || '',
      warehouseCode: data.warehouseCode || '',
      address: data.address || '',
      contactPerson: data.contactPerson || '',
      contactPhone: data.contactPhone || '',
      status: data.status || '0',
      remark: data.remark || ''
    })
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

async function submitForm() {
  if (!form.warehouseName.trim()) { uni.showToast({ title: '请输入仓库名称', icon: 'none' }); return }
  if (!form.warehouseCode.trim()) { uni.showToast({ title: '请输入仓库编码', icon: 'none' }); return }
  if (form.contactPhone && !/^1[3-9]\d{9}$/.test(form.contactPhone)) { uni.showToast({ title: '请输入正确的手机号', icon: 'none' }); return }

  submitting.value = true
  try {
    const formData = {
      warehouseName: form.warehouseName.trim(),
      warehouseCode: form.warehouseCode.trim(),
      address: form.address.trim() || null,
      contactPerson: form.contactPerson.trim() || null,
      contactPhone: form.contactPhone.trim() || null,
      status: form.status,
      remark: form.remark.trim() || null
    }

    if (form.warehouseId) {
      formData.warehouseId = form.warehouseId
      await updateWarehouse(formData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      await addWarehouse(formData)
      uni.showToast({ title: '新增成功', icon: 'success' })
    }
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('提交失败:', e)
    const msg = e?.msg || e?.message || '操作失败，请重试'
    uni.showToast({ title: msg, icon: 'none', duration: 2000 })
  } finally { submitting.value = false }
}

function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.redirectTo({ url: '/pages/wms/warehouse/index' })
}

onLoad((options) => {
  mode.value = options?.mode || 'add'
  warehouseId.value = options?.id ? parseInt(options.id) : null

  if (mode.value === 'add') {
    uni.setNavigationBarTitle({ title: '新增仓库' })
  } else if (mode.value === 'edit') {
    uni.setNavigationBarTitle({ title: '编辑仓库' })
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
  &.switch-field { background: transparent; padding: 0; height: auto; gap: 16rpx; }
}
.field-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 84rpx; line-height: 84rpx; background: transparent; }
.field-placeholder { color: #C9CDD4; font-size: 28rpx; }

.switch-text { font-size: 28rpx; color: #1D2129; }

.field-textarea-box { background: #F7F8FA; border-radius: 12rpx; padding: 20rpx 24rpx; }
.field-textarea { width: 100%; min-height: 120rpx; font-size: 28rpx; color: #1D2129; line-height: 1.6; background: transparent; }

.form-row { display: flex; gap: 24rpx; }
.half { flex: 1; min-width: 0; }

.form-actions { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; display: flex; gap: 20rpx; z-index: 100;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
