<template>
  <view class="visit-page">
    <!-- 加载态 -->
    <view v-if="loading" class="loading-wrap">
      <u-loading-icon mode="circle" size="48" color="#3D6DF7"></u-loading-icon>
      <text class="loading-text">问卷加载中...</text>
    </view>

    <!-- 错误态（token无效/已填写/已过期） -->
    <view v-else-if="loadError" class="error-wrap">
      <view class="error-card">
        <view class="error-icon">
          <u-icon name="info-circle-fill" size="80" color="#FF7D00"></u-icon>
        </view>
        <text class="error-title">{{ loadError }}</text>
        <text class="error-tip">如有疑问，请联系服务人员</text>
      </view>
    </view>

    <!-- 提交成功态 -->
    <view v-else-if="submitted" class="success-wrap">
      <view class="success-card">
        <view class="success-icon">
          <u-icon name="checkmark-circle-fill" size="96" color="#00B42A"></u-icon>
        </view>
        <text class="success-title">提交成功</text>
        <text class="success-tip">感谢您的反馈，我们会持续提升服务质量</text>
      </view>
    </view>

    <!-- 问卷主体 -->
    <block v-else>
      <!-- 企业信息头 -->
      <view class="hero">
        <view class="hero-title">{{ formData.enterpriseName || '满意度回访' }}</view>
        <view v-if="formData.templateName" class="hero-sub">{{ formData.templateName }}</view>
        <view v-if="formData.description" class="hero-desc">{{ formData.description }}</view>
      </view>

      <!-- 题目列表 -->
      <view class="question-list">
        <view v-for="(item, idx) in formData.items" :key="item.itemId" class="q-card">
          <view class="q-title">
            <text class="q-index">{{ idx + 1 }}</text>
            <text class="q-text">{{ item.questionTitle }}</text>
            <text v-if="item.required === '0'" class="q-required">*</text>
          </view>

          <!-- 单选题 -->
          <view v-if="item.questionType === '1'" class="q-options">
            <view
              v-for="opt in item.options"
              :key="opt"
              class="opt-item"
              :class="{ active: answers[item.itemId] === opt }"
              @click="answers[item.itemId] = opt"
            >
              <view class="opt-radio">
                <view v-if="answers[item.itemId] === opt" class="opt-radio-inner"></view>
              </view>
              <text class="opt-text">{{ opt }}</text>
            </view>
          </view>

          <!-- 多选题 -->
          <view v-else-if="item.questionType === '2'" class="q-options">
            <view
              v-for="opt in item.options"
              :key="opt"
              class="opt-item"
              :class="{ active: (answers[item.itemId] || []).includes(opt) }"
              @click="toggleMulti(item.itemId, opt)"
            >
              <view class="opt-check">
                <u-icon v-if="(answers[item.itemId] || []).includes(opt)" name="checkmark" size="24" color="#FFFFFF"></u-icon>
              </view>
              <text class="opt-text">{{ opt }}</text>
            </view>
          </view>

          <!-- 评分题 1-5星 -->
          <view v-else-if="item.questionType === '3'" class="q-rate">
            <view
              v-for="star in 5"
              :key="star"
              class="rate-star"
              :class="{ active: (answers[item.itemId] || 0) >= star }"
              @click="answers[item.itemId] = star"
            >
              <u-icon
                :name="(answers[item.itemId] || 0) >= star ? 'star-fill' : 'star'"
                size="56"
                :color="(answers[item.itemId] || 0) >= star ? '#FF7D00' : '#C9CDD4'"
              ></u-icon>
              <text class="rate-label">{{ rateLabels[star - 1] }}</text>
            </view>
          </view>

          <!-- 文本题 -->
          <view v-else class="q-textarea-wrap">
            <textarea
              class="q-textarea"
              v-model="answers[item.itemId]"
              placeholder="请输入您的意见或建议"
              :maxlength="500"
              auto-height
              placeholder-class="q-placeholder"
            />
            <text class="q-char-count">{{ (answers[item.itemId] || '').length }}/500</text>
          </view>
        </view>
      </view>

      <!-- 联系信息（选填） -->
      <view class="contact-card">
        <view class="contact-title">
          <u-icon name="file-text" size="32" color="#3D6DF7"></u-icon>
          <text class="contact-title-text">联系信息（选填）</text>
        </view>
        <view class="contact-form">
          <view class="contact-item">
            <text class="contact-label">姓名</text>
            <input class="contact-input" v-model="contact.name" placeholder="便于我们与您回访" placeholder-class="q-placeholder" />
          </view>
          <view class="contact-item">
            <text class="contact-label">手机</text>
            <input class="contact-input" v-model="contact.phone" type="number" maxlength="11" placeholder="便于我们与您联系" placeholder-class="q-placeholder" />
          </view>
        </view>
      </view>

      <!-- 提交按钮 -->
      <view class="submit-bar">
        <u-button
          type="primary"
          text="提交问卷"
          @click="submit"
          :loading="submitting"
          :customStyle="submitBtnStyle"
        ></u-button>
      </view>
    </block>
  </view>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getPublicVisitForm, submitPublicVisitForm } from '@/api/business/visit'

