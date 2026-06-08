<template>
  <view class="form-container">
    <view class="form-section">
      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="setting" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.configName" placeholder="* 参数名称" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="file-text" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.configKey" placeholder="* 参数键名" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-textarea-box">
          <view class="textarea-prefix"><u-icon name="edit-pen" size="18" color="#86909C"></u-icon><text class="prefix-text">* 参数键值</text></view>
          <textarea class="field-textarea" v-model="form.configValue" placeholder="请输入参数键值" placeholder-class="field-placeholder" :maxlength="500" auto-height></textarea>
        </view>
      </view>

      <view class="form-field status-field">
        <view class="status-label">
          <u-icon name="checkbox-mark" size="18" color="#86909C"></u-icon>
          <text class="label-text">系统内置</text>
        </view>
        <view class="status-options">
          <view
            v-for="dict in configTypeOptions"
            :key="dict.dictValue"
            class="status-item"
            :class="{ active: form.configType === dict.dictValue }"
            @click="form.configType = dict.dictValue"
          >
            <view class="status-radio" :class="{ checked: form.configType === dict.dictValue }"></view>
            <text>{{ dict.dictLabel }}</text>
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
import { getConfig, addConfig, updateConfig } from '@/api/system/config'
import { getDicts } from '@/api/system/dictData'

const submitting = ref(false)
const mode = ref('add')
const configId = ref(null)
const configTypeOptions = ref([])

const form = reactive({
  configId: undefined,
  configName: '',
  configKey: '',
  configValue: '',
  configType: 'Y',
  remark: ''
})

async function loadDetail() {
  if (!configId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const res = await getConfig(configId.value)
    const data = res.data || {}
    Object.assign(form, {
      configId: data.configId,
      configName: data.configName || '',
      configKey: data.configKey || '',
      configValue: data.configValue || '',
      configType: String(data.configType ?? 'Y'),
      remark: data.remark || ''
    })
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

async function loadDicts() {
  try {
    const res = await getDicts('sys_yes_no')
    configTypeOptions.value = res.data || []
  } catch (e) {
    console.error('获取字典失败:', e)
  }
}

async function submitForm() {
  if (!form.configName) { uni.showToast({ title: '请输入参数名称', icon: 'none' }); return }
  if (!form.configKey) { uni.showToast({ title: '请输入参数键名', icon: 'none' }); return }
  if (!form.configValue) { uni.showToast({ title: '请输入参数键值', icon: 'none' }); return }

  submitting.value = true
  try {
    const formData = { ...form }
    if (formData.configId) {
      await updateConfig(formData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      delete formData.configId
      await addConfig(formData)
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
  else uni.redirectTo({ url: '/pages/system/config/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  mode.value = options.mode || 'add'
  configId.value = options.id ? parseInt(options.id) : null

  loadDicts()

  if (mode.value === 'add') {
    uni.setNavigationBarTitle({ title: '新增参数' })
  } else if (mode.value === 'edit') {
    uni.setNavigationBarTitle({ title: '编辑参数' })
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
.status-label { display: flex; align-items: center; gap: 10rpx; margin-bottom: 16rpx; }
.label-text { font-size: 28rpx; color: #86909C; font-weight: 500; }
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
