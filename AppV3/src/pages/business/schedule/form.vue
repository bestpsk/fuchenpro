<template>
  <view class="form-container">
    <view class="form-section">
      <!-- Enterprise mode: Enterprise → Employee(multi) → Date -->
      <template v-if="formMode === 'enterprise'">
        <view class="form-field" @click="showEnterprisePicker = mode !== 'view'">
          <view class="field-input-box">
            <u-icon name="home-fill" size="18" color="#86909C"></u-icon>
            <input class="field-input" :value="form.enterpriseName" placeholder="* 企业" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
            <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>

        <view class="form-field" @click="showUserPicker = mode !== 'view'">
          <view class="field-input-box">
            <u-icon name="account-fill" size="18" color="#86909C"></u-icon>
            <input class="field-input" :value="selectedUsersText" placeholder="* 选择员工（可多选）" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
            <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>

        <view class="form-item">
          <view class="form-label"><u-icon name="calendar" size="16" color="#86909C" style="margin-right:6rpx"></u-icon>日期</view>
          <view class="date-tags-row" v-if="form.selectedDates.length > 0">
            <view class="date-tag" v-for="(date, idx) in form.selectedDates" :key="idx">{{ formatMonthDay(date) }}</view>
          </view>
          <view class="date-empty" v-else @click="openCalendar">* 选择日期</view>
          <view class="date-edit-hint" v-if="mode !== 'view'" @click="openCalendar">点击修改日期</view>
        </view>
      </template>

      <!-- Employee mode: Employee → Enterprise → Date (original) -->
      <template v-else>
        <view class="form-field" @click="showUserPicker = mode !== 'view'">
          <view class="field-input-box">
            <u-icon name="account-fill" size="18" color="#86909C"></u-icon>
            <input class="field-input" :value="form.userName" placeholder="* 员工姓名" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
            <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>

        <view class="form-field" @click="showEnterprisePicker = mode !== 'view'">
          <view class="field-input-box">
            <u-icon name="home-fill" size="18" color="#86909C"></u-icon>
            <input class="field-input" :value="form.enterpriseName" placeholder="* 企业" placeholder-class="field-placeholder" disabled :disabledColor="'#fff'" />
            <u-icon v-if="mode !== 'view'" name="arrow-right" size="14" color="#C9CDD4"></u-icon>
          </view>
        </view>

        <view class="form-item">
          <view class="form-label"><u-icon name="calendar" size="16" color="#86909C" style="margin-right:6rpx"></u-icon>日期</view>
          <view class="date-tags-row" v-if="form.selectedDates.length > 0">
            <view class="date-tag" v-for="(date, idx) in form.selectedDates" :key="idx">{{ formatMonthDay(date) }}</view>
          </view>
          <view class="date-empty" v-else @click="openCalendar">* 选择日期范围</view>
          <view class="date-edit-hint" v-if="mode !== 'view'" @click="openCalendar">点击修改日期</view>
        </view>
      </template>

      <view class="form-item">
        <view class="form-label">下店目的</view>
        <view class="option-cards">
          <view v-for="item in purposeColumns" :key="item.value" class="option-card" :class="{ active: form.purpose === item.value, disabled: mode === 'view' }" @click="mode !== 'view' && (form.purpose = item.value, form.purposeName = item.label)">
            {{ item.label }}
          </view>
        </view>
      </view>

      <view class="form-item">
        <view class="form-label">状态</view>
        <view class="option-cards">
          <view v-for="item in statusColumns" :key="item.value" class="option-card" :class="{ active: form.status === item.value, disabled: mode === 'view' }" @click="mode !== 'view' && (form.status = item.value, form.statusName = item.label)">
            {{ item.label }}
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

    <!-- Employee picker popup (supports both single and multi-select) -->
    <u-popup :show="showUserPicker" mode="bottom" round="16" @close="showUserPicker = false">
      <view class="picker-popup">
        <view class="picker-header">
          <text class="picker-title">选择员工</text>
          <view class="picker-close" @click="showUserPicker = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <view class="picker-search">
          <u-icon name="search" size="16" color="#86909C"></u-icon>
          <input class="picker-search-input" v-model="userSearchKeyword" placeholder="搜索员工姓名" placeholder-class="field-placeholder" @input="filterUserList" />
        </view>
        <scroll-view scroll-y class="picker-list">
          <view v-for="item in filteredUserList" :key="item.userId" class="picker-item" :class="{ 'picker-item-selected': formMode === 'enterprise' && isUserSelected(item.userId) }" @click="onUserConfirm(item)">
            <view class="picker-item-content">
              <view v-if="formMode === 'enterprise'" class="picker-checkbox" :class="{ checked: isUserSelected(item.userId) }">
                <u-icon v-if="isUserSelected(item.userId)" name="checkmark" size="14" color="#fff"></u-icon>
              </view>
              <text class="picker-item-text">{{ item.nickName || item.userName }}</text>
            </view>
          </view>
          <u-empty v-if="filteredUserList.length === 0" mode="data" text="暂无员工数据" :marginTop="40"></u-empty>
        </scroll-view>
        <view v-if="formMode === 'enterprise'" class="picker-footer">
          <text class="picker-footer-text">已选 {{ selectedUsers.length }} 人</text>
          <view class="picker-footer-btn"><u-button type="primary" text="确认" size="small" @click="confirmUserMultiSelect" :disabled="selectedUsers.length === 0"></u-button></view>
        </view>
      </view>
    </u-popup>

    <!-- Enterprise picker popup -->
    <u-popup :show="showEnterprisePicker" mode="bottom" round="16" @close="showEnterprisePicker = false">
      <view class="picker-popup">
        <view class="picker-header">
          <text class="picker-title">选择企业</text>
          <view class="picker-close" @click="showEnterprisePicker = false"><u-icon name="close" size="20" color="#86909C"></u-icon></view>
        </view>
        <view class="picker-search">
          <u-icon name="search" size="16" color="#86909C"></u-icon>
          <input class="picker-search-input" v-model="enterpriseSearchKeyword" placeholder="搜索企业名称" placeholder-class="field-placeholder" @input="filterEnterpriseList" />
        </view>
        <scroll-view scroll-y class="picker-list">
          <view v-for="item in filteredEnterpriseList" :key="item.enterpriseId" class="picker-item" @click="onEnterpriseConfirm(item)">
            <text class="picker-item-text">{{ item.enterpriseName }}</text>
          </view>
          <u-empty v-if="filteredEnterpriseList.length === 0" mode="data" text="暂无企业数据" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <u-calendar
      :show="showCalendarPicker"
      mode="multiple"
      :defaultDate="form.selectedDates"
      :maxDate="maxDate"
      :minDate="minDate"
      :monthNum="monthNum"
      :formatter="calendarFormatter"
      :color="'#3D6DF7'"
      @confirm="onMultiDateConfirm"
      @close="showCalendarPicker = false"
    ></u-calendar>

    <view class="form-actions" v-if="mode !== 'view'">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>
    <view class="form-actions" v-else>
      <u-button v-if="checkPermi('business:schedule:edit')" type="primary" plain text="编辑" @click="goEdit"></u-button>
      <u-button v-if="checkPermi('business:schedule:remove')" type="error" plain text="删除" @click="handleDelete"></u-button>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 行程表单页 - 新增/编辑/查看行程
 * @description 支持三种模式（add/edit/view），包含员工选择器、企业选择器、
 * 日历多选日期、字典加载、日期冲突检测、批量新增多天行程等功能
 * @description 支持企业排班模式（from=enterprise），字段顺序为企业→日期→员工（多选）
 */