const loading = ref(true)
const loadError = ref('')
const submitted = ref(false)
const submitting = ref(false)

const token = ref('')
const visitId = ref(0)
const formData = reactive({
  enterpriseName: '',
  templateName: '',
  description: '',
  items: []
})

const answers = reactive({})
const contact = reactive({
  name: '',
  phone: ''
})

const rateLabels = ['很不满意', '不满意', '一般', '满意', '很满意']

const submitBtnStyle = {
  width: '100%',
  height: '96rpx',
  borderRadius: '48rpx',
  fontSize: '32rpx',
  fontWeight: '600',
  background: 'linear-gradient(135deg, #3D6DF7 0%, #5B8FF9 100%)',
  border: 'none'
}

// 多选题切换
function toggleMulti(itemId, opt) {
  const arr = answers[itemId] || []
  const idx = arr.indexOf(opt)
  if (idx === -1) {
    arr.push(opt)
  } else {
    arr.splice(idx, 1)
  }
  answers[itemId] = [...arr]
}

// 初始化答案结构
function initAnswers() {
  formData.items.forEach(item => {
    if (item.questionType === '2') {
      answers[item.itemId] = []
    } else if (item.questionType === '3') {
      answers[item.itemId] = 0
    } else {
      answers[item.itemId] = ''
    }
  })
}

// 加载问卷
async function loadForm() {
  if (!token.value) {
    loadError.value = '缺少回访凭证，请通过服务人员发送的链接访问'
    loading.value = false
    return
  }
  try {
    const res = await getPublicVisitForm(token.value)
    const data = res.data || res
    visitId.value = data.visitId
    formData.enterpriseName = data.enterpriseName || ''
    formData.templateName = data.templateName || ''
    formData.description = data.description || ''
    formData.items = data.items || []
    contact.name = data.contactName || ''
    contact.phone = data.contactPhone || ''
    initAnswers()
  } catch (e) {
    loadError.value = e?.msg || e?.message || '问卷加载失败'
  } finally {
    loading.value = false
  }
}

// 提交校验
function validate() {
  for (const item of formData.items) {
    if (item.required !== '0') continue
    const val = answers[item.itemId]
    const empty = item.questionType === '2'
      ? !val || val.length === 0
      : item.questionType === '3'
        ? !val || val === 0
        : !val || String(val).trim() === ''
    if (empty) {
      uni.showToast({ title: `请完成第${formData.items.indexOf(item) + 1}题：${item.questionTitle}`, icon: 'none' })
      return false
    }
  }
  return true
}

// 构建提交答案载荷（snake_case，与后端一致）
function buildPayload() {
  return formData.items.map(item => {
    const val = answers[item.itemId]
    if (item.questionType === '4') {
      return {
        item_id: item.itemId,
        answer_value: '',
        answer_text: String(val || '').trim()
      }
    }
    if (item.questionType === '2') {
      return {
        item_id: item.itemId,
        answer_value: (val || []).join(','),
        answer_text: ''
      }
    }
    return {
      item_id: item.itemId,
      answer_value: String(val ?? ''),
      answer_text: ''
    }
  }).filter(a => a.answer_value !== '' || a.answer_text !== '')
}

async function submit() {
  if (!validate()) return
  submitting.value = true
  try {
    await submitPublicVisitForm({
      token: token.value,
      answers: buildPayload(),
      contactName: contact.name,
      contactPhone: contact.phone
    })
    submitted.value = true
  } catch (e) {
    // request.js 已统一 toast 提示
  } finally {
    submitting.value = false
  }
}

