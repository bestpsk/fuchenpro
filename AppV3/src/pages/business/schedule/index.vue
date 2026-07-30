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
              <view class="date-tag" :class="{'rest': d.type === 'rest', 'leave': d.type === 'leave'}" v-for="(d, idx) in getDisplayDatesWithStatus(item).slice(0, 6)" :key="idx">
                {{ d.label }}
              </view>
              <view class="date-tag more" v-if="getDisplayDatesWithStatus(item).length > 6">
                +{{ getDisplayDatesWithStatus(item).length - 6 }}
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
                <view class="date-tag" :class="{'rest': d.type === 'rest', 'leave': d.type === 'leave'}" v-for="(d, dIdx) in getDisplayDatesWithStatus(item).slice(0, 6)" :key="dIdx">
                  {{ d.label }}
                </view>
                <view class="date-tag more" v-if="getDisplayDatesWithStatus(item).length > 6">
                  +{{ getDisplayDatesWithStatus(item).length - 6 }}
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
                <view class="action-btn edit" v-if="checkPermi('business:schedule:edit')" @click.stop="goEdit(item, true)">
                  <u-icon name="edit-pen" size="14"></u-icon><text>编辑</text>
                </view>
                <view class="action-btn delete" v-if="checkPermi('business:schedule:remove')" @click.stop="handleDelete(item, getEnterpriseList)">
                  <u-icon name="trash" size="14"></u-icon><text>删除</text>
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
              <u-switch v-model="item.isSchedulable" activeValue="1" inactiveValue="0" size="small" @change="handleSchedulableChange(item)" :activeColor="'#3D6DF7'"></u-switch>
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
                  <view class="date-tag rest" v-for="(d, idx) in item.restDates" :key="idx">{{ formatDay(typeof d === 'string' ? d : d.date) }}</view>
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

    <!-- 休息日期配置弹窗 -->
    <u-popup :show="showRestDateConfig" mode="bottom" round="16" @close="showRestDateConfig = false">
      <view class="rest-config-popup">
        <view class="rest-config-header">
          <text class="rest-config-title">配置休息日</text>
          <view class="rest-config-close" @click="showRestDateConfig = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <view class="rest-config-body">
          <view class="rest-config-user">
            <text class="rest-config-label">员工：</text>
            <text class="rest-config-name">{{ currentConfigUser.userName || '-' }}</text>
          </view>

          <!-- 休假类型选择器 -->
          <view class="rest-type-section">
            <view class="rest-type-label"><u-icon name="tags" size="14" color="#3D6DF7"></u-icon><text>休息日类型</text></view>
            <scroll-view scroll-x class="rest-type-scroll">
              <view class="rest-type-tags">
                <view v-for="t in leaveTypes" :key="t.typeId" class="rest-type-tag" :class="{ active: String(selectedTypeId) === String(t.typeId) }" @click="onTypeSelect(t.typeId, t.typeName)">
                  {{ t.typeName }}
                </view>
                <view v-if="leaveTypes.length === 0" class="rest-type-empty">暂无休假类型，请到休假管理添加</view>
              </view>
            </scroll-view>
          </view>

          <!-- 图例（展示所有休息日类型及数量） -->
          <view class="rest-legend" v-if="allRestTypeList.length > 0">
            <view class="rest-legend-item" v-for="t in allRestTypeList" :key="t.type">
              <view class="rest-legend-dot" :style="{ background: t.color }"></view>
              <text class="rest-legend-text">{{ t.name }} {{ t.count }}天</text>
            </view>
          </view>

          <!-- 已选自定义休息日列表 -->
          <view class="rest-selected-section">
            <view class="rest-selected-header">
              <text class="rest-selected-title">已选休息日（{{ customDateList.length }}天）</text>
              <view class="rest-add-btn" @click="openCalendarPicker"><u-icon name="plus" size="12" color="#fff"></u-icon><text>选择日期</text></view>
            </view>
            <view class="rest-selected-empty" v-if="customDateList.length === 0" @click="openCalendarPicker">
              <u-icon name="calendar" size="32" color="#C9CDD4"></u-icon>
              <text class="rest-empty-text">点击选择休息日期</text>
            </view>
            <view class="rest-selected-list" v-else>
              <view class="rest-selected-chip" v-for="item in customDateList" :key="item.date">
                <text class="chip-date">{{ item.date.substring(5) }}</text>
                <text class="chip-type">{{ item.typeName }}</text>
                <view class="chip-remove" @click="removeCustomDate(item.date)"><u-icon name="close" size="12" color="#86909C"></u-icon></view>
              </view>
            </view>
          </view>
        </view>
        <view class="rest-config-footer">
          <u-button type="info" plain text="取消" @click="showRestDateConfig = false"></u-button>
          <u-button type="primary" text="保存" :loading="restSaving" @click="saveRestDateConfig"></u-button>
        </view>
      </view>
    </u-popup>

    <!-- 休息日期选择日历（带类型标注） -->
    <u-calendar
      :show="showRestCalendar"
      mode="multiple"
      :defaultDate="calendarDefaultDates"
      :maxDate="calendarMaxDate"
      :minDate="calendarMinDate"
      :monthNum="48"
      :formatter="restDateFormatter"
      :color="'#3D6DF7'"
      @confirm="onCalendarConfirm"
      @close="showRestCalendar = false"
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
import { listEmployeeConfig, updateSchedulable, saveRestDates, getAllRestDatesAll, getAllRestDatesBatch } from '@/api/business/employeeConfig'
import { getLeaveCalendar, listAllLeaveType } from '@/api/business/leave'
import { getDicts } from '@/api/system/dictData'
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