import { ref, reactive, computed, onMounted } from 'vue'
import { getSchedule, addSchedule, addScheduleBatch, updateSchedule, delSchedule, getScheduleDates } from '@/api/business/schedule'
import { getRestDates } from '@/api/business/employeeConfig'
import { listEnterprise } from '@/api/business/enterprise'
import { listUser } from '@/api/system/user'
import { getDicts } from '@/api/system/dictData'
import { checkPermi } from '@/utils/permission'

const submitting = ref(false)
const showUserPicker = ref(false)
const showEnterprisePicker = ref(false)
const showCalendarPicker = ref(false)
const mode = ref('add')
const scheduleId = ref(null)
const formMode = ref('employee') // 'employee' or 'enterprise'

const userList = ref([])
const filteredUserList = ref([])
const userSearchKeyword = ref('')

const enterpriseList = ref([])
const filteredEnterpriseList = ref([])
const enterpriseSearchKeyword = ref('')
const selectedUsers = ref([]) // Multi-select users for enterprise mode

const purposeColumns = ref([])
const statusColumns = ref([])

const bookedDates = ref([])
const originalDates = ref([])
const restDates = ref([])

const minDate = ref(Number(new Date(new Date().setFullYear(new Date().getFullYear() - 2))))
const maxDate = ref(Number(new Date(new Date().setFullYear(new Date().getFullYear() + 1))))
// 生成足够月份覆盖 minDate ~ maxDate，让 u-calendar 能滚动到当前月/已选日期月
const monthNum = ref(48)

