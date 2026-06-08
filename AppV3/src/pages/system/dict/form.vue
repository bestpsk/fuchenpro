<template>
  <view class="form-container">
    <view class="form-section">
      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="list" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.dictName" placeholder="* 字典名称" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="file-text" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.dictType" placeholder="* 字典类型" placeholder-class="field-placeholder" :disabled="mode === 'edit'" :disabledColor="'#F7F8FA'" />
        </view>
      </view>

      <view class="form-field status-field">
        <view class="status-options">
          <view
            class="status-item"
            :class="{ active: form.status === '0' }"
            @click="form.status = '0'"
          >
            <view class="status-radio" :class="{ checked: form.status === '0' }"></view>
            <text>正常</text>
          </view>
          <view
            class="status-item"
            :class="{ active: form.status === '1' }"
            @click="form.status = '1'"
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

    <view class="form-actions">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getType, addType, updateType } from '@/api/system/dictType'
import { getDicts } from '@/api/system/dictData'

const submitting = ref(false)
const mode = ref('add')
const dictId = ref(null)

const form = reactive({
  dictId: undefined,
  dictName: '',
  dictType: '',
  status: '0',
  remark: ''
})

async function loadDetail() {
  if (!dictId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const res = await getType(dictId.value)
    const data = res.data || {}
    Object.assign(form, {
      dictId: data.dictId,
      dictName: data.dictName || '',
      dictType: data.dictType || '',
      status: String(data.status ?? '0'),
      remark: data.remark || ''
    })
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

async function submitForm() {
  if (!form.dictName) { uni.showToast({ title: '请输入字典名称', icon: 'none' }); return }
  if (!form.dictType) { uni.showToast({ title: '请输入字典类型', icon: 'none' }); return }

  submitting.value = true
  try {
    if (form.dictId) {
      await updateType({ ...form })
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      const formData = { ...form }
      delete formData.dictId
      await addType(formData)
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
  else uni.redirectTo({ url: '/pages/system/dict/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  mode.value = options.mode || 'add'
  dictId.value = options.id ? parseInt(options.id) : null

  if (mode.value === 'add') {
    uni.setNavigationBarTitle({ title: '新增字典类型' })
  } else if (mode.value === 'edit') {
    uni.setNavigationBarTitle({ title: '编辑字典类型' })
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

.form-actions {
  position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx;
  display: flex; gap: 20rpx; z-index: 100;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
