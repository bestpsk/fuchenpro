<template>
  <view class="op-page">
    <view class="customer-info">
      <view class="info-row">
        <u-icon name="account-fill" size="18" color="#3D6DF7"></u-icon>
        <text class="customer-name">{{ customerName }}</text>
      </view>
      <view class="info-row">
        <u-icon name="map" size="14" color="#86909C"></u-icon>
        <text class="store-name">{{ enterpriseName }} · {{ storeName }}</text>
      </view>
    </view>

    <u-tabs :list="tabList" :current="currentTab" @click="onTabChange" :activeStyle="{ color: '#3D6DF7', fontWeight: 'bold' }" :lineColor="'#3D6DF7'" :scrollable="false"></u-tabs>

    <view class="tab-content">
      <view v-if="currentTab === 0" class="tab-panel">
        <view class="section-header">
          <view class="section-line"></view>
          <text class="section-title">选择要操作的品项</text>
          <text class="section-subtitle" v-if="packageList.length > 0">共 {{ packageList.length }} 个套餐</text>
          <button class="trial-entry-btn" v-if="checkPermi('business:operation:add')" @click="openTrialDrawer">
          <u-icon name="plus" size="12" color="#3D6DF7"></u-icon>
          <text>体验操作</text>
        </button>
        </view>

        <scroll-view scroll-y class="op-list-scroll">
          <view v-if="packageList.length > 0" class="pkg-list">
            <view v-for="pkg in packageList" :key="pkg.packageId" class="pkg-card">
              <view class="pkg-card-head">
                <text class="pkg-name">{{ pkg.packageName }}</text>
                <view class="pkg-tag owed" v-if="owedPackageMap[pkg.packageId] && Number(owedPackageMap[pkg.packageId].owedAmount || 0) > 0">欠款</view>
                <view class="pkg-tag payment" v-if="owedPackageMap[pkg.packageId] && owedPackageMap[pkg.packageId].paymentMethod">{{ getPaymentMethodName(owedPackageMap[pkg.packageId].paymentMethod) }}</view>
                <text class="pkg-amount">¥{{ Number(pkg.totalAmount || 0).toFixed(2) }}</text>
              </view>
              <view v-for="item in (pkg.items || [])" :key="item.packageItemId" class="item-row" :class="{ disabled: item.remainingQuantity <= 0 || pkg.status === '2', selected: isSelected(item.packageItemId) }">
                <label class="item-check" :class="{ checked: isSelected(item.packageItemId) }" @click.stop="toggleItem(pkg, item, !isSelected(item.packageItemId))">
                  <view class="check-box"></view>
                </label>
                <text class="item-name">{{ item.productName }}</text>
                <text class="item-price">¥{{ Number(item.unitPrice || 0).toFixed(2) }}</text>
                <text class="item-remain">剩{{ item.remainingQuantity || 0 }}</text>
              </view>
              <view v-if="!pkg.items || pkg.items.length === 0" class="pkg-empty">暂无品项</view>
            </view>
          </view>
          <u-empty v-else mode="data" text="该客户暂无可用套餐" :marginTop="100"></u-empty>
        </scroll-view>

        <view class="op-bottom-bar">
          <view class="bar-info">
            <text class="bar-count">已选 <text class="count-num">{{ selectedItems.length }}</text> 项</text>
            <text class="bar-total" v-if="selectedItems.length > 0">合计 ¥{{ getTotalPrice() }}</text>
          </view>
          <view class="bar-actions">
            <button class="bar-btn" :class="{ active: selectedItems.length > 0 }" :disabled="selectedItems.length === 0" v-if="checkPermi('business:operation:add')" @click="openDetailDrawer">确认操作</button>
          </view>
        </view>
      </view>

      <view v-if="currentTab === 1" class="tab-panel">
        <view v-if="operationList.length > 0" class="record-list">
          <view v-for="item in operationList" :key="item.operationId" class="record-card">
            <view class="rc-head-row">
              <u-icon name="list" size="16" color="#86909C"></u-icon>
              <text class="rc-product-head">{{ item.productName || '-' }}</text>
              <view class="rc-type-tag" :class="'type-' + (item.operationType || '0')">{{ item.operationType === '1' ? '体验' : '持卡' }}</view>
              <text class="rc-pkg-name">{{ item.packageName || item.package_name || '散项' }}</text>
            </view>

            <view class="rc-price-row">
              <text class="rc-unit-price">¥{{ Number((item.consume_amount || item.consumeAmount || 0) / (item.operation_quantity || item.operationQuantity || 1)).toFixed(2) }}/次</text>
              <text class="rc-price-sep">×</text>
              <text class="rc-qty-num">{{ item.operationQuantity || 1 }}</text>
              <text class="rc-price-eq">=</text>
              <text class="rc-total-price">¥{{ Number(item.consumeAmount || 0).toFixed(2) }}</text>
            </view>

            <view class="rc-meta-row">
              <view class="rc-operator"><u-icon name="account" size="14" color="#86909C"></u-icon><text>{{ item.operatorUserName || item.operator_user_name || item.operatorName || '-' }}</text></view>
              <view class="rc-satisfaction" v-if="item.satisfaction != null && item.satisfaction !== ''"><u-rate :modelValue="Number(item.satisfaction) || 0" :count="5" activeColor="#FF9900" inactiveColor="#E5E6EB" size="20" activeIcon="star-fill" inactiveIcon="star" :readonly="true"></u-rate></view>
              <text class="rc-date">{{ formatTimeShort(item.operationDate || item.createTime) }}</text>
            </view>

            <view class="rc-remark" v-if="item.remark"><u-icon name="edit-pen" size="14" color="#C9CDD4"></u-icon><text>{{ item.remark }}</text></view>
          </view>
        </view>
        <u-empty v-else mode="data" text="暂无操作记录" :marginTop="40"></u-empty>
      </view>
    </view>

    <u-popup :show="showDetailDrawer" mode="bottom" round="24" :closeable="true" @close="closeDetailDrawer" :customStyle="{ width: '100vw', maxWidth: '100vw', left: 0 }">
      <view class="detail-drawer">
        <view class="drawer-head">
          <view class="head-left">
            <u-icon name="grid" size="18" color="#3D6DF7"></u-icon>
            <text class="drawer-title">持卡操作</text>
          </view>
          <view class="head-tag">
            <u-icon name="account" size="13" color="#3D6DF7"></u-icon>
            <text>{{ customerName }}</text>
          </view>
        </view>

        <scroll-view scroll-y class="drawer-scroll" :style="{ height: drawerScrollHeight + 'px' }">
          <view v-if="selectedItems.length > 0" class="dd-section">
            <view class="section-label"><text>已选品项 ({{ selectedItems.length }})</text></view>

            <view class="item-card-list">
              <view v-for="(it, idx) in selectedItems" :key="it.packageItemId" class="item-card">
                <view class="ic-main-row">
                  <text class="ic-product">{{ it.productName }}</text>
                  <view class="ic-pkg-tag">{{ it.packageName }}</view>
                  <view class="ic-remove" @click="removeItem(idx)"><u-icon name="close" size="18" color="#C9CDD4"></u-icon></view>
                </view>
                <view class="ic-price-row">
                  <view class="col-price">¥{{ Number(it.unitPrice || 0).toFixed(2) }}</view>
                  <view class="col-qty">
                    <view class="qty-btn" @click="qtyChange(idx, -1)">−</view>
                    <text class="qty-val">{{ it.operationQuantity }}</text>
                    <view class="qty-btn" @click="qtyChange(idx, 1)">+</view>
                  </view>
                  <view class="col-amount">¥{{ it.consumeAmount }}</view>
                </view>
              </view>
            </view>

            <view class="total-card">
              <text class="total-left">合计消耗</text>
              <text class="total-right">¥{{ getTotalConsume() }}</text>
            </view>
          </view>

          <view class="dd-section">
            <view class="form-grid">
              <view class="form-cell">
                <view class="fc-label"><u-icon name="calendar" size="14" color="#86909C"></u-icon><text>操作时间</text></view>
                <view class="fc-field" @click="showDatePicker = true">
                  <text :class="{ placeholder: !form.operationDate }">{{ form.operationDate || '请选择日期' }}</text>
                  <u-icon name="arrow-right" size="12" color="#C9CDD4"></u-icon>
                </view>
              </view>
              <view class="form-cell">
                <view class="fc-label"><u-icon name="account" size="14" color="#86909C"></u-icon><text>操作人</text></view>
                <view class="fc-field" @click="showOperatorPicker = true">
                  <text :class="{ placeholder: !form.operatorName }">{{ form.operatorName || '选择操作人' }}</text>
                  <u-icon name="arrow-right" size="12" color="#C9CDD4"></u-icon>
                </view>
              </view>
            </view>
          </view>

          <view class="dd-section">
            <view class="satisfaction-card">
              <view class="sat-label"><u-icon name="star" size="14" color="#FF9900"></u-icon><text>满意度评价</text></view>
              <u-rate v-model="form.satisfaction" :count="5" activeColor="#FF9900" inactiveColor="#E5E6EB" size="24" activeIcon="star-fill" inactiveIcon="star" :allowHalf="true"></u-rate>
            </view>
          </view>

          <view class="dd-section">
            <view class="fc-label"><u-icon name="chat" size="14" color="#86909C"></u-icon><text>顾客反馈</text></view>
            <view class="fc-textarea-wrap">
              <textarea class="fc-textarea" v-model="form.customerFeedback" placeholder="记录顾客的反馈意见..." maxlength="200"></textarea>
            </view>
            <view class="fc-textarea-counter">{{ form.customerFeedback.length }} / 200</view>
          </view>

          <view class="dd-section">
            <view class="photo-grid">
              <view class="photo-cell">
                <view class="pc-label"><u-icon name="camera" size="14" color="#86909C"></u-icon><text>操作前</text></view>
                <view class="pc-upload">
                  <u-upload
                    :fileList="form.beforePhoto"
                    :afterRead="(e) => onBeforePhoto(e)"
                    :delete="(e) => form.beforePhoto.splice(e.index, 1)"
                    :maxCount="2"
                    :maxSize="5 * 1024 * 1024"
                    width="140rpx"
                    height="140rpx"
                  ></u-upload>
                </view>
              </view>
              <view class="photo-cell">
                <view class="pc-label"><u-icon name="camera" size="14" color="#86909C"></u-icon><text>操作后</text></view>
                <view class="pc-upload">
                  <u-upload
                    :fileList="form.afterPhoto"
                    :afterRead="(e) => onAfterPhoto(e)"
                    :delete="(e) => form.afterPhoto.splice(e.index, 1)"
                    :maxCount="2"
                    :maxSize="5 * 1024 * 1024"
                    width="140rpx"
                    height="140rpx"
                  ></u-upload>
                </view>
              </view>
            </view>
          </view>

          <view class="dd-section">
            <view class="fc-label"><u-icon name="edit-pen" size="14" color="#86909C"></u-icon><text>备注</text></view>
            <view class="fc-textarea-wrap">
              <textarea class="fc-textarea" v-model="form.remark" placeholder="补充说明或注意事项..." maxlength="200"></textarea>
            </view>
            <view class="fc-textarea-counter">{{ form.remark.length }} / 200</view>
          </view>
        </scroll-view>

        <view class="drawer-foot">
          <button class="submit-btn" :disabled="submitting || selectedItems.length === 0" @click="submitOperation">
            <u-icon v-if="!submitting" name="checkmark" size="16" color="#fff" style="margin-right: 8rpx"></u-icon>
            {{ submitting ? '提交中...' : '提交持卡操作' }}
          </button>
        </view>
      </view>
    </u-popup>

    <u-popup :show="showTrialDrawer" mode="bottom" round="24" :closeable="true" @close="closeTrialDrawer" :customStyle="{ width: '100vw', maxWidth: '100vw', left: 0 }">
      <view class="detail-drawer">
        <view class="head-bar"></view>
        <view class="drawer-head">
          <view class="head-left">
            <u-icon name="edit-pen" size="18" color="#3D6DF7"></u-icon>
            <text class="drawer-title">体验操作</text>
          </view>
          <view class="head-tag trial-head-tag">
            <u-icon name="account" size="13" color="#3D6DF7"></u-icon>
            <text>{{ customerName }}</text>
          </view>
        </view>

        <scroll-view scroll-y class="drawer-scroll" :style="{ height: drawerScrollHeight + 'px' }">
          <view class="dd-section">
            <view class="section-label required"><text>体验项目</text><text class="required-mark">*</text></view>
            <view class="trial-input-card">
              <input class="trial-text-input" type="text" v-model="trialForm.productName" placeholder="请输入操作项目名称" placeholder-class="trial-placeholder" />
            </view>
          </view>

          <view class="dd-section">
            <view class="form-grid">
              <view class="form-cell">
                <view class="fc-label"><u-icon name="reload" size="14" color="#86909C"></u-icon><text>操作次数</text></view>
                <view class="fc-field trial-num-field">
                  <u-number-box v-model="trialForm.operationQuantity" :min="1" :step="1" inputWidth="80" buttonSize="28"></u-number-box>
                </view>
              </view>
              <view class="form-cell">
                <view class="fc-label"><u-icon name="rmb" size="14" color="#86909C"></u-icon><text>体验价</text></view>
                <view class="fc-field trial-num-field">
                  <u-number-box v-model="trialForm.trialPrice" :min="0" :step="0.01" :decimalLength="2" inputWidth="80" buttonSize="28"></u-number-box>
                </view>
              </view>
            </view>
          </view>

          <view class="dd-section">
            <view class="form-grid">
              <view class="form-cell">
                <view class="fc-label"><u-icon name="calendar" size="14" color="#86909C"></u-icon><text>操作时间</text></view>
                <view class="fc-field" @click="openTrialDatePicker">
                  <text :class="{ placeholder: !trialForm.operationDate }">{{ trialForm.operationDate || '请选择日期' }}</text>
                  <u-icon name="arrow-right" size="12" color="#C9CDD4"></u-icon>
                </view>
              </view>
              <view class="form-cell">
                <view class="fc-label"><u-icon name="account" size="14" color="#86909C"></u-icon><text>操作人</text></view>
                <view class="fc-field" @click="openTrialOperatorPicker">
                  <text :class="{ placeholder: !trialForm.operatorName }">{{ trialForm.operatorName || '选择操作人' }}</text>
                  <u-icon name="arrow-right" size="12" color="#C9CDD4"></u-icon>
                </view>
              </view>
            </view>
          </view>

          <view class="dd-section">
            <view class="satisfaction-card">
              <view class="sat-label"><u-icon name="star" size="14" color="#FF9900"></u-icon><text>满意度评价</text></view>
              <u-rate v-model="trialForm.satisfaction" :count="5" activeColor="#FF9900" inactiveColor="#E5E6EB" size="24" activeIcon="star-fill" inactiveIcon="star" :allowHalf="true"></u-rate>
            </view>
          </view>

          <view class="dd-section">
            <view class="fc-label"><u-icon name="chat" size="14" color="#86909C"></u-icon><text>顾客反馈</text></view>
            <view class="fc-textarea-wrap">
              <textarea class="fc-textarea" v-model="trialForm.customerFeedback" placeholder="记录顾客的反馈意见..." maxlength="200"></textarea>
            </view>
            <view class="fc-textarea-counter">{{ trialForm.customerFeedback.length }} / 200</view>
          </view>

          <view class="dd-section">
            <view class="photo-grid">
              <view class="photo-cell">
                <view class="pc-label"><u-icon name="camera" size="14" color="#86909C"></u-icon><text>操作前</text></view>
                <view class="pc-upload">
                  <u-upload
                    :fileList="trialForm.beforePhoto"
                    :afterRead="(e) => onTrialBeforePhoto(e)"
                    :delete="(e) => trialForm.beforePhoto.splice(e.index, 1)"
                    :maxCount="2"
                    :maxSize="5 * 1024 * 1024"
                    width="140rpx"
                    height="140rpx"
                  ></u-upload>
                </view>
              </view>
              <view class="photo-cell">
                <view class="pc-label"><u-icon name="camera" size="14" color="#86909C"></u-icon><text>操作后</text></view>
                <view class="pc-upload">
                  <u-upload
                    :fileList="trialForm.afterPhoto"
                    :afterRead="(e) => onTrialAfterPhoto(e)"
                    :delete="(e) => trialForm.afterPhoto.splice(e.index, 1)"
                    :maxCount="2"
                    :maxSize="5 * 1024 * 1024"
                    width="140rpx"
                    height="140rpx"
                  ></u-upload>
                </view>
              </view>
            </view>
          </view>

          <view class="dd-section">
            <view class="fc-label"><u-icon name="edit-pen" size="14" color="#86909C"></u-icon><text>备注</text></view>
            <view class="fc-textarea-wrap">
              <textarea class="fc-textarea" v-model="trialForm.remark" placeholder="补充说明或注意事项..." maxlength="200"></textarea>
            </view>
            <view class="fc-textarea-counter">{{ trialForm.remark.length }} / 200</view>
          </view>
        </scroll-view>

        <view class="drawer-foot">
          <button class="submit-btn trial-submit-btn" :disabled="trialSubmitting" @click="submitTrialOperation">
            <u-icon v-if="!trialSubmitting" name="checkmark" size="16" color="#fff" style="margin-right: 8rpx"></u-icon>
            {{ trialSubmitting ? '提交中...' : '提交体验操作' }}
          </button>
        </view>
      </view>
    </u-popup>

    <u-datetime-picker
      :show="showDatePicker"
      mode="date"
      v-model="datePickerValue"
      @confirm="onDateConfirm"
      @cancel="showDatePicker = false"
      @close="showDatePicker = false"
    ></u-datetime-picker>
    <u-action-sheet
      :show="showOperatorPicker"
      :actions="operatorList"
      title="选择操作人"
      @select="onOperatorSelect"
      @close="showOperatorPicker = false"
    ></u-action-sheet>
  </view>