/** 动态加载行程目的和状态的字典数据，失败时保留硬编码兜底 */
async function loadDictData() {
  try {
    const [purposeRes, statusRes] = await Promise.all([
      getDicts('biz_schedule_purpose'),
      getDicts('biz_schedule_status')
    ])
    const purposeData = (purposeRes.data || [])
    const statusData = (statusRes.data || [])
    if (purposeData.length > 0) {
      purposeOptions.value = purposeData.map(p => ({ label: p.dictLabel, value: p.dictValue }))
    }
    if (statusData.length > 0) {
      statusOptions.value = statusData.map(p => ({ label: p.dictLabel, value: p.dictValue }))
    }
  } catch (e) { console.error('加载字典数据失败:', e) }
}

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

// ==================== 休息日/请假数据（供日历格子标注，与Web端对齐） ====================
const restDateMap = ref({})
const leaveDateMap = ref({})

/** 收集当前Tab列表中所有员工的userId（去重） */
function getCurrentUserIds() {
  const ids = new Set()
  if (currentTab.value === 0) {
    scheduleList.value.forEach(item => {
      if (item.userId) ids.add(item.userId)
    })
  } else if (currentTab.value === 1) {
    enterpriseScheduleList.value.forEach(group => {
      (group.schedules || []).forEach(s => {
        if (s.userId) ids.add(s.userId)
      })
    })
  }
  return Array.from(ids)
}

/** 批量加载所有员工的某月休息日（含轮休/请假/自定义/法定假日，带类型），结果存入 restDateMap */
async function loadRestDateMap() {
  const userIds = getCurrentUserIds()
  if (!userIds.length) {
    restDateMap.value = {}
    return
  }
  try {
    // 使用批量API获取所有休息日，带类型信息
    const res = await getAllRestDatesBatch(userIds, queryParams.yearMonth)
    const arr = res.data || []
    const map = {}
    arr.forEach(item => {
      const userMap = {}
      ;(item.dates || []).forEach(d => {
        userMap[d.date] = d
      })
      map[item.userId] = userMap
    })
    restDateMap.value = map
  } catch (e) {
    console.error('加载休息日数据失败:', e)
    restDateMap.value = {}
  }
}

/** 批量加载所有员工的某月请假日期，结果存入 leaveDateMap */
async function loadLeaveDateMap() {
  const userIds = getCurrentUserIds()
  if (!userIds.length) {
    leaveDateMap.value = {}
    return
  }
  try {
    const res = await getLeaveCalendar({
      yearMonth: queryParams.yearMonth,
      userIds: userIds.join(',')
    })
    leaveDateMap.value = res.data || {}
  } catch (e) {
    console.error('加载请假数据失败:', e)
    leaveDateMap.value = {}
  }
}

