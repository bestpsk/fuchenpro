<template>
  <view class="supplier-container">
    <view class="search-section">
      <view class="search-box">
        <u-icon name="search" size="16" color="#86909C"></u-icon>
        <input class="search-input" type="text" v-model="queryParams.keyword" placeholder="搜索供货商名称/联系人" placeholder-class="search-placeholder" confirm-type="search" @input="onSearchInput" @confirm="handleSearch" />
        <view v-if="queryParams.keyword" class="clear-btn" @click="clearKeyword">
          <u-icon name="close-circle-fill" size="14" color="#C9CDD4"></u-icon>
        </view>
        <view class="filter-btn" :class="{ active: hasActiveFilters }" @click="toggleFilter">
          <u-icon name="list" size="12" :color="hasActiveFilters ? '#3D6DF7' : '#4E5969'"></u-icon>
          <text>筛选</text>
        </view>
      </view>
    </view>

    <u-popup :show="showFilter" mode="top" round="16" @close="toggleFilter">
      <view class="popup-content">
        <view class="popup-title">筛选条件</view>
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

    <scroll-view scroll-y class="list-scroll" @scrolltolower="loadMore" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onPullDownRefresh">
      <view v-if="supplierList.length > 0" class="card-list">
        <view v-for="item in supplierList" :key="item.supplierId" class="supplier-card" @click="goDetail(item)">
          <view class="card-header">
            <text class="supplier-name">{{ item.supplierName || '-' }}</text>
            <view class="status-badge" :class="'status-' + item.status">{{ item.status === '0' ? '正常' : '停用' }}</view>
          </view>
          <view class="card-body">
            <view class="info-row">
              <view class="info-item">
                <text class="info-label">联系人</text>
                <text class="info-value">{{ item.contactPerson || '-' }}</text>
              </view>
              <view class="info-item" @click.stop="item.contactPhone && callPhone(item.contactPhone)">
                <text class="info-label">电话</text>
                <text class="info-value" :class="{ 'phone-link': item.contactPhone }">{{ item.contactPhone || '-' }}</text>
              </view>
            </view>
            <view v-if="item.address" class="info-row single">
              <text class="info-label">地址</text>
              <text class="info-value address-text">{{ item.address }}</text>
            </view>
            <view v-if="item.cooperationStartDate" class="info-row single">
              <text class="info-label">合作日期</text>
              <text class="info-value">{{ item.cooperationStartDate }}</text>
            </view>
          </view>
        </view>
      </view>
      <u-empty v-else-if="!loading" mode="data" text="暂无供货商数据" :marginTop="100"></u-empty>
      <u-loadmore :status="loadStatus" :loading-text="'加载中...'" :loadmore-text="'上拉加载更多'" :nomore-text="'没有更多了'" :marginTop="20" />
    </scroll-view>

    <view v-if="checkPermi(['wms:supplier:add', 'wms:supplier:edit', 'wms:supplier:query', 'wms:supplier:export', 'wms:supplier:remove'])" class="fab-btn" @click="handleAdd">
      <u-icon name="plus" size="28" color="#fff"></u-icon>
    </view>

    <!-- 新增/编辑抽屉 -->
    <u-popup :show="showDrawer" mode="bottom" :round="20" @close="closeDrawer" :customStyle="{ height: '80vh' }">
      <view class="drawer-container">
        <view class="drawer-header">
          <text class="drawer-title">{{ drawerMode === 'add' ? '新增供货商' : '编辑供货商' }}</text>
          <u-icon name="close" size="20" color="#86909C" @click="closeDrawer"></u-icon>
        </view>
        <scroll-view scroll-y class="drawer-scroll">
          <view class="form-section">
            <view class="form-field">
              <view class="field-label"><text class="required">*</text> 供货商名称</view>
              <view class="field-input-box">
                <input class="field-input" type="text" v-model="form.supplierName" placeholder="请输入供货商名称" placeholder-class="field-placeholder" />
              </view>
            </view>
            <view class="form-row">
              <view class="form-field half">
                <view class="field-label">联系人</view>
                <view class="field-input-box">
                  <input class="field-input" type="text" v-model="form.contactPerson" placeholder="请输入联系人" placeholder-class="field-placeholder" />
                </view>
              </view>
              <view class="form-field half">
                <view class="field-label">联系电话</view>
                <view class="field-input-box">
                  <input class="field-input" type="number" v-model="form.contactPhone" placeholder="请输入联系电话" placeholder-class="field-placeholder" maxlength="11" />
                </view>
              </view>
            </view>
            <view class="form-field">
              <view class="field-label">地址</view>
              <view class="field-input-box">
                <input class="field-input" type="text" v-model="form.address" placeholder="请输入地址" placeholder-class="field-placeholder" />
              </view>
            </view>
            <view class="form-row">
              <view class="form-field half" @click="showDatePicker = true">
                <view class="field-label">合作起始日期</view>
                <view class="field-input-box picker-field">
                  <input class="field-input" :value="form.cooperationStartDate" placeholder="请选择日期" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
                  <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
                </view>
              </view>
              <view class="form-field half">
                <view class="field-label">状态</view>
                <view class="field-input-box radio-field">
                  <view class="radio-group">
                    <view class="radio-item" :class="{ active: form.status === '0' }" @click="form.status = '0'">
                      <view class="radio-dot"></view>
                      <text>正常</text>
                    </view>
                    <view class="radio-item" :class="{ active: form.status === '1' }" @click="form.status = '1'">
                      <view class="radio-dot"></view>
                      <text>停用</text>
                    </view>
                  </view>
                </view>
              </view>
            </view>
            <view class="form-field">
              <view class="field-label">备注</view>
              <view class="field-textarea-box">
                <textarea class="field-textarea" v-model="form.remark" placeholder="请输入备注信息" placeholder-class="field-placeholder" :maxlength="500" auto-height></textarea>
              </view>
            </view>
          </view>
        </scroll-view>
        <view class="drawer-actions">
          <u-button type="info" plain text="取消" @click="closeDrawer"></u-button>
          <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
        </view>
      </view>
    </u-popup>

    <u-datetime-picker :show="showDatePicker" mode="date" @confirm="onDateConfirm" @cancel="showDatePicker = false" @close="showDatePicker = false"></u-datetime-picker>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onUnmounted } from 'vue'