</template>

<script setup>
/**
 * @description 项目操作页 - 持卡操作/体验操作与操作记录
 * @description 从客户套餐中选择品项进行持卡操作，支持数量调整、满意度评价、
 * 操作前后照片上传、操作记录查看等功能；同时支持体验操作（operationType='1'），
 * 无需关联套餐/卡项，仅需录入项目名称、次数、体验价等信息
 */
import { ref, reactive, onMounted } from 'vue'
import { getPackageByCustomer } from '@/api/business/customerPackage'
import { listOperation, addOperation } from '@/api/business/operationRecord'
import { getOwedPackages } from '@/api/business/repayment'
import { listEmployeeConfig } from '@/api/business/employeeConfig'
import { useUserStore } from '@/store/modules/user'
import upload from '@/utils/upload'
import { useScrollHeight } from '@/utils/useScrollHeight'
import { checkPermi } from '@/utils/permission'

const userStore = useUserStore()

const customerId = ref('')
const customerName = ref('')
const storeId = ref('')
const storeName = ref('')
const enterpriseId = ref('')
const enterpriseName = ref('')

/** 当前Tab索引：0-操作/1-操作记录 */
const currentTab = ref(0)
const tabList = ref([{ name: '操作' }, { name: '操作记录' }])
const operationList = ref([])