onLoad((options) => {
  token.value = options.token || ''
  uni.setNavigationBarTitle({ title: '满意度回访' })
  loadForm()
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; min-height: 100%; }
.visit-page { padding: 24rpx 24rpx 160rpx; min-height: 100vh; box-sizing: border-box; }

/* 加载态 */
.loading-wrap { display: flex; flex-direction: column; align-items: center; justify-content: center; padding-top: 240rpx; }
.loading-text { margin-top: 24rpx; font-size: 26rpx; color: #86909C; }

/* 错误态 */
.error-wrap, .success-wrap { padding-top: 160rpx; }
.error-card, .success-card {
  background: #FFFFFF; border-radius: 24rpx; padding: 64rpx 48rpx;
  display: flex; flex-direction: column; align-items: center;
  box-shadow: 0 4rpx 24rpx rgba(0, 0, 0, 0.04);
}
.error-icon, .success-icon { margin-bottom: 24rpx; }
.error-title { font-size: 32rpx; color: #1D2129; font-weight: 600; text-align: center; line-height: 1.5; }
.error-tip { margin-top: 16rpx; font-size: 26rpx; color: #86909C; }
.success-title { font-size: 36rpx; color: #1D2129; font-weight: 600; }
.success-tip { margin-top: 16rpx; font-size: 26rpx; color: #86909C; text-align: center; }

/* Hero 头部 */
.hero {
  background: linear-gradient(135deg, #3D6DF7 0%, #5B8FF9 100%);
  border-radius: 20rpx; padding: 36rpx 32rpx; color: #FFFFFF;
  box-shadow: 0 8rpx 24rpx rgba(61, 109, 247, 0.18);
}
.hero-title { font-size: 36rpx; font-weight: 700; line-height: 1.4; }
.hero-sub { margin-top: 12rpx; font-size: 26rpx; opacity: 0.92; }
.hero-desc { margin-top: 16rpx; font-size: 26rpx; opacity: 0.85; line-height: 1.5; }

/* 题目卡片 */
.question-list { margin-top: 24rpx; display: flex; flex-direction: column; gap: 20rpx; }
.q-card {
  background: #FFFFFF; border-radius: 16rpx; padding: 28rpx 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(61, 109, 247, 0.04);
}
.q-title { display: flex; align-items: flex-start; margin-bottom: 20rpx; }
.q-index {
  flex-shrink: 0; width: 36rpx; height: 36rpx; border-radius: 50%;
  background: #E8F0FE; color: #3D6DF7; font-size: 22rpx; font-weight: 600;
  display: flex; align-items: center; justify-content: center; margin-right: 12rpx; margin-top: 4rpx;
}
.q-text { flex: 1; font-size: 30rpx; color: #1D2129; font-weight: 500; line-height: 1.5; }
.q-required { color: #F53F3F; margin-left: 6rpx; font-size: 30rpx; }

/* 选项 */
.q-options { display: flex; flex-direction: column; gap: 16rpx; }
.opt-item {
  display: flex; align-items: center; padding: 20rpx 24rpx;
  background: #F7F8FA; border-radius: 12rpx; border: 2rpx solid transparent;
  transition: all 0.2s;
}
.opt-item.active { background: #E8F0FE; border-color: #3D6DF7; }
.opt-radio {
  width: 36rpx; height: 36rpx; border-radius: 50%; border: 4rpx solid #C9CDD4;
  display: flex; align-items: center; justify-content: center; margin-right: 16rpx; flex-shrink: 0;
  transition: border-color 0.2s;
}
.opt-item.active .opt-radio { border-color: #3D6DF7; }
.opt-radio-inner { width: 16rpx; height: 16rpx; border-radius: 50%; background: #3D6DF7; }
.opt-check {
  width: 36rpx; height: 36rpx; border-radius: 8rpx; border: 4rpx solid #C9CDD4;
  display: flex; align-items: center; justify-content: center; margin-right: 16rpx; flex-shrink: 0;
  transition: all 0.2s;
}
.opt-item.active .opt-check { background: #3D6DF7; border-color: #3D6DF7; }
.opt-text { flex: 1; font-size: 28rpx; color: #1D2129; }
.opt-item.active .opt-text { color: #3D6DF7; font-weight: 500; }

/* 评分 */
.q-rate { display: flex; justify-content: space-between; padding: 12rpx 0; }
.rate-star { display: flex; flex-direction: column; align-items: center; gap: 8rpx; }
.rate-label { font-size: 22rpx; color: #86909C; }
.rate-star.active .rate-label { color: #FF7D00; font-weight: 500; }

/* 文本框 */
.q-textarea-wrap { position: relative; }
.q-textarea {
  width: 100%; min-height: 88rpx; background: #F7F8FA; border-radius: 12rpx;
  padding: 20rpx 24rpx; font-size: 28rpx; color: #1D2129; box-sizing: border-box; line-height: 1.6;
}
.q-placeholder { color: #C9CDD4; font-size: 28rpx; }
.q-char-count {
  position: absolute; right: 24rpx; bottom: 16rpx;
  font-size: 22rpx; color: #C9CDD4;
}

/* 联系信息 */
.contact-card {
  margin-top: 24rpx; background: #FFFFFF; border-radius: 16rpx; padding: 28rpx 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(61, 109, 247, 0.04);
}
.contact-title { display: flex; align-items: center; gap: 8rpx; margin-bottom: 20rpx; }
.contact-title-text { font-size: 30rpx; color: #1D2129; font-weight: 600; }
.contact-form { display: flex; flex-direction: column; gap: 16rpx; }
.contact-item {
  display: flex; align-items: center; background: #F7F8FA; border-radius: 12rpx; padding: 0 24rpx; height: 80rpx;
}
.contact-label { width: 80rpx; font-size: 28rpx; color: #4E5969; flex-shrink: 0; }
.contact-input { flex: 1; height: 80rpx; font-size: 28rpx; color: #1D2129; }

/* 提交按钮 */
.submit-bar {
  position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; z-index: 100;
  padding: 16rpx; background: rgba(255, 255, 255, 0.95); border-radius: 24rpx;
  box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.06);
  backdrop-filter: blur(20rpx);
}
</style>