import { onShow, onLoad } from '@dcloudio/uni-app'
import { listSupplier, getSupplier, addSupplier, updateSupplier } from '@/api/wms/supplier'
import { checkPermi } from '@/utils/permission'


const supplierList = ref([])
const loading = ref(false)
const refreshing = ref(false)
const loadStatus = ref('loadmore')
const showFilter = ref(false)

// 抽屉相关
const showDrawer = ref(false)
const drawerMode = ref('add')
const submitting = ref(false)
const showDatePicker = ref(false)
const form = reactive({
  supplierId: undefined,
  supplierName: '',
  contactPerson: '',
  contactPhone: '',
  address: '',
  cooperationStartDate: '',
  status: '0',
  remark: ''
})

let searchTimer = null
onUnmounted(() => { clearTimeout(searchTimer) })

const hasActiveFilters = computed(() => queryParams.status !== '' && queryParams.status !== undefined)

const queryParams = reactive({ pageNum: 1, pageSize: 10, keyword: '', status: '' })

const statusOptions = ref([
  { label: '正常', value: '0' },
  { label: '停用', value: '1' }
])

async function getList(isRefresh = false) {
  if (loading.value) return
  loading.value = true
  if (isRefresh) { queryParams.pageNum = 1; loadStatus.value = 'loadmore' }
  try {
    const params = { pageNum: queryParams.pageNum, pageSize: queryParams.pageSize }
    if (queryParams.status !== '' && queryParams.status !== undefined) params.status = queryParams.status
    if (queryParams.keyword) { params.supplierName = queryParams.keyword; params.contactPerson = queryParams.keyword }
    const response = await listSupplier(params)
    const data = response.data || response
    const list = data.rows || data.items || []
    const total = data.total || 0
    supplierList.value = isRefresh ? list : [...supplierList.value, ...list]
    loadStatus.value = supplierList.value.length >= total ? 'nomore' : 'loadmore'
  } catch (e) { console.error('获取供货商列表失败:', e); loadStatus.value = 'error' }
  finally { loading.value = false; refreshing.value = false }
}

function loadMore() { if (loading.value || loadStatus.value === 'nomore') return; loadStatus.value = 'loading'; queryParams.pageNum++; getList() }
function onPullDownRefresh() { refreshing.value = true; getList(true) }
function handleSearch() { getList(true) }
function onSearchInput() { if (searchTimer) clearTimeout(searchTimer); searchTimer = setTimeout(() => handleSearch(), 500) }
function clearKeyword() { queryParams.keyword = ''; handleSearch() }
function toggleFilter() { showFilter.value = !showFilter.value }
function resetFilter() { queryParams.status = '' }
function confirmFilter() { showFilter.value = false; getList(true) }

function callPhone(phone) { uni.makePhoneCall({ phoneNumber: phone }) }

function goDetail(item) {
  uni.navigateTo({ url: `/pages/wms/supplier/detail?id=${item.supplierId}` })
}

