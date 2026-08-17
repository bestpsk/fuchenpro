<template>
  <view class="visit-form-container">
    <!-- 基本信息 -->
    <view class="form-card">
      <view class="card-title">
        <u-icon name="file-text" size="16" color="#3D6DF7"></u-icon>
        <text>基本信息</text>
      </view>

      <!-- 企业选择 -->
      <view class="form-item" @click="openEnterprisePicker">
        <text class="form-label required">企业</text>
        <view class="form-value-box">
          <text :class="form.enterpriseName ? 'form-value' : 'form-placeholder'">{{ form.enterpriseName || '请选择企业' }}</text>
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <!-- 模板选择 -->
      <view class="form-item" @click="openTemplatePicker">
        <text class="form-label required">回访模板</text>
        <view class="form-value-box">
          <text :class="form.templateId ? 'form-value' : 'form-placeholder'">{{ templateName || '请选择模板' }}</text>
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <!-- 回访方式 -->
      <view class="form-item form-item-column">
        <text class="form-label required">回访方式</text>
        <view class="radio-group">
          <view v-for="item in visitModeOptions" :key="item.value" class="radio-item" :class="{ active: form.visitMode === item.value }" @click="form.visitMode = item.value">
            <view class="radio" :class="{ checked: form.visitMode === item.value }"></view>
            <text>{{ item.label }}</text>
          </view>
        </view>
      </view>

      <!-- 门店名称 -->
      <view class="form-item">
        <text class="form-label">门店名称</text>
        <input class="form-input" type="text" v-model="form.storeName" placeholder="选填，请输入门店名称" placeholder-class="form-placeholder" maxlength="100" />
      </view>

      <!-- 备注 -->
      <view class="form-item form-item-column">
        <text class="form-label">备注</text>
        <textarea class="form-textarea" v-model="form.remark" placeholder="选填，请输入备注" placeholder-class="form-placeholder" :maxlength="500" auto-height />
      </view>
    </view>

    <!-- H5模式提示 -->
    <view v-if="form.visitMode === '2'" class="hint-card">
      <u-icon name="info-circle" size="16" color="#00B42A"></u-icon>
      <text class="hint-text">H5链接模式：创建任务后可在详情页点击"生成H5链接"，将链接发送给企业负责人填写</text>
    </view>

    <!-- 员工填写模式：问卷题目 -->
    <view v-if="form.visitMode === '1' && templateItems.length > 0" class="form-card">
      <view class="card-title">
        <u-icon name="file-text-fill" size="16" color="#3D6DF7"></u-icon>
        <text>问卷填写</text>
      </view>

      <view class="question-list">
        <view v-for="(item, idx) in templateItems" :key="item.itemId" class="q-card">
          <view class="q-title">
            <text class="q-index">{{ idx + 1 }}</text>
            <text class="q-text">{{ item.questionTitle }}</text>
            <text v-if="item.required === '0'" class="q-required">*</text>
          </view>

          <!-- 单选题 -->
          <view v-if="item.questionType === '1'" class="q-options">
            <view v-for="opt in item.options" :key="opt" class="opt-item" :class="{ active: form.answers[item.itemId] === opt }" @click="form.answers[item.itemId] = opt">
              <view class="opt-radio">
                <view v-if="form.answers[item.itemId] === opt" class="opt-radio-inner"></view>
              </view>
              <text class="opt-text">{{ opt }}</text>
            </view>
          </view>

          <!-- 多选题 -->
          <view v-else-if="item.questionType === '2'" class="q-options">
            <view v-for="opt in item.options" :key="opt" class="opt-item" :class="{ active: (form.answers[item.itemId] || []).includes(opt) }" @click="toggleMulti(item.itemId, opt)">
              <view class="opt-check">
                <u-icon v-if="(form.answers[item.itemId] || []).includes(opt)" name="checkmark" size="24" color="#FFFFFF"></u-icon>
              </view>
              <text class="opt-text">{{ opt }}</text>
            </view>
          </view>

          <!-- 评分题 -->
          <view v-else-if="item.questionType === '3'" class="q-rate">
            <view v-for="star in 5" :key="star" class="rate-star" :class="{ active: (form.answers[item.itemId] || 0) >= star }" @click="form.answers[item.itemId] = star">
              <u-icon :name="(form.answers[item.itemId] || 0) >= star ? 'star-fill' : 'star'" size="48" :color="(form.answers[item.itemId] || 0) >= star ? '#FF7D00' : '#C9CDD4'"></u-icon>
              <text class="rate-label">{{ rateLabels[star - 1] }}</text>
            </view>
          </view>

          <!-- 文本题 -->
          <view v-else class="q-textarea-wrap">
            <textarea class="q-textarea" v-model="form.answers[item.itemId]" placeholder="请输入您的意见或建议" :maxlength="500" placeholder-class="q-placeholder" />
            <text class="q-char-count">{{ (form.answers[item.itemId] || '').length }}/500</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 底部按钮 -->
    <view class="bottom-bar">
      <view class="submit-btn" :class="{ disabled: submitting }" @click="submitForm">
        <text>{{ submitting ? '提交中...' : (isEdit ? '保存修改' : '确定') }}</text>
      </view>
    </view>

    <!-- 企业选择弹窗 -->
    <u-popup :show="showEnterprisePicker" mode="bottom" round="16" @close="showEnterprisePicker = false">
      <view class="picker-content">
        <view class="picker-header">
          <text class="picker-title">选择企业</text>
          <u-icon name="close" size="20" color="#86909C" @click="showEnterprisePicker = false"></u-icon>
        </view>
        <view class="picker-search">
          <u-icon name="search" size="16" color="#86909C"></u-icon>
          <input class="picker-input" type="text" v-model="enterpriseKeyword" placeholder="输入企业名称搜索" placeholder-class="form-placeholder" confirm-type="search" @confirm="searchEnterpriseList" @input="onEnterpriseInput" />
        </view>
        <scroll-view scroll-y class="picker-list">
          <view v-if="enterpriseOptions.length > 0">
            <view v-for="item in enterpriseOptions" :key="item.enterpriseId" class="picker-item" :class="{ active: form.enterpriseId === item.enterpriseId }" @click="selectEnterprise(item)">
              <view class="picker-item-main">
                <text class="picker-item-title">{{ item.enterpriseName }}</text>
                <text v-if="item.contactName" class="picker-item-sub">{{ item.contactName }} {{ item.phone || '' }}</text>
              </view>
              <u-icon v-if="form.enterpriseId === item.enterpriseId" name="checkmark" size="20" color="#3D6DF7"></u-icon>
            </view>
          </view>
          <view v-else class="picker-empty">
            <text>{{ enterpriseKeyword ? '未找到匹配企业' : '请输入企业名称搜索' }}</text>
          </view>
        </scroll-view>
      </view>
    </u-popup>

    <!-- 模板选择弹窗 -->
    <u-popup :show="showTemplatePicker" mode="bottom" round="16" @close="showTemplatePicker = false">
      <view class="picker-content">
        <view class="picker-header">
          <text class="picker-title">选择回访模板</text>
          <u-icon name="close" size="20" color="#86909C" @click="showTemplatePicker = false"></u-icon>
        </view>
        <scroll-view scroll-y class="picker-list">
          <view v-if="templateOptions.length > 0">
            <view v-for="item in templateOptions" :key="item.templateId" class="picker-item" :class="{ active: form.templateId === item.templateId }" @click="selectTemplate(item)">
              <view class="picker-item-main">
                <text class="picker-item-title">{{ item.templateName }}</text>
                <text v-if="item.description" class="picker-item-sub">{{ item.description }}</text>
              </view>
              <u-icon v-if="form.templateId === item.templateId" name="checkmark" size="20" color="#3D6DF7"></u-icon>
            </view>
          </view>
          <view v-else class="picker-empty">
            <text>暂无可用模板</text>
          </view>
        </scroll-view>
      </view>
    </u-popup>
  </view>
