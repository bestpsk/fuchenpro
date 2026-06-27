<template>
  <view class="order-container">
    <view class="customer-info" v-if="customerInfo">
      <view class="info-row">
        <u-icon name="account-fill" size="18" color="#3D6DF7"></u-icon>
        <text class="customer-name">{{ customerInfo.customerName }}</text>
        <text class="customer-phone" @click="callPhone(customerInfo.phone)">{{ customerInfo.phone }}</text>
      </view>
      <view class="info-row">
        <u-icon name="map" size="14" color="#86909C"></u-icon>
        <text class="store-name">{{ enterpriseName }} · {{ storeName }}</text>
      </view>
    </view>

    <u-tabs :list="tabList" :current="currentTab" @click="onTabChange" :activeStyle="{ color: '#3D6DF7', fontWeight: 'bold' }" :lineColor="'#3D6DF7'" :scrollable="false"></u-tabs>

    <view class="tab-content">
      <view v-if="currentTab === 0" class="tab-panel">
        <view class="package-name-section">
          <view class="section-title-row">
            <u-icon name="gift-fill" size="16" color="#3D6DF7"></u-icon>
            <text class="section-label">套餐名称</text>
          </view>
          <input class="package-name-input" type="text" v-model="orderPackageName" placeholder="请输入套餐名称" />
        </view>

        <view class="items-section">
          <view class="section-header">
            <view class="section-title-row">
              <u-icon name="list" size="16" color="#3D6DF7"></u-icon>
              <text class="section-label">品项列表</text>
            </view>
            <view class="add-item-btn" @click="addOrderItemRow">
              <u-icon name="plus-circle-fill" size="15" color="#3D6DF7"></u-icon>
              <text class="add-item-text">添加品项</text>
            </view>
          </view>

          <view v-for="(item, index) in orderItems" :key="index" class="item-card">
            <view class="item-card-header">
              <view class="item-index-wrap">
                <u-icon name="edit-pen" size="13" color="#3D6DF7"></u-icon>
                <text class="item-index">品项 {{ index + 1 }}</text>
              </view>
              <view class="item-delete" @click="removeOrderItem(index)" v-if="orderItems.length > 1">
                <u-icon name="trash" size="14" color="#F56C6C"></u-icon>
                <text class="delete-text">删除</text>
              </view>
            </view>
            <view class="item-form">
              <view class="form-row">
                <text class="form-label">名称</text>
                <input class="form-input" type="text" v-model="item.productName" placeholder="搜索卡项" @focus="openCardItemSearch(index)" readonly />
                <u-icon name="search" size="16" color="#86909C" @click="openCardItemSearch(index)"></u-icon>
              </view>
              <view class="form-row">
                <text class="form-label">付款方式</text>
                <view class="item-payment-methods">
                  <view v-for="method in orderPaymentMethods" :key="method.value"
                    class="method-tag" :class="{ active: item.paymentMethod === method.value }"
                    @click="selectItemPaymentMethod(index, method.value)">
                    <text>{{ method.label }}</text>
                  </view>
                </view>
              </view>
              <view class="form-row">
                <text class="form-label">次数</text>
                <input class="form-input" type="number" v-model="item.quantity" placeholder="1" @input="calcItemAuto(index)" :disabled="!packageQuantityEditable" />
              </view>
              <view class="form-row">
                <text class="form-label">成交金额</text>
                <input class="form-input" type="digit" v-model="item.dealAmount" placeholder="0.00" @input="calcItemAuto(index)" :disabled="!packageDealAmountEditable || item.paymentMethod === 'gift'" />
              </view>
              <view class="form-row readonly">
                <text class="form-label">单次价</text>
                <text class="form-value auto-hint">¥{{ calcUnitPrice(item) }}</text>
              </view>
              <view class="form-row">
                <text class="form-label">实付金额</text>
                <input class="form-input" type="digit" v-model="item.paidAmount" placeholder="0.00" @input="calcItemAuto(index)" :disabled="!packagePaidAmountEditable || item.paymentMethod === 'gift'" />
              </view>
              <view class="form-row readonly">
                <text class="form-label">欠款金额</text>
                <text class="form-value owed">¥{{ calcOwedAmount(item) }}</text>
              </view>
            </view>
          </view>
        </view>

        <view class="summary-section">
          <view class="summary-title-row">
            <u-icon name="red-packet-fill" size="16" color="#FF6B35"></u-icon>
            <text class="summary-title">费用合计</text>
          </view>
          <view class="summary-body">
            <view class="summary-item">
              <text class="summary-label">成交</text>
              <text class="summary-value">¥{{ totalDealAmount.toFixed(2) }}</text>
            </view>
            <view class="summary-divider"></view>
            <view class="summary-item">
              <text class="summary-label">实付</text>
              <text class="summary-value paid">¥{{ totalPaidAmount.toFixed(2) }}</text>
            </view>
            <view class="summary-divider" v-if="totalOwedAmount > 0"></view>
            <view class="summary-item" v-if="totalOwedAmount > 0">
              <text class="summary-label">欠款</text>
              <text class="summary-value owed">¥{{ totalOwedAmount.toFixed(2) }}</text>
            </view>
          </view>
        </view>

        <view class="dealer-section">
          <view class="section-title-row">
            <u-icon name="account" size="16" color="#3D6DF7"></u-icon>
            <text class="section-label">门店管理</text>
          </view>
          <input class="dealer-input" type="text" v-model="orderStoreDealer" placeholder="请输入门店管理（选填）" />
        </view>

        <view class="remark-section">
          <view class="section-title-row">
            <u-icon name="chat" size="16" color="#86909C"></u-icon>
            <text class="section-label">备注</text>
          </view>
          <u-textarea v-model="orderRemark" placeholder="请输入备注（选填）" count :maxlength="500" height="80" :customStyle="{ background: '#F7F8FA', borderRadius: '8rpx', fontSize: '26rpx' }"></u-textarea>
        </view>

        <view class="submit-bar">
          <u-button v-if="checkPermi('business:order:add')" type="primary" text="提交订单" :loading="submitting" @click="submitOrder" :customStyle="{ borderRadius: '12rpx', height: '84rpx' }"></u-button>
        </view>
      </view>

      <view v-if="currentTab === 1" class="tab-panel">
        <view v-if="orderList.length > 0" class="record-list">
          <view v-for="item in orderList" :key="item.orderId" class="record-card">
            <view class="rc-header">
              <view class="rc-header-left">
                <u-icon name="file-text" size="28" color="#3D6DF7"></u-icon>
                <text class="rc-no">{{ item.orderNo || ('ORD' + item.orderId) }}</text>
              </view>
              <text class="rc-status" :class="'st-' + item.orderStatus">{{ getOrderStatusName(item.orderStatus) }}</text>
            </view>

            <view class="rc-items" v-if="item.items && item.items.length">
              <view v-for="(it, idx) in item.items" :key="idx" class="rc-item-row">
                <u-icon name="checkbox-mark" size="24" color="#3D6DF7"></u-icon>
                <text class="rc-item-name">{{ it.productName || '未命名品项' }}</text>
                <text class="rc-item-qty">×{{ it.quantity || 1 }}</text>
                <text class="rc-item-price">¥{{ Number(it.dealAmount || 0).toFixed(2) }}</text>
              </view>
            </view>

            <view class="rc-divider" v-if="item.items && item.items.length"></view>

            <view class="rc-amounts">
              <view class="rc-amount-group">
                <text class="rc-amt-label">成交</text>
                <text class="rc-amt-deal">¥{{ Number(item.dealAmount || 0).toFixed(2) }}</text>
              </view>
              <view class="rc-amount-group">
                <text class="rc-amt-label">实付</text>
                <text class="rc-amt-paid">¥{{ Number(item.paidAmount || 0).toFixed(2) }}</text>
              </view>
              <view class="rc-amount-group" v-if="Number(item.owedAmount || 0) > 0">
                <text class="rc-amt-label">欠款</text>
                <text class="rc-amt-owed">¥{{ Number(item.owedAmount || 0).toFixed(2) }}</text>
              </view>
              <view class="rc-amount-group" v-if="item.paymentMethod">
                <text class="rc-amt-label">付款</text>
                <text class="rc-amt-method">{{ getPaymentMethodName(item.paymentMethod) }}</text>
              </view>
            </view>

            <view class="rc-footer">
              <view class="rc-meta-row" v-if="item.storeDealer || item.creatorUserName">
                <view class="rc-meta-item">
                  <u-icon name="account" size="18" color="#86909C"></u-icon>
                  <text class="rc-meta-val">{{ item.storeDealer || '-' }}</text>
                </view>
                <text class="rc-meta-sep">|</text>
                <view class="rc-meta-item">
                  <u-icon name="man-add" size="18" color="#86909C"></u-icon>
                  <text class="rc-meta-val">{{ item.creatorUserName || '-' }}</text>
                </view>
              </view>
              <text class="rc-time">{{ formatTimeShort(item.createTime) }}</text>
            </view>

            <view class="rc-remark" v-if="item.remark">
              <u-icon name="edit-pen" size="18" color="#C9CDD4"></u-icon>
              <text class="rc-remark-text">{{ item.remark }}</text>
            </view>
          </view>
        </view>
        <u-empty v-else mode="data" text="暂无开单记录" :marginTop="40"></u-empty>
      </view>

      <view v-if="currentTab === 2" class="tab-panel">
        <view v-if="owedPackageList.length > 0" class="record-list">
          <view v-for="pkg in owedPackageList" :key="pkg.packageId" class="record-card rc-owed-card">
            <view class="rc-header">
              <view class="rc-header-left">
                <u-icon name="file-text" size="28" color="#F53F3F"></u-icon>
                <text class="rc-no">{{ pkg.packageName || pkg.packageNo }}</text>
              </view>
              <view class="rc-owed-badge">欠¥{{ Number(pkg.owedAmount || 0).toFixed(2) }}</view>
            </view>

            <view class="rc-items rc-owed-info">
              <view class="rc-item-row" style="padding: 8rpx 16rpx;">
                <u-icon name="rmb-circle" size="22" color="#86909C"></u-icon>
                <text class="rc-item-name">成交 ¥{{ Number(pkg.totalAmount || 0).toFixed(2) }}</text>
              </view>
              <view class="rc-item-row" style="padding: 8rpx 16rpx;">
                <u-icon name="checkmark-circle" size="22" color="#00B42A"></u-icon>
                <text class="rc-item-name">已付 ¥{{ Number(pkg.paidAmount || 0).toFixed(2) }}</text>
              </view>
            </view>

            <view class="rc-divider"></view>

            <view class="rc-action-row">
              <view class="rc-repay-btn" @click="openRepayPopup(pkg)">
                <u-icon name="red-packet" size="24" color="#fff"></u-icon>
                <text class="rc-repay-text">还款</text>
              </view>
            </view>

            <view class="rc-footer">
              <u-icon name="clock" size="18" color="#C9CDD4"></u-icon>
              <text class="rc-time">{{ formatTimeShort(pkg.createTime) }}</text>
            </view>
          </view>
        </view>
        <u-empty v-else mode="data" text="暂无欠款记录" :marginTop="40"></u-empty>

        <view v-if="repaymentList.length > 0" class="repay-section">
          <view class="repay-section-title">
            <u-icon name="list" size="16" color="#3D6DF7"></u-icon>
            <text class="section-label">还款记录</text>
          </view>
          <view class="record-list">
            <view v-for="item in repaymentList" :key="item.repaymentId" class="record-card rc-repay-card" @click="openRepayDetailPopup(item)">
              <view class="rc-header">
                <view class="rc-header-left">
                  <u-icon name="red-packet-fill" size="28" color="#3D6DF7"></u-icon>
                  <text class="rc-no">¥{{ Number(item.repaymentAmount || 0).toFixed(2) }}</text>
                </view>
                <text class="rc-audit-tag" :class="getRepaymentStatusClass(item.status)">{{ getRepaymentStatusName(item.status) }}</text>
              </view>

              <view class="rc-repay-info">
                <view class="rc-repay-row">
                  <text class="rc-repay-label">套餐</text>
                  <text class="rc-repay-value">{{ item.packageName || '-' }}</text>
                </view>
                <view class="rc-repay-row">
                  <text class="rc-repay-label">方式</text>
                  <text class="rc-repay-value">{{ getPaymentMethodName(item.paymentMethod) }}</text>
                </view>
              </view>

              <view class="rc-divider"></view>

              <view class="rc-repay-footer">
                <text class="rc-time">{{ formatTimeShort(item.createTime) }}</text>
                <view class="rc-repay-actions" v-if="item.status === '0' && checkPermi('business:repayment:audit')">
                  <view class="rc-action-btn rc-btn-pass" @click.stop="handleAuditPass(item.repaymentId)">
                    <u-icon name="checkmark" size="14" color="#fff"></u-icon>
                    <text>通过</text>
                  </view>
                  <view class="rc-action-btn rc-btn-reject" @click.stop="openRejectPopup(item.repaymentId)">
                    <u-icon name="close" size="14" color="#fff"></u-icon>
                    <text>驳回</text>
                  </view>
                  <view class="rc-action-btn rc-btn-cancel" @click.stop="handleCancelRepayment(item.repaymentId)">
                    <u-icon name="trash" size="14" color="#86909C"></u-icon>
                    <text>取消</text>
                  </view>
                </view>
              </view>
            </view>
          </view>
        </view>
      </view>
    </view>

    <u-popup :show="showCardItemSearch" mode="bottom" round="16" @close="closeCardItemSearch">
      <view class="card-item-search-popup">
        <view class="popup-header">
          <text class="popup-title">选择卡项</text>
          <view class="popup-close" @click="closeCardItemSearch">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <view class="popup-body">
          <view class="search-bar">
            <u-search v-model="cardItemKeyword" placeholder="搜索卡项名称" :showAction="false" @search="doSearchCardItem" @change="onCardItemKeywordChange"></u-search>
          </view>
          <view class="card-item-list">
            <view v-for="item in cardItemSearchResults" :key="item.cardItemId" class="card-item-option" @click="selectCardItem(item)">
              <view class="card-item-info">
                <text class="card-item-name">{{ item.cardItemName }}</text>
                <text class="card-item-meta">{{ item.defaultQuantity || 1 }}次 · ¥{{ item.suggestedPrice || 0 }}</text>
              </view>
              <u-icon name="plus-circle" size="22" color="#3D6DF7"></u-icon>
            </view>
            <u-empty v-if="cardItemSearchResults.length === 0 && cardItemKeyword" mode="search" text="未找到卡项" :marginTop="20"></u-empty>
          </view>
        </view>
      </view>
    </u-popup>

    <u-popup :show="showRepayPopup" mode="bottom" round="16" @close="closeRepayPopup">
      <view class="repay-popup">
        <view class="popup-header">
          <text class="popup-title">还款</text>
          <view class="popup-close" @click="closeRepayPopup">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <view class="popup-body">
          <view class="repay-info-row">
            <text class="repay-label">套餐名称</text>
            <text class="repay-value">{{ selectedPackage?.packageName || '-' }}</text>
          </view>
          <view class="repay-info-row">
            <text class="repay-label">欠款金额</text>
            <text class="repay-value owed">¥{{ Number(selectedPackage?.owedAmount || 0).toFixed(2) }}</text>
          </view>
          <view class="repay-info-row">
            <text class="repay-label">还款金额</text>
            <view class="repay-input-wrap">
              <text class="currency">¥</text>
              <input class="repay-input" type="digit" v-model="repayAmount" placeholder="请输入还款金额" />
            </view>
          </view>
          <view class="repay-info-row">
            <text class="repay-label">支付方式</text>
            <view class="payment-methods">
              <view v-for="method in paymentMethods" :key="method.value" class="method-tag" :class="{ active: selectedPaymentMethod === method.value }" @click="selectedPaymentMethod = method.value">
                <text>{{ method.label }}</text>
              </view>
            </view>
          </view>
          <view class="repay-info-row">
            <text class="repay-label">备注</text>
            <u-textarea v-model="repayRemark" placeholder="请输入备注" :maxlength="200" height="60"></u-textarea>
          </view>
        </view>
        <view class="popup-actions">
          <u-button v-if="checkPermi('business:repayment:add')" type="primary" text="确认还款" :loading="repaySubmitting" @click="submitRepay"></u-button>
        </view>
      </view>
    </u-popup>

    <u-popup :show="showRepayDetailPopup" mode="bottom" round="16" @close="closeRepayDetailPopup">
      <view class="repay-popup">
        <view class="popup-header">
          <text class="popup-title">还款详情</text>
          <view class="popup-close" @click="closeRepayDetailPopup">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <view class="popup-body">
          <view class="repay-info-row">
            <text class="repay-label">还款金额</text>
            <text class="repay-value" style="color: #3D6DF7; font-weight: 700;">¥{{ Number(repayDetail?.repaymentAmount || 0).toFixed(2) }}</text>
          </view>
          <view class="repay-info-row">
            <text class="repay-label">支付方式</text>
            <text class="repay-value">{{ getPaymentMethodName(repayDetail?.paymentMethod) }}</text>
          </view>
          <view class="repay-info-row">
            <text class="repay-label">审核状态</text>
            <text class="rc-audit-tag" :class="getRepaymentStatusClass(repayDetail?.status)">{{ getRepaymentStatusName(repayDetail?.status) }}</text>
          </view>
          <view class="repay-info-row">
            <text class="repay-label">套餐名称</text>
            <text class="repay-value">{{ repayDetail?.packageName || '-' }}</text>
          </view>
          <view class="repay-info-row">
            <text class="repay-label">创建时间</text>
            <text class="repay-value">{{ formatTime(repayDetail?.createTime) }}</text>
          </view>
          <view class="repay-info-row" v-if="repayDetail?.auditUserName">
            <text class="repay-label">审核人</text>
            <text class="repay-value">{{ repayDetail.auditUserName }}</text>
          </view>
          <view class="repay-info-row" v-if="repayDetail?.auditTime">
            <text class="repay-label">审核时间</text>
            <text class="repay-value">{{ formatTime(repayDetail.auditTime) }}</text>
          </view>
          <view class="repay-info-row" v-if="repayDetail?.auditRemark">
            <text class="repay-label">审核备注</text>
            <text class="repay-value" style="color: #F53F3F;">{{ repayDetail.auditRemark }}</text>
          </view>
          <view class="repay-info-row" v-if="repayDetail?.remark">
            <text class="repay-label">备注</text>
            <text class="repay-value">{{ repayDetail.remark }}</text>
          </view>
        </view>
        <view class="popup-actions" v-if="repayDetail?.status === '0' && checkPermi('business:repayment:audit')">
          <view class="detail-action-row">
            <u-button type="success" text="通过" @click="handleAuditPass(repayDetail.repaymentId); closeRepayDetailPopup()"></u-button>
            <u-button type="error" text="驳回" @click="closeRepayDetailPopup(); openRejectPopup(repayDetail.repaymentId)"></u-button>
            <u-button type="info" text="取消" plain @click="handleCancelRepayment(repayDetail.repaymentId); closeRepayDetailPopup()"></u-button>
          </view>
        </view>
      </view>
    </u-popup>

    <u-popup :show="showRejectPopup" mode="center" round="16" @close="showRejectPopup = false">
      <view class="reject-popup">
        <view class="popup-header">
          <text class="popup-title">驳回原因</text>
          <view class="popup-close" @click="showRejectPopup = false">
            <u-icon name="close" size="20" color="#86909C"></u-icon>
          </view>
        </view>
        <view class="popup-body">
          <u-textarea v-model="rejectReason" placeholder="请输入驳回原因" :maxlength="200" height="80"></u-textarea>
        </view>
        <view class="popup-actions">
          <u-button type="error" text="确认驳回" @click="handleAuditReject"></u-button>
        </view>
      </view>
    </u-popup>
  </view>
