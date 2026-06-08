<template>
  <view class="archive-page">
    <view class="customer-info">
      <view class="info-row">
        <u-icon name="account-fill" size="18" color="#722ED1"></u-icon>
        <text class="customer-name">{{ customerName }}</text>
      </view>
      <view class="info-row">
        <u-icon name="map" size="14" color="#86909C"></u-icon>
        <text class="store-name">{{ enterpriseName }} · {{ storeName }}</text>
      </view>
    </view>

    <view class="toolbar">
      <view v-if="checkPermi('business:archive:add')" class="tb-btn" @click="openAddDrawer"><u-icon name="plus" size="14" color="#fff"></u-icon><text>新增档案</text></view>
      <scroll-view scroll-x class="tb-filter">
        <view class="filter-tags">
          <view class="ft" :class="{ active: !filterKey }" @click="switchFilter('')">全部</view>
          <view class="ft" v-for="tag in filterTags" :key="tag.filterKey" :class="{ active: filterKey === tag.filterKey }" @click="switchFilter(tag.filterKey)">{{ tag.label }}</view>
        </view>
      </scroll-view>
    </view>

    <scroll-view scroll-y class="list-scroll">
      <view v-if="archiveList.length > 0" class="card-list">
        <view v-for="item in archiveList" :key="item.archiveId" class="arc-card">
          <view class="arc-head">
            <view class="arc-head-left">
              <text class="arc-date">{{ item.archiveDate }}</text>
              <view class="src-tag" :class="'st-' + (item.sourceType || '3')">{{ getDictArchiveLabel('biz_source_type', item.sourceType) }}</view>
              <view class="type-tag" v-if="item.archiveType && item.archiveType !== 'sales'">{{ getDictArchiveLabel('biz_archive_type', item.archiveType) }}</view>
            </view>
            <view class="arc-head-right">
              <text class="arc-op" v-if="item.operatorUserName">{{ item.operatorUserName }}</text>
              <view class="arc-del" v-if="item.sourceType === '3' && checkPermi('business:archive:remove')" @click="handleDelete(item)"><u-icon name="trash" size="16" color="#F53F3F"></u-icon></view>
            </view>
          </view>

          <view class="arc-body">
            <view class="arc-plan" v-if="parsePlanItems(item.planItems).length > 0">
              <text class="arc-plan-lb">方案：</text><text>{{ formatPlanItems(item.planItems) }}</text>
            </view>
            <view class="arc-meta">
              <text class="arc-amt" v-if="Number(item.amount) > 0">金额：<text class="arc-amt-val">¥{{ Number(item.amount).toFixed(2) }}</text></text>
              <view class="arc-sat" v-if="item.satisfaction != null && item.satisfaction !== ''"><u-rate :modelValue="Number(item.satisfaction) || 0" :count="5" activeColor="#FF9900" inactiveColor="#E5E6EB" size="16" activeIcon="star-fill" inactiveIcon="star" :readonly="true"></u-rate></view>
            </view>
            <view class="arc-fb" v-if="item.customerFeedback"><text class="lb">顾客反馈：</text>{{ item.customerFeedback }}</view>
            <view class="arc-rm" v-if="item.remark"><text class="lb">备注：</text>{{ item.remark }}</view>
            <view class="arc-photos" v-if="parsePhotos(item.photos).length > 0">
              <image v-for="(url, idx) in parsePhotos(item.photos)" :key="idx" :src="getImgUrl(url)" mode="aspectFill" class="arc-photo-img" @click="previewImg(url, parsePhotos(item.photos))" />
            </view>
          </view>
        </view>
      </view>
      <u-empty v-else mode="data" text="暂无档案记录" :marginTop="80"></u-empty>
    </scroll-view>

    <u-popup :show="showAddDrawer" mode="bottom" round="24" :closeable="true" @close="showAddDrawer = false" :customStyle="{ width: '100vw', maxWidth: '100vw', left: 0, maxHeight: '85vh' }">
      <view class="drawer-wrapper">
        <view class="drawer-title">新增档案</view>
        <scroll-view scroll-y class="drawer-scroll">
          <view class="fg">
            <text class="fl">档案日期</text>
            <view class="fv" @click="showDatePicker = true"><text :class="{ ph: !form.archiveDate }">{{ form.archiveDate || '请选择日期' }}</text><u-icon name="arrow-right" size="14" color="#86909C"></u-icon></view>
          </view>
          <view class="fg">
            <text class="fl">档案类型</text>
            <view class="radio-row">
              <view class="rb" v-for="d in formArchiveTypes" :key="d.value" :class="{ on: form.archiveType === d.value }" @click="form.archiveType = d.value">{{ d.label }}</view>
            </view>
          </view>
          <view class="fg">
            <text class="fl">服务人</text>
            <view class="fv" @click="showOpPicker = true"><text :class="{ ph: !form.operatorUserName }">{{ form.operatorUserName || '请选择服务人' }}</text><u-icon name="arrow-right" size="14" color="#86909C"></u-icon></view>
          </view>
          <view class="fg">
            <text class="fl">方案品项</text>
            <view class="pi-list">
              <view v-for="(pi, idx) in form.planItems" :key="idx" class="pi-row">
                <input v-model="pi.name" placeholder="品项名称" class="pi-inp" />
                <input type="number" v-model="pi.quantity" placeholder="次数" class="pi-qty-inp" />
                <view class="pi-del" v-if="form.planItems.length > 1" @click="removePi(idx)"><u-icon name="close" size="16" color="#F53F3F"></u-icon></view>
              </view>
            </view>
            <view class="pi-add-btn" @click="addPiRow"><u-icon name="plus" size="14" color="#165DFF"></u-icon><text>添加品项</text></view>
          </view>
          <view class="fg">
            <text class="fl">金额</text>
            <input type="number" v-model="form.amount" placeholder="请输入金额" class="fi" />
          </view>
          <view class="fg">
            <text class="fl">满意度</text>
            <u-rate v-model="form.satisfaction" :count="5" activeColor="#FF9900" inactiveColor="#E5E6EB" size="24" activeIcon="star-fill" inactiveIcon="star"></u-rate>
          </view>
          <view class="fg">
            <text class="fl">内容</text>
            <textarea v-model="form.remark" placeholder="请输入内容" class="fa" :maxLength="500" />
          </view>
          <view class="fg">
            <text class="fl">顾客反馈</text>
            <textarea v-model="form.customerFeedback" placeholder="请输入顾客反馈" class="fa" :maxlength="500" />
          </view>
        </scroll-view>
        <view class="drawer-footer">
          <button class="df-btn" :loading="submitting" @click="submitForm">确认新增</button>
        </view>
      </view>
    </u-popup>

    <u-datetime-picker
      :show="showDatePicker"
      mode="date"
      v-model="datePickerVal"
      @confirm="onDateConfirm"
      @cancel="showDatePicker = false"
      @close="showDatePicker = false"
    ></u-datetime-picker>
    <u-action-sheet
      :show="showOpPicker"
      :actions="operatorList"
      title="选择服务人"
      @select="onOpSelect"
      @close="showOpPicker = false"
    ></u-action-sheet>
  </view>
