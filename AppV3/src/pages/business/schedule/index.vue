<template>
  <view class="schedule-container">
    <view class="search-section">
      <view class="month-picker" @click="showMonthPicker = true" v-if="currentTab === 0 || currentTab === 1">
        <u-icon name="calendar" size="16" color="#fff"></u-icon>
        <text class="month-text">{{ queryParams.yearMonth }}</text>
        <u-icon name="arrow-down" size="12" color="#fff"></u-icon>
      </view>
      <view class="search-box" v-if="currentTab === 0">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="queryParams.keyword" placeholder="搜索员工/企业" placeholder-class="search-placeholder" confirm-type="search" @input="onSearchInput" @confirm="handleSearch" />
        <view v-if="queryParams.keyword" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
        <view class="filter-btn" @click="toggleFilter">
          <text>筛选</text>
          <u-icon name="arrow-down" size="12" :class="{ 'icon-rotate': showFilter }"></u-icon>
        </view>
      </view>
      <view class="search-box" v-if="currentTab === 1">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="enterpriseSearchKeyword" placeholder="搜索企业/员工" placeholder-class="search-placeholder" confirm-type="search" @confirm="getEnterpriseList" />
        <view v-if="enterpriseSearchKeyword" class="clear-btn" @click="enterpriseSearchKeyword = ''; getEnterpriseList()">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>
      <view class="search-box" v-if="currentTab === 2">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="configQueryParams.userName" placeholder="搜索员工姓名" placeholder-class="search-placeholder" confirm-type="search" @confirm="queryConfig" />
        <view v-if="configQueryParams.userName" class="clear-btn" @click="configQueryParams.userName = ''; queryConfig()">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
        <view class="filter-btn" @click="showConfigFilter = !showConfigFilter">
          <text>筛选</text>
          <u-icon name="arrow-down" size="12" :class="{ 'icon-rotate': showConfigFilter }"></u-icon>
        </view>
      </view>
    </view>

    <!-- Tab 0: 员工行程 筛选 -->
    <view v-if="hasActiveFilters && currentTab === 0" class="active-filters">
      <scroll-view scroll-x class="filter-scroll">
        <view class="filter-tags">
          <view v-if="queryParams.purpose" class="filter-tag active" @click="clearFilter('purpose')">
            <text>{{ getPurposeName(queryParams.purpose) }}</text><u-icon name="close" size="12"></u-icon>
          </view>
          <view v-if="queryParams.status" class="filter-tag active" @click="clearFilter('status')">
            <text>{{ getStatusName(queryParams.status) }}</text><u-icon name="close" size="12"></u-icon>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- Tab 2: 员工配置 筛选 -->
    <view v-if="currentTab === 2 && showConfigFilter" class="active-filters">
      <view class="config-filter-bar">
        <view class="config-filter-item">
          <text class="config-filter-label">是否可排班</text>
          <view class="config-filter-options">
            <view class="option-tag" :class="{ active: configQueryParams.isSchedulable === '1' }" @click="configQueryParams.isSchedulable = configQueryParams.isSchedulable === '1' ? '' : '1'">是</view>
            <view class="option-tag" :class="{ active: configQueryParams.isSchedulable === '0' }" @click="configQueryParams.isSchedulable = configQueryParams.isSchedulable === '0' ? '' : '0'">否</view>
          </view>
        </view>
      </view>
    </view>

    <u-popup v-if="showFilter" :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
        <view class="form-item">
          <view class="form-label">下店目的</view>
          <view class="form-options">
            <view v-for="item in purposeOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.purpose === item.value }" @click="queryParams.purpose = queryParams.purpose === item.value ? '' : item.value">{{ item.label }}</view>
          </view>
        </view>
        <view class="form-item">
          <view class="form-label">状态</view>
          <view class="form-options">
            <view v-for="item in statusOptions" :key="item.value" class="option-tag" :class="{ active: queryParams.status === item.value }" @click="queryParams.status = queryParams.status === item.value ? '' : item.value">{{ item.label }}</view>
          </view>
        </view>
        <view class="popup-actions">
          <u-button type="info" plain text="重置" @click="resetFilter"></u-button>
          <u-button type="primary" text="确定" @click="confirmFilter"></u-button>
        </view>
      </view>
    </u-popup>

    <u-datetime-picker v-if="showMonthPicker" :show="showMonthPicker" mode="year-month" v-model="monthPickerValue" @confirm="onMonthConfirm" @cancel="showMonthPicker = false" @close="showMonthPicker = false"></u-datetime-picker>

    <!-- Tabs -->
    <view class="tabs-wrapper">
      <u-tabs :list="tabList" :current="currentTab" @click="onTabChange" :activeStyle="{ color: '#3D6DF7', fontWeight: 'bold' }" :lineColor="'#3D6DF7'" :scrollable="false"></u-tabs>
    </view>

    <!-- Tab 0: 员工行程 -->
    <scroll-view v-if="currentTab === 0" scroll-y class="list-scroll" @scrolltolower="loadMore" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onPullDownRefresh">
      <view v-if="scheduleList.length > 0" class="card-list">
        <view v-for="item in scheduleList" :key="item.scheduleIds[0]" class="schedule-card" @click="goDetail(item)">
          <view class="card-header">
            <view class="user-info">
              <u-icon name="account-fill" size="16" color="#3D6DF7"></u-icon>
              <text class="user-name">{{ item.userName || '-' }}</text>
            </view>
            <view class="status-tag" :class="'status-' + item.status">{{ getStatusName(item.status) }}</view>
          </view>
          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="label">企业</text>
                <text class="value">{{ item.enterpriseName || '-' }}</text>
              </view>
              <view class="info-item">
                <text class="label">目的</text>
                <text class="value purpose-text">{{ getPurposeName(item.purpose) }}</text>
              </view>
            </view>
            <view class="date-tags-row">
              <view class="date-tag" v-for="(date, idx) in getDisplayDates(item.scheduleDates)" :key="idx">
                {{ formatDay(date) }}
              </view>
              <view class="date-tag more" v-if="item.scheduleDates.length > 6">
                +{{ item.scheduleDates.length - 6 }}
              </view>
            </view>
            <view class="info-row" v-if="item.remark">
              <view class="info-item full">
                <text class="label">备注</text>
                <text class="value remark-text">{{ item.remark }}</text>
              </view>
            </view>
          </view>
          <view class="card-footer">
            <view class="time-text">共{{ item.scheduleDates.length }}天</view>
            <view class="action-btns">
              <view class="action-btn edit" v-if="checkPermi('business:schedule:edit')" @click.stop="goEdit(item)">
                <u-icon name="edit-pen" size="14"></u-icon><text>编辑</text>
              </view>
              <view class="action-btn delete" v-if="checkPermi('business:schedule:remove')" @click.stop="handleDelete(item)">
                <u-icon name="trash" size="14"></u-icon><text>删除</text>
              </view>
            </view>
          </view>
        </view>
      </view>
      <u-empty v-else-if="!loading" mode="data" text="暂无行程数据" :marginTop="100"></u-empty>
      <u-loadmore :status="loadStatus" :loading-text="'加载中...'" :loadmore-text="'上拉加载更多'" :nomore-text="'没有更多了'" :marginTop="20" />
    </scroll-view>

    <!-- Tab 1: 企业排班 -->
    <scroll-view v-if="currentTab === 1" scroll-y class="list-scroll" refresher-enabled :refresher-triggered="enterpriseRefreshing" @refresherrefresh="onEnterpriseRefresh">
      <view v-if="enterpriseScheduleList.length > 0" class="card-list">
        <view v-for="group in enterpriseScheduleList" :key="group.enterpriseId" class="enterprise-group">
          <view class="enterprise-header">
            <u-icon name="home-fill" size="16" color="#3D6DF7"></u-icon>
            <text class="enterprise-name">{{ group.enterpriseName }}</text>
            <text class="enterprise-count">{{ group.schedules.length }}人</text>
          </view>
          <view v-for="(item, idx) in group.schedules" :key="idx" class="schedule-card enterprise-schedule-card">
            <view class="card-header">
              <view class="user-info">
                <u-icon name="account-fill" size="16" color="#3D6DF7"></u-icon>
                <text class="user-name">{{ item.userName || '-' }}</text>
              </view>
              <view class="status-tag" :class="'status-' + item.status">{{ getStatusName(item.status) }}</view>
            </view>
            <view class="card-body">
              <view class="info-row">
                <view class="info-item full">
                  <text class="label">目的</text>
                  <text class="value purpose-text">{{ getPurposeName(item.purpose) }}</text>
                </view>
              </view>
              <view class="date-tags-row">
                <view class="date-tag" v-for="(date, dIdx) in item.scheduleDates" :key="dIdx">
                  {{ formatDay(date) }}
                </view>
                <view class="date-tag more" v-if="item.scheduleDates.length > 6">
                  +{{ item.scheduleDates.length - 6 }}
                </view>
              </view>
              <view class="info-row" v-if="item.remark">
                <view class="info-item full">
                  <text class="label">备注</text>
                  <text class="value remark-text">{{ item.remark }}</text>
                </view>
              </view>
            </view>
          </view>
        </view>
      </view>
      <u-empty v-else-if="!enterpriseLoading" mode="data" text="暂无企业排班数据" :marginTop="100"></u-empty>
      <u-loadmore v-else :status="'loading'" :loading-text="'加载中...'" :marginTop="20" />
    </scroll-view>

    <!-- Tab 2: 员工配置 -->
    <scroll-view v-if="currentTab === 2" scroll-y class="list-scroll" refresher-enabled :refresher-triggered="configRefreshing" @refresherrefresh="onConfigRefresh">
      <view v-if="employeeConfigList.length > 0" class="card-list">
        <view v-for="item in employeeConfigList" :key="item.userId" class="schedule-card config-card">
          <view class="card-header">
            <view class="user-info">
              <u-icon name="account-fill" size="16" color="#3D6DF7"></u-icon>
              <text class="user-name">{{ item.userName || '-' }}</text>
              <text v-if="item.deptName" class="dept-tag">{{ item.deptName }}</text>
            </view>
            <view class="schedulable-switch" v-if="hasEditPermi">
              <text class="switch-label">可排班</text>
              <u-switch v-model="item.isSchedulable" activeValue="1" inactiveValue="0" @change="handleSchedulableChange(item)" :activeColor="'#3D6DF7'"></u-switch>
            </view>
            <view v-else class="schedulable-status">
              <text :class="item.isSchedulable === '1' ? 'schedulable-yes' : 'schedulable-no'">{{ item.isSchedulable === '1' ? '可排班' : '不可排班' }}</text>
            </view>
          </view>
          <view class="card-body">
            <view class="info-row">
              <view class="info-item full">
                <text class="label">休息日</text>
                <view class="rest-dates-wrap" v-if="item.restDates && item.restDates.length > 0">
                  <view class="date-tag rest" v-for="(date, idx) in item.restDates" :key="idx">{{ formatDay(date) }}</view>
                </view>
                <text class="value remark-text" v-else>未配置</text>
              </view>
            </view>
          </view>
          <view class="card-footer" v-if="hasEditPermi">
            <view></view>
            <view class="action-btns">
              <view class="action-btn edit" @click="openRestDateConfig(item)">
                <u-icon name="calendar" size="14"></u-icon><text>配置休息日</text>
              </view>
            </view>
          </view>
        </view>
      </view>
      <u-empty v-else-if="!configLoading" mode="data" text="暂无员工配置数据" :marginTop="100"></u-empty>
      <u-loadmore v-else :status="'loading'" :loading-text="'加载中...'" :marginTop="20" />
    </scroll-view>

    <!-- FAB: 仅在员工行程Tab显示 -->
    <view class="fab-btn" v-if="(currentTab === 0 || currentTab === 1) && checkPermi('business:schedule:add')" @click="goAdd">
      <u-icon name="plus" size="24" color="#fff"></u-icon>
    </view>

    <!-- 休息日期配置日历 -->
    <u-calendar
      :show="showRestDateCalendar"
      mode="multiple"
      :defaultDate="tempRestDates"
      :color="'#3D6DF7'"
      @confirm="onRestDateConfirm"
      @close="showRestDateCalendar = false"
    ></u-calendar>
  </view>