</template>

<script setup>
/**
 * @description 销售订单页 - 开单/开单记录/还款
 * @description 支持为客户创建销售订单（含品项、金额计算）、查看历史订单、
 * 欠款套餐还款（支持多种支付方式），自动计算单次价和欠款金额
 */
import { ref, computed, onMounted } from 'vue'
import { getCustomer } from '@/api/business/customer'
import { addSalesOrder, listSalesOrder } from '@/api/business/salesOrder'
import { getOwedPackages, addRepayment, listRepayment, auditRepayment, cancelRepayment } from '@/api/business/repayment'
import { searchCardItem, listCardItem } from '@/api/business/cardItem'
import { getConfigKey } from '@/api/system/config'
import { checkPermi } from '@/utils/permission'

const currentTab = ref(0)
/** Tab列表，有欠款时动态添加"还欠款"标签 */
const tabList = computed(() => {
  const tabs = [{ name: '开单' }, { name: '开单记录' }]
  if (owedPackageList.value.length > 0) tabs.push({ name: '还欠款' })
  return tabs
})
const customerInfo = ref(null)
const orderList = ref([])
// const operationList = ref([])
const owedPackageList = ref([])
const submitting = ref(false)
const customerId = ref('')
const storeId = ref('')
const storeName = ref('')
const enterpriseName = ref('')