</template>

<script setup>
/**
 * @description 客户档案页 - 档案记录查看与新增
 * @description 展示客户所有档案记录（开单/操作/还款/手动），支持按来源类型筛选、
 * 新增手动档案（含方案品项、满意度、照片）、删除手动档案、图片预览
 */
import { ref, reactive, computed } from 'vue'
import { listArchive, addArchive, deleteArchive } from '@/api/business/archive'
import { listEmployeeConfig } from '@/api/business/employeeConfig'
import { getDicts } from '@/api/system/dict/data'
import { useUserStore } from '@/store/modules/user'
import config from '@/config'
import { checkPermi } from '@/utils/permission'

const userStore = useUserStore()

const customerId = ref('')
const customerName = ref('')
const storeId = ref('')
const storeName = ref('')
const enterpriseId = ref('')
const enterpriseName = ref('')

const archiveList = ref([])
const filterKey = ref('')
const showAddDrawer = ref(false)
const showDatePicker = ref(false)
const showOpPicker = ref(false)
const datePickerVal = ref(Number(new Date()))
const submitting = ref(false)
const operatorList = ref([])
const archiveTypeDict = ref([])
const sourceTypeDict = ref([])

async function loadDictData() {
  try {
    const [archiveRes, sourceRes] = await Promise.all([
      getDicts('biz_archive_type'),
      getDicts('biz_source_type')
    ])
    archiveTypeDict.value = (archiveRes.data || []).map(d => ({ label: d.dictLabel, value: d.dictValue }))
    sourceTypeDict.value = (sourceRes.data || []).filter(d => d.dictValue !== '3').map(d => ({ label: d.dictLabel, value: d.dictValue }))
  } catch (e) {
    console.error(e)
  }
}

const FILTER_SOURCE_TYPES = ['0', '1', '2']
const FILTER_ARCHIVE_TYPES = ['preparation', 'after_sales']
const FORM_ARCHIVE_TYPES = ['preparation', 'after_sales']

