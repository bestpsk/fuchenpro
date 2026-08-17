<template>
  <view class="visit-detail-container">
    <!-- 加载态 -->
    <view v-if="loading" class="loading-wrap">
      <u-loading-icon mode="circle" size="48" color="#3D6DF7"></u-loading-icon>
      <text class="loading-text">加载中...</text>
    </view>

    <block v-else-if="task">
      <!-- 顶部渐变头部 -->
      <view class="header-section">
        <view class="header-title-row">
          <text class="header-title">{{ task.enterpriseName }}</text>
          <view class="status-tag" :class="getStatusClass(task.visitStatus)">
            <text>{{ getStatusLabel(task.visitStatus) }}</text>
          </view>
        </view>
        <view class="header-tags">
          <view class="header-tag">{{ getVisitTypeLabel(task.visitType) }}</view>
          <view class="header-tag">{{ getVisitModeLabel(task.visitMode) }}</view>
        </view>
      </view>

      <!-- 满意度卡片 -->
      <view v-if="task.satisfactionScore" class="satisfaction-card">
        <view class="sat-label">
          <u-icon name="star-fill" size="18" color="#FF7D00"></u-icon>
          <text class="sat-title">满意度评分</text>
        </view>
        <view class="sat-stars">
          <u-icon v-for="n in 5" :key="n" :name="n <= Number(task.satisfactionScore) ? 'star-fill' : 'star'" size="32" :color="n <= Number(task.satisfactionScore) ? '#FF7D00' : '#E5E6EB'"></u-icon>
          <text class="sat-score">{{ Number(task.satisfactionScore).toFixed(1) }} 分</text>
        </view>
      </view>

      <!-- 基本信息 -->
      <view class="info-card">
        <view class="card-title">
          <u-icon name="file-text" size="16" color="#3D6DF7"></u-icon>
          <text>基本信息</text>
        </view>
        <view class="info-grid">
          <view class="info-row">
            <text class="info-label">企业名称</text>
            <text class="info-value">{{ task.enterpriseName || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">门店名称</text>
            <text class="info-value">{{ task.storeName || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">回访类型</text>
            <text class="info-value">{{ getVisitTypeLabel(task.visitType) }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">回访方式</text>
            <text class="info-value">{{ getVisitModeLabel(task.visitMode) }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">回访员工</text>
            <text class="info-value">{{ task.visitorUserName || '-' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">回访时间</text>
            <text class="info-value">{{ formatTime(task.visitTime) }}</text>
          </view>
          <view v-if="task.contactName" class="info-row">
            <text class="info-label">企业负责人</text>
            <text class="info-value">{{ task.contactName }} {{ task.contactPhone || '' }}</text>
          </view>
          <view v-if="task.remark" class="info-row info-row-block">
            <text class="info-label">备注</text>
            <text class="info-value info-value-block">{{ task.remark }}</text>
          </view>
        </view>
      </view>

      <!-- H5链接信息 -->
      <view v-if="task.visitMode === '2' && linkInfo.url" class="info-card">
        <view class="card-title">
          <u-icon name="share" size="16" color="#3D6DF7"></u-icon>
          <text>H5回访链接</text>
        </view>
        <view class="link-info">
          <text class="link-url">{{ linkInfo.url }}</text>
          <view v-if="linkInfo.expireTime" class="link-expire">
            <u-icon name="clock" size="14" color="#86909C"></u-icon>
            <text>有效期至：{{ formatTime(linkInfo.expireTime) }}</text>
          </view>
          <view class="link-actions">
            <view class="link-btn copy" @click="copyLink">
              <u-icon name="file-text" size="14" color="#fff"></u-icon>
              <text>复制链接</text>
            </view>
            <view v-if="task.visitStatus !== '1'" class="link-btn refresh" @click="handleRefreshLink">
              <u-icon name="reload" size="14" color="#3D6DF7"></u-icon>
              <text>刷新链接</text>
            </view>
          </view>
        </view>
      </view>

      <!-- 问卷答案 -->
      <view v-if="items.length > 0" class="info-card">
        <view class="card-title">
          <u-icon name="file-text-fill" size="16" color="#3D6DF7"></u-icon>
          <text>问卷答案</text>
        </view>
        <view class="question-list">
          <view v-for="(item, idx) in items" :key="item.itemId" class="q-card">
            <view class="q-title">
              <text class="q-index">{{ idx + 1 }}</text>
              <text class="q-text">{{ item.questionTitle }}</text>
              <text class="q-type">{{ getQuestionTypeLabel(item.questionType) }}</text>
            </view>
            <view class="q-answer">
              <!-- 评分题 -->
              <view v-if="item.questionType === '3'" class="answer-rate">
                <u-icon v-for="n in 5" :key="n" :name="n <= Number(getAnswerValue(item.itemId)) ? 'star-fill' : 'star'" size="28" :color="n <= Number(getAnswerValue(item.itemId)) ? '#FF7D00' : '#E5E6EB'"></u-icon>
                <text class="rate-score">{{ getAnswerValue(item.itemId) || 0 }} 分</text>
              </view>
              <!-- 单选/多选 -->
              <view v-else-if="getAnswerValue(item.itemId)" class="answer-tags">
                <view v-for="(tag, ti) in String(getAnswerValue(item.itemId)).split(',')" :key="ti" class="answer-tag">{{ tag }}</view>
              </view>
              <!-- 文本 -->
              <view v-else-if="getAnswerText(item.itemId)" class="answer-text">
                <text>{{ getAnswerText(item.itemId) }}</text>
              </view>
              <text v-else class="answer-empty">未作答</text>
            </view>
          </view>
        </view>
      </view>

      <!-- 操作按钮 -->
      <view class="action-bar">
        <view v-if="task.visitMode === '2' && task.visitStatus !== '1'" class="action-btn primary" @click="handleGenerateLink">
          <u-icon name="share" size="16" color="#fff"></u-icon>
          <text>生成H5链接</text>
        </view>
        <view class="action-btn outline" @click="handleEdit">
          <u-icon name="edit-pen" size="16" color="#3D6DF7"></u-icon>
          <text>编辑</text>
        </view>
        <view class="action-btn danger" @click="handleDelete">
          <u-icon name="trash" size="16" color="#f56c6c"></u-icon>
          <text>删除</text>
        </view>
      </view>
    </block>

    <!-- 空状态 -->
    <view v-else class="empty-state">
      <u-icon name="empty-data" size="80" color="#C9CDD4"></u-icon>
      <text class="empty-text">未找到回访任务</text>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 回访任务详情页 - 展示回访任务基本信息、问卷答案、H5链接
 */
import { ref, reactive } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import { getVisit, delVisit, generateVisitLink } from '@/api/business/visitManage'
import { copyToClipboard } from '@/utils/common'
import config from '@/config'

const visitId = ref(null)
const loading = ref(true)
const task = ref(null)
const items = ref([])
const answers = ref({})
const linkInfo = reactive({ url: '', expireTime: '' })

const visitTypeMap = {
  after_service: '服务后回访',
  monthly: '月度回访',
  quarterly: '季度回访',
  custom: '自定义'
}
const visitModeMap = { '1': '员工填写', '2': 'H5链接' }
const statusMap = { '0': '待回访', '1': '已完成', '2': '已取消' }
const statusClassMap = { '0': 'status-pending', '1': 'status-done', '2': 'status-cancel' }
const questionTypeMap = { '1': '单选', '2': '多选', '3': '评分', '4': '文本' }

function getVisitTypeLabel(val) { return visitTypeMap[val] || val || '-' }
function getVisitModeLabel(val) { return visitModeMap[String(val)] || '-' }
function getStatusLabel(val) { return statusMap[String(val)] || '-' }
function getStatusClass(val) { return statusClassMap[String(val)] || 'status-pending' }
function getQuestionTypeLabel(val) { return questionTypeMap[String(val)] || '' }

function formatTime(val) {
  if (!val) return '-'
  const str = String(val).replace(/-/g, '/')
  const d = new Date(str)
  if (isNaN(d.getTime())) return val
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  const hh = String(d.getHours()).padStart(2, '0')
  const mm = String(d.getMinutes()).padStart(2, '0')
  return `${y}-${m}-${day} ${hh}:${mm}`
}

function getAnswerValue(itemId) {
  const a = answers.value[itemId]
  return a ? a.answerValue : ''
}
function getAnswerText(itemId) {
  const a = answers.value[itemId]
  return a ? a.answerText : ''
}

async function loadDetail() {
  if (!visitId.value) return
  loading.value = true
  try {
    const res = await getVisit(visitId.value)
    const data = res.data || res
    task.value = data.task || data
    items.value = data.items || []
    // 构建答案映射
    const map = {}
    if (Array.isArray(data.answers)) {
      data.answers.forEach(a => {
        map[a.itemId] = a
      })
    } else if (data.answers && typeof data.answers === 'object') {
      Object.values(data.answers).forEach(a => {
        map[a.itemId] = a
      })
    }
    answers.value = map
    // 提取H5链接信息
    if (task.value.visitToken) {
      linkInfo.url = buildH5Url(task.value.visitToken)
      linkInfo.expireTime = task.value.tokenExpireTime || ''
    }
  } catch (e) {
    console.error('加载回访详情失败', e)
    task.value = null
  } finally {
    loading.value = false
  }
}

function buildH5Url(token) {
  if (!token) return ''
  // 兼容 H5/小程序/APP
  // #ifdef H5
  const origin = window.location.origin
  const base = window.location.pathname.replace(/\/[^/]*$/, '')
  return `${origin}${base}/#/pages/visit/fill?token=${token}`
  // #endif
  // #ifndef H5
  // 非H5环境（App/小程序）用配置的站点地址拼接完整可分享链接
  const siteUrl = (config.appInfo.site_url || '').replace(/\/$/, '')
  return `${siteUrl}/#/pages/visit/fill?token=${token}`
  // #endif
}

function copyLink() {
  if (!linkInfo.url) {
    uni.showToast({ title: '暂无链接', icon: 'none' })
    return
  }
  copyToClipboard(linkInfo.url)
}

async function handleGenerateLink() {
  uni.showLoading({ title: '生成中...', mask: true })
  try {
    const res = await generateVisitLink(visitId.value)
    const data = res.data || res
    const token = data.visitToken || data.h5Token || ''
    if (token) {
      linkInfo.url = buildH5Url(token)
      linkInfo.expireTime = data.tokenExpireTime || ''
    } else if (data.linkUrl || data.url) {
      linkInfo.url = data.linkUrl || data.url
      linkInfo.expireTime = data.tokenExpireTime || ''
    }
    uni.showToast({ title: '链接已生成', icon: 'success' })
    // 复制到剪贴板
    setTimeout(() => copyLink(), 500)
  } catch (e) {
    console.error('生成链接失败', e)
  } finally {
    uni.hideLoading()
  }
}

function handleRefreshLink() {
  handleGenerateLink()
}

function handleEdit() {
  uni.navigateTo({ url: '/pages/visit/form?visitId=' + visitId.value })
}

function handleDelete() {
  uni.showModal({
    title: '提示',
    content: '是否确认删除该回访任务？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await delVisit(visitId.value)
          uni.showToast({ title: '删除成功', icon: 'success' })
          setTimeout(() => uni.navigateBack(), 800)
        } catch (e) {
          console.error('删除失败', e)
        }
      }
    }
  })
}

onLoad((options) => {
  visitId.value = options.visitId
  loadDetail()
})

onShow(() => {
  if (visitId.value && task.value) loadDetail()
})
</script>

<style lang="scss" scoped>
page {
  background-color: #F5F7FA;
}

.visit-detail-container {
  min-height: 100vh;
  padding: 24rpx 24rpx 160rpx;
  box-sizing: border-box;
}

/* 加载态 */
.loading-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding-top: 240rpx;
}

.loading-text {
  margin-top: 24rpx;
  font-size: 26rpx;
  color: #86909C;
}

/* 顶部头部 */
.header-section {
  background: linear-gradient(135deg, #3D6DF7 0%, #5B8FF9 100%);
  border-radius: 20rpx;
  padding: 32rpx 28rpx;
  color: #FFFFFF;
  box-shadow: 0 8rpx 24rpx rgba(61, 109, 247, 0.18);
  margin-bottom: 20rpx;
}

.header-title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16rpx;
  margin-bottom: 16rpx;
}

.header-title {
  flex: 1;
  font-size: 36rpx;
  font-weight: 700;
  line-height: 1.4;
}

.status-tag {
  padding: 6rpx 16rpx;
  border-radius: 8rpx;
  font-size: 22rpx;
  flex-shrink: 0;
  background: rgba(255, 255, 255, 0.2);
  color: #fff;

  &.status-pending { background: rgba(230, 162, 60, 0.3); }
  &.status-done { background: rgba(82, 196, 26, 0.3); }
  &.status-cancel { background: rgba(193, 197, 204, 0.3); }
}

.header-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8rpx;
}

.header-tag {
  font-size: 22rpx;
  padding: 4rpx 16rpx;
  border-radius: 20rpx;
  background: rgba(255, 255, 255, 0.18);
}

/* 满意度卡片 */
.satisfaction-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 28rpx 24rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.sat-label {
  display: flex;
  align-items: center;
  gap: 8rpx;
  margin-bottom: 16rpx;
}

.sat-title {
  font-size: 28rpx;
  font-weight: 600;
  color: #1D2129;
}

.sat-stars {
  display: flex;
  align-items: center;
  gap: 6rpx;
}

.sat-score {
  margin-left: 16rpx;
  font-size: 32rpx;
  font-weight: 700;
  color: #FF7D00;
}

/* 信息卡片 */
.info-card {
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

.info-grid {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.info-row {
  display: flex;
  align-items: flex-start;
  gap: 16rpx;
}

.info-row-block {
  flex-direction: column;
  gap: 8rpx;
}

.info-label {
  width: 160rpx;
  font-size: 26rpx;
  color: #86909C;
  flex-shrink: 0;
}

.info-value {
  flex: 1;
  font-size: 26rpx;
  color: #1D2129;
  line-height: 1.5;
  word-break: break-all;
}

.info-value-block {
  background: #F7F8FA;
  border-radius: 8rpx;
  padding: 16rpx;
  white-space: pre-wrap;
}

/* H5链接信息 */
.link-info {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.link-url {
  font-size: 24rpx;
  color: #3D6DF7;
  background: #E8F0FE;
  border-radius: 8rpx;
  padding: 16rpx;
  word-break: break-all;
}

.link-expire {
  display: flex;
  align-items: center;
  gap: 6rpx;
  font-size: 22rpx;
  color: #86909C;
}

.link-actions {
  display: flex;
  gap: 16rpx;
  margin-top: 8rpx;
}

.link-btn {
  display: flex;
  align-items: center;
  gap: 6rpx;
  padding: 12rpx 24rpx;
  border-radius: 8rpx;
  font-size: 24rpx;

  &.copy {
    background: #3D6DF7;
    color: #fff;
  }

  &.refresh {
    background: #E8F0FE;
    color: #3D6DF7;
  }
}

/* 问卷答案 */
.question-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.q-card {
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 20rpx 16rpx;
}

.q-title {
  display: flex;
  align-items: flex-start;
  margin-bottom: 12rpx;
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

.q-type {
  flex-shrink: 0;
  font-size: 20rpx;
  padding: 2rpx 8rpx;
  border-radius: 4rpx;
  background: rgba(61, 109, 247, 0.1);
  color: #3D6DF7;
  margin-top: 4rpx;
}

.q-answer {
  padding-left: 40rpx;
}

.answer-rate {
  display: flex;
  align-items: center;
  gap: 6rpx;
}

.rate-score {
  margin-left: 12rpx;
  font-size: 26rpx;
  color: #FF7D00;
  font-weight: 600;
}

.answer-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8rpx;
}

.answer-tag {
  background: rgba(82, 196, 26, 0.1);
  color: #52c41a;
  font-size: 22rpx;
  padding: 4rpx 12rpx;
  border-radius: 4rpx;
}

.answer-text {
  font-size: 26rpx;
  color: #4E5969;
  line-height: 1.6;
  white-space: pre-wrap;
}

.answer-empty {
  font-size: 24rpx;
  color: #C9CDD4;
}

/* 操作按钮 */
.action-bar {
  position: fixed;
  left: 24rpx;
  right: 24rpx;
  bottom: 40rpx;
  z-index: 100;
  display: flex;
  gap: 16rpx;
  padding: 16rpx;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 16rpx;
  box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.06);
  backdrop-filter: blur(20rpx);
}

.action-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6rpx;
  height: 80rpx;
  border-radius: 12rpx;
  font-size: 26rpx;
  font-weight: 500;

  &.primary {
    background: linear-gradient(135deg, #3D6DF7 0%, #5B8FF9 100%);
    color: #fff;
  }

  &.outline {
    background: #E8F0FE;
    color: #3D6DF7;
  }

  &.danger {
    background: rgba(245, 108, 108, 0.1);
    color: #f56c6c;
  }
}

/* 空状态 */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 200rpx 0;
  gap: 16rpx;
}

.empty-text {
  font-size: 28rpx;
  color: #86909C;
}
</style>