function handleAdd() {
  if (!checkPermi('wms:supplier:add')) { uni.showToast({ title: '无新增权限', icon: 'none' }); return }
  openDrawer('add')
}

// 抽屉方法
function resetForm() {
  Object.assign(form, {
    supplierId: undefined,
    supplierName: '',
    contactPerson: '',
    contactPhone: '',
    address: '',
    cooperationStartDate: '',
    status: '0',
    remark: ''
  })
}

function openDrawer(mode, id) {
  drawerMode.value = mode
  resetForm()
  if (mode === 'edit' && id) {
    form.supplierId = id
    loadDrawerDetail(id)
  }
  showDrawer.value = true
}

function closeDrawer() {
  showDrawer.value = false
  resetForm()
}

async function loadDrawerDetail(id) {
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getSupplier(id)
    const data = response.data || response
    Object.assign(form, {
      supplierId: data.supplierId,
      supplierName: data.supplierName || '',
      contactPerson: data.contactPerson || '',
      contactPhone: data.contactPhone || '',
      address: data.address || '',
      cooperationStartDate: data.cooperationStartDate || '',
      status: data.status || '0',
      remark: data.remark || ''
    })
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

function onDateConfirm(e) {
  const date = new Date(e.value)
  form.cooperationStartDate = date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0')
  showDatePicker.value = false
}

async function submitForm() {
  if (!form.supplierName.trim()) { uni.showToast({ title: '请输入供货商名称', icon: 'none' }); return }
  if (form.contactPhone && !/^1[3-9]\d{9}$/.test(form.contactPhone)) { uni.showToast({ title: '请输入正确的手机号', icon: 'none' }); return }

  submitting.value = true
  try {
    const formData = {
      supplierName: form.supplierName.trim(),
      contactPerson: form.contactPerson.trim() || null,
      contactPhone: form.contactPhone.trim() || null,
      address: form.address.trim() || null,
      cooperationStartDate: form.cooperationStartDate || null,
      status: form.status,
      remark: form.remark.trim() || null
    }

    if (form.supplierId) {
      formData.supplierId = form.supplierId
      await updateSupplier(formData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      await addSupplier(formData)
      uni.showToast({ title: '新增成功', icon: 'success' })
    }
    showDrawer.value = false
    resetForm()
    getList(true)
  } catch (e) {
    console.error('提交失败:', e)
    const msg = e?.msg || e?.message || '操作失败，请重试'
    uni.showToast({ title: msg, icon: 'none', duration: 2000 })
  } finally { submitting.value = false }
}

// 监听从详情页返回的编辑事件（onLoad只执行一次，避免重复注册）
onLoad((options) => {
  uni.$on('editSupplier', (id) => openDrawer('edit', id))
  if (options && options.editId) {
    openDrawer('edit', parseInt(options.editId))
  }
})

onShow(() => {
  getList(true)
})

onUnmounted(() => {
  uni.$off('editSupplier')
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; height: 100%; overflow: hidden; }
.supplier-container { display: flex; flex-direction: column; height: 100%; overflow: hidden; padding: 0 24rpx;
  :deep(.u-popup) { flex: none !important; }
}

.search-section { flex-shrink: 0; padding: 20rpx 0; }
.search-box { display: flex; align-items: center; background: #fff; border-radius: 36rpx; padding: 0 8rpx 0 28rpx; height: 72rpx; gap: 12rpx; box-sizing: border-box; box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.04); }
.search-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 72rpx; min-width: 0; }
.search-placeholder { color: #86909C; font-size: 28rpx; }
.clear-btn { flex-shrink: 0; padding: 8rpx; display: flex; align-items: center; }
.filter-btn { flex-shrink: 0; display: flex; align-items: center; justify-content: center; gap: 6rpx; height: 56rpx; padding: 0 22rpx; background: #F5F7FA; border-radius: 28rpx; transition: all 0.2s;
  text { font-size: 26rpx; color: #4E5969; font-weight: 500; white-space: nowrap; }
  &.active { background: #e8f0fe;
    text { color: #3D6DF7; }
  }
}

.popup-content { padding: 30rpx; background: #fff; }
.popup-title { font-size: 32rpx; font-weight: 600; color: #1D2129; margin-bottom: 30rpx; }
.form-item { margin-bottom: 30rpx; }
.form-label { font-size: 28rpx; color: #1D2129; font-weight: 500; margin-bottom: 16rpx; }
.form-options { display: flex; flex-wrap: wrap; gap: 16rpx; }
.option-tag { padding: 14rpx 28rpx; background: #F5F7FA; border-radius: 8rpx; font-size: 26rpx; color: #4E5969; border: 2rpx solid transparent; transition: all 0.2s;
  &.active { background: #e8f0fe; color: #3D6DF7; border-color: #3D6DF7; }
}
.popup-actions { display: flex; gap: 20rpx; margin-top: 40rpx; padding-top: 30rpx; border-top: 1rpx solid #E5E6EB; .u-button { flex: 1; } }

.list-scroll { flex: 1; overflow: hidden; padding: 12rpx 0; }
.card-list { display: flex; flex-direction: column; gap: 16rpx; }

.supplier-card { background: #fff; border-radius: 16rpx; padding: 28rpx 32rpx; transition: all 0.15s;
  &:active { transform: scale(0.985); background: #FAFBFC; }
}
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
.supplier-name { font-size: 30rpx; font-weight: 600; color: #1D2129; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; margin-right: 16rpx; }
.status-badge { padding: 4rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; flex-shrink: 0;
  &.status-0 { background: #e8f0fe; color: #3D6DF7; }
  &.status-1 { background: #F2F3F5; color: #86909C; }
}

.card-body { display: flex; flex-direction: column; gap: 12rpx; }
.info-row { display: flex; gap: 32rpx;
  &.single { gap: 12rpx; }
}
.info-item { display: flex; align-items: center; gap: 8rpx; flex: 1; min-width: 0; }
.info-label { font-size: 24rpx; color: #86909C; flex-shrink: 0; }
.info-value { font-size: 26rpx; color: #1D2129; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
  &.phone-link { color: #3D6DF7; }
  &.address-text { white-space: normal; overflow: visible; }
}

.fab-btn { position: fixed; right: 40rpx; bottom: 80rpx; width: 100rpx; height: 100rpx; border-radius: 50%; background: #3D6DF7; display: flex; align-items: center; justify-content: center; box-shadow: 0 8rpx 24rpx rgba(61,109,247,0.35); z-index: 100;
  &:active { transform: scale(0.92); }
}

/* 抽屉样式 */
.drawer-container { display: flex; flex-direction: column; height: 80vh; box-sizing: border-box; }
.drawer-header { display: flex; align-items: center; justify-content: space-between; padding: 28rpx 32rpx; border-bottom: 1rpx solid #F2F3F5; flex-shrink: 0; }
.drawer-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.drawer-scroll { flex: 1; min-height: 0; overflow: hidden; padding: 24rpx 32rpx; box-sizing: border-box; }
.drawer-actions { display: flex; gap: 20rpx; padding: 20rpx 32rpx; border-top: 1rpx solid #F2F3F5; flex-shrink: 0;
  .u-button { flex: 1; height: 80rpx; border-radius: 40rpx; font-size: 30rpx; font-weight: 600; }
}

.form-section { background: #fff; border-radius: 20rpx; padding: 32rpx; box-sizing: border-box; }
.form-field { margin-bottom: 28rpx; &:last-child { margin-bottom: 0; } }
.field-label { font-size: 26rpx; color: #4E5969; font-weight: 500; margin-bottom: 12rpx;
  .required { color: #F53F3F; margin-right: 4rpx; }
}
.field-input-box { display: flex; align-items: center; background: #F7F8FA; border-radius: 12rpx; padding: 0 24rpx; height: 84rpx; gap: 12rpx; transition: background 0.2s; box-sizing: border-box;
  &:focus-within { background: #EFF0F1; }
  &.picker-field { cursor: pointer; }
  &.radio-field { background: transparent; padding: 0; height: auto; }
}
.field-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 84rpx; line-height: 84rpx; background: transparent; }
.field-placeholder { color: #C9CDD4; font-size: 28rpx; }
.field-textarea-box { background: #F7F8FA; border-radius: 12rpx; padding: 20rpx 24rpx; box-sizing: border-box; }
.field-textarea { width: 100%; min-height: 120rpx; font-size: 28rpx; color: #1D2129; line-height: 1.6; background: transparent; }
.form-row { display: flex; gap: 24rpx; }
.half { flex: 1; min-width: 0; }
.radio-group { display: flex; gap: 40rpx; padding: 8rpx 0; }
.radio-item { display: flex; align-items: center; gap: 10rpx; font-size: 28rpx; color: #86909C; transition: color 0.2s;
  &.active { color: #1D2129; }
}
.radio-dot { width: 32rpx; height: 32rpx; border-radius: 50%; border: 4rpx solid #C9CDD4; position: relative; transition: border-color 0.2s;
  .radio-item.active & { border-color: #3D6DF7;
    &::after { content: ''; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 16rpx; height: 16rpx; border-radius: 50%; background: #3D6DF7; }
  }
}
</style>