const form = reactive({
  scheduleId: undefined,
  scheduleIds: [],
  userId: '',
  userName: '',
  enterpriseId: '',
  enterpriseName: '',
  selectedDates: [],
  startDate: '',
  endDate: '',
  purpose: '',
  purposeName: '',
  status: '1',
  statusName: '',
  remark: ''
})

/** 格式化日期为"X月X日" */
function formatMonthDay(dateStr) {
  if (!dateStr) return ''
  const [year, month, day] = dateStr.split('-')
  return `${parseInt(month)}月${parseInt(day)}日`
}

const selectedUsersText = computed(() => {
  if (formMode.value !== 'enterprise') return form.userName
  if (selectedUsers.value.length === 0) return ''
  const names = selectedUsers.value.map(u => u.userName)
  if (names.length <= 3) return names.join('、')
  return `${names.slice(0, 3).join('、')} 等${names.length}人`
})

/** 员工选择确认，企业模式支持多选，员工模式单选 */
function onUserConfirm(item) {
  if (formMode.value === 'enterprise') {
    const idx = selectedUsers.value.findIndex(u => u.userId === item.userId)
    if (idx >= 0) {
      selectedUsers.value.splice(idx, 1)
    } else {
      selectedUsers.value.push({ userId: item.userId, userName: item.nickName || item.userName })
    }
  } else {
    form.userId = item.userId
    form.userName = item.nickName || item.userName
    showUserPicker.value = false
    loadBookedDates()
  }
}

function isUserSelected(userId) {
  return selectedUsers.value.some(u => u.userId === userId)
}

function confirmUserMultiSelect() {
  showUserPicker.value = false
  loadBookedDatesForAll()
}

/** 企业选择确认，更新表单中的企业ID和名称 */
function onEnterpriseConfirm(item) {
  form.enterpriseId = item.enterpriseId
  form.enterpriseName = item.enterpriseName
  showEnterprisePicker.value = false
}

