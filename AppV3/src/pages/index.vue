<template>
  <view class="home-page">
    <HeaderNav ref="headerNavRef" />

    <scroll-view
      scroll-y
      class="main-content"
      :style="{ height: scrollHeight }"
      @refresherrefresh="onPullDownRefresh"
      :refresher-enabled="true"
      :refresher-triggered="isRefreshing"
      :refresher-threshold="80"
      refresher-background="#F5F7FA"
    >
      <NoticeBar ref="noticeBarRef" />

      <StatisticsCard :data="combinedStats" @refresh="loadHomeData" />

      <OrderList :list="orderList" />

      <view class="bottom-spacer"></view>
    </scroll-view>
  </view>
</template>

<script setup>
/**
 * @description 首页 - 应用总览与快捷入口
 * @description 展示通知栏、统计卡片、最近订单列表，支持下拉刷新获取最新数据
 */
import { ref, onMounted, computed } from 'vue'
import HeaderNav from '@/components/home/HeaderNav.vue'
import NoticeBar from '@/components/home/NoticeBar.vue'
import StatisticsCard from '@/components/home/StatisticsCard.vue'
import OrderList from '@/components/home/OrderList.vue'
import { listSalesOrder } from '@/api/business/salesOrder'
import { listArchive } from '@/api/business/archive'
import { getTodayStats } from '@/api/home'
import { useUserStore } from '@/store/modules/user'

const isRefreshing = ref(false)
const combinedStats = ref([])
const orderList = ref([])
const headerNavRef = ref(null)
const noticeBarRef = ref(null)

const userStore = useUserStore()

/** 计算滚动区域高度，基于系统窗口高度适配不同设备 */
const scrollHeight = computed(() => {
  const systemInfo = uni.getSystemInfoSync()
  const headerHeight = systemInfo.statusBarHeight + 200
  return `${systemInfo.windowHeight - headerHeight}px`
})

onMounted(() => {
  loadHomeData()
})

/** 加载首页统计数据和最近归档订单列表，将归档数据映射为订单展示格式 */
async function loadHomeData() {
  try {
    const statsRes = await getTodayStats()
    const stats = statsRes.data || statsRes || {}
    const dealCustomer = stats.dealCustomerCount || {}
    const dealAmount = stats.dealAmount || {}
    const operationCustomer = stats.operationCustomerCount || {}

    combinedStats.value = [
      { label: '成交客数', todayValue: String(dealCustomer.today || 0), monthValue: String(dealCustomer.month || 0) },
      { label: '成交金额', todayValue: formatAmount(dealAmount.today || 0), monthValue: formatAmount(dealAmount.month || 0) },
      { label: '操作客数', todayValue: String(operationCustomer.today || 0), monthValue: String(operationCustomer.month || 0) }
    ]

    const archiveRes = await listArchive({
      operatorUserId: userStore.getId,
      pageNum: 1,
      pageSize: 5,
      orderByColumn: 'archive_date',
      isAsc: 'desc'
    })
    orderList.value = (archiveRes.rows || []).map(item => ({
      id: item.archiveId || item.archive_id,
      name: item.customerName || item.customer_name || '',
      store: [item.enterpriseName || item.enterprise_name, item.storeName || item.store_name].filter(Boolean).join('·'),
      avatar: '/static/images/profile.jpg',
      amount: Number(item.amount || 0).toFixed(2),
      sourceType: item.sourceType || item.source_type,
      sourceId: item.sourceId || item.source_id,
      status: getSourceTypeLabel(item.sourceType || item.source_type),
      createTime: item.archiveDate || item.archive_date || item.createTime,
      operatorName: item.operatorUserName || item.operator_user_name || ''
    }))
  } catch (error) {
    console.error('加载首页数据失败:', error)
    uni.showToast({ title: '数据加载失败', icon: 'none' })
  }
}

/** 下拉刷新处理，延迟800ms后重新加载数据并停止刷新动画 */
function onPullDownRefresh() {
  isRefreshing.value = true
  loadHomeData().finally(() => {
    isRefreshing.value = false
  })
  headerNavRef.value?.loadUnreadCount()
  noticeBarRef.value?.loadNotices()
}

/** 根据来源类型编码返回中文标签（0-开单/1-操作/2-还款/3-手动） */
function getSourceTypeLabel(type) {
  const map = { '0': '开单', '1': '操作', '2': '还款', '3': '手动' }
  return map[type] || (type || '未知')
}

function formatAmount(value) {
  const num = Number(value) || 0
  if (num >= 10000) {
    return '¥' + (num / 10000).toFixed(1) + 'w'
  }
  if (num >= 1000) {
    return '¥' + (num / 1000).toFixed(1) + 'k'
  }
  return '¥' + num.toFixed(0)
}
</script>

<style lang="scss" scoped>
.home-page {
  min-height: 100vh;
  background: #F5F7FA;
}

.main-content {
  padding-top: 20rpx;
}

.bottom-spacer {
  height: 40rpx;
}
</style>
