<template>
  <view class="home-page">
    <HeaderNav ref="headerNavRef" />

    <scroll-view
      scroll-y
      class="main-content"
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
import { ref, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
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
const isFirstShow = ref(true)

const userStore = useUserStore()

onMounted(() => {
  loadHomeData()
})

// 页面重新显示时刷新数据（从子页面返回首页时数据同步）
onShow(() => {
  if (isFirstShow.value) {
    isFirstShow.value = false
    return
  }
  loadHomeData()
})

/** 加载首页统计数据和最近归档订单列表，将归档数据映射为订单展示格式 */
async function loadHomeData() {
  try {
    const statsRes = await getTodayStats()
    const stats = statsRes.data || statsRes || {}
    const dealCustomer = stats.dealCustomerCount || {}
    const dealAmount = stats.dealAmount || {}
    const paidAmount = stats.paidAmount || {}
    const owedAmount = stats.owedAmount || {}
    const cashAmount = stats.cashAmount || {}
    const cardAmount = stats.cardAmount || {}
    const giftCount = stats.giftCount || {}
    const operationCustomer = stats.operationCustomerCount || {}
    const operationAmount = stats.operationAmount || {}

    combinedStats.value = [
      { label: '成交客数', todayValue: String(dealCustomer.today || 0), monthValue: String(dealCustomer.month || 0) },
      { label: '成交金额', todayValue: formatAmount(dealAmount.today || 0), monthValue: formatAmount(dealAmount.month || 0) },
      { label: '实付金额', todayValue: formatAmount(paidAmount.today || 0), monthValue: formatAmount(paidAmount.month || 0) },
      { label: '欠款金额', todayValue: formatAmount(owedAmount.today || 0), monthValue: formatAmount(owedAmount.month || 0) },
      { label: '现金', todayValue: formatAmount(cashAmount.today || 0), monthValue: formatAmount(cashAmount.month || 0) },
      { label: '耗卡', todayValue: formatAmount(cardAmount.today || 0), monthValue: formatAmount(cardAmount.month || 0) },
      { label: '赠送', todayValue: String(giftCount.today || 0), monthValue: String(giftCount.month || 0) },
      { label: '操作客数', todayValue: String(operationCustomer.today || 0), monthValue: String(operationCustomer.month || 0) },
      { label: '操作金额', todayValue: formatAmount(operationAmount.today || 0), monthValue: formatAmount(operationAmount.month || 0) }
    ].filter(item => {
      const today = String(item.todayValue).replace(/[¥,]/g, '')
      const month = String(item.monthValue).replace(/[¥,]/g, '')
      return parseFloat(today) !== 0 || parseFloat(month) !== 0
    })

    const archiveRes = await listArchive({
      operatorUserId: userStore.getId,
      pageNum: 1,
      pageSize: 20,
      orderByColumn: 'archive_date',
      isAsc: 'desc'
    })
    const filteredRows = (archiveRes.rows || []).filter(item => {
      const st = item.sourceType || item.source_type
      return st !== '3'
    })
    orderList.value = filteredRows.slice(0, 5).map(item => ({
      id: item.archiveId || item.archive_id,
      name: item.customerName || item.customer_name || '',
      store: [item.enterpriseName || item.enterprise_name, item.storeName || item.store_name].filter(Boolean).join('·'),
      avatar: item.avatar || '',
      amount: Number(item.amount || 0).toFixed(2),
      sourceType: item.sourceType || item.source_type,
      sourceId: item.sourceId || item.source_id,
      status: getSourceTypeLabel(item.sourceType || item.source_type),
      createTime: item.createTime || item.create_time || item.archiveDate || item.archive_date,
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
  return '¥' + Math.round(num)
}
</script>

<style lang="scss" scoped>
page { height: 100%; overflow: hidden; }
.home-page {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: #F5F7FA;
  overflow: hidden;
}

.main-content {
  padding-top: 20rpx;
  flex: 1;
  overflow: hidden;
}

.bottom-spacer {
  height: 40rpx;
}
</style>
