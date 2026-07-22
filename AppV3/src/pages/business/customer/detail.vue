<template>
  <view class="form-container">
    <view class="avatar-section">
      <view @click="chooseAvatar">
        <u-avatar v-if="avatarPreview" :src="avatarPreview" size="80" mode="aspectFill" />
        <u-avatar v-else :text="form.customerName ? form.customerName.charAt(0) : '客'" size="80" :bg-color="form.gender === '1' ? '#FF6B9D' : '#3D6DF7'" color="#fff" fontSize="36" />
      </view>
      <view class="avatar-hint" @click="chooseAvatar">
        <u-icon name="camera" size="16" color="#86909C"></u-icon>
        <text>点击更换头像</text>
      </view>
    </view>

    <view class="form-section">
      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="account" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.customerName" placeholder="* 客户姓名" placeholder-class="field-placeholder" />
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
        <view class="form-field half-width" @click="showGenderPicker = true">
          <view class="field-input-box">
            <u-icon name="man" size="18" color="#86909C"></u-icon>
            <input class="field-input" :value="genderLabel" placeholder="性别" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
            <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>
        <view class="form-field half-width">
          <view class="field-input-box">
            <u-icon name="calendar" size="18" color="#86909C"></u-icon>
            <input class="field-input" type="number" v-model.number="form.age" placeholder="年龄" placeholder-class="field-placeholder" />
          </view>
        </view>
      </view>

      <view class="form-field">
        <view class="field-label"><u-icon name="tags" size="18" color="#86909C"></u-icon><text class="label-text">客户标签</text></view>
        <view class="tag-selector">
          <view class="tag-option" v-for="d in customerTagDict" :key="d.value" :class="{ active: form.tag.includes(d.value) }" @click="toggleTag(d.value)">{{ d.label }}</view>
        </view>
      </view>

      <view class="form-field">
        <view class="field-textarea-box">
          <view class="textarea-prefix"><u-icon name="edit-pen" size="18" color="#86909C"></u-icon><text class="prefix-text">备注</text></view>
          <textarea class="field-textarea" v-model="form.remark" placeholder="请输入备注信息" placeholder-class="field-placeholder" :maxlength="200" auto-height></textarea>
        </view>
      </view>
    </view>

    <u-picker
      :show="showGenderPicker"
      :columns="[genderOptions]"
      keyName="label"
      title="选择性别"
      @confirm="onGenderConfirm"
      @cancel="showGenderPicker = false"
      @close="showGenderPicker = false"
    ></u-picker>

    <view class="form-actions">
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getCustomer, addCustomer, updateCustomer } from '@/api/business/customer'
import { getDicts } from '@/api/system/dictData'
import config from '@/config'

const submitting = ref(false)
const showGenderPicker = ref(false)
const customerId = ref(null)
const avatarPreview = ref('')
const avatarTempFile = ref('')

const form = reactive({
  customerName: '',
  phone: '',
  wechat: '',
  gender: '1',
  age: null,
  tag: [],
  remark: ''
})

const genderOptions = [
  { label: '女', value: '1' },
  { label: '男', value: '0' }
]

const genderLabel = computed(() => {
  const item = genderOptions.find(g => g.value === form.gender)
  return item ? item.label : ''
})

const customerTagDict = ref([])