const orderPackageName = ref('')
const orderItems = ref([
  { cardItemId: null, productName: '', quantity: 1, dealAmount: 0, paidAmount: 0, paymentMethod: 'cash' }
])
const orderRemark = ref('')
const orderStoreDealer = ref('')

const packageQuantityEditable = ref(true)
const packageDealAmountEditable = ref(true)
const packagePaidAmountEditable = ref(true)

const showCardItemSearch = ref(false)
const cardItemSearchIndex = ref(-1)
const cardItemKeyword = ref('')
const cardItemSearchResults = ref([])
let cardItemSearchTimer = null

// ==================== 卡项使用频次（localStorage） ====================
const CARD_ITEM_FREQ_KEY = 'cardItemFrequency'

function getCardItemFrequency() {
  try {
    return JSON.parse(uni.getStorageSync(CARD_ITEM_FREQ_KEY) || '{}')
  } catch { return {} }
}

function updateCardItemFrequency(cardItemId, cardItemName) {
  const freq = getCardItemFrequency()
  if (!freq[cardItemId]) {
    freq[cardItemId] = { cardItemId, cardItemName, count: 0 }
  }
  freq[cardItemId].count += 1
  freq[cardItemId].cardItemName = cardItemName
  uni.setStorageSync(CARD_ITEM_FREQ_KEY, JSON.stringify(freq))
}