const filterTags = computed(() => {
  const sourceItems = sourceTypeDict.value
    .filter(d => FILTER_SOURCE_TYPES.includes(d.value))
    .map(d => ({ label: d.label.replace(/^\d+[.、\s]+/, ''), filterKey: 'source_' + d.value }))
  const archiveItems = archiveTypeDict.value
    .filter(d => FILTER_ARCHIVE_TYPES.includes(d.value))
    .map(d => ({ label: d.label.replace(/^\d+[.、\s]+/, ''), filterKey: 'archive_' + d.value }))
  return [...sourceItems, ...archiveItems]
})

const formArchiveTypes = computed(() => {
  return archiveTypeDict.value.filter(d => FORM_ARCHIVE_TYPES.includes(d.value)).map(d => ({ ...d, label: d.label.replace(/^\d+[.、\s]+/, '') }))
})

/** 新增档案表单数据 */
const form = reactive({
  archiveDate: '',
  archiveType: 'preparation',
  operatorUserId: null,
  operatorUserName: '',
  amount: 0,
  planItems: [{ name: '', quantity: 1 }],
  satisfaction: 5,
  customerFeedback: '',
  remark: ''
})

function getDictArchiveLabel(dictType, value) {
  const dict = dictType === 'biz_archive_type' ? archiveTypeDict.value : sourceTypeDict.value
  const item = dict.find(d => d.value === String(value))
  if (!item) return value || ''
  return item.label.replace(/^\d+[.、\s]+/, '')
}

/** 解析JSON格式的方案品项字符串，失败返回空数组 */
function parsePlanItems(s) {
  if (!s) return []
  try { return JSON.parse(s) } catch { return [] }
}

/** 将方案品项格式化为"品项名×次数"的展示文本 */
function formatPlanItems(s) {
  const arr = parsePlanItems(s)
  return arr.map((pi, i) => pi.name + '×' + pi.quantity + (i < arr.length - 1 ? '、' : '')).join('')
}

/** 根据图片路径拼接完整URL，处理相对路径和绝对路径 */
function getImgUrl(path) {
  if (!path) return ''
  if (String(path).startsWith('http')) return path
  if (String(path).startsWith('/profile/')) return config.baseUrl + path
  return config.baseUrl + '/profile/upload/' + path
}

/** 解析照片字段，优先尝试JSON解析，失败则按逗号分隔 */
function parsePhotos(s) {
  if (!s) return []
  try {
    const p = JSON.parse(s)
    return Array.isArray(p) ? p.filter(Boolean) : []
  } catch {
    return s.split(',').map(x => x.trim()).filter(Boolean)
  }
}

/** 预览图片，使用uni.previewImage全屏查看 */
function previewImg(cur, urls) {
  uni.previewImage({ current: getImgUrl(cur), urls: urls.map(u => getImgUrl(u)).filter(Boolean) })
}

/** 加载档案列表，支持按来源类型筛选 */
async function loadList() {
  if (!customerId.value) return
  try {
    const params = { customerId: customerId.value, pageSize: 100 }
    if (filterKey.value.startsWith('archive_')) {
      params.archiveType = filterKey.value.replace('archive_', '')
    } else if (filterKey.value.startsWith('source_')) {
      params.sourceType = filterKey.value.replace('source_', '')
    }
    const res = await listArchive(params)
    const data = res.data || res
    archiveList.value = data.rows || []
  } catch (e) {
    console.error(e)
  }
}

/** 切换来源类型筛选并重新加载列表 */
function switchFilter(t) {
  filterKey.value = t
  loadList()
}

/** 加载员工列表作为操作人选项 */
async function loadOperators() {
  try {
    const res = await listEmployeeConfig({ pageNum: 1, pageSize: 100 })
    const data = res.data || res
    const list = data.rows || []
    operatorList.value = list.map(item => ({
      name: item.realName || item.nickName || item.userName || '-',
      userId: item.userId,
      subname: item.phonenumber || ''
    }))
  } catch (e) {
    console.error(e)
  }
}

/** 打开新增档案抽屉，初始化表单默认值并加载操作人列表 */
function openAddDrawer() {
  form.archiveDate = new Date().toISOString().slice(0, 10)
  form.archiveType = 'preparation'
  form.operatorUserId = userStore.getId
  form.operatorUserName = userStore.nickName || ''
  form.amount = 0
  form.planItems = [{ name: '', quantity: 1 }]
  form.satisfaction = 5
  form.customerFeedback = ''
  form.remark = ''
  datePickerVal.value = Number(new Date())
  loadOperators()
  showAddDrawer.value = true
}