</template>

<script setup>
/**
 * @description 行程管理页 - 员工行程/企业排班/员工配置三Tab
 * @description Tab1: 员工行程列表，支持月份选择、筛选、搜索
 * Tab2: 企业排班，按企业分组展示排班数据
 * Tab3: 员工配置，管理员工排班开关和休息日期
 */
import { ref, reactive, onMounted, computed, onUnmounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listSchedule, delSchedule, getEnterpriseSchedule } from '@/api/business/schedule'
import { listEmployeeConfig, updateSchedulable, saveRestDates, getRestDates } from '@/api/business/employeeConfig'
import { checkPermi } from '@/utils/permission'

// ==================== 通用 ====================
const currentTab = ref(0)
const showMonthPicker = ref(false)
const monthPickerValue = ref(Number(new Date()))

const tabList = computed(() => {
  const list = [{ name: '员工行程' }, { name: '企业排班' }]
  if (checkPermi('business:employeeConfig:list')) {
    list.push({ name: '员工配置' })
  }
  return list
})

const hasEditPermi = computed(() => checkPermi('business:employeeConfig:edit'))

function onTabChange(e) {
  currentTab.value = e.index
  if (currentTab.value === 1) {
    getEnterpriseList()
  } else if (currentTab.value === 2) {
    queryConfig()
  }
}