function getFrequentCardItems(limit = 20) {
  const freq = getCardItemFrequency()
  return Object.values(freq).sort((a, b) => b.count - a.count).slice(0, limit)
}

/** 所有品项成交金额合计 */
const totalDealAmount = computed(() => orderItems.value.reduce((sum, item) => sum + (parseFloat(item.dealAmount) || 0), 0))
/** 所有品项实付金额合计 */
const totalPaidAmount = computed(() => orderItems.value.reduce((sum, item) => sum + (parseFloat(item.paidAmount) || 0), 0))
/** 所有品项欠款金额合计（成交-实付） */
const totalOwedAmount = computed(() => totalDealAmount.value - totalPaidAmount.value)

/** 计算品项单次价：成交金额÷次数 */
function calcUnitPrice(item) {
  const qty = parseInt(item.quantity) || 0
  const deal = parseFloat(item.dealAmount) || 0
  if (qty <= 0) return '0.00'
  return (deal / qty).toFixed(2)
}

/** 计算品项欠款金额：成交金额-实付金额，最小为0 */
function calcOwedAmount(item) {
  const deal = parseFloat(item.dealAmount) || 0
  const paid = parseFloat(item.paidAmount) || 0
  return Math.max(0, deal - paid).toFixed(2)
}

/** 触发品项金额响应式更新（computed自动重算） */
function calcItemAuto(index) {
}

/** 添加一个空白品项行 */
function addOrderItemRow() {
  orderItems.value.push({ cardItemId: null, productName: '', quantity: 1, dealAmount: 0, paidAmount: 0, paymentMethod: 'cash' })
}

async function openCardItemSearch(index) {
  cardItemSearchIndex.value = index
  cardItemKeyword.value = ''
  showCardItemSearch.value = true
  // 默认加载常用卡项
  await loadDefaultCardItems()
}

function closeCardItemSearch() {
  showCardItemSearch.value = false
  cardItemSearchIndex.value = -1
}

function onCardItemKeywordChange(val) {
  if (cardItemSearchTimer) clearTimeout(cardItemSearchTimer)
  cardItemSearchTimer = setTimeout(() => { doSearchCardItem() }, 500)
}

async function loadDefaultCardItems() {
  try {
    const res = await listCardItem({ pageNum: 1, pageSize: 20 })
    const data = res.data || res
    const items = data.rows || data || []
    const freqMap = getCardItemFrequency()
    cardItemSearchResults.value = items.sort((a, b) => {
      const freqA = freqMap[a.cardItemId]?.count || 0
      const freqB = freqMap[b.cardItemId]?.count || 0
      if (freqA > 0 && freqB > 0) return freqB - freqA
      if (freqA > 0) return -1
      if (freqB > 0) return 1
      return 0
    })
  } catch (e) { console.error('加载卡项列表失败:', e) }
}

async function doSearchCardItem() {
  if (!cardItemKeyword.value) {
    await loadDefaultCardItems()
    return
  }
  try {
    const res = await searchCardItem(cardItemKeyword.value)
    cardItemSearchResults.value = res.data || []
  } catch (e) { console.error('搜索卡项失败:', e) }
}