/** 添加一行空白方案品项 */
function addPiRow() {
  form.planItems.push({ name: '', quantity: 1 })
}

/** 删除指定方案品项行 */
function removePi(idx) {
  form.planItems.splice(idx, 1)
}

/** 选择操作人后更新表单 */
function onOpSelect(e) {
  form.operatorUserName = e.name
  form.operatorUserId = e.userId
  showOpPicker.value = false
}

/** 日期选择确认，格式化为YYYY-MM-DD */
function onDateConfirm(e) {
  const d = new Date(Number(e))
  form.archiveDate = d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0')
  showDatePicker.value = false
}

/** 提交新增档案，校验日期后组装数据（含方案品项、满意度等）调用接口，成功后刷新列表 */
async function submitForm() {
  if (!form.archiveDate) return uni.showToast({ title: '请选择档案日期', icon: 'none' })
  submitting.value = true
  try {
    const validItems = form.planItems.filter(i => i.name)
    await addArchive({
      customerId: customerId.value,
      customerName: customerName.value,
      enterpriseId: enterpriseId.value,
      storeId: storeId.value,
      archiveDate: form.archiveDate,
      archiveType: form.archiveType,
      operatorUserId: form.operatorUserId,
      operatorUserName: form.operatorUserName,
      amount: form.amount,
      planItems: validItems.length > 0 ? validItems : [],
      satisfaction: form.satisfaction,
      customerFeedback: form.customerFeedback,
      remark: form.remark
    })
    uni.showToast({ title: '新增成功', icon: 'success' })
    showAddDrawer.value = false
    loadList()
  } catch (e) {
    console.error(e)
    uni.showToast({ title: '新增失败', icon: 'none' })
  } finally {
    submitting.value = false
  }
}

/** 删除手动档案，弹出确认框后调用删除接口，仅允许删除来源为"手动"的档案 */
function handleDelete(item) {
  uni.showModal({
    title: '提示',
    content: '确认删除该档案记录？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await deleteArchive(item.archiveId)
          uni.showToast({ title: '删除成功', icon: 'success' })
          loadList()
        } catch (e) {
          uni.showToast({ title: '删除失败', icon: 'none' })
        }
      }
    }
  })
}

const pages = getCurrentPages()
const options = pages[pages.length - 1].options || {}
customerId.value = options.customerId || ''
customerName.value = decodeURIComponent(options.customerName || '')
storeId.value = options.storeId || ''
storeName.value = decodeURIComponent(options.storeName || '')
enterpriseId.value = options.enterpriseId || ''
enterpriseName.value = decodeURIComponent(options.enterpriseName || '')

loadDictData().then(() => loadList())
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.archive-page { min-height: 100vh; display: flex; flex-direction: column;
  :deep(.u-popup) { flex: none !important; }
}