const packageList = ref([])
const owedPackageMap = ref({})
const selectedItems = ref([])

const showDetailDrawer = ref(false)
const submitting = ref(false)
const showDatePicker = ref(false)
const datePickerValue = ref(Number(new Date()))
const showOperatorPicker = ref(false)
const operatorList = ref([])
/** 当前日期/操作人选择器目标表单：'operation'-持卡操作 / 'trial'-体验操作 */
const pickerTarget = ref('operation')
/** 体验操作弹窗显示状态 */
const showTrialDrawer = ref(false)
/** 体验操作提交中状态 */
const trialSubmitting = ref(false)
/** 抽屉内滚动区域高度 */
const { scrollHeight: drawerScrollHeight, recalc: recalcDrawerHeight } = useScrollHeight(() => {
  const sysInfo = uni.getSystemInfoSync()
  const safeBottom = sysInfo.safeAreaInsets?.bottom || 0
  const headH = uni.upx2px ? uni.upx2px(56) : 28
  const footH = uni.upx2px ? uni.upx2px(100) : 50 + safeBottom
  return Math.floor(sysInfo.windowHeight * 0.93) - headH - footH
})

/** 操作表单数据 */
const form = reactive({
  operationType: '0',
  operationDate: '',
  operatorUserId: null,
  operatorName: '',
  satisfaction: 5,
  customerFeedback: '',
  beforePhoto: [],
  afterPhoto: [],
  remark: ''
})

/** 体验操作表单数据，operationType='1'，无需关联套餐/卡项，仅需项目和客户 */
const trialForm = reactive({
  operationType: '1',
  productName: '',
  operationQuantity: 1,
  trialPrice: 0,
  operationDate: '',
  operatorUserId: null,
  operatorName: '',
  satisfaction: 5,
  customerFeedback: '',
  beforePhoto: [],
  afterPhoto: [],
  remark: ''
})

/** 判断品项是否已被选中 */
function isSelected(packageItemId) {
  return selectedItems.value.some(i => i.packageItemId === packageItemId)
}