function selectCardItem(cardItem) {
  const index = cardItemSearchIndex.value
  if (index >= 0 && index < orderItems.value.length) {
    orderItems.value[index].cardItemId = cardItem.cardItemId
    orderItems.value[index].productName = cardItem.cardItemName
    orderItems.value[index].quantity = cardItem.defaultQuantity || 1
    orderItems.value[index].dealAmount = cardItem.suggestedPrice || 0
    orderItems.value[index].paidAmount = orderItems.value[index].dealAmount
  }
  // 记录使用频次
  updateCardItemFrequency(cardItem.cardItemId, cardItem.cardItemName)
  closeCardItemSearch()
}

/** 删除指定品项行 */
function removeOrderItem(index) {
  orderItems.value.splice(index, 1)
}

/** 支付方式选项 */
const paymentMethods = ref([
  { label: '现金', value: 'cash' },
  { label: '微信', value: 'wechat' },
  { label: '支付宝', value: 'alipay' },
  { label: '银行卡', value: 'bank' }
])
const selectedPaymentMethod = ref('cash')

const orderPaymentMethods = ref([
  { label: '现金', value: 'cash' },
  { label: '耗卡', value: 'card' },
  { label: '赠送', value: 'gift' }
])

function selectItemPaymentMethod(index, value) {
  orderItems.value[index].paymentMethod = value
  if (value === 'gift') {
    orderItems.value[index].dealAmount = 0
    orderItems.value[index].paidAmount = 0
  }
}

const showRepayPopup = ref(false)
const selectedPackage = ref(null)
const repayAmount = ref('')
const repayRemark = ref('')
const repaySubmitting = ref(false)

const repaymentList = ref([])
const showRepayDetailPopup = ref(false)
const repayDetail = ref(null)
const showRejectPopup = ref(false)
const rejectRepaymentId = ref(null)
const rejectReason = ref('')

/** Tab切换处理，切换到记录或还款时加载对应数据 */
function onTabChange(e) {
  currentTab.value = e.index
  if (e.index === 1) loadOrders()
  if (e.index === 2) { loadOwedPackages(); loadRepaymentList() }
}

/** 加载客户信息，成功后自动加载欠款列表 */
async function loadCustomer() {
  if (!customerId.value) return
  try {
    const response = await getCustomer(customerId.value)
    customerInfo.value = response.data || response
    loadOwedPackages()
  } catch (e) { console.error('加载客户失败:', e) }
}

/** 加载客户历史订单列表 */
async function loadOrders() {
  if (!customerId.value) return
  try {
    const response = await listSalesOrder({ customerId: customerId.value, pageNum: 1, pageSize: 50 })
    const data = response.data || response
    orderList.value = data.rows || []
  } catch (e) { console.error('加载订单失败:', e) }
}

// async function loadOperations() {
//   if (!customerId.value) return
//   try {
//     const response = await listOperation({ customerId: customerId.value, pageNum: 1, pageSize: 50 })
//     const data = response.data || response
//     operationList.value = data.rows || []
//   } catch (e) { console.error('加载操作记录失败:', e) }
// }

/** 加载客户欠款套餐列表，无欠款时自动切回开单Tab */
async function loadOwedPackages() {
  if (!customerId.value) return
  try {
    const response = await getOwedPackages(customerId.value)
    const data = response.data || response
    owedPackageList.value = Array.isArray(data) ? data : []
    if (owedPackageList.value.length === 0 && currentTab.value === 2) {
      currentTab.value = 0
    }
  } catch (e) { console.error('加载欠款列表失败:', e) }
}

/** 加载客户还款记录列表 */
async function loadRepaymentList() {
  if (!customerId.value) return
  try {
    const response = await listRepayment({ customerId: customerId.value, pageNum: 1, pageSize: 100 })
    const data = response.data || response
    repaymentList.value = data.rows || []
  } catch (e) { console.error('加载还款记录失败:', e) }
}

/** 还款审核状态名称映射 */
function getRepaymentStatusName(status) {
  const map = { '0': '待审核', '1': '已通过', '2': '已驳回', '3': '已取消' }
  return map[status] || '未知'
}

/** 还款审核状态样式类名映射 */
function getRepaymentStatusClass(status) {
  const map = { '0': 'audit-pending', '1': 'audit-pass', '2': 'audit-reject', '3': 'audit-cancel' }
  return map[status] || ''
}

/** 审核通过还款 */
async function handleAuditPass(repaymentId) {
  try {
    await auditRepayment({ repaymentId, auditStatus: '1' })
    uni.showToast({ title: '审核通过', icon: 'success' })
    loadRepaymentList()
    loadOwedPackages()
  } catch (e) {
    console.error('审核失败:', e)
    uni.showToast({ title: '审核失败', icon: 'none' })
  }
}

/** 打开驳回弹窗 */
function openRejectPopup(repaymentId) {
  rejectRepaymentId.value = repaymentId
  rejectReason.value = ''
  showRejectPopup.value = true
}

/** 确认驳回还款 */
async function handleAuditReject() {
  if (!rejectReason.value.trim()) {
    uni.showToast({ title: '请输入驳回原因', icon: 'none' })
    return
  }
  try {
    await auditRepayment({ repaymentId: rejectRepaymentId.value, auditStatus: '2', auditRemark: rejectReason.value })
    uni.showToast({ title: '已驳回', icon: 'success' })
    showRejectPopup.value = false
    loadRepaymentList()
    loadOwedPackages()
  } catch (e) {
    console.error('驳回失败:', e)
    uni.showToast({ title: '驳回失败', icon: 'none' })
  }
}

/** 取消还款 */
async function handleCancelRepayment(repaymentId) {
  uni.showModal({
    title: '提示',
    content: '确认取消该还款记录？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await cancelRepayment(repaymentId)
          uni.showToast({ title: '已取消', icon: 'success' })
          loadRepaymentList()
          loadOwedPackages()
        } catch (e) {
          console.error('取消失败:', e)
          uni.showToast({ title: '取消失败', icon: 'none' })
        }
      }
    }
  })
}

/** 打开还款详情弹窗 */
function openRepayDetailPopup(item) {
  repayDetail.value = item
  showRepayDetailPopup.value = true
}

/** 关闭还款详情弹窗 */
function closeRepayDetailPopup() {
  showRepayDetailPopup.value = false
  repayDetail.value = null
}

/** 打开还款弹窗，初始化还款表单 */
function openRepayPopup(pkg) {
  selectedPackage.value = pkg
  repayAmount.value = ''
  selectedPaymentMethod.value = 'cash'
  repayRemark.value = ''
  showRepayPopup.value = true
}