/** 打开日历选择器，查看模式下禁用，需先选择员工才能打开 */
async function openCalendar() {
  if (mode.value === 'view') return
  if (formMode.value === 'employee' && !form.userId) {
    uni.showToast({ title: '请先选择员工', icon: 'none' })
    return
  }
  if (formMode.value === 'enterprise' && selectedUsers.value.length === 0) {
    uni.showToast({ title: '请先选择员工', icon: 'none' })
    return
  }
  await loadBookedDates()
  // 加载选中员工的休息日
  if (formMode.value === 'employee' && form.userId) {
    try {
      const res = await getRestDates(form.userId)
      const data = res.data || res
      restDates.value = data || []
    } catch (e) {
      restDates.value = []
    }
  } else if (formMode.value === 'enterprise' && selectedUsers.value.length > 0) {
    try {
      const allDates = new Set()
      for (const user of selectedUsers.value) {
        const res = await getRestDates(user.userId)
        const data = res.data || res
        const dates = Array.isArray(data) ? data : []
        dates.forEach(d => allDates.add(d))
      }
      restDates.value = Array.from(allDates)
    } catch (e) {
      restDates.value = []
    }
  } else {
    restDates.value = []
  }
  showCalendarPicker.value = true
}

/** 日历日期格式化，休息日和已安排的日期标记并禁用选择 */
function calendarFormatter(day) {
  const dateObj = day.date instanceof Date ? day.date : new Date(day.date)
  const y = dateObj.getFullYear()
  const m = String(dateObj.getMonth() + 1).padStart(2, '0')
  const d = String(dateObj.getDate()).padStart(2, '0')
  const dateStr = `${y}-${m}-${d}`
  if (restDates.value.includes(dateStr)) {
    day.bottomInfo = '休息日'
    day.disabled = true
  } else if (bookedDates.value.includes(dateStr)) {
    // 编辑模式下，当前行程自身的日期可取消选中
    if (originalDates.value.includes(dateStr)) {
      day.bottomInfo = '当前行程'
    } else {
      day.bottomInfo = '已安排'
      day.disabled = true
    }
  }
  return day
}

/** 日历多选确认，将选中的日期排序后更新到表单，并设置起止日期 */
function onMultiDateConfirm(e) {
  if (Array.isArray(e) && e.length > 0) {
    form.selectedDates = [...e].sort()

    if (form.selectedDates.length > 0) {
      form.startDate = form.selectedDates[0]
      form.endDate = form.selectedDates[form.selectedDates.length - 1]
    }
  } else {
    console.warn('[Calendar] 未选择任何日期或格式异常:', e)
  }

  showCalendarPicker.value = false
}

/** 加载行程目的和状态的字典数据 */
async function loadDictData() {
  try {
    const [purposeRes, statusRes] = await Promise.all([
      getDicts('biz_schedule_purpose'),
      getDicts('biz_schedule_status')
    ])
    purposeColumns.value = (purposeRes.data || []).map(p => ({ label: p.dictLabel, value: p.dictValue }))
    statusColumns.value = (statusRes.data || []).map(p => ({ label: p.dictLabel, value: p.dictValue }))
    if (statusColumns.value.length > 0 && !form.status) {
      form.status = statusColumns.value[0].value
      form.statusName = statusColumns.value[0].label
    }
  } catch (e) { console.error('加载字典数据失败:', e) }
}

/** 加载指定员工当月已安排的日期列表，用于日历冲突检测 */
async function loadBookedDates() {
  if (formMode.value === 'enterprise') {
    await loadBookedDatesForAll()
    return
  }
  if (!form.userId) return
  try {
    const now = new Date()
    const yearMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`
    const response = await getScheduleDates({ userId: form.userId, yearMonth })
    bookedDates.value = response.data || []
  } catch (e) { console.error('加载已安排日期失败:', e) }
}

async function loadBookedDatesForAll() {
  if (selectedUsers.value.length === 0) {
    bookedDates.value = []
    return
  }
  try {
    const now = new Date()
    const yearMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`
    const allDates = new Set()
    for (const user of selectedUsers.value) {
      const response = await getScheduleDates({ userId: user.userId, yearMonth })
      const dates = response.data || []
      dates.forEach(d => allDates.add(d))
    }
    bookedDates.value = Array.from(allDates)
  } catch (e) { console.error('加载已安排日期失败:', e) }
}