.customer-info { padding: 14rpx 16rpx; background: #fff; border-bottom: 1rpx solid #F2F3F5; }
.info-row { display: flex; align-items: center; gap: 10rpx; margin-bottom: 6rpx; &:last-child { margin-bottom: 0; } }
.customer-name { font-size: 30rpx; font-weight: 600; color: #1D2129; }
.store-name { font-size: 24rpx; color: #86909C; }

.toolbar { display: flex; align-items: center; padding: 16rpx 20rpx; background: #fff; border-bottom: 1rpx solid #F2F3F5; gap: 12rpx; }
.tb-btn { display: flex; align-items: center; gap: 6rpx; background: #722ED1; color: #fff; font-size: 24rpx; padding: 12rpx 24rpx; border-radius: 8rpx; flex-shrink: 0; }
.tb-filter { flex: 1; white-space: nowrap; }
.filter-tags { display: inline-flex; gap: 8rpx; }
.ft { font-size: 22rpx; padding: 6rpx 16rpx; border-radius: 6rpx; background: #F2F3F5; color: #86909C; flex-shrink: 0; }
.ft.active { background: #F5E8FF; color: #722ED1; }

.list-scroll { flex: 1; padding: 16rpx; box-sizing: border-box; }

.card-list { display: flex; flex-direction: column; gap: 14rpx; }
.arc-card { background: #fff; border-radius: 10rpx; padding: 16rpx 18rpx; border: 1rpx solid #F0F2F5; }
.arc-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 10rpx; }
.arc-head-left { display: flex; align-items: center; gap: 8rpx; }
.arc-head-right { display: flex; align-items: center; gap: 12rpx; }
.arc-date { font-size: 24rpx; font-weight: 600; color: #1D2129; }
.src-tag { font-size: 20rpx; padding: 2rpx 14rpx; border-radius: 4rpx; font-weight: 500;
  &.st-0 { color: #FF7D00; background: #FFF7E8; }
  &.st-1 { color: #3D6DF7; background: #EEF2FF; }
  &.st-2 { color: #00B42A; background: #E8FFEA; }
  &.st-3 { color: #722ED1; background: #F5E8FF; }
}
.type-tag { font-size: 20rpx; padding: 2rpx 14rpx; border-radius: 4rpx; color: #722ED1; background: #F5E8FF; font-weight: 500; }
.arc-op { font-size: 22rpx; color: #86909C; }
.arc-del { padding: 4rpx; }

.arc-body { }
.arc-plan { font-size: 24rpx; color: #4E5969; margin-bottom: 8rpx; word-break: break-all; }
.arc-plan-lb { color: #86909C; }
.arc-meta { display: flex; align-items: center; gap: 16rpx; margin-bottom: 8rpx; }
.arc-amt { font-size: 24rpx; color: #4E5969; }
.arc-amt-val { font-weight: 700; color: #FF6B35; font-size: 28rpx; }
.arc-sat { flex-shrink: 0; }
.arc-fb { font-size: 22rpx; color: #4E5969; margin-bottom: 6rpx; }
.arc-fb .lb { color: #86909C; }
.arc-rm { font-size: 22rpx; color: #86909C; margin-bottom: 6rpx; }
.arc-rm .lb { color: #86909C; }
.arc-photos { display: flex; flex-wrap: wrap; gap: 10rpx; margin-top: 8rpx; }
.arc-photo-img { width: 120rpx; height: 120rpx; border-radius: 8rpx; }

.drawer-wrapper { display: flex; flex-direction: column; max-height: 85vh; }
.drawer-title { font-size: 30rpx; font-weight: 600; color: #1D2129; margin-bottom: 20rpx; padding: 0 24rpx; flex-shrink: 0; }
.drawer-scroll { flex: 1; overflow-y: auto; padding: 0 24rpx; }
.fg { margin-bottom: 18rpx; }
.fl { display: block; font-size: 24rpx; color: #86909C; margin-bottom: 8rpx; font-weight: 500; }
.fv { display: flex; align-items: center; justify-content: space-between; background: #F7F8FA; border-radius: 8rpx; padding: 12rpx 14rpx;
  text { font-size: 26rpx; color: #1D2129; &.ph { color: #C9CDD4; } }
}
.fi { width: 100%; height: 72rpx; line-height: 48rpx; font-size: 26rpx; padding: 12rpx 14rpx; border: 1rpx solid #E5E6EB; border-radius: 8rpx; background: #F7F8FA; box-sizing: border-box; }
.radio-row { display: flex; gap: 16rpx; }
.rb { font-size: 26rpx; padding: 10rpx 32rpx; border-radius: 8rpx; background: #F2F3F5; color: #86909C; }
.rb.on { background: #F5E8FF; color: #722ED1; font-weight: 600; }
.pi-list { display: flex; flex-direction: column; gap: 10rpx; }
.pi-row { display: flex; align-items: center; gap: 10rpx; }
.pi-inp { flex: 1; font-size: 26rpx; padding: 10rpx 16rpx; border: 1rpx solid #E5E6EB; border-radius: 8rpx; background: #F7F8FA; }
.pi-qty-inp { width: 120rpx; font-size: 26rpx; padding: 10rpx 16rpx; border: 1rpx solid #E5E6EB; border-radius: 8rpx; background: #F7F8FA; text-align: center; }
.pi-del { padding: 4rpx; }
.pi-add-btn { display: flex; align-items: center; gap: 4rpx; margin-top: 10rpx; font-size: 24rpx; color: #165DFF; }
.fa { width: 100%; height: 72rpx; background: #fff; border-radius: 8rpx; padding: 10rpx 12rpx; font-size: 23rpx; color: #1D2129; box-sizing: border-box; border: 1rpx solid #F0F2F5; }
.drawer-footer { padding: 12rpx 24rpx; padding-bottom: calc(12rpx + env(safe-area-inset-bottom)); flex-shrink: 0; }
.df-btn { width: 100%; height: 68rpx; border-radius: 12rpx; font-size: 26rpx; font-weight: 700; border: none; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #722ED1, #9B51E0); color: #fff;
  &[disabled] { opacity: 0.45; background: #E5E6EB; }
}
</style>