/** 关闭还款弹窗并清空选中套餐 */
function closeRepayPopup() {
  showRepayPopup.value = false
  selectedPackage.value = null
}

/** 提交还款，校验金额有效性后调用接口，成功后刷新欠款列表 */
async function submitRepay() {
  if (!selectedPackage.value) return
  const amount = parseFloat(repayAmount.value)
  if (!amount || amount <= 0) {
    uni.showToast({ title: '请输入有效的还款金额', icon: 'none' })
    return
  }
  if (amount > Number(selectedPackage.value.owedAmount || 0)) {
    uni.showToast({ title: '还款金额不能超过欠款金额', icon: 'none' })
    return
  }

  repaySubmitting.value = true
  try {
    await addRepayment({
      customerId: customerId.value,
      customerName: customerInfo.value?.customerName || '',
      packageId: selectedPackage.value.packageId,
      packageNo: selectedPackage.value.packageNo,
      packageName: selectedPackage.value.packageName,
      orderId: selectedPackage.value.orderId,
      orderNo: selectedPackage.value.orderNo,
      repaymentAmount: amount,
      repaymentType: '1',
      paymentMethod: selectedPaymentMethod.value,
      remark: repayRemark.value,
      enterpriseId: selectedPackage.value.enterpriseId,
      enterpriseName: enterpriseName.value,
      storeId: storeId.value,
      storeName: storeName.value
    })
    uni.showToast({ title: '还款成功', icon: 'success' })
    closeRepayPopup()
    loadOwedPackages()
    loadRepaymentList()
  } catch (e) {
    console.error('还款失败:', e)
    uni.showToast({ title: '还款失败', icon: 'none' })
  } finally {
    repaySubmitting.value = false
  }
}

/** 提交销售订单，校验套餐名称和品项后调用接口，成功后提示欠款金额并重置表单 */
async function submitOrder() {
  if (!orderPackageName.value) {
    uni.showToast({ title: '请输入套餐名称', icon: 'none' })
    return
  }

  const validItems = orderItems.value.filter(i => i.productName)
  if (validItems.length === 0) {
    uni.showToast({ title: '请选择品项', icon: 'none' })
    return
  }

  const hasInvalidAmount = validItems.some(i => i.paymentMethod !== 'gift' && (parseFloat(i.dealAmount) || 0) <= 0)
  if (hasInvalidAmount) {
    uni.showToast({ title: '请填写成交金额', icon: 'none' })
    return
  }

  submitting.value = true
  try {
    await addSalesOrder({
      customerId: customerId.value,
      customerName: customerInfo.value?.customerName || '',
      storeId: storeId.value,
      storeName: storeName.value,
      enterpriseId: customerInfo.value?.enterpriseId || '',
      enterpriseName: enterpriseName.value,
      orderStatus: '0',
      packageName: orderPackageName.value,
      storeDealer: orderStoreDealer.value,
      remark: orderRemark.value,
      items: validItems.map(i => ({
        cardItemId: i.cardItemId,
        productName: i.productName,
        quantity: parseInt(i.quantity) || 1,
        dealAmount: parseFloat(i.dealAmount) || 0,
        paidAmount: parseFloat(i.paidAmount) || 0,
        paymentMethod: i.paymentMethod || 'cash'
      }))
    })

    const owed = totalOwedAmount.value
    if (owed > 0) {
      uni.showToast({ title: `开单成功，欠款¥${owed.toFixed(2)}`, icon: 'success', duration: 2000 })
    } else {
      uni.showToast({ title: '开单成功', icon: 'success' })
    }

    orderPackageName.value = ''
    orderItems.value = [{ cardItemId: null, productName: '', quantity: 1, dealAmount: 0, paidAmount: 0 }]
    orderRemark.value = ''
    orderStoreDealer.value = ''
  } catch (e) {
    console.error('开单失败:', e)
    uni.showToast({ title: '开单失败: ' + (e.message || '未知错误'), icon: 'none' })
  } finally {
    submitting.value = false
  }
}

/** 订单状态码映射为中文名称 */
function getOrderStatusName(status) {
  const map = { '0': '待确认', '1': '企业已审', '2': '财务已审', '4': '已取消' }
  return map[status] || '未知'
}

function getPaymentMethodName(method) {
  const map = { cash: '现金', card: '耗卡', gift: '赠送', wechat: '微信', alipay: '支付宝', bank: '银行卡' }
  return map[method] || method || '-'
}

/** 格式化时间为YYYY-MM-DD HH:mm */
function formatTime(time) { if (!time) return ''; return time.substring(0, 16) }
/** 格式化为MM-DD HH:mm简短格式 */
function formatTimeShort(time) { if (!time) return ''; return time.substring(5, 16).replace('-', '-').replace(' ', ' ') }
/** 拨打客户电话 */
function callPhone(phone) { if (!phone) return; uni.makePhoneCall({ phoneNumber: phone }) }

onMounted(() => {
  const pages = getCurrentPages()
  const options = pages[pages.length - 1].options || {}
  customerId.value = options.customerId || ''
  storeId.value = options.storeId || ''
  storeName.value = decodeURIComponent(options.storeName || '')
  enterpriseName.value = decodeURIComponent(options.enterpriseName || '')
  loadCustomer()
  loadSalesConfig()
})

async function loadSalesConfig() {
  try {
    const [qtyRes, dealRes, paidRes] = await Promise.all([
      getConfigKey('biz.sales.packageQuantityEditable'),
      getConfigKey('biz.sales.packageDealAmountEditable'),
      getConfigKey('biz.sales.packagePaidAmountEditable')
    ])
    packageQuantityEditable.value = qtyRes.data !== 'false'
    packageDealAmountEditable.value = dealRes.data !== 'false'
    packagePaidAmountEditable.value = paidRes.data !== 'false'
  } catch (e) {
    // 读取失败时使用默认值
  }
}
</script>