</template>

<script setup>
/**
 * @description 回访任务表单页 - 新增/编辑回访任务
 */
import { ref, reactive } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { addVisit, updateVisit, getVisit, listVisitTemplate, getVisitTemplate } from '@/api/business/visitManage'
import { searchEnterprise } from '@/api/business/enterprise'

const visitModeOptions = [
  { value: '1', label: '员工填写' },
  { value: '2', label: 'H5链接' }
]
const rateLabels = ['很不满意', '不满意', '一般', '满意', '很满意']

const isEdit = ref(false)
const submitting = ref(false)
const visitId = ref(null)

const form = reactive({
  visitId: null,
  enterpriseId: undefined,
  enterpriseName: '',
  templateId: undefined,
  visitMode: '1',
  storeName: '',
  remark: '',
  answers: {}
})

const templateName = ref('')
const templateOptions = ref([])
const templateItems = ref([])

// 企业选择
const showEnterprisePicker = ref(false)
const enterpriseKeyword = ref('')
const enterpriseOptions = ref([])
let searchTimer = null

function openEnterprisePicker() {
  showEnterprisePicker.value = true
  if (enterpriseOptions.value.length === 0) {
    // 默认加载前几条
    searchEnterpriseList()
  }
}

function onEnterpriseInput() {
  if (searchTimer) clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    searchEnterpriseList()
  }, 300)
}