/**
 * 合并行程日期 + 休息日 + 请假日，按日期排序后返回带类型信息的数组
 * 显示优先级：休息日 > 请假 > 行程
 * @param {object} item - 行程卡片数据（含 userId, scheduleDates）
 * @returns {Array<{date, label, type}>} type: 'rest' | 'leave' | 'schedule'
 */
function getDisplayDatesWithStatus(item) {
  const scheduleDates = item.scheduleDates || []
  const userId = item.userId

  // 无userId或无休息/请假数据时，仅返回行程日期
  if (!userId || (Object.keys(restDateMap.value).length === 0 && Object.keys(leaveDateMap.value).length === 0)) {
    return scheduleDates.map(date => ({ date, label: formatDay(date), type: 'schedule' }))
  }

  const restMap = restDateMap.value[userId] || {}
  const restDates = Object.keys(restMap)
  const leaves = leaveDateMap.value[userId] || []
  const leaveDates = leaves.map(l => l.date)

  // 合并所有日期并去重排序
  const allDatesSet = new Set([...scheduleDates, ...restDates, ...leaveDates])
  const allDates = Array.from(allDatesSet).sort()

  return allDates.map(date => {
    if (restMap[date]) {
      return { date, label: restMap[date].typeName || '休息', type: 'rest' }
    }
    const leave = leaves.find(l => l.date === date)
    if (leave) {
      return { date, label: leave.label || leave.typeName || '请假', type: 'leave' }
    }
    return { date, label: formatDay(date), type: 'schedule' }
  })
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

    // 行程列表已更新，加载休息日和请假数据用于日历格子标注（异步，不阻塞加载状态）
    loadRestDateMap()
    loadLeaveDateMap()

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
function goEdit(item, fromEnterprise = false) {
  uni.setStorageSync('scheduleGroupData', { scheduleIds: item.scheduleIds, scheduleDates: item.scheduleDates })
  let url = `/pages/business/schedule/form?id=${item.scheduleIds[0]}&mode=edit`
  if (fromEnterprise) url += '&from=enterprise'
  uni.navigateTo({ url })
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

function handleDelete(item, refreshFn = getList) {
  uni.showModal({
    title: '提示', content: `是否确认删除该行程（共${item.scheduleIds.length}天）?`,
    success: async (res) => {
      if (res.confirm) {
        try { await delSchedule(item.scheduleIds.join(',')); uni.showToast({ title: '删除成功', icon: 'success' }); refreshFn(true) }
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
            scheduleIds: [s.scheduleId || s.schedule_id],
            scheduleDates: [s.scheduleDate]
          })
        } else {
          const existing = employeeMap.get(key)
          const sid = s.scheduleId || s.schedule_id
          if (sid && !existing.scheduleIds.includes(sid)) {
            existing.scheduleIds.push(sid)
          }
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

    // 企业排班列表已更新，加载休息日和请假数据用于日历格子标注（异步，不阻塞加载状态）
    loadRestDateMap()
    loadLeaveDateMap()
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
const showRestDateConfig = ref(false)
const showRestCalendar = ref(false)
const currentConfigUser = ref({})
const restSaving = ref(false)

// 休假类型列表（取自休假管理）
const leaveTypes = ref([])
// 当前选择的休假类型
const selectedTypeId = ref(null)
const selectedTypeName = ref('')
// 所有休息日数据（含轮休/请假/自定义/法定假日），用于日历标注
const allRestDateMap = ref({})
const allRestTypeList = ref([])
// 自定义休息日 map: {dateStr: {date, typeId, typeName}}
const customDateMap = ref({})
// 日历日期范围
const calendarMinDate = ref(Number(new Date(new Date().setFullYear(new Date().getFullYear() - 2))))
const calendarMaxDate = ref(Number(new Date(new Date().setFullYear(new Date().getFullYear() + 1))))

// 已选自定义休息日列表（排序后展示）
const customDateList = computed(() => {
  return Object.values(customDateMap.value).sort((a, b) => a.date.localeCompare(b.date))
})

// 日历默认选中日期（已有自定义休息日）
const calendarDefaultDates = computed(() => {
  return Object.keys(customDateMap.value).sort()
})

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

/** 打开休息日配置弹窗，加载休假类型和所有休息日数据（全量，支持跨月查看和回显） */
async function openRestDateConfig(row) {
  currentConfigUser.value = row
  selectedTypeId.value = null
  selectedTypeName.value = ''
  allRestDateMap.value = {}
  allRestTypeList.value = []
  customDateMap.value = {}
  showRestDateConfig.value = true

  try {
    // 并行加载休假类型列表和全部休息日数据（不限月份，2年前~1年后）
    const [typeRes, allRes] = await Promise.all([
      listAllLeaveType(),
      getAllRestDatesAll(row.userId)
    ])
    leaveTypes.value = (typeRes.data || []).filter(t => t.status === '0' || t.status === 0 || t.status === undefined)

    const allData = allRes.data || {}
    const dates = allData.dates || []
    const map = {}
    dates.forEach(item => {
      map[item.date] = item
    })
    allRestDateMap.value = map
    allRestTypeList.value = allData.typeList || []

    // 提取已有自定义休息日（type === 'custom'），初始化 customDateMap
    const customMap = {}
    dates.forEach(item => {
      if (item.type === 'custom') {
        customMap[item.date] = {
          date: item.date,
          typeId: item.typeId ?? null,
          typeName: item.typeName || ''
        }
      }
    })
    customDateMap.value = customMap
  } catch (e) {
    console.error('加载休息日数据失败:', e)
  }
}

/** 选择休假类型 */
function onTypeSelect(typeId, typeName) {
  selectedTypeId.value = typeId
  selectedTypeName.value = typeName
}

/** 打开日历选择器 */
function openCalendarPicker() {
  showRestCalendar.value = true
}

/** 日历日期格式化，标注各类已有休息日 */
function restDateFormatter(day) {
  const dateObj = day.date instanceof Date ? day.date : new Date(day.date)
  const y = dateObj.getFullYear()
  const m = String(dateObj.getMonth() + 1).padStart(2, '0')
  const d = String(dateObj.getDate()).padStart(2, '0')
  const dateStr = `${y}-${m}-${d}`

  const restInfo = allRestDateMap.value[dateStr]
  if (restInfo) {
    // 自定义休息日 → 不加 bottomInfo（由 defaultDate 选中状态显示）
    if (restInfo.type === 'custom') {
      // 由 defaultDate 控制选中
    } else if (restInfo.type === 'weekly') {
      day.bottomInfo = '轮休'
    } else if (restInfo.type === 'plan') {
      day.bottomInfo = restInfo.typeName || '方案休息'
    } else if (restInfo.type === 'leave') {
      day.bottomInfo = restInfo.typeName || '请假'
    } else if (restInfo.type === 'holiday') {
      day.bottomInfo = restInfo.typeName || '假日'
    }
  }
  return day
}

/** 日历确认选择，将新增日期关联当前休假类型 */
function onCalendarConfirm(e) {
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

  const selectedSet = new Set(selectedDates)
  const existingMap = { ...customDateMap.value }

  // 新增的日期关联当前休假类型
  selectedDates.forEach(date => {
    if (!existingMap[date]) {
      existingMap[date] = {
        date,
        typeId: selectedTypeId.value || null,
        typeName: selectedTypeName.value || ''
      }
    }
    // 已存在的日期保留原类型
  })

  // 移除取消选择的日期
  Object.keys(existingMap).forEach(date => {
    if (!selectedSet.has(date)) {
      delete existingMap[date]
    }
  })

  customDateMap.value = existingMap
  showRestCalendar.value = false
}

/** 移除单个自定义休息日 */
function removeCustomDate(date) {
  const newMap = { ...customDateMap.value }
  delete newMap[date]
  customDateMap.value = newMap
}

/** 保存休息日配置 */
async function saveRestDateConfig() {
  // 验证：每个日期必须有类型
  const restDates = Object.values(customDateMap.value)
  if (restDates.length > 0) {
    const noType = restDates.find(item => !item.typeId)
    if (noType) {
      uni.showToast({ title: '日期 ' + noType.date + ' 未选择类型', icon: 'none' })
      return
    }
  }
  restSaving.value = true
  try {
    const submitData = restDates.map(item => ({
      date: item.date,
      typeId: item.typeId,
      typeName: item.typeName
    }))
    await saveRestDates(currentConfigUser.value.userId, submitData)
    uni.showToast({ title: '保存成功', icon: 'success' })
    showRestDateConfig.value = false
    queryConfig()
  } catch (err) {
    uni.showToast({ title: err.message || '保存失败', icon: 'none' })
  } finally {
    restSaving.value = false
  }
}

// ==================== 初始化 ====================
onMounted(() => { loadDictData() })
onShow(() => {
  // 按当前 Tab 刷新对应数据，避免返回后列表不更新
  if (currentTab.value === 0) {
    getList(true)
  } else if (currentTab.value === 1) {
    getEnterpriseList()
  } else if (currentTab.value === 2) {
    queryConfig()
  }
})
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
  &.rest { background: #E8F0FE; color: #3D6DF7; }
  &.leave { background: #FFF7E8; color: #FF7D00; }
}

.rest-type-empty {
  font-size: 24rpx;
  color: #C9CDD4;
  padding: 16rpx 0;
  white-space: nowrap;
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

/* 休息日配置弹窗样式 */
.rest-config-popup { padding: 30rpx; }
.rest-config-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24rpx; }
.rest-config-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.rest-config-body { max-height: 800rpx; overflow-y: auto; }
.rest-config-user { display: flex; align-items: center; gap: 8rpx; margin-bottom: 24rpx; }
.rest-config-label { font-size: 26rpx; color: #86909C; }
.rest-config-name { font-size: 28rpx; font-weight: 600; color: #1D2129; }

.rest-type-section { margin-bottom: 24rpx; }
.rest-type-label { display: flex; align-items: center; gap: 8rpx; font-size: 26rpx; color: #4E5969; margin-bottom: 16rpx; font-weight: 500; }
.rest-type-scroll { white-space: nowrap; }
.rest-type-tags { display: inline-flex; gap: 12rpx; padding: 4rpx 0; }
.rest-type-tag { display: inline-flex; align-items: center; justify-content: center; padding: 12rpx 28rpx; background: #F5F7FA; border-radius: 8rpx; font-size: 26rpx; color: #4E5969; border: 2rpx solid transparent; white-space: nowrap;
  &.active { background: #E8F0FE; color: #3D6DF7; border-color: #3D6DF7; font-weight: 500; }
}

.rest-legend { display: flex; flex-wrap: wrap; gap: 16rpx; padding: 16rpx 20rpx; background: #F7F8FA; border-radius: 12rpx; margin-bottom: 24rpx; }
.rest-legend-item { display: flex; align-items: center; gap: 8rpx; }
.rest-legend-dot { width: 16rpx; height: 16rpx; border-radius: 50%; }
.rest-legend-text { font-size: 22rpx; color: #4E5969; }

.rest-selected-section { margin-bottom: 24rpx; }
.rest-selected-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.rest-selected-title { font-size: 26rpx; color: #4E5969; font-weight: 500; }
.rest-add-btn { display: flex; align-items: center; gap: 6rpx; padding: 10rpx 24rpx; background: #3D6DF7; border-radius: 28rpx;
  text { font-size: 24rpx; color: #fff; }
}
.rest-selected-empty { display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 12rpx; padding: 60rpx 0; background: #F7F8FA; border-radius: 12rpx; }
.rest-empty-text { font-size: 26rpx; color: #C9CDD4; }
.rest-selected-list { display: flex; flex-wrap: wrap; gap: 12rpx; }
.rest-selected-chip { display: flex; align-items: center; gap: 8rpx; padding: 10rpx 16rpx; background: #E8F0FE; border-radius: 8rpx; }
.chip-date { font-size: 24rpx; color: #1D2129; font-weight: 500; }
.chip-type { font-size: 20rpx; color: #3D6DF7; background: #fff; padding: 2rpx 10rpx; border-radius: 4rpx; }
.chip-remove { display: flex; align-items: center; padding: 4rpx; }

.rest-config-footer { display: flex; gap: 20rpx; margin-top: 24rpx; padding-top: 24rpx; border-top: 1rpx solid #E5E6EB;
  .u-button { flex: 1; }
}
</style>
