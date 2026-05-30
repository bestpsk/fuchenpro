<template>
  <view class="form-container">
    <view class="form-section">
      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="chat" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.wechat" placeholder="微信号" placeholder-class="field-placeholder" maxlength="50" />
        </view>
      </view>

      <view class="form-field" @click="showBirthdayPicker = true">
        <view class="field-input-box">
          <u-icon name="calendar" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.birthday" placeholder="生日" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field">
        <view class="field-input-box">
          <u-icon name="file-text-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" type="text" v-model="form.idCard" placeholder="身份证号" placeholder-class="field-placeholder" maxlength="18" />
        </view>
      </view>

      <view class="form-field" @click="showHireDatePicker = true">
        <view class="field-input-box">
          <u-icon name="calendar-fill" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.hireDate" placeholder="入职日期" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field" @click="showEmploymentPicker = true">
        <view class="field-input-box">
          <u-icon name="account" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="employmentName" placeholder="在职状态" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view v-if="form.employmentStatus === '1'" class="form-field" @click="showResignDatePicker = true">
        <view class="field-input-box">
          <u-icon name="calendar" size="18" color="#86909C"></u-icon>
          <input class="field-input" :value="form.resignDate" placeholder="离职日期" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field">
        <view class="field-textarea-box">
          <view class="textarea-prefix"><u-icon name="map" size="18" color="#86909C"></u-icon><text class="prefix-text">住址</text></view>
          <textarea class="field-textarea" v-model="form.address" placeholder="请输入住址" placeholder-class="field-placeholder" :maxlength="200" auto-height></textarea>
        </view>
      </view>

      <view class="form-field">
        <view class="field-textarea-box">
          <view class="textarea-prefix"><u-icon name="edit-pen" size="18" color="#86909C"></u-icon><text class="prefix-text">备注</text></view>
          <textarea class="field-textarea" v-model="form.remark" placeholder="请输入备注" placeholder-class="field-placeholder" :maxlength="500" auto-height></textarea>
        </view>
      </view>
    </view>

    <u-datetime-picker
      :show="showBirthdayPicker"
      v-model="birthdayPickerValue"
      mode="date"
      title="选择生日"
      @confirm="onBirthdayConfirm"
      @cancel="showBirthdayPicker = false"
      @close="showBirthdayPicker = false"
    ></u-datetime-picker>

    <u-datetime-picker
      :show="showHireDatePicker"
      v-model="hireDatePickerValue"
      mode="date"
      title="选择入职日期"
      @confirm="onHireDateConfirm"
      @cancel="showHireDatePicker = false"
      @close="showHireDatePicker = false"
    ></u-datetime-picker>

    <u-datetime-picker
      :show="showResignDatePicker"
      v-model="resignDatePickerValue"
      mode="date"
      title="选择离职日期"
      @confirm="onResignDateConfirm"
      @cancel="showResignDatePicker = false"
      @close="showResignDatePicker = false"
    ></u-datetime-picker>

    <u-picker
      :show="showEmploymentPicker"
      :columns="[employmentColumns]"
      keyName="label"
      title="选择在职状态"
      @confirm="onEmploymentConfirm"
      @cancel="showEmploymentPicker = false"
      @close="showEmploymentPicker = false"
    ></u-picker>

    <view class="form-actions">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getUserDetail, addUserDetail, updateUserDetail } from '@/api/system/user'

const submitting = ref(false)
const showBirthdayPicker = ref(false)
const showHireDatePicker = ref(false)
const showResignDatePicker = ref(false)
const showEmploymentPicker = ref(false)
const userId = ref(null)

const birthdayPickerValue = ref(Date.now())
const hireDatePickerValue = ref(Date.now())
const resignDatePickerValue = ref(Date.now())

const form = reactive({
  detailId: null,
  userId: null,
  wechat: '',
  birthday: '',
  idCard: '',
  hireDate: '',
  employmentStatus: '0',
  resignDate: '',
  address: '',
  remark: ''
})

const employmentColumns = ref([
  { label: '在职', value: '0' },
  { label: '离职', value: '1' }
])

const employmentName = computed(() => {
  const item = employmentColumns.value.find(e => e.value === form.employmentStatus)
  return item ? item.label : ''
})

function formatDate(timestamp) {
  const date = new Date(timestamp)
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

function onBirthdayConfirm(e) {
  form.birthday = formatDate(e.value)
  showBirthdayPicker.value = false
}

function onHireDateConfirm(e) {
  form.hireDate = formatDate(e.value)
  showHireDatePicker.value = false
}

function onResignDateConfirm(e) {
  form.resignDate = formatDate(e.value)
  showResignDatePicker.value = false
}

function onEmploymentConfirm(e) {
  const item = e.value[0]
  form.employmentStatus = item.value
  if (item.value === '0') {
    form.resignDate = ''
  }
  showEmploymentPicker.value = false
}

async function loadDetail() {
  if (!userId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const res = await getUserDetail(userId.value)
    if (res.data) {
      Object.assign(form, {
        detailId: res.data.detailId,
        userId: res.data.userId,
        wechat: res.data.wechat || '',
        birthday: res.data.birthday || '',
        idCard: res.data.idCard || '',
        hireDate: res.data.hireDate || '',
        employmentStatus: res.data.employmentStatus || '0',
        resignDate: res.data.resignDate || '',
        address: res.data.address || '',
        remark: res.data.remark || ''
      })
    }
  } catch (e) {
    console.error('加载员工详情失败:', e)
  } finally {
    uni.hideLoading()
  }
}

async function submitForm() {
  if (form.idCard && !/^[1-9]\d{5}(18|19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dXx]$/.test(form.idCard)) {
    uni.showToast({ title: '身份证号格式不正确', icon: 'none' })
    return
  }

  submitting.value = true
  try {
    const data = { ...form, userId: userId.value }
    if (form.detailId) {
      await updateUserDetail(data)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      await addUserDetail(data)
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
  else uni.redirectTo({ url: '/pages/system/user/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  userId.value = options.userId ? parseInt(options.userId) : null
  form.userId = userId.value
  if (userId.value) {
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

.form-actions {
  position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx;
  display: flex; gap: 20rpx; z-index: 100;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