async function loadUserList() {
  try {
    const response = await listUser({ pageNum: 1, pageSize: 1000, status: '0' })
    const data = response.data || response
    userList.value = data.rows || []
    filteredUserList.value = userList.value
  } catch (e) { console.error('加载员工列表失败:', e) }
}

async function loadEnterpriseList() {
  try {
    const response = await listEnterprise({ pageNum: 1, pageSize: 1000, status: '0' })
    const data = response.data || response
    enterpriseList.value = data.rows || []
    filteredEnterpriseList.value = enterpriseList.value
  } catch (e) { console.error('加载企业列表失败:', e) }
}

function filterUserList() {
  const keyword = userSearchKeyword.value.toLowerCase()
  filteredUserList.value = userList.value.filter(u => (u.nickName || u.userName || '').toLowerCase().includes(keyword))
}

function filterEnterpriseList() {
  const keyword = enterpriseSearchKeyword.value.toLowerCase()
  filteredEnterpriseList.value = enterpriseList.value.filter(e => (e.enterpriseName || '').toLowerCase().includes(keyword))
}

/** 加载行程详情数据并填充到表单，用于编辑和查看模式 */
async function loadDetail() {
  if (!scheduleId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getSchedule(scheduleId.value)
    const data = response.data || response
    const pItem = purposeColumns.value.find(p => p.value === String(data.purpose))
    const sItem = statusColumns.value.find(s => s.value === String(data.status))
    // 读取列表页传递的分组日期数据
    const groupData = uni.getStorageSync('scheduleGroupData')
    const scheduleDates = (groupData && groupData.scheduleDates) ? groupData.scheduleDates : (data.scheduleDate ? [data.scheduleDate] : [])
    const groupScheduleIds = (groupData && groupData.scheduleIds) ? groupData.scheduleIds : [data.scheduleId]
    uni.removeStorageSync('scheduleGroupData')
    Object.assign(form, {
      scheduleId: data.scheduleId,
      scheduleIds: groupScheduleIds,
      userId: data.userId || '',
      userName: data.userName || '',
      enterpriseId: data.enterpriseId || '',
      enterpriseName: data.enterpriseName || '',
      selectedDates: scheduleDates,
      startDate: data.scheduleDate || '',
      endDate: data.scheduleDate || '',
      purpose: String(data.purpose || ''),
      purposeName: pItem ? pItem.label : '',
      status: String(data.status ?? '1'),
      statusName: sItem ? sItem.label : '',
      remark: data.remark || ''
    })
    originalDates.value = [...scheduleDates]
    // 企业模式编辑时，将当前员工加入 selectedUsers
    if (formMode.value === 'enterprise' && data.userId) {
      selectedUsers.value = [{
        userId: data.userId,
        userName: data.userName || ''
      }]
    }
  } catch (e) { console.error('加载详情失败:', e); uni.showToast({ title: '加载失败', icon: 'none' }) }
  finally { uni.hideLoading() }
}

/**
 * 提交行程表单，校验员工/企业/日期/目的必填后，
 * 检测选中日期是否与已安排日期冲突，
 * 新增模式调用批量新增接口，编辑模式调用更新接口
 * 企业模式支持多员工批量提交
 */