<style lang="scss" scoped>
page { background-color: #F5F6F8; }
.order-container { display: flex; flex-direction: column;
  :deep(.u-popup) { flex: none !important; }
}

.customer-info { padding: 16rpx 24rpx; background: #fff; border-bottom: 1rpx solid #F2F3F5; }
.info-row { display: flex; align-items: center; gap: 10rpx; margin-bottom: 6rpx; &:last-child { margin-bottom: 0; } }
.customer-name { font-size: 30rpx; font-weight: 600; color: #1D2129; }
.customer-phone { font-size: 26rpx; color: #3D6DF7; margin-left: auto; }
.store-name { font-size: 24rpx; color: #86909C; }

.tab-content { flex: 1; }
.tab-panel { padding: 16rpx 24rpx 40rpx; }

.package-name-section { background: #fff; border-radius: 10rpx; padding: 18rpx 20rpx; margin-bottom: 14rpx; border: 1rpx solid #EDEEF2; }
.section-title-row { display: flex; align-items: center; gap: 8rpx; margin-bottom: 10rpx; }
.section-label { font-size: 26rpx; font-weight: 600; color: #1D2129; }
.package-name-input { width: 100%; height: 60rpx; background: #F7F8FA; border-radius: 8rpx; padding: 0 18rpx; font-size: 27rpx; color: #1D2129; box-sizing: border-box; }

.items-section { margin-bottom: 14rpx; }
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12rpx; }
.add-item-btn { display: flex; align-items: center; gap: 6rpx; padding: 8rpx 16rpx; background: #EEF2FF; border-radius: 8rpx; }
.add-item-text { font-size: 24rpx; color: #3D6DF7; font-weight: 500; }

.item-card { background: #fff; border-radius: 10rpx; padding: 16rpx 18rpx; margin-bottom: 12rpx; border: 1rpx solid #EDEEF2; }
.item-card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10rpx; padding-bottom: 8rpx; border-bottom: 1rpx solid #F5F6F7; }
.item-index-wrap { display: flex; align-items: center; gap: 6rpx; }
.item-index { font-size: 25rpx; font-weight: 600; color: #1D2129; }
.item-delete { display: flex; align-items: center; gap: 4rpx; padding: 6rpx 12rpx; background: #FEF2F2; border-radius: 6rpx; }
.delete-text { font-size: 22rpx; color: #F56C6C; }

.item-form { display: flex; flex-direction: column; gap: 8rpx; }
.form-row { display: flex; align-items: center; gap: 12rpx; min-height: 56rpx; background: #FAFBFC; border-radius: 6rpx; padding: 0 12rpx; }
.form-row.readonly { }
.form-label { font-size: 24rpx; color: #86909C; width: 120rpx; min-width: 120rpx; white-space: nowrap; }
.form-input { flex: 1; height: 56rpx; background: #F7F8FA; border-radius: 6rpx; padding: 0 16rpx; font-size: 26rpx; color: #1D2129; text-align: right; box-sizing: border-box; }
.form-value { flex: 1; font-size: 26rpx; color: #1D2129; font-weight: 500; text-align: right; display: flex; align-items: center; justify-content: flex-end; gap: 4rpx; }
.auto-hint { color: #4E5969 !important; font-weight: 400; }

.summary-section { background: #fff; border-radius: 10rpx; padding: 16rpx 20rpx; margin-bottom: 14rpx; border: 1rpx solid #EDEEF2; }
.summary-title-row { display: flex; align-items: center; gap: 8rpx; margin-bottom: 12rpx; }
.summary-title { font-size: 26rpx; font-weight: 600; color: #1D2129; }
.summary-body { display: flex; align-items: center; gap: 0; }
.summary-item { flex: 1; text-align: center; padding: 8rpx 0; }
.summary-divider { width: 1rpx; height: 36rpx; background: #F2F3F5; }
.summary-label { font-size: 22rpx; color: #86909C; display: block; margin-bottom: 4rpx; }
.summary-value { font-size: 28rpx; font-weight: 700; color: #1D2129; display: block; }
.summary-value.paid { color: #00B42A; }
.summary-value.owed { color: #F53F3F; }

.dealer-section { background: #fff; border-radius: 10rpx; padding: 16rpx 20rpx; margin-bottom: 14rpx; border: 1rpx solid #EDEEF2; }
.dealer-input { width: 100%; height: 60rpx; background: #F7F8FA; border-radius: 8rpx; padding: 0 18rpx; font-size: 27rpx; color: #1D2129; box-sizing: border-box; }
.payment-section { background: #fff; border-radius: 10rpx; padding: 16rpx 20rpx; margin-bottom: 14rpx; border: 1rpx solid #EDEEF2; }
.item-payment-methods { display: flex; flex-wrap: wrap; gap: 10rpx; flex: 1; }
.remark-section { background: #fff; border-radius: 10rpx; padding: 16rpx 20rpx; margin-bottom: 14rpx; border: 1rpx solid #EDEEF2; }
.submit-bar { margin-top: 16rpx; padding-bottom: env(safe-area-inset-bottom); }

.record-list { display: flex; flex-direction: column; gap: 16rpx; }

.record-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}

.rc-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.rc-header-left { display: flex; align-items: center; gap: 8rpx; }
.rc-no { font-size: 26rpx; font-weight: 600; color: #1D2129; letter-spacing: 0.5rpx; }
.rc-status { font-size: 20rpx; padding: 4rpx 14rpx; border-radius: 20rpx; font-weight: 500;
  &.st-0 { background: #FFF7E8; color: #FF7D00; }
  &.st-1 { background: #E8F0FE; color: #3D6DF7; }
  &.st-2 { background: #E8FFEA; color: #00B42A; }
  &.st-4 { background: #F2F3F5; color: #86909C; }
}

.rc-items { display: flex; flex-direction: column; gap: 10rpx; margin-bottom: 4rpx; }
.rc-item-row { display: flex; align-items: center; gap: 12rpx; padding: 10rpx 16rpx; background: #FAFBFC; border-radius: 10rpx; }
.rc-item-name { flex: 1; font-size: 25rpx; color: #1D2129; font-weight: 500; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.rc-item-qty { font-size: 23rpx; color: #86909C; flex-shrink: 0; }
.rc-item-price { font-size: 25rpx; color: #1D2129; font-weight: 600; flex-shrink: 0; }

.rc-divider { height: 1rpx; background: linear-gradient(90deg, transparent, #E5E6EB, transparent); margin: 16rpx 0; }

.rc-amounts { display: flex; align-items: center; gap: 24rpx; padding: 16rpx 20rpx; background: linear-gradient(135deg, #F7F8FA, #FDFEFF); border-radius: 12rpx; margin-bottom: 12rpx; }
.rc-amount-group { display: flex; align-items: baseline; gap: 6rpx; }
.rc-amt-label { font-size: 21rpx; color: #86909C; }
.rc-amt-deal { font-size: 28rpx; font-weight: 700; color: #FF6B35; }
.rc-amt-paid { font-size: 28rpx; font-weight: 700; color: #00B42A; }
.rc-amt-owed { font-size: 26rpx; font-weight: 700; color: #F53F3F; }
.rc-amt-method { font-size: 24rpx; font-weight: 500; color: #3D6DF7; background: #E8F0FE; padding: 2rpx 12rpx; border-radius: 6rpx; }

.rc-footer { display: flex; justify-content: space-between; align-items: center; }
.rc-meta-row { display: flex; align-items: center; gap: 8rpx; }
.rc-meta-item { display: flex; align-items: center; gap: 4rpx; white-space: nowrap; flex-shrink: 0; }
.rc-meta-val { font-size: 22rpx; color: #86909C; white-space: nowrap; }
.rc-meta-sep { font-size: 18rpx; color: #E5E6EB; margin: 0 4rpx; }
.rc-time { font-size: 21rpx; color: #C9CDD4; }

.rc-remark { display: flex; align-items: flex-start; gap: 6rpx; margin-top: 12rpx; padding-top: 12rpx; border-top: 1rpx dashed #EDEEF2; }
.rc-remark-text { font-size: 23rpx; color: #86909C; line-height: 1.5; }
.record-type { font-size: 24rpx; color: #3D6DF7; font-weight: 500; }
.record-content { font-size: 25rpx; color: #4E5969; }

.rc-owed-card { border-left: 6rpx solid #F53F3F; }
.rc-owed-badge { font-size: 24rpx; font-weight: 700; color: #F53F3F; background: #FEF2F2; padding: 4rpx 16rpx; border-radius: 20rpx; }
.rc-owed-info { gap: 4rpx; }
.rc-action-row { display: flex; justify-content: flex-end; padding: 8rpx 0; }
.rc-repay-btn { display: flex; align-items: center; gap: 8rpx; padding: 14rpx 40rpx; background: linear-gradient(135deg, #F53F3F 0%, #FF7875 100%); border-radius: 30rpx;
  .rc-repay-text { font-size: 26rpx; color: #fff; font-weight: 600; }
}

.repay-popup { background: #fff; border-radius: 20rpx 20rpx 0 0; max-height: 80vh; }
.popup-header { display: flex; justify-content: space-between; align-items: center; padding: 28rpx; border-bottom: 1rpx solid #F2F3F5; }
.popup-title { font-size: 30rpx; font-weight: 600; color: #1D2129; }
.popup-close { padding: 8rpx; }
.popup-body { padding: 20rpx 28rpx; max-height: 50vh; overflow-y: auto; }
.repay-info-row { margin-bottom: 18rpx; }
.repay-label { font-size: 26rpx; color: #86909C; margin-bottom: 8rpx; display: block; }
.repay-value { font-size: 28rpx; color: #1D2129; font-weight: 500;
  &.owed { color: #F53F3F; }
}
.repay-input-wrap { display: flex; align-items: center; background: #F7F8FA; border-radius: 10rpx; padding: 0 20rpx; height: 80rpx; box-sizing: border-box; }
.currency { font-size: 30rpx; color: #1D2129; font-weight: 600; margin-right: 6rpx; }
.repay-input { flex: 1; font-size: 30rpx; color: #1D2129; height: 80rpx; }
.payment-methods { display: flex; flex-wrap: wrap; gap: 12rpx; }
.method-tag { padding: 14rpx 28rpx; background: #F7F8FA; border-radius: 8rpx; border: 1rpx solid transparent;
  text { font-size: 24rpx; color: #4E5969; }
  &.active { background: #EEF2FF; border-color: #3D6DF7;
    text { color: #3D6DF7; }
  }
}
.popup-actions { padding: 20rpx 28rpx calc(20rpx + env(safe-area-inset-bottom)); border-top: 1rpx solid #F2F3F5; }

.card-item-search-popup { background: #fff; border-radius: 20rpx 20rpx 0 0; max-height: 80vh; }
.card-item-search-popup .popup-header { display: flex; justify-content: space-between; align-items: center; padding: 28rpx; border-bottom: 1rpx solid #F2F3F5; }
.card-item-search-popup .popup-body { padding: 20rpx 28rpx; max-height: 60vh; overflow-y: auto; }
.search-bar { margin-bottom: 16rpx; }
.card-item-list { display: flex; flex-direction: column; gap: 12rpx; }
.card-item-option { display: flex; justify-content: space-between; align-items: center; padding: 20rpx 24rpx; background: #F7F8FA; border-radius: 12rpx; }
.card-item-info { display: flex; flex-direction: column; gap: 6rpx; flex: 1; }
.card-item-name { font-size: 28rpx; font-weight: 600; color: #1D2129; }
.card-item-meta { font-size: 24rpx; color: #86909C; }

.repay-section { margin-top: 24rpx; }
.repay-section-title { display: flex; align-items: center; gap: 8rpx; margin-bottom: 16rpx; }

.rc-repay-card { border-left: 6rpx solid #3D6DF7; }

.rc-audit-tag { font-size: 20rpx; padding: 4rpx 14rpx; border-radius: 20rpx; font-weight: 500;
  &.audit-pending { background: #FFF7E8; color: #FF7D00; }
  &.audit-pass { background: #E8FFEA; color: #00B42A; }
  &.audit-reject { background: #FEF2F2; color: #F53F3F; }
  &.audit-cancel { background: #F2F3F5; color: #86909C; }
}

.rc-repay-info { display: flex; flex-direction: column; gap: 8rpx; padding: 8rpx 0; }
.rc-repay-row { display: flex; align-items: center; gap: 12rpx; }
.rc-repay-label { font-size: 24rpx; color: #86909C; width: 80rpx; min-width: 80rpx; }
.rc-repay-value { font-size: 25rpx; color: #1D2129; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

.rc-repay-footer { display: flex; justify-content: space-between; align-items: center; }
.rc-repay-actions { display: flex; align-items: center; gap: 12rpx; }
.rc-action-btn { display: flex; align-items: center; gap: 4rpx; padding: 8rpx 18rpx; border-radius: 20rpx; font-size: 22rpx; font-weight: 500; }
.rc-btn-pass { background: #00B42A; color: #fff; }
.rc-btn-reject { background: #F53F3F; color: #fff; }
.rc-btn-cancel { background: #F2F3F5; color: #86909C; }

.reject-popup { background: #fff; border-radius: 20rpx; width: 600rpx; }
.detail-action-row { display: flex; gap: 16rpx; }
.detail-action-row :deep(.u-button) { flex: 1; }
</style>