async function loadCustomerTagDict() {
  try {
    const res = await getDicts('biz_customer_tag')
    customerTagDict.value = (res.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
  } catch (e) {
    console.error(e)
  }
}

function toggleTag(value) {
  const idx = form.tag.indexOf(value)
  if (idx === -1) {
    form.tag.push(value)
  } else {
    form.tag.splice(idx, 1)
  }
}

function onGenderConfirm(e) {
  form.gender = e.value[0].value
  showGenderPicker.value = false
}

function getAvatarUrl(avatar) {
  if (!avatar) return ''
  if (avatar.startsWith('http://') || avatar.startsWith('https://')) return avatar
  return config.baseUrl + avatar
}

async function loadDetail() {
  if (!customerId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getCustomer(customerId.value)
    const data = response.data || response
    Object.assign(form, {
      customerName: data.customerName || data.customer_name || '',
      phone: data.phone || '',
      wechat: data.wechat || '',
      gender: String(data.gender ?? '1'),
      age: data.age || null,
      tag: data.tag ? data.tag.split(',') : [],
      remark: data.remark || ''
    })
    const avatar = data.avatar || ''
    avatarPreview.value = getAvatarUrl(avatar)
  } catch (e) {
    console.error('加载客户详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

function chooseAvatar() {
  uni.chooseImage({
    count: 1,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera'],
    success: (res) => {
      avatarTempFile.value = res.tempFilePaths[0]
      avatarPreview.value = res.tempFilePaths[0]
    }
  })
}

async function uploadAvatar() {
  if (!avatarTempFile.value || !customerId.value) return
  const baseUrl = '/prod-api'
  const token = uni.getStorageSync('App-Token')
  return new Promise((resolve) => {
    uni.uploadFile({
      url: baseUrl + '/business/customer/avatar',
      filePath: avatarTempFile.value,
      name: 'avatarfile',
      formData: { customer_id: customerId.value },
      header: { 'Authorization': 'Bearer ' + token },
      success: (res) => {
        try {
          const data = JSON.parse(res.data)
          resolve(data.code === 200 ? data : null)
        } catch { resolve(null) }
      },
      fail: () => resolve(null)
    })
  })
}

async function submitForm() {
  if (!form.customerName.trim()) {
    uni.showToast({ title: '请输入客户姓名', icon: 'none' })
    return
  }

  if (form.phone && !/^1[3-9]\d{9}$/.test(form.phone)) {
    uni.showToast({ title: '手机号格式不正确', icon: 'none' })
    return
  }

  submitting.value = true
  try {
    const data = {
      customerId: customerId.value,
      customerName: form.customerName.trim(),
      phone: form.phone || null,
      wechat: form.wechat || null,
      gender: form.gender,
      age: form.age || null,
      tag: form.tag.length > 0 ? form.tag.join(',') : null,
      remark: form.remark || null
    }

    if (customerId.value) {
      await updateCustomer(data)
    } else {
      await addCustomer(data)
    }

    if (avatarTempFile.value) {
      await uploadAvatar()
    }

    uni.showToast({ title: '保存成功', icon: 'success' })
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('保存失败:', e)
    uni.showToast({ title: '保存失败', icon: 'none' })
  } finally {
    submitting.value = false
  }
}

function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.redirectTo({ url: '/pages/business/customer/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  customerId.value = options.customerId ? parseInt(options.customerId) : null

  loadCustomerTagDict()

  if (customerId.value) {
    uni.setNavigationBarTitle({ title: '客户信息' })
    loadDetail()
  } else {
    uni.setNavigationBarTitle({ title: '新增客户' })
  }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }

.form-container { min-height: 100vh; padding-bottom: 140rpx; }

.avatar-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 40rpx 0 20rpx;
  gap: 12rpx;
}

.avatar-hint {
  display: flex;
  align-items: center;
  gap: 6rpx;
  font-size: 24rpx;
  color: #86909C;
}

.form-section {
  margin: 24rpx;
  background: #fff;
  border-radius: 20rpx;
  padding: 32rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05);
}

.form-field { margin-bottom: 20rpx; &:last-child { margin-bottom: 0; } }

.form-row { display: flex; gap: 20rpx; }
.half-width { flex: 1; }

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

.field-label {
  display: flex;
  align-items: center;
  gap: 10rpx;
  margin-bottom: 12rpx;
}

.label-text {
  font-size: 28rpx;
  color: #86909C;
  font-weight: 500;
}

.tag-selector {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.tag-option {
  font-size: 26rpx;
  padding: 10rpx 24rpx;
  border-radius: 8rpx;
  background: #F2F3F5;
  color: #86909C;
}

.tag-option.active {
  background: #E8F3FF;
  color: #165DFF;
}

.field-textarea-box {
  display: flex;
  flex-direction: column;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 16rpx 20rpx;
  gap: 8rpx;
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
  font-size: 30rpx;
  color: #1D2129;
  min-height: 80rpx;
  width: 100%;
  box-sizing: border-box;
}

.form-actions {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 20rpx 32rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  background: #fff;
  box-shadow: 0 -4rpx 16rpx rgba(0, 0, 0, 0.06);
  display: flex;
  gap: 20rpx;
}
</style>