async function searchEnterpriseList() {
  try {
    const res = await searchEnterprise(enterpriseKeyword.value)
    enterpriseOptions.value = res.data || res.rows || []
  } catch (e) {
    console.error('搜索企业失败', e)
    enterpriseOptions.value = []
  }
}

function selectEnterprise(item) {
  form.enterpriseId = item.enterpriseId
  form.enterpriseName = item.enterpriseName
  showEnterprisePicker.value = false
}

// 模板选择
const showTemplatePicker = ref(false)

async function loadTemplates() {
  try {
    const res = await listVisitTemplate({ pageNum: 1, pageSize: 100, status: '0' })
    templateOptions.value = res.rows || []
  } catch (e) {
    console.error('加载模板列表失败', e)
    templateOptions.value = []
  }
}

function openTemplatePicker() {
  showTemplatePicker.value = true
}

async function selectTemplate(item) {
  form.templateId = item.templateId
  templateName.value = item.templateName
  showTemplatePicker.value = false
  // 加载模板题目
  await loadTemplateItems(item.templateId)
}

async function loadTemplateItems(templateId) {
  if (!templateId) {
    templateItems.value = []
    return
  }
  try {
    const res = await getVisitTemplate(templateId)
    const data = res.data || res
    templateItems.value = data.items || []
    // 初始化answers结构
    templateItems.value.forEach(item => {
      if (!(item.itemId in form.answers)) {
        form.answers[item.itemId] = item.questionType === '2' ? [] : (item.questionType === '3' ? 0 : '')
      }
    })
  } catch (e) {
    console.error('加载模板题目失败', e)
    templateItems.value = []
  }
}

// 多选题切换
function toggleMulti(itemId, opt) {
  const arr = form.answers[itemId] || []
  const idx = arr.indexOf(opt)
  if (idx === -1) {
    arr.push(opt)
  } else {
    arr.splice(idx, 1)
  }
  form.answers[itemId] = [...arr]
}