function onMonthConfirm(e) {
  const date = new Date(e.value)
  queryParams.yearMonth = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`
  showMonthPicker.value = false
  if (currentTab.value === 0) {
    getList(true)
  } else if (currentTab.value === 1) {
    getEnterpriseList()
  }
}

const purposeOptions = ref([
  { label: '爆卡', value: '1' },
  { label: '销售', value: '2' },
  { label: '售后', value: '3' },
  { label: '业务', value: '4' }
])

const statusOptions = ref([
  { label: '已预约', value: '1' },
  { label: '服务中', value: '2' },
  { label: '已完成', value: '3' },
  { label: '已取消', value: '4' }
])

function getPurposeName(value) {
  const item = purposeOptions.value.find(p => p.value === String(value))
  return item ? item.label : '-'
}

function getStatusName(value) {
  const item = statusOptions.value.find(s => s.value === String(value))
  return item ? item.label : '-'
}

function formatDay(dateStr) {
  if (!dateStr) return ''
  return dateStr.substring(5)
}

// ==================== Tab 0: 员工行程 ====================
const scheduleList = ref([])
const rawLoadedCount = ref(0)
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)

let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const hasActiveFilters = computed(() => queryParams.purpose || queryParams.status)

const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  keyword: '',
  yearMonth: new Date().toISOString().slice(0, 7),
  purpose: '',
  status: ''
})

function groupScheduleList(list) {
  const groupMap = new Map()

  list.forEach(item => {
    const key = `${item.userId}_${item.enterpriseId}_${item.purpose}_${item.status}_${item.remark || ''}`

    if (!groupMap.has(key)) {
      groupMap.set(key, {
        ...item,
        scheduleIds: [item.scheduleId],
        scheduleDates: [item.scheduleDate]
      })
    } else {
      const group = groupMap.get(key)
      if (!group.scheduleIds.includes(item.scheduleId)) {
        group.scheduleIds.push(item.scheduleId)
      }
      if (!group.scheduleDates.includes(item.scheduleDate)) {
        group.scheduleDates.push(item.scheduleDate)
      }
    }
  })

  const result = Array.from(groupMap.values())
    .map(group => {
      // 以 {id, date} 配对后按 date 同步排序，确保 scheduleIds 与 scheduleDates 索引一致
      const pairs = []
      const seen = new Set()
      group.scheduleDates.forEach((date, idx) => {
        const id = group.scheduleIds[idx]
        const key = `${date}_${id}`
        if (!seen.has(key)) {
          seen.add(key)
          pairs.push({ id, date })
        }
      })
      pairs.sort((a, b) => new Date(a.date) - new Date(b.date))
      return {
        ...group,
        scheduleIds: pairs.map(p => p.id),
        scheduleDates: pairs.map(p => p.date)
      }
    })
    .sort((a, b) => new Date(a.scheduleDates[0]) - new Date(b.scheduleDates[0]))

  return result
}

function getDisplayDates(dates) {
  return dates.slice(0, 6)
}

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) { queryParams.pageNum = 1; loadStatus.value = 'loadmore' }

  try {
    const [year, month] = queryParams.yearMonth.split('-')
    const startDate = `${year}-${month}-01`
    const endDate = `${year}-${month}-${new Date(year, month, 0).getDate()}`
    const params = { ...queryParams, startDate, endDate }
    // keyword 直接传给后端，后端做 OR 模糊搜索（员工名/企业名）
    delete params.yearMonth

    const response = await listSchedule(params)
    const data = response.data || response
    const list = data.rows || []
    const total = data.total || 0

    const grouped = groupScheduleList(list)

    if (isRefresh) {
      scheduleList.value = grouped
      rawLoadedCount.value = list.length
    } else {
      const existingIds = new Set(scheduleList.value.flatMap(item => item.scheduleIds))
      const newItems = grouped.filter(item =>
        !item.scheduleIds.some(id => existingIds.has(id))
      )
      scheduleList.value = [...scheduleList.value, ...newItems]
      rawLoadedCount.value += list.length
    }

    loadStatus.value = rawLoadedCount.value >= total ? 'nomore' : 'loadmore'
  } catch (e) {
    console.error('获取行程列表失败:', e)
    loadStatus.value = 'error'
  } finally { loading.value = false; refreshing.value = false }
}

function loadMore() {
  if (loading.value || loadStatus.value === 'nomore') return
  loadStatus.value = 'loading'
  queryParams.pageNum++
  getList()
}

function onPullDownRefresh() { refreshing.value = true; getList(true) }
function handleSearch() { getList(true) }
function onSearchInput() { if (searchTimer) clearTimeout(searchTimer); searchTimer = setTimeout(() => handleSearch(), 500) }
function clearKeyword() { queryParams.keyword = ''; handleSearch() }
function toggleFilter() { showFilter.value = !showFilter.value }
function resetFilter() { queryParams.purpose = ''; queryParams.status = '' }
function confirmFilter() { showFilter.value = false; getList(true) }
function clearFilter(field) { queryParams[field] = ''; getList(true) }

function goDetail(item) {
  uni.setStorageSync('scheduleGroupData', { scheduleIds: item.scheduleIds, scheduleDates: item.scheduleDates })
  uni.navigateTo({ url: `/pages/business/schedule/form?id=${item.scheduleIds[0]}&mode=view` })
}
function goEdit(item) {
  uni.setStorageSync('scheduleGroupData', { scheduleIds: item.scheduleIds, scheduleDates: item.scheduleDates })
  uni.navigateTo({ url: `/pages/business/schedule/form?id=${item.scheduleIds[0]}&mode=edit` })
}
function goAdd() {
  let url = '/pages/business/schedule/form?mode=add'
  if (currentTab.value === 1) {
    url += '&from=enterprise'
    if (enterpriseScheduleList.value.length === 1) {
      const ent = enterpriseScheduleList.value[0]
      url += `&enterpriseId=${ent.enterpriseId}&enterpriseName=${encodeURIComponent(ent.enterpriseName)}`
    }
  }
  uni.navigateTo({ url })
}

function handleDelete(item) {
  uni.showModal({
    title: '提示', content: `是否确认删除该行程（共${item.scheduleIds.length}天）?`,
    success: async (res) => {
      if (res.confirm) {
        try { await delSchedule(item.scheduleIds.join(',')); uni.showToast({ title: '删除成功', icon: 'success' }); getList(true) }
        catch (e) { console.error('删除失败:', e) }
      }
    }
  })
}

// ==================== Tab 1: 企业排班 ====================
const enterpriseScheduleList = ref([])
const enterpriseLoading = ref(false)
const enterpriseRefreshing = ref(false)
const enterpriseSearchKeyword = ref('')

async function getEnterpriseList() {
  enterpriseLoading.value = true
  try {
    const [year, month] = queryParams.yearMonth.split('-')
    const startDate = `${year}-${month}-01`
    const endDate = `${year}-${month}-${new Date(year, month, 0).getDate()}`
    const params = { startDate, endDate }
    if (enterpriseSearchKeyword.value) {
      params.keyword = enterpriseSearchKeyword.value
    }
    const response = await getEnterpriseSchedule(params)
    const data = response.data || response
    const list = Array.isArray(data) ? data : (data.rows || [])

    // 后端已按企业分组，schedules 是日期键值对映射 { day: scheduleObj }
    // 需要将 schedules 映射转为数组
    enterpriseScheduleList.value = list.map(group => {
      const scheduleMap = group.schedules || {}
      const rawSchedules = Object.values(scheduleMap).flat().map(s => ({
        ...s,
        scheduleDate: s.scheduleDate || s.schedule_date || ''
      }))

      // Group by userId to merge same employee's dates
      const employeeMap = new Map()
      rawSchedules.forEach(s => {
        const userId = s.userId || s.user_id
        const key = `${userId}_${s.purpose || ''}_${s.status || ''}`
        if (!employeeMap.has(key)) {
          employeeMap.set(key, {
            ...s,
            scheduleDates: [s.scheduleDate]
          })
        } else {
          const existing = employeeMap.get(key)
          if (!existing.scheduleDates.includes(s.scheduleDate)) {
            existing.scheduleDates.push(s.scheduleDate)
          }
        }
      })

      const schedules = Array.from(employeeMap.values()).map(item => ({
        ...item,
        scheduleDates: [...new Set(item.scheduleDates)].sort()
      }))

      return {
        enterpriseId: group.enterpriseId || group.enterprise_id,
        enterpriseName: group.enterpriseName || group.enterprise_name || '未知企业',
        schedules
      }
    })
  } catch (e) {
    console.error('获取企业排班失败:', e)
    enterpriseScheduleList.value = []
  } finally {
    enterpriseLoading.value = false
    enterpriseRefreshing.value = false
  }
}

function onEnterpriseRefresh() {
  enterpriseRefreshing.value = true
  getEnterpriseList()
}

// ==================== Tab 2: 员工配置 ====================
const employeeConfigList = ref([])
const configLoading = ref(false)
const configRefreshing = ref(false)
const showConfigFilter = ref(false)
const showRestDateCalendar = ref(false)
const currentConfigUser = ref({})
const tempRestDates = ref([])

const configQueryParams = reactive({
  pageNum: 1,
  pageSize: 50,
  userName: '',
  deptName: '',
  isSchedulable: ''
})

async function queryConfig() {
  configLoading.value = true
  try {
    const params = { ...configQueryParams }
    // 清理空值
    Object.keys(params).forEach(key => {
      if (params[key] === '' || params[key] === undefined || params[key] === null) {
        delete params[key]
      }
    })
    const response = await listEmployeeConfig(params)
    const data = response.data || response
    employeeConfigList.value = data.rows || []
  } catch (e) {
    console.error('获取员工配置失败:', e)
    employeeConfigList.value = []
  } finally {
    configLoading.value = false
    configRefreshing.value = false
  }
}

function onConfigRefresh() {
  configRefreshing.value = true
  queryConfig()
}

async function handleSchedulableChange(row) {
  try {
    await updateSchedulable(row.userId, row.isSchedulable)
    uni.showToast({ title: '更新成功', icon: 'success' })
  } catch (e) {
    // 回滚
    row.isSchedulable = row.isSchedulable === '1' ? '0' : '1'
    uni.showToast({ title: '更新失败', icon: 'none' })
  }
}

function openRestDateConfig(row) {
  currentConfigUser.value = row
  tempRestDates.value = []
  // 加载已有休息日期后打开日历
  getRestDates(row.userId).then(response => {
    const dates = response.data || []
    tempRestDates.value = dates
    showRestDateCalendar.value = true
  }).catch(() => {
    showRestDateCalendar.value = true
  })
}

async function onRestDateConfirm(e) {
  // u-calendar confirm returns selected dates array
  const items = Array.isArray(e) ? e : (e ? [e] : [])
  const selectedDates = items.map(d => {
    if (typeof d === 'string') return d
    if (d && typeof d === 'object' && d.year !== undefined) {
      return `${d.year}-${String(d.month).padStart(2, '0')}-${String(d.day).padStart(2, '0')}`
    }
    if (d instanceof Date) {
      return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
    }
    return String(d)
  })

  // Save rest dates directly
  try {
    await saveRestDates(currentConfigUser.value.userId, selectedDates)
    uni.showToast({ title: '保存成功', icon: 'success' })
    showRestDateCalendar.value = false
    queryConfig()
  } catch (err) {
    uni.showToast({ title: '保存失败', icon: 'none' })
  }
}

// ==================== 初始化 ====================
onMounted(() => { getList(true) })
onShow(() => { getList(true) })
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.schedule-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx;
  :deep(.u-popup) { flex: none !important; }
}

.search-section { flex-shrink: 0; padding: 20rpx 24rpx; margin-left: -24rpx; margin-right: -24rpx; background: linear-gradient(180deg, #3D6DF7 0%, #4A7AEF 100%); }
.month-picker { display: flex; align-items: center; justify-content: center; gap: 8rpx; margin-bottom: 16rpx; }
.month-text { font-size: 30rpx; font-weight: 600; color: #fff; }

.search-box { display: flex; align-items: center; background: #fff; border-radius: 36rpx; padding: 0 8rpx 0 28rpx; height: 72rpx; gap: 12rpx; box-sizing: border-box; }
.search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; min-width: 0; }
.search-placeholder { color: #86909C; font-size: 28rpx; }
.clear-btn { flex-shrink: 0; padding: 8rpx; display: flex; align-items: center; }
.filter-btn { flex-shrink: 0; display: flex; align-items: center; justify-content: center; gap: 4rpx; height: 56rpx; padding: 0 22rpx; background: #E8F0FE; border-radius: 28rpx;
  text { font-size: 26rpx; color: #3D6DF7; font-weight: 500; white-space: nowrap; }
  .icon-rotate { transform: rotate(180deg); transition: transform 0.3s ease; }
}

.active-filters { flex-shrink: 0; padding: 12rpx 24rpx 16rpx; margin-left: -24rpx; margin-right: -24rpx; background: linear-gradient(180deg, #4A7AEF 0%, #F5F7FA 100%); }
.filter-scroll { white-space: nowrap; }
.filter-tags { display: inline-flex; gap: 16rpx; padding: 16rpx 0; }
.filter-tag { display: inline-flex; align-items: center; gap: 8rpx; padding: 10rpx 20rpx; background: rgba(255,255,255,0.2); border-radius: 28rpx; font-size: 24rpx; color: #fff;
  &.active { background: #fff; color: #3D6DF7; }
}

.config-filter-bar { padding: 12rpx 0; }
.config-filter-item { margin-bottom: 12rpx; }
.config-filter-label { font-size: 26rpx; color: #fff; margin-bottom: 8rpx; }
.config-filter-options { display: flex; gap: 12rpx; }

.popup-content { padding: 30rpx; background: #fff; }
.popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; margin-bottom: 30rpx; }
.form-item { margin-bottom: 30rpx; }
.form-label { font-size: 28rpx; color: #1D2129; font-weight: 500; margin-bottom: 16rpx; }
.form-options { display: flex; flex-wrap: wrap; gap: 16rpx; }
.option-tag { padding: 14rpx 28rpx; background: #F5F7FA; border-radius: 8rpx; font-size: 26rpx; color: #4E5969; border: 2rpx solid transparent;
  &.active { background: #E8F0FE; color: #3D6DF7; border-color: #3D6DF7; }
}
.popup-actions { display: flex; gap: 20rpx; margin-top: 40rpx; padding-top: 30rpx; border-top: 1rpx solid #E5E6EB; .u-button { flex: 1; } }

.tabs-wrapper { flex-shrink: 0; background: #fff; }

.list-scroll { flex: 1; overflow: hidden; padding: 20rpx 0; }
.card-list { display: flex; flex-direction: column; gap: 20rpx; }

.schedule-card { background: #fff; border-radius: 16rpx; padding: 28rpx; box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
  &:active { transform: scale(0.98); opacity: 0.9; }
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.user-info { display: flex; align-items: center; gap: 8rpx; flex: 1; min-width: 0; }
.user-name { font-size: 28rpx; font-weight: 600; color: #1D2129; }
.status-tag { padding: 6rpx 16rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-1 { background: #E8F0FE; color: #3D6DF7; }
  &.status-2 { background: #FFF7E8; color: #FF7D00; }
  &.status-3 { background: #E8FFEA; color: #00B42A; }
  &.status-4 { background: #F2F3F5; color: #86909C; }
}

.card-body { padding: 20rpx 0; border-top: 1rpx solid #F2F3F5; border-bottom: 1rpx solid #F2F3F5; }
.info-row { display: flex; margin-bottom: 16rpx; &:last-child { margin-bottom: 0; } }
.info-item { flex: 1; display: flex; align-items: center; gap: 12rpx;
  &.full { flex: none; width: 100%; }
  .label { font-size: 24rpx; color: #86909C; min-width: 60rpx; flex-shrink: 0; }
  .value { font-size: 26rpx; color: #1D2129;
    &.purpose-text { color: #3D6DF7; }
    &.remark-text { color: #86909C; }
  }
}

.date-tags-row {
  display: flex;
  flex-wrap: nowrap;
  gap: 12rpx;
  margin-top: 16rpx;
  overflow: hidden;
}

.date-tag {
  padding: 6rpx 16rpx;
  background: #F7F8FA;
  border-radius: 6rpx;
  font-size: 22rpx;
  color: #4E5969;
  flex-shrink: 0;

  &.more { background: #E8F0FE; color: #3D6DF7; }
  &.rest { background: #FFF1F0; color: #F53F3F; }
}

.card-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 20rpx; padding-top: 16rpx; }
.time-text { font-size: 22rpx; color: #C9CDD4; }
.action-btns { display: flex; gap: 24rpx; }
.action-btn { display: flex; align-items: center; gap: 6rpx; font-size: 24rpx; padding: 8rpx 16rpx; border-radius: 8rpx;
  &.edit { color: #3D6DF7; background: #E8F0FE; }
  &.delete { color: #F53F3F; background: #FFF1F0; }
}

.fab-btn { position: fixed; right: 32rpx; bottom: 120rpx; width: 100rpx; height: 100rpx; border-radius: 50%; background: linear-gradient(135deg, #FF6B35, #FF8F5E); display: flex; align-items: center; justify-content: center; box-shadow: 0 8rpx 24rpx rgba(255,107,53,0.4);
  &:active { transform: scale(0.95); opacity: 0.9; }
}

/* 企业排班样式 */
.enterprise-group { margin-bottom: 20rpx; }
.enterprise-header { display: flex; align-items: center; gap: 10rpx; padding: 16rpx 20rpx; background: #E8F0FE; border-radius: 12rpx 12rpx 0 0; }
.enterprise-name { font-size: 28rpx; font-weight: 600; color: #3D6DF7; flex: 1; }
.enterprise-count { font-size: 22rpx; color: #86909C; }
.enterprise-schedule-card { border-radius: 0; box-shadow: none; border-bottom: 1rpx solid #F2F3F5;
  &:last-child { border-bottom: none; border-radius: 0 0 12rpx 12rpx; }
}

/* 员工配置样式 */
.config-card { padding: 24rpx 28rpx; }
.dept-tag { font-size: 22rpx; color: #86909C; background: #F2F3F5; padding: 2rpx 12rpx; border-radius: 4rpx; margin-left: 8rpx; }
.schedulable-switch { display: flex; align-items: center; gap: 8rpx; flex-shrink: 0; }
.switch-label { font-size: 24rpx; color: #4E5969; }
.schedulable-status { flex-shrink: 0; }
.schedulable-yes { font-size: 24rpx; color: #00B42A; font-weight: 500; }
.schedulable-no { font-size: 24rpx; color: #F53F3F; font-weight: 500; }
.rest-dates-wrap { display: flex; flex-wrap: wrap; gap: 8rpx; }
</style>