/** 切换品项选中状态，选中时初始化数量为1并计算消耗金额，取消时移除 */
function toggleItem(pkg, item, checked) {
  if (checked) {
    if (!isSelected(item.packageItemId)) {
      selectedItems.value.push({
        ...item,
        packageName: pkg.packageName,
        packageId: pkg.packageId,
        customerId: customerId.value,
        customerName: customerName.value,
        enterpriseId: enterpriseId.value,
        storeId: storeId.value,
        operationQuantity: Math.min(1, item.remainingQuantity || 0),
        consumeAmount: Number((item.unitPrice || 0) * Math.min(1, item.remainingQuantity || 0)).toFixed(2)
      })
    }
  } else {
    selectedItems.value = selectedItems.value.filter(i => i.packageItemId !== item.packageItemId)
  }
}

/** 从已选列表中移除指定品项 */
function removeItem(idx) {
  selectedItems.value.splice(idx, 1)
}

/** 调整已选品项数量，限制在1到剩余次数之间，同步更新消耗金额 */
function qtyChange(idx, delta) {
  const it = selectedItems.value[idx]
  if (!it) return
  let qty = parseInt(it.operationQuantity) || 0
  qty += delta
  const maxQty = parseInt(it.remainingQuantity) || 0
  if (qty < 1) qty = 1
  if (qty > maxQty) qty = maxQty
  it.operationQuantity = qty
  it.consumeAmount = Number((it.unitPrice || 0) * qty).toFixed(2)
}

/** 计算已选品项总价 */
function getTotalPrice() {
  return selectedItems.value.reduce((sum, it) => sum + parseFloat(it.consumeAmount || 0), 0).toFixed(2)
}

/** 打开操作详情抽屉，初始化表单默认值并计算抽屉高度 */
function openDetailDrawer() {
  if (selectedItems.value.length === 0) return
  form.operationDate = new Date().toISOString().slice(0, 10)
  form.operatorName = userStore.nickName || userStore.name || ''
  form.satisfaction = 5
  form.customerFeedback = ''
  form.beforePhoto = []
  form.afterPhoto = []
  form.remark = ''
  datePickerValue.value = Number(new Date())
  pickerTarget.value = 'operation'
  loadOperators()
  recalcDrawerHeight()
  showDetailDrawer.value = true
}

/** 关闭操作详情抽屉 */
function closeDetailDrawer() {
  showDetailDrawer.value = false
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
    console.error('加载员工列表失败:', e)
  }
}

/** 选择操作人后更新表单，根据 pickerTarget 更新对应表单（持卡/体验） */
function onOperatorSelect(e) {
  if (pickerTarget.value === 'trial') {
    trialForm.operatorName = e.name
    trialForm.operatorUserId = e.userId
  } else {
    form.operatorName = e.name
    form.operatorUserId = e.userId
  }
  showOperatorPicker.value = false
}

/** 计算已选品项合计消耗金额 */
function getTotalConsume() {
  return selectedItems.value.reduce((sum, it) => sum + parseFloat(it.consumeAmount || 0), 0).toFixed(2)
}

/** 提交持卡操作，逐个品项调用接口创建操作记录，成功后返回上一页 */
async function submitOperation() {
  if (selectedItems.value.length === 0) {
    return uni.showToast({ title: '请选择操作品项', icon: 'none' })
  }
  submitting.value = true
  try {
    for (const item of selectedItems.value) {
      await addOperation({
        customerId: customerId.value,
        customerName: customerName.value,
        packageId: item.packageId,
        packageItemId: item.packageItemId,
        productName: item.productName,
        operationType: form.operationType,
        operationQuantity: item.operationQuantity,
        consumeAmount: item.consumeAmount,
        unitPrice: item.unitPrice,
        operationDate: form.operationDate,
        operatorUserId: form.operatorUserId,
        operatorUserName: form.operatorName,
        satisfaction: form.satisfaction,
        customerFeedback: form.customerFeedback,
        beforePhoto: form.beforePhoto.map(p => p.name).join(','),
        afterPhoto: form.afterPhoto.map(p => p.name).join(','),
        remark: form.remark,
        enterpriseId: enterpriseId.value,
        storeId: storeId.value
      })
    }
    uni.showToast({ title: '操作成功', icon: 'success' })
    closeDetailDrawer()
    selectedItems.value = []
    setTimeout(() => uni.navigateBack(), 1500)
  } catch (e) {
    console.error('操作失败:', e)
    uni.showToast({ title: '操作失败', icon: 'none' })
  } finally {
    submitting.value = false
  }
}

/** 操作前照片上传，上传到服务端后将返回的URL存入表单 */
async function onBeforePhoto(e) {
  if (e.file) {
    try {
      const res = await upload({ url: '/common/upload', name: 'file', filePath: e.url })
      const url = res.url || res.fileName
      form.beforePhoto.push({ url: url, name: url })
    } catch (err) {
      uni.showToast({ title: '上传失败', icon: 'none' })
    }
  }
}

/** 操作后照片上传，上传到服务端后将返回的URL存入表单 */
async function onAfterPhoto(e) {
  if (e.file) {
    try {
      const res = await upload({ url: '/common/upload', name: 'file', filePath: e.url })
      const url = res.url || res.fileName
      form.afterPhoto.push({ url: url, name: url })
    } catch (err) {
      uni.showToast({ title: '上传失败', icon: 'none' })
    }
  }
}

/** 打开体验操作弹窗，初始化体验表单默认值（无需选择套餐/卡项），加载操作人列表并计算抽屉高度 */
function openTrialDrawer() {
  trialForm.productName = ''
  trialForm.operationQuantity = 1
  trialForm.trialPrice = 0
  trialForm.operationDate = new Date().toISOString().slice(0, 10)
  trialForm.operatorName = userStore.nickName || userStore.name || ''
  trialForm.operatorUserId = null
  trialForm.satisfaction = 5
  trialForm.customerFeedback = ''
  trialForm.beforePhoto = []
  trialForm.afterPhoto = []
  trialForm.remark = ''
  datePickerValue.value = Number(new Date())
  pickerTarget.value = 'trial'
  loadOperators()
  recalcDrawerHeight()
  showTrialDrawer.value = true
}

/** 关闭体验操作弹窗 */
function closeTrialDrawer() {
  showTrialDrawer.value = false
}

/** 打开体验操作日期选择器，设置选择目标为体验表单 */
function openTrialDatePicker() {
  pickerTarget.value = 'trial'
  datePickerValue.value = Number(new Date(trialForm.operationDate ? trialForm.operationDate.replace(/-/g, '/') : new Date()))
  showDatePicker.value = true
}

/** 打开体验操作操作人选择器，设置选择目标为体验表单 */
function openTrialOperatorPicker() {
  pickerTarget.value = 'trial'
  showOperatorPicker.value = true
}

/** 体验操作-操作前照片上传，上传到服务端后将返回的URL存入体验表单 */
async function onTrialBeforePhoto(e) {
  if (e.file) {
    try {
      const res = await upload({ url: '/common/upload', name: 'file', filePath: e.url })
      const url = res.url || res.fileName
      trialForm.beforePhoto.push({ url: url, name: url })
    } catch (err) {
      uni.showToast({ title: '上传失败', icon: 'none' })
    }
  }
}