async function submitForm() {
  if (formMode.value === 'enterprise') {
    if (!form.enterpriseId) { uni.showToast({ title: '请选择企业', icon: 'none' }); return }
    if (!form.selectedDates || form.selectedDates.length === 0) { uni.showToast({ title: '请选择至少一个日期', icon: 'none' }); return }
    if (selectedUsers.value.length === 0) { uni.showToast({ title: '请选择至少一个员工', icon: 'none' }); return }
    if (!form.purpose) { uni.showToast({ title: '请选择下店目的', icon: 'none' }); return }

    const conflicts = []
    for (const user of selectedUsers.value) {
      try {
        const now = new Date()
        const yearMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`
        const response = await getScheduleDates({ userId: user.userId, yearMonth })
        const userBooked = response.data || []
        // 编辑模式下，当前员工排除自身原有日期
        const isOriginalUser = mode.value === 'edit' && form.userId && String(user.userId) === String(form.userId)
        const datesToCheck = isOriginalUser
          ? form.selectedDates.filter(d => !originalDates.value.includes(d))
          : form.selectedDates
        const conflictDates = datesToCheck.filter(date => userBooked.includes(date))
        if (conflictDates.length > 0) {
          conflicts.push(`${user.userName}：${conflictDates.join('、')}`)
        }
      } catch (e) { console.error('检查冲突失败:', e) }
    }

    if (conflicts.length > 0) {
      uni.showModal({ title: '日期冲突', content: `以下员工日期已有安排：\n${conflicts.join('\n')}`, showCancel: false })
      return
    }

    submitting.value = true
    try {
      const scheduleList = []
      for (const user of selectedUsers.value) {
        for (const scheduleDate of form.selectedDates) {
          scheduleList.push({
            userId: user.userId,
            userName: user.userName,
            enterpriseId: form.enterpriseId,
            enterpriseName: form.enterpriseName,
            scheduleDate,
            purpose: form.purpose,
            status: form.status,
            remark: form.remark
          })
        }
      }
      if (mode.value === 'edit' && form.scheduleId) {
        // 编辑模式：先删除原有行程，再批量新增
        if (form.scheduleIds && form.scheduleIds.length > 0) {
          await delSchedule(form.scheduleIds.join(','))
        }
        await addScheduleBatch(scheduleList)
        uni.showToast({ title: '修改成功', icon: 'success' })
      } else {
        await addScheduleBatch(scheduleList)
        uni.showToast({ title: `新增成功（${selectedUsers.value.length}人×${form.selectedDates.length}天）`, icon: 'success' })
      }
      setTimeout(() => goBack(), 1500)
    } catch (e) {
      console.error('提交失败:', e)
      const msg = e?.msg || e?.message || '操作失败，请重试'
      uni.showToast({ title: msg, icon: 'none', duration: 2000 })
    } finally { submitting.value = false }
  } else {
    if (!form.userName) { uni.showToast({ title: '请选择员工', icon: 'none' }); return }
    if (!form.enterpriseId) { uni.showToast({ title: '请选择企业', icon: 'none' }); return }
    if (!form.selectedDates || form.selectedDates.length === 0) { uni.showToast({ title: '请选择至少一个日期', icon: 'none' }); return }
    if (!form.purpose) { uni.showToast({ title: '请选择下店目的', icon: 'none' }); return }

    // 检查休息日冲突
    const restConflictDates = form.selectedDates.filter(date => restDates.value.includes(date))
    if (restConflictDates.length > 0) {
      uni.showToast({ title: `所选日期 ${restConflictDates.join('、')} 为休息日，不可安排行程`, icon: 'none', duration: 3000 })
      return
    }

    const conflictDates = form.selectedDates.filter(date => bookedDates.value.includes(date) && !originalDates.value.includes(date))
    if (conflictDates.length > 0) {
      uni.showModal({ title: '日期冲突', content: `以下日期已有安排：${conflictDates.join('、')}`, showCancel: false })
      return
    }

    submitting.value = true
    try {
      const scheduleList = form.selectedDates.map(scheduleDate => ({
        userId: form.userId,
        userName: form.userName,
        enterpriseId: form.enterpriseId,
        enterpriseName: form.enterpriseName,
        scheduleDate,
        purpose: form.purpose,
        status: form.status,
        remark: form.remark
      }))

      if (form.scheduleId) {
        // 编辑模式：差量更新（新增/删除/更新日期）
        const newDates = form.selectedDates.filter(d => !originalDates.value.includes(d))
        const removedDates = originalDates.value.filter(d => !form.selectedDates.includes(d))
        const keptDates = form.selectedDates.filter(d => originalDates.value.includes(d))

        // 构建 date -> id 映射，避免依赖数组索引对齐
        const dateToIdMap = new Map()
        originalDates.value.forEach((date, idx) => {
          if (form.scheduleIds[idx] != null) {
            dateToIdMap.set(date, form.scheduleIds[idx])
          }
        })

        // 1. 删除被移除的日期对应的记录
        if (removedDates.length > 0) {
          const removedIds = removedDates.map(date => dateToIdMap.get(date)).filter(Boolean)
          if (removedIds.length > 0) {
            await delSchedule(removedIds.join(','))
          }
        }

        // 2. 新增新选中的日期
        if (newDates.length > 0) {
          const newSchedules = newDates.map(scheduleDate => ({
            userId: form.userId,
            userName: form.userName,
            enterpriseId: form.enterpriseId,
            enterpriseName: form.enterpriseName,
            scheduleDate,
            purpose: form.purpose,
            status: form.status,
            remark: form.remark
          }))
          await addScheduleBatch(newSchedules)
        }

        // 3. 更新保留日期的非日期字段
        if (keptDates.length > 0) {
          const keptIds = keptDates.map(date => dateToIdMap.get(date)).filter(Boolean)
          for (const id of keptIds) {
            await updateSchedule({
              scheduleId: id,
              userId: form.userId,
              userName: form.userName,
              enterpriseId: form.enterpriseId,
              enterpriseName: form.enterpriseName,
              purpose: form.purpose,
              status: form.status,
              remark: form.remark
            })
          }
        }

        uni.showToast({ title: '修改成功', icon: 'success' })
      } else {
        await addScheduleBatch(scheduleList)
        uni.showToast({ title: `新增成功（共${scheduleList.length}天）`, icon: 'success' })
      }
      setTimeout(() => goBack(), 1500)
    } catch (e) {
      console.error('提交失败:', e)
      const msg = e?.msg || e?.message || '操作失败，请重试'
      uni.showToast({ title: msg, icon: 'none', duration: 2000 })
    } finally { submitting.value = false }
  }
}

function handleDelete() {
  if (!scheduleId.value) return
  uni.showModal({ title: '提示', content: '确认删除该行程?', success: async (res) => {
    if (res.confirm) { try { await delSchedule(scheduleId.value); uni.showToast({ title: '删除成功', icon: 'success' }); setTimeout(() => goBack(), 1500) } catch (e) { console.error('删除失败:', e) } }
  }})
}

function goEdit() { mode.value = 'edit'; uni.setNavigationBarTitle({ title: '编辑行程' }) }
function goBack() { const pages = getCurrentPages(); if (pages.length > 1) uni.navigateBack(); else uni.redirectTo({ url: '/pages/business/schedule/index' }) }

onMounted(async () => {
  const pages = getCurrentPages()
  const options = pages[pages.length - 1].options || {}
  mode.value = options.mode || 'add'
  scheduleId.value = options.id ? parseInt(options.id) : null

  if (options.from === 'enterprise') {
    formMode.value = 'enterprise'
  }

  // 预填企业信息（从企业排班Tab传入）
  if (options.enterpriseId) {
    form.enterpriseId = options.enterpriseId
    form.enterpriseName = options.enterpriseName ? decodeURIComponent(options.enterpriseName) : ''
  }

  await loadDictData()
  loadUserList()
  loadEnterpriseList()
  if (mode.value === 'view') { uni.setNavigationBarTitle({ title: '行程详情' }); loadDetail() }
  else if (mode.value === 'edit') { uni.setNavigationBarTitle({ title: '编辑行程' }); loadDetail() }
  else { uni.setNavigationBarTitle({ title: '新增行程' }) }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }

.form-container { min-height: 100vh; padding-bottom: 140rpx; }

.form-section {
  margin: 24rpx;
  background: #fff;
  border-radius: 20rpx;
  padding: 32rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05);
}

.form-field { margin-bottom: 20rpx; &:last-child { margin-bottom: 0; } }

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

.field-textarea-box {
  display: flex;
  flex-direction: column;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 16rpx 20rpx;
  gap: 8rpx;
  border: 2rpx solid transparent;
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
  width: 100%;
  min-height: 120rpx;
  font-size: 28rpx;
  color: #1D2129;
  line-height: 1.6;
}

.form-item { margin-bottom: 24rpx; }

.form-label {
  font-size: 26rpx;
  color: #86909C;
  font-weight: 500;
  margin-bottom: 16rpx;
}

.option-cards {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.option-card {
  padding: 16rpx 28rpx;
  background: #F7F8FA;
  border-radius: 8rpx;
  font-size: 26rpx;
  color: #4E5969;
  border: 2rpx solid transparent;
  transition: all 0.2s;

  &.active {
    background: #E8F0FE;
    color: #3D6DF7;
    border-color: #3D6DF7;
  }

  &.disabled {
    opacity: 0.5;
    pointer-events: none;
  }
}

.date-tags-row {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
}

.date-tag {
  padding: 8rpx 20rpx;
  background: #F7F8FA;
  border-radius: 8rpx;
  font-size: 26rpx;
  color: #4E5969;
}

.date-empty {
  font-size: 28rpx;
  color: #C9CDD4;
}

.date-edit-hint {
  font-size: 24rpx;
  color: #3D6DF7;
  margin-top: 12rpx;
}

.picker-popup {
  background: #fff;
  border-radius: 24rpx 24rpx 0 0;
  max-height: 70vh;
  display: flex;
  flex-direction: column;
}

.picker-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28rpx 32rpx;
  border-bottom: 1rpx solid #F2F3F5;
}

.picker-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #1D2129;
}

.picker-close { padding: 8rpx; }

.picker-search {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin: 20rpx 32rpx;
  padding: 0 20rpx;
  background: #F7F8FA;
  border-radius: 36rpx;
  height: 72rpx;
}

.picker-search-input {
  flex: 1;
  font-size: 28rpx;
  color: #1D2129;
  height: 72rpx;
}

.picker-list {
  flex: 1;
  padding: 0 32rpx 32rpx;
  max-height: 50vh;
}

.picker-item {
  padding: 24rpx 0;
  border-bottom: 1rpx solid #F2F3F5;

  &:last-child { border-bottom: none; }
  &:active { background: #F7F8FA; }
}

.picker-item-selected {
  background: #F5F7FA;
}

.picker-item-content {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.picker-checkbox {
  width: 36rpx;
  height: 36rpx;
  border-radius: 6rpx;
  border: 2rpx solid #C9CDD4;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all 0.2s;

  &.checked {
    background: #3D6DF7;
    border-color: #3D6DF7;
  }
}

.picker-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 32rpx;
  border-top: 1rpx solid #F2F3F5;
  background: #fff;
}

.picker-footer-text {
  font-size: 26rpx;
  color: #86909C;
  white-space: nowrap;
  flex-shrink: 0;
}

.picker-footer-btn {
  flex-shrink: 0;
  width: auto;
}

.picker-item-text {
  font-size: 28rpx;
  color: #1D2129;
}

.form-actions {
  position: fixed;
  left: 24rpx;
  right: 24rpx;
  bottom: 40rpx;
  display: flex;
  gap: 20rpx;
  z-index: 100;

  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>

<style lang="scss">
/* 日历禁用日期（休息日/已安排）显示红色 - 全局样式穿透 scoped */
.u-calendar-month__days__day__select__info--disabled {
  color: #f56c6c !important;
}
.u-calendar-month__days__day__select__buttom-info--disabled {
  color: #f56c6c !important;
}
</style>