// 加载编辑数据
async function loadVisitDetail(id) {
  uni.showLoading({ title: '加载中...', mask: true })
  try {
    const res = await getVisit(id)
    const data = res.data || res
    const task = data.task || data
    if (task) {
      Object.assign(form, {
        visitId: task.visitId,
        enterpriseId: task.enterpriseId,
        enterpriseName: task.enterpriseName,
        templateId: task.templateId,
        visitMode: task.visitMode,
        storeName: task.storeName || '',
        remark: task.remark || ''
      })
      templateName.value = task.templateName || ''
      // 加载模板题目
      if (task.templateId) {
        await loadTemplateItems(task.templateId)
        // 回填答案
        if (data.answers) {
          const answers = {}
          const ansList = Array.isArray(data.answers) ? data.answers : Object.values(data.answers)
          ansList.forEach(ans => {
            let val = ans.answerValue
            if (ans.questionType === '2') {
              val = val ? val.split(',') : []
            } else if (ans.questionType === '3') {
              val = Number(val) || 0
            }
            answers[ans.itemId] = (val !== '' && val !== null && val !== undefined)
              ? val
              : (ans.answerText || (ans.questionType === '2' ? [] : (ans.questionType === '3' ? 0 : '')))
          })
          form.answers = answers
        }
      }
    }
  } catch (e) {
    console.error('加载回访详情失败', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

// 校验
function validateForm() {
  if (!form.enterpriseId) {
    uni.showToast({ title: '请选择企业', icon: 'none' })
    return false
  }
  if (!form.templateId) {
    uni.showToast({ title: '请选择回访模板', icon: 'none' })
    return false
  }
  if (!form.visitMode) {
    uni.showToast({ title: '请选择回访方式', icon: 'none' })
    return false
  }
  // 员工填写模式校验必答题
  if (form.visitMode === '1' && templateItems.value.length > 0) {
    for (let i = 0; i < templateItems.value.length; i++) {
      const item = templateItems.value[i]
      if (item.required !== '0') continue
      const val = form.answers[item.itemId]
      const empty = item.questionType === '2'
        ? !val || val.length === 0
        : item.questionType === '3'
          ? !val || val === 0
          : !val || String(val).trim() === ''
      if (empty) {
        uni.showToast({ title: `请完成第${i + 1}题：${item.questionTitle}`, icon: 'none' })
        return false
      }
    }
  }
  return true
}

// 构建问卷答案载荷
function buildAnswersPayload() {
  const payload = []
  templateItems.value.forEach(item => {
    const val = form.answers[item.itemId]
    if (val === undefined || val === '' || (Array.isArray(val) && val.length === 0)) return
    if (item.questionType === '4') {
      payload.push({ item_id: item.itemId, answer_value: '', answer_text: String(val) })
    } else {
      payload.push({
        item_id: item.itemId,
        answer_value: Array.isArray(val) ? val.join(',') : String(val),
        answer_text: ''
      })
    }
  })
  return payload
}

async function submitForm() {
  if (!validateForm()) return
  if (submitting.value) return
  submitting.value = true
  try {
    const data = {
      enterpriseId: form.enterpriseId,
      enterpriseName: form.enterpriseName,
      templateId: form.templateId,
      visitMode: form.visitMode,
      storeName: form.storeName,
      remark: form.remark
    }
    // 员工填写模式附带答案
    if (form.visitMode === '1' && templateItems.value.length > 0) {
      data.answers = buildAnswersPayload()
    }
    if (form.visitId) {
      data.visitId = form.visitId
      await updateVisit(data)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      await addVisit(data)
      uni.showToast({ title: '新增成功', icon: 'success' })
    }
    setTimeout(() => uni.navigateBack(), 800)
  } catch (e) {
    console.error('提交失败', e)
  } finally {
    submitting.value = false
  }
}

onLoad(async (options) => {
  await loadTemplates()
  if (options.visitId) {
    isEdit.value = true
    visitId.value = options.visitId
    uni.setNavigationBarTitle({ title: '编辑回访' })
    loadVisitDetail(options.visitId)
  } else {
    uni.setNavigationBarTitle({ title: '新增回访' })
  }
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
}

.visit-form-container {
  min-height: 100vh;
  padding: 24rpx 24rpx 160rpx;
  box-sizing: border-box;
}

/* 卡片 */
.form-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.card-title {
  display: flex;
  align-items: center;
  gap: 8rpx;
  margin-bottom: 20rpx;
  padding-bottom: 16rpx;
  border-bottom: 1rpx solid #F0F0F0;

  text {
    font-size: 28rpx;
    font-weight: 600;
    color: #1D2129;
  }
}

/* 表单项 */
.form-item {
  display: flex;
  align-items: center;
  min-height: 80rpx;
  padding: 16rpx 0;
  border-bottom: 1rpx solid #F5F5F5;
  gap: 16rpx;

  &:last-child {
    border-bottom: none;
  }
}

.form-item-column {
  flex-direction: column;
  align-items: flex-start;
  gap: 12rpx;
}

.form-label {
  width: 160rpx;
  font-size: 28rpx;
  color: #4E5969;
  flex-shrink: 0;

  &.required::before {
    content: '*';
    color: #F53F3F;
    margin-right: 6rpx;
  }
}

.form-input {
  flex: 1;
  font-size: 28rpx;
  color: #1D2129;
  text-align: right;
}

.form-textarea {
  width: 100%;
  min-height: 120rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 20rpx 24rpx;
  font-size: 28rpx;
  color: #1D2129;
  box-sizing: border-box;
  line-height: 1.6;
}

.form-value-box {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 8rpx;
}

.form-value {
  font-size: 28rpx;
  color: #1D2129;
  text-align: right;
  max-width: 400rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.form-placeholder {
  font-size: 28rpx;
  color: #C9CDD4;
}

/* 单选组 */
.radio-group {
  display: flex;
  gap: 24rpx;
  flex-wrap: wrap;
}

.radio-item {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 12rpx 24rpx;
  background: #F5F7FA;
  border-radius: 8rpx;
  border: 1rpx solid transparent;

  &.active {
    background: #E8F0FE;
    border-color: #3D6DF7;
  }

  text {
    font-size: 26rpx;
    color: #4E5969;
  }

  &.active text {
    color: #3D6DF7;
    font-weight: 500;
  }
}

.radio {
  width: 32rpx;
  height: 32rpx;
  border-radius: 50%;
  border: 4rpx solid #C9CDD4;
  display: flex;
  align-items: center;
  justify-content: center;

  &.checked {
    border-color: #3D6DF7;

    &::after {
      content: '';
      width: 16rpx;
      height: 16rpx;
      border-radius: 50%;
      background: #3D6DF7;
    }
  }
}

/* 提示卡片 */
.hint-card {
  display: flex;
  align-items: flex-start;
  gap: 8rpx;
  background: rgba(0, 180, 42, 0.06);
  border-radius: 12rpx;
  padding: 20rpx 24rpx;
  margin-bottom: 20rpx;
}

.hint-text {
  flex: 1;
  font-size: 24rpx;
  color: #00B42A;
  line-height: 1.5;
}

/* 问卷题目 */
.question-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.q-card {
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 24rpx 20rpx;
}

.q-title {
  display: flex;
  align-items: flex-start;
  margin-bottom: 16rpx;
  gap: 8rpx;
}

.q-index {
  flex-shrink: 0;
  width: 32rpx;
  height: 32rpx;
  border-radius: 50%;
  background: #E8F0FE;
  color: #3D6DF7;
  font-size: 20rpx;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 4rpx;
}

.q-text {
  flex: 1;
  font-size: 28rpx;
  color: #1D2129;
  font-weight: 500;
  line-height: 1.5;
}

.q-required {
  color: #F53F3F;
  font-size: 28rpx;
}

/* 选项 */
.q-options {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.opt-item {
  display: flex;
  align-items: center;
  padding: 16rpx 20rpx;
  background: #FFFFFF;
  border-radius: 10rpx;
  border: 2rpx solid transparent;
  transition: all 0.2s;
}

.opt-item.active {
  background: #E8F0FE;
  border-color: #3D6DF7;
}

.opt-radio {
  width: 36rpx;
  height: 36rpx;
  border-radius: 50%;
  border: 4rpx solid #C9CDD4;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16rpx;
  flex-shrink: 0;
  transition: border-color 0.2s;
}

.opt-item.active .opt-radio {
  border-color: #3D6DF7;
}

.opt-radio-inner {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  background: #3D6DF7;
}

.opt-check {
  width: 36rpx;
  height: 36rpx;
  border-radius: 8rpx;
  border: 4rpx solid #C9CDD4;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16rpx;
  flex-shrink: 0;
  transition: all 0.2s;
}

.opt-item.active .opt-check {
  background: #3D6DF7;
  border-color: #3D6DF7;
}

.opt-text {
  flex: 1;
  font-size: 28rpx;
  color: #1D2129;
}

.opt-item.active .opt-text {
  color: #3D6DF7;
  font-weight: 500;
}

/* 评分 */
.q-rate {
  display: flex;
  justify-content: space-between;
  padding: 12rpx 0;
}

.rate-star {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
}

.rate-label {
  font-size: 22rpx;
  color: #86909C;
}

.rate-star.active .rate-label {
  color: #FF7D00;
  font-weight: 500;
}

/* 文本框 */
.q-textarea-wrap {
  position: relative;
}

.q-textarea {
  width: 100%;
  min-height: 160rpx;
  background: #FFFFFF;
  border-radius: 10rpx;
  padding: 20rpx 24rpx;
  font-size: 28rpx;
  color: #1D2129;
  box-sizing: border-box;
  line-height: 1.6;
}

.q-placeholder {
  color: #C9CDD4;
  font-size: 28rpx;
}

.q-char-count {
  position: absolute;
  right: 24rpx;
  bottom: 16rpx;
  font-size: 22rpx;
  color: #C9CDD4;
}

/* 底部按钮 */
.bottom-bar {
  position: fixed;
  left: 24rpx;
  right: 24rpx;
  bottom: 40rpx;
  z-index: 100;
}

.submit-btn {
  height: 96rpx;
  border-radius: 48rpx;
  background: linear-gradient(135deg, #3D6DF7 0%, #5B8FF9 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 24rpx rgba(61, 109, 247, 0.3);

  text {
    font-size: 32rpx;
    font-weight: 600;
    color: #fff;
  }

  &.disabled {
    opacity: 0.6;
  }
}

/* 选择弹窗 */
.picker-content {
  background: #fff;
  border-radius: 16rpx 16rpx 0 0;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
}

.picker-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24rpx;
  border-bottom: 1rpx solid #F0F0F0;
}

.picker-title {
  font-size: 30rpx;
  font-weight: 600;
  color: #1D2129;
}

.picker-search {
  display: flex;
  align-items: center;
  background: #F5F7FA;
  border-radius: 24rpx;
  padding: 12rpx 24rpx;
  margin: 16rpx 24rpx;
  gap: 12rpx;
}

.picker-input {
  flex: 1;
  font-size: 26rpx;
  color: #1D2129;
}

.picker-list {
  flex: 1;
  max-height: 60vh;
  padding: 0 24rpx 24rpx;
}

.picker-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24rpx 16rpx;
  border-bottom: 1rpx solid #F5F5F5;
  gap: 16rpx;

  &.active {
    background: #E8F0FE;
    border-radius: 8rpx;
  }
}

.picker-item-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.picker-item-title {
  font-size: 28rpx;
  color: #1D2129;
  font-weight: 500;
}

.picker-item-sub {
  font-size: 22rpx;
  color: #86909C;
}

.picker-empty {
  text-align: center;
  padding: 80rpx 0;
  font-size: 26rpx;
  color: #C9CDD4;
}
</style>