/** 体验操作-操作后照片上传，上传到服务端后将返回的URL存入体验表单 */
async function onTrialAfterPhoto(e) {
  if (e.file) {
    try {
      const res = await upload({ url: '/common/upload', name: 'file', filePath: e.url })
      const url = res.url || res.fileName
      trialForm.afterPhoto.push({ url: url, name: url })
    } catch (err) {
      uni.showToast({ title: '上传失败', icon: 'none' })
    }
  }
}

/** 提交体验操作，operationType='1'，不关联套餐/卡项，仅传项目名称、次数、体验价等字段，成功后返回上一页 */
async function submitTrialOperation() {
  if (!trialForm.productName || !trialForm.productName.trim()) {
    return uni.showToast({ title: '请输入操作项目', icon: 'none' })
  }
  if (!trialForm.operationDate) {
    return uni.showToast({ title: '请选择操作时间', icon: 'none' })
  }
  trialSubmitting.value = true
  try {
    await addOperation({
      customerId: customerId.value,
      customerName: customerName.value,
      operationType: '1',
      productName: trialForm.productName.trim(),
      operationQuantity: trialForm.operationQuantity,
      trialPrice: trialForm.trialPrice,
      operationDate: trialForm.operationDate,
      operatorUserId: trialForm.operatorUserId,
      operatorUserName: trialForm.operatorName,
      satisfaction: trialForm.satisfaction,
      customerFeedback: trialForm.customerFeedback,
      beforePhoto: trialForm.beforePhoto.map(p => p.name).join(','),
      afterPhoto: trialForm.afterPhoto.map(p => p.name).join(','),
      remark: trialForm.remark,
      enterpriseId: enterpriseId.value,
      storeId: storeId.value
    })
    uni.showToast({ title: '体验操作提交成功', icon: 'success' })
    closeTrialDrawer()
    setTimeout(() => uni.navigateBack(), 1500)
  } catch (e) {
    console.error('体验操作提交失败:', e)
    uni.showToast({ title: '操作失败', icon: 'none' })
  } finally {
    trialSubmitting.value = false
  }
}

/** 日期选择确认，格式化为YYYY-MM-DD，根据 pickerTarget 更新对应表单（持卡/体验） */
function onDateConfirm(e) {
  const d = new Date(Number(e))
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  const dateStr = `${y}-${m}-${day}`
  if (pickerTarget.value === 'trial') {
    trialForm.operationDate = dateStr
  } else {
    form.operationDate = dateStr
  }
  showDatePicker.value = false
}

/** Tab切换处理，切换到操作记录时加载数据 */
function onTabChange(e) {
  currentTab.value = e.index
  if (e.index === 1) loadOperations()
}

/** 加载客户操作记录列表 */
async function loadOperations() {
  if (!customerId.value) return
  try {
    const response = await listOperation({ customerId: customerId.value, pageNum: 1, pageSize: 50 })
    const data = response.data || response
    operationList.value = data.rows || []
  } catch (e) {
    console.error('加载操作记录失败:', e)
  }
}

/** 操作状态码映射为中文名称 */
function getOperationStatusName(status) {
  const map = { '0': '待操作', '1': '已成交', '2': '已完成' }
  return map[status] || '未知'
}

/** 格式化时间为MM-DD HH:mm简短格式 */
function formatTimeShort(time) { if (!time) return ''; return time.substring(5, 16).replace('-', '-').replace(' ', ' ') }

/** 加载客户已成交的套餐列表，仅展示状态为已成交的套餐 */
async function loadPackages() {
  if (!customerId.value) return
  try {
    const response = await getPackageByCustomer(customerId.value)
    const data = response.data || response
    packageList.value = Array.isArray(data) ? data.filter(p => p.status === '1') : []
  } catch (e) {
    console.error('加载套餐失败:', e)
  }
  loadOwedPackages()
}

async function loadOwedPackages() {
  if (!customerId.value) return
  try {
    const res = await getOwedPackages({ customerId: customerId.value })
    const data = res.data || res
    const list = Array.isArray(data) ? data : (data.rows || [])
    const map = {}
    list.forEach(pkg => { map[pkg.packageId] = pkg })
    owedPackageMap.value = map
  } catch (e) {
    console.error('加载欠款信息失败:', e)
  }
}

function getPaymentMethodName(method) {
  const map = { cash: '现金', card: '耗卡', gift: '赠送' }
  return map[method] || method || ''
}

const pages = getCurrentPages()
const options = pages[pages.length - 1].options || {}
customerId.value = options.customerId || ''
customerName.value = decodeURIComponent(options.customerName || '')
storeId.value = options.storeId || ''
storeName.value = decodeURIComponent(options.storeName || '')
enterpriseId.value = options.enterpriseId || ''
enterpriseName.value = decodeURIComponent(options.enterpriseName || '')
uni.setNavigationBarTitle({ title: '选择操作项目' })

loadPackages()
</script>

<style lang="scss" scoped>
/* ==========================================================
   持卡操作/体验操作/选择品项 - 钉钉/企业微信风
   3 层视觉：抽屉背景 #F5F7FA → section 白卡 16rpx → field 透明
   字号统一：22/26/28/30/36rpx（caption/body/body-lg/title/display）
   圆角统一：12/16/24rpx（小元素/卡片/drawer）
   ========================================================== */

page { background-color: #F5F7FA; }

.op-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  overflow-x: hidden;
  box-sizing: border-box;

  :deep(.u-popup) { flex: none !important; }
}

/* ============ 顶部客户信息条 ============ */
.customer-info {
  padding: 16rpx 24rpx;
  background: #fff;
  border-bottom: 1rpx solid #F2F3F5;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}
.info-row {
  display: flex;
  align-items: center;
  gap: 12rpx;

  &:last-child { margin-bottom: 0; }
}
.customer-name {
  font-size: 32rpx;
  font-weight: 600;
  color: #1D2129;
  letter-spacing: 0.5rpx;
}
.store-name {
  font-size: 24rpx;
  color: #86909C;
}

.tab-content { flex: 1; }
.tab-panel { padding: 12rpx 0 40rpx; }

/* ============ section header（外层选择品项页） ============ */
.section-header {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin: 0 24rpx 16rpx;
  padding: 22rpx 24rpx;
  background: #FFFFFF;
  border-radius: 16rpx;
  box-shadow: 0 2rpx 8rpx rgba(61, 109, 247, 0.06);
}
.section-line {
  width: 6rpx;
  height: 28rpx;
  background: linear-gradient(180deg, #3D6DF7 0%, #5B8FF9 100%);
  border-radius: 4rpx;
}
.section-title {
  font-size: 30rpx;
  font-weight: 600;
  color: #1D2129;
  letter-spacing: 0.5rpx;
}
.section-subtitle {
  font-size: 24rpx;
  color: #86909C;
  font-weight: 400;
}
.trial-entry-btn {
  margin-left: auto;
  height: 56rpx;
  padding: 0 20rpx;
  border-radius: 999rpx;
  font-size: 24rpx;
  font-weight: 500;
  background: linear-gradient(135deg, #E8F0FE 0%, #EEF2FF 100%);
  color: #3D6DF7;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6rpx;
  flex-shrink: 0;
  box-shadow: 0 2rpx 8rpx rgba(61, 109, 247, 0.12);
  transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

  &:active {
    background: linear-gradient(135deg, #D4E2FD 0%, #D6E4FF 100%);
    transform: scale(0.96);
  }
}

/* ============ 套餐列表（外层） ============ */
.op-list-scroll {
  flex: 1;
  padding: 0 24rpx;
  box-sizing: border-box;
  overflow-x: hidden;
}

.pkg-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}
.pkg-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 20rpx;
  border: 1rpx solid #F0F2F5;
  box-sizing: border-box;
  overflow: hidden;
  box-shadow: 0 2rpx 8rpx rgba(61, 109, 247, 0.06);
}
.pkg-card-head {
  display: flex;
  align-items: center;
  gap: 8rpx;
  margin-bottom: 16rpx;
  padding-bottom: 16rpx;
  border-bottom: 1rpx solid #F2F3F5;

  .pkg-name {
    font-size: 30rpx;
    font-weight: 600;
    color: #1D2129;
  }
}
.pkg-tag {
  font-size: 22rpx;
  padding: 4rpx 12rpx;
  border-radius: 6rpx;
  font-weight: 500;
  flex-shrink: 0;

  &.owed { color: #F53F3F; background: #FFF1F0; }
  &.payment { color: #3D6DF7; background: #E8F0FE; }
}
.pkg-amount {
  margin-left: auto;
  font-size: 30rpx;
  color: #1D2129;
  font-weight: 700;
}

/* ============ 品项行（外层） ============ */
.item-row {
  display: flex;
  align-items: center;
  gap: 16rpx;
  padding: 16rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
  margin-bottom: 12rpx;
  transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);
  overflow: hidden;
  border-left: 6rpx solid transparent;

  &:last-child { margin-bottom: 0; }
  &.disabled { opacity: 0.45; pointer-events: none; }
  &:active:not(.disabled) { background: #EEF2FF; }
  &.selected {
    background: linear-gradient(135deg, #E8F0FE 0%, #EEF2FF 100%);
    border-left: 6rpx solid #3D6DF7;
  }
}
.item-check { padding: 4rpx; }
.check-box {
  width: 36rpx;
  height: 36rpx;
  border: 2rpx solid #E5E6EB;
  border-radius: 8rpx;
  transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);
  display: flex;
  align-items: center;
  justify-content: center;

  &::after {
    content: '';
    width: 18rpx;
    height: 18rpx;
    border-radius: 4rpx;
    background: transparent;
    transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);
  }
}
.item-check.checked .check-box {
  border-color: #3D6DF7;
  background: #3D6DF7;

  &::after { background: #fff; }
}
.item-name {
  flex: 1;
  font-size: 28rpx;
  color: #1D2129;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-weight: 500;
}
.item-price {
  font-size: 26rpx;
  color: #3D6DF7;
  min-width: 100rpx;
  text-align: right;
  font-weight: 600;
}
.item-remain {
  font-size: 24rpx;
  color: #00B42A;
  font-weight: 600;
  min-width: 80rpx;
  text-align: right;
}
.pkg-empty {
  font-size: 26rpx;
  color: #C9CDD4;
  text-align: center;
  padding: 20rpx 0;
}

/* ============ 底部操作栏（外层） ============ */
.op-bottom-bar {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  align-items: center;
  padding: 16rpx 24rpx;
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
  background: #FFFFFF;
  border-top: 1rpx solid #F2F3F5;
  box-shadow: 0 -2rpx 12rpx rgba(0, 0, 0, 0.04);
  z-index: 100;
}
.bar-info {
  display: flex;
  align-items: center;
  gap: 16rpx;
  flex: 1;

  .bar-count {
    font-size: 26rpx;
    color: #86909C;

    .count-num {
      display: inline-block;
      margin: 0 4rpx;
      color: #3D6DF7;
      font-weight: 700;
      font-size: 36rpx;
      line-height: 1;
      letter-spacing: -0.5rpx;
    }
  }
  .bar-total {
    font-size: 26rpx;
    color: #FF7D00;
    font-weight: 700;
  }
}
.bar-actions {
  margin-left: auto;
  display: flex;
  align-items: center;
  gap: 12rpx;
  flex-shrink: 0;
}
.bar-btn {
  width: 240rpx;
  height: 72rpx;
  border-radius: 12rpx;
  font-size: 28rpx;
  font-weight: 600;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #E5E6EB;
  color: #FFF;
  transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);
  flex-shrink: 0;
  padding: 0;

  &.active {
    background: $gradient-brand;
    box-shadow: 0 4rpx 12rpx rgba(61, 109, 247, 0.30);

    &:active {
      transform: scale(0.98);
      box-shadow: 0 2rpx 6rpx rgba(61, 109, 247, 0.30);
    }
  }
  &[disabled],
  &.disabled {
    background: #E5E6EB !important;
    color: #FFFFFF !important;
    box-shadow: none !important;
    opacity: 1;
  }
}

/* ==========================================================
   抽屉部分 - 持卡操作 / 体验操作 共用样式
   ========================================================== */
.detail-drawer {
  background: #F5F7FA;
  border-radius: 24rpx 24rpx 0 0;
  height: 88vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  width: 100%;
  max-width: 100vw;
  box-sizing: border-box;
}

/* 抽屉顶部装饰条（区分两种模式） */
.head-bar {
  height: 6rpx;
  background: linear-gradient(90deg, #3D6DF7 0%, #5B8FF9 50%, #86ABFF 100%);
  border-radius: 0 0 4rpx 4rpx;
  flex-shrink: 0;
}

/* 抽屉头部：白底 + 标题装饰条 */
.drawer-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 24rpx 24rpx;
  background: #FFFFFF;
  border-bottom: 1rpx solid #F2F3F5;
  flex-shrink: 0;

  .head-left {
    display: flex;
    align-items: center;
    gap: 12rpx;
    flex: 1;
    min-width: 0;

    .drawer-title {
      font-size: 32rpx;
      font-weight: 700;
      color: #1D2129;
      letter-spacing: 0.5rpx;
    }

    .drawer-subtitle {
      font-size: 22rpx;
      color: #86909C;
      font-weight: 400;
    }
  }

  .head-tag {
    display: flex;
    align-items: center;
    gap: 6rpx;
    background: linear-gradient(135deg, #E8F0FE 0%, #EEF2FF 100%);
    padding: 8rpx 16rpx;
    border-radius: 999rpx;
    flex-shrink: 0;
    transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

    text {
      font-size: 24rpx;
      color: #3D6DF7;
      font-weight: 600;
      max-width: 200rpx;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    &:active { background: linear-gradient(135deg, #D4E2FD 0%, #D6E4FF 100%); }
  }

  .head-tag.trial-head-tag {
    background: linear-gradient(135deg, #FFF7E8 0%, #FFE9C8 100%);

    text { color: #FF7D00; }
  }
}

/* 抽屉滚动区 */
.drawer-scroll {
  overflow-y: auto;
  overflow-x: hidden;
  width: 100%;
  box-sizing: border-box;
  flex: 1;
  padding: 20rpx 0 24rpx;
  min-height: 400rpx;
}

/* ============ section 容器（统一） ============ */
.dd-section {
  margin: 0 24rpx 20rpx;
  background: #FFFFFF;
  border-radius: 16rpx;
  padding: 24rpx;
  box-shadow: 0 2rpx 8rpx rgba(61, 109, 247, 0.06);
}

.section-label {
  display: flex;
  align-items: center;
  gap: 8rpx;
  margin-bottom: 16rpx;
  font-size: 28rpx;
  font-weight: 600;
  color: #1D2129;
  letter-spacing: 0.5rpx;

  text { font-size: 28rpx; font-weight: 600; color: #1D2129; }

  .label-icon {
    color: #3D6DF7;
    font-size: 28rpx;
  }
}

/* 必填标识 */
.section-label.required text:first-child { color: #1D2129; font-weight: 600; }
.required-mark {
  color: #F53F3F;
  font-weight: 700;
  margin-left: 2rpx;
  font-size: 28rpx;
  line-height: 1;
}

/* ============ 已选品项卡片 ============ */
.item-card-list {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}
.item-card {
  background: #FFFFFF;
  border-radius: 12rpx;
  padding: 16rpx;
  border: 1rpx solid #F0F2F5;
  transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

  &:active {
    border-color: #C3D8FF;
  }
}
.ic-main-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 12rpx;

  .ic-pkg-tag {
    font-size: 20rpx;
    color: #3D6DF7;
    background: #E8F0FE;
    padding: 2rpx 10rpx;
    border-radius: 6rpx;
    white-space: nowrap;
    flex-shrink: 0;
    font-weight: 500;
  }

  .ic-product {
    flex: 1;
    font-size: 28rpx;
    font-weight: 600;
    color: #1D2129;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    min-width: 0;
  }

  .ic-remove {
    width: 40rpx;
    height: 40rpx;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #F5F7FA;
    transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);
    flex-shrink: 0;

    &:active {
      background: #FFF1F0;

      :deep(.u-icon) { color: #F53F3F !important; }
    }
  }
}
.ic-price-row {
  display: flex;
  align-items: center;
  background: #F7F8FA;
  border-radius: 10rpx;
  padding: 4rpx;
  gap: 4rpx;

  .col-price,
  .col-qty,
  .col-amount {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    min-width: 0;
  }
}
.col-price {
  font-size: 24rpx;
  color: #86909C;
  font-weight: 500;
  padding: 12rpx 4rpx;
}
.col-qty {
  gap: 0;
  padding: 4rpx;

  .qty-btn {
    width: 48rpx;
    height: 48rpx;
    border-radius: 50%;
    background: #FFFFFF;
    border: 1rpx solid #C3D8FF;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 32rpx;
    color: #3D6DF7;
    line-height: 1;
    font-weight: 600;
    flex-shrink: 0;
    transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

    &:active {
      background: #3D6DF7;
      color: #FFFFFF;
    }
  }
  .qty-val {
    font-size: 28rpx;
    font-weight: 700;
    color: #1D2129;
    min-width: 56rpx;
    text-align: center;
    flex: 1;
  }
}
.col-amount {
  font-size: 28rpx;
  font-weight: 700;
  color: #FF7D00;
  padding: 12rpx 4rpx;
}

/* ============ 合计消耗卡片 ============ */
.total-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: $gradient-brand-soft;
  border-radius: 12rpx;
  padding: 24rpx 24rpx;
  margin-top: 16rpx;
  border: 1rpx solid #D4E2FD;

  .total-left {
    font-size: 26rpx;
    color: #1D2129;
    font-weight: 500;
    letter-spacing: 0.5rpx;
  }
  .total-right {
    font-size: 36rpx;
    font-weight: 800;
    color: #3D6DF7;
    letter-spacing: -0.5rpx;
  }
}

/* ============ 表单 2x2 网格 ============ */
.form-grid {
  display: flex;
  gap: 16rpx;
  width: 100%;
  box-sizing: border-box;
  min-width: 0;
}
.form-cell {
  flex: 1;
  background: #F7F8FA;
  border-radius: 10rpx;
  padding: 12rpx 16rpx;
  min-width: 0;
  box-sizing: border-box;
  border: 1rpx solid transparent;
  transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

  &:active { background: #EEF2FF; }

  .fc-label {
    display: flex;
    align-items: center;
    gap: 6rpx;
    margin-bottom: 8rpx;

    text {
      font-size: 22rpx;
      color: #86909C;
      font-weight: 500;
    }
  }

  .fc-field {
    display: flex;
    align-items: center;
    justify-content: space-between;
    min-height: 44rpx;
    gap: 8rpx;

    text {
      font-size: 28rpx;
      color: #1D2129;
      font-weight: 600;
      flex: 1;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;

      &.placeholder { color: #C9CDD4; font-weight: 400; }
    }
  }
}

/* ============ 满意度评价卡 ============ */
.satisfaction-card {
  display: flex;
  justify-content: space-between;
  align-items: center;

  .sat-label {
    display: inline-flex;
    align-items: center;
    gap: 8rpx;

    text {
      font-size: 28rpx;
      color: #1D2129;
      font-weight: 600;
    }

    :deep(.u-icon) { color: #FFB300; }
  }
}

/* ============ 顶层 fc-label（图标题同行） ============ */
.fc-label {
  display: flex;
  align-items: center;
  gap: 8rpx;
  margin-bottom: 12rpx;
  font-size: 26rpx;
  font-weight: 600;
  color: #1D2129;
  letter-spacing: 0.5rpx;

  text {
    font-size: 26rpx;
    font-weight: 600;
    color: #1D2129;
  }

  :deep(.u-icon) {
    color: #3D6DF7;
  }
}

/* ============ textarea 容器 ============ */
.fc-textarea-wrap {
  position: relative;
  background: #F7F8FA;
  border-radius: 12rpx;
  border: 1rpx solid transparent;
  transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

  &:focus-within {
    background: #FFFFFF;
    border-color: #3D6DF7;
    box-shadow: 0 0 0 4rpx rgba(61, 109, 247, 0.08);

    .fc-textarea-counter {
      background: linear-gradient(180deg, transparent 0%, #FFFFFF 30%);
    }
  }
}
.fc-textarea {
  width: 100%;
  min-height: 80rpx;
  max-height: 200rpx;
  padding: 12rpx;
  padding-right: 80rpx;
  font-size: 26rpx;
  color: #1D2129;
  box-sizing: border-box;
  line-height: 1.5;
}
.fc-textarea-counter {
  position: absolute;
  right: 12rpx;
  bottom: 8rpx;
  font-size: 20rpx;
  color: #C9CDD4;
  font-weight: 400;
  pointer-events: none;
  background: linear-gradient(180deg, transparent 0%, #F7F8FA 30%);
  padding: 4rpx 6rpx 0 8rpx;
}

/* ============ 照片上传区 ============ */
.photo-grid {
  display: flex;
  gap: 16rpx;
}
.photo-cell {
  flex: 1;
  background: #F7F8FA;
  border-radius: 12rpx;
  padding: 16rpx;
  border: 1rpx solid transparent;
  transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

  .pc-label {
    display: flex;
    align-items: center;
    gap: 8rpx;
    margin-bottom: 12rpx;

    text {
      font-size: 26rpx;
      color: #1D2129;
      font-weight: 600;
    }

    :deep(.u-icon) { color: #3D6DF7; }
  }

  .pc-upload {
    display: flex;
    justify-content: flex-start;

    :deep(.u-upload) { background: transparent !important; }
    :deep(.u-upload__button) {
      width: 180rpx !important;
      height: 180rpx !important;
      border-radius: 12rpx !important;
      border: 2rpx dashed #C3D8FF !important;
      background: #F5F8FF !important;
      transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);
    }
    :deep(.u-upload__button:hover),
    :deep(.u-upload__button:active) {
      border-color: #3D6DF7 !important;
      background: #EEF2FF !important;
    }
    :deep(.u-icon) { color: #3D6DF7 !important; font-size: 48rpx !important; }
  }

  .pc-hint {
    margin-top: 8rpx;
    font-size: 22rpx;
    color: #86909C;
    text-align: center;
  }
}

/* ============ 抽屉底部 ============ */
.drawer-foot {
  padding: 16rpx 24rpx;
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
  background: #FFFFFF;
  border-top: 1rpx solid #F2F3F5;
  flex-shrink: 0;
}
.submit-btn {
  width: 100%;
  height: 88rpx;
  border-radius: 16rpx;
  font-size: 30rpx;
  font-weight: 700;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  background: $gradient-brand;
  color: #fff;
  letter-spacing: 1rpx;
  box-shadow: 0 8rpx 24rpx rgba(61, 109, 247, 0.30);
  transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

  &:active:not([disabled]) {
    transform: scale(0.98);
    box-shadow: 0 4rpx 12rpx rgba(61, 109, 247, 0.30);
  }

  &[disabled],
  &.disabled {
    background: #E5E6EB !important;
    color: #FFFFFF !important;
    box-shadow: none !important;
    opacity: 1;
  }
}
.submit-btn.trial-submit-btn {
  background: $gradient-warning !important;
  box-shadow: 0 8rpx 24rpx rgba(255, 125, 0, 0.30) !important;

  &[disabled],
  &.disabled {
    background: #E5E6EB !important;
    color: #FFFFFF !important;
    box-shadow: none !important;
    opacity: 1;
  }
}

/* ============ 体验操作数字输入（u-number-box 覆盖） ============ */
.trial-num-field {
  background: #FFFFFF;
  border: 1rpx solid transparent;
  padding: 0 !important;
  transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

  &:focus-within {
    background: #FFFFFF;
    border-color: #3D6DF7;
  }

  :deep(.u-number-box) {
    background: transparent !important;
    display: flex !important;
    flex: 1 !important;
    width: 100% !important;
    align-items: stretch;
    height: 48rpx;
  }
  :deep(.u-number-box__plus),
  :deep(.u-number-box__minus) {
    background: #E8F0FE !important;
    color: #3D6DF7 !important;
    border: none !important;
    flex-shrink: 0;
    min-width: 48rpx !important;
    width: 48rpx !important;
    height: 48rpx !important;
    border-radius: 12rpx !important;
    font-size: 32rpx !important;
    font-weight: 600 !important;

    &:active {
      background: #3D6DF7 !important;
      color: #FFFFFF !important;
    }
  }
  :deep(.u-number-box__input) {
    color: #1D2129 !important;
    flex: 1 !important;
    width: 100% !important;
    min-width: 0 !important;
    background: transparent !important;
    border: none !important;
    font-size: 28rpx !important;
    font-weight: 600 !important;
    text-align: center;
  }
}

/* ============ 体验操作-项目名称输入卡 ============ */
.trial-input-card {
  background: #F7F8FA;
  border-radius: 12rpx;
  border: 1rpx solid transparent;
  transition: all 150ms cubic-bezier(0.16, 1, 0.3, 1);

  &:focus-within {
    background: #FFFFFF;
    border-color: #3D6DF7;
    box-shadow: 0 0 0 4rpx rgba(61, 109, 247, 0.08);
  }
}
.trial-text-input {
  width: 100%;
  height: 56rpx;
  font-size: 28rpx;
  color: #1D2129;
  font-weight: 500;
  padding: 0 16rpx;
  box-sizing: border-box;
  background: transparent;
  border: none;
}
.trial-placeholder {
  color: #C9CDD4;
  font-size: 26rpx;
  font-weight: 400;
}

/* ==========================================================
   操作记录 Tab 样式
   ========================================================== */
.record-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
  padding: 0 24rpx;
}

.record-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 20rpx;
  border: 1rpx solid #F0F2F5;
  box-shadow: 0 2rpx 8rpx rgba(61, 109, 247, 0.06);
}

.rc-head-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 12rpx;
}
.rc-product-head {
  flex: 1;
  font-size: 28rpx;
  font-weight: 600;
  color: #1D2129;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  min-width: 0;
}
.rc-type-tag {
  font-size: 22rpx;
  padding: 4rpx 12rpx;
  border-radius: 6rpx;
  font-weight: 500;
  flex-shrink: 0;

  &.type-0 { color: #FF7D00; background: #FFF7E8; }
  &.type-1 { color: #3D6DF7; background: #E8F0FE; }
  &.type-2 { color: #00B42A; background: #E8FFEA; }
}
.rc-pkg-name {
  font-size: 24rpx;
  color: #86909C;
  flex-shrink: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 200rpx;
}

.rc-price-row {
  display: flex;
  align-items: baseline;
  gap: 8rpx;
  margin-bottom: 16rpx;
  padding: 16rpx 20rpx;
  background: #F7F8FA;
  border-radius: 12rpx;
}
.rc-unit-price {
  font-size: 24rpx;
  color: #86909C;
}
.rc-price-sep,
.rc-price-eq {
  font-size: 24rpx;
  color: #C9CDD4;
}
.rc-qty-num {
  font-size: 26rpx;
  font-weight: 600;
  color: #4E5969;
}
.rc-total-price {
  font-size: 30rpx;
  font-weight: 700;
  color: #FF7D00;
  margin-left: auto;
}

.rc-meta-row {
  display: flex;
  align-items: center;
  gap: 16rpx;
  padding-top: 16rpx;
  border-top: 1rpx solid #F2F3F5;
}
.rc-operator {
  display: flex;
  align-items: center;
  gap: 6rpx;
  font-size: 22rpx;
  color: #86909C;
  flex-shrink: 0;
}
.rc-satisfaction { flex-shrink: 0; }
.rc-date {
  font-size: 22rpx;
  color: #C9CDD4;
  margin-left: auto;
}

.rc-remark {
  display: flex;
  align-items: flex-start;
  gap: 8rpx;
  margin-top: 12rpx;
  padding-top: 12rpx;
  border-top: 1rpx dashed #EDEEF2;
  font-size: 24rpx;
  color: #86909C;
  line-height: 1.5;
}
</style>
