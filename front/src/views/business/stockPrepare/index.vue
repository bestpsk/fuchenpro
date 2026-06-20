<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="企业名称" prop="enterpriseId">
        <el-select v-model="queryParams.enterpriseId" filterable remote :remote-method="searchEnterpriseList" :loading="enterpriseLoading" placeholder="请选择企业" clearable style="width: 200px" @change="handleEnterpriseChange">
          <el-option v-for="item in enterpriseOptions" :key="item.enterpriseId" :label="item.enterpriseName" :value="item.enterpriseId" />
        </el-select>
      </el-form-item>
      <el-form-item label="门店名称" prop="storeId">
        <el-select v-model="queryParams.storeId" filterable remote :remote-method="searchStoreList" :loading="storeLoading" placeholder="请选择门店" clearable style="width: 200px">
          <el-option v-for="item in storeOptions" :key="item.storeId" :label="item.storeName" :value="item.storeId" />
        </el-select>
      </el-form-item>
      <el-form-item label="备货编号" prop="prepareNo">
        <el-input v-model="queryParams.prepareNo" placeholder="请输入备货编号" clearable style="width: 160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable style="width: 160px">
          <el-option v-for="dict in biz_stock_prepare_status" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="warning" plain icon="Download" @click="handleExport" v-hasPermi="['business:stockPrepare:export']">导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="stockPrepareList">
      <el-table-column label="企业名称" prop="enterpriseName" min-width="140" show-overflow-tooltip />
      <el-table-column label="来源" width="140" align="center">
        <template #default="scope">
          <span v-if="scope.row.planId" class="link-type" @click="viewPlan(scope.row)">{{ scope.row.planNo }}</span>
          <span v-else-if="scope.row.orderId">订单备货</span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="门店名称" prop="storeName" min-width="120" show-overflow-tooltip />
      <el-table-column label="货品种类数" width="100" align="center">
        <template #default="scope">
          {{ scope.row.productCount || 0 }}
        </template>
      </el-table-column>
      <el-table-column label="总数量（整）" width="130" align="center">
        <template #default="scope">
          {{ calcMainTotalQty(scope.row.items, 'quantity') }}
        </template>
      </el-table-column>
      <el-table-column label="总金额" prop="totalAmount" width="110" align="right">
        <template #default="scope">
          ¥{{ scope.row.totalAmount }}
        </template>
      </el-table-column>
      <el-table-column label="已出库数量（整）" width="140" align="center">
        <template #default="scope">
          {{ calcMainTotalQty(scope.row.items, 'shippedQuantity') }}
        </template>
      </el-table-column>
      <el-table-column label="已出库金额" prop="shippedAmount" width="110" align="right">
        <template #default="scope">
          ¥{{ scope.row.shippedAmount }}
        </template>
      </el-table-column>
      <el-table-column label="待出库数量（整）" width="140" align="center">
        <template #default="scope">
          {{ calcMainTotalQty(scope.row.items, 'remainingQuantity') }}
        </template>
      </el-table-column>
      <el-table-column label="待出库金额" prop="pendingAmount" width="110" align="right">
        <template #default="scope">
          ¥{{ scope.row.pendingAmount }}
        </template>
      </el-table-column>
      <el-table-column label="状态" prop="status" width="90" align="center">
        <template #default="scope">
          <dict-tag :options="biz_stock_prepare_status" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="150" align="center">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleDetail(scope.row)">详情</el-button>
          <el-button link type="primary" icon="Sell" @click="handleStockOut(scope.row)" v-if="scope.row.status !== '2' && scope.row.status !== '3'" v-hasPermi="['business:stockPrepare:createStockOut']">出库</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="备货详情" v-model="detailOpen" width="1400px" append-to-body>
      <el-descriptions v-if="detailData.planId" :column="2" border size="small" style="margin-bottom: 16px;">
        <el-descriptions-item label="方案编号">{{ detailData.planNo }}</el-descriptions-item>
        <el-descriptions-item label="方案名称">{{ detailData.planName }}</el-descriptions-item>
      </el-descriptions>
      <el-tabs v-model="detailActiveTab">
        <el-tab-pane label="库存明细" name="items">
          <el-table :data="detailData.items" border size="small">
            <el-table-column label="货品名称" prop="productName" min-width="140" />
            <el-table-column label="单位(整)" width="80" align="center">
              <template #default="scope">
                <dict-tag :options="biz_product_unit" :value="scope.row.unit" />
              </template>
            </el-table-column>
            <el-table-column label="规格(拆)" width="80" align="center">
              <template #default="scope">
                <dict-tag :options="biz_product_spec" :value="scope.row.spec" />
              </template>
            </el-table-column>
            <el-table-column label="换算" width="120" align="center">
              <template #default="scope">
                <span v-if="scope.row.packQty > 1">1{{ getUnitLabel(scope.row.unit) }}={{ scope.row.packQty }}{{ getSpecLabel(scope.row.spec) }}</span>
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column label="出货价(整)" prop="mainSalePrice" width="100" align="right" />
            <el-table-column label="出货价(拆)" prop="salePriceSpec" width="100" align="right" />
            <el-table-column label="数量（整）" width="130" align="center">
              <template #default="scope">
                {{ formatMainQty(scope.row.quantity, scope.row.packQty, scope.row.unit, scope.row.spec) }}
              </template>
            </el-table-column>
            <el-table-column label="金额" prop="amount" width="100" align="right" />
            <el-table-column label="已出库（整）" width="130" align="center">
              <template #default="scope">
                {{ formatMainQty(scope.row.shippedQuantity, scope.row.packQty, scope.row.unit, scope.row.spec) }}
              </template>
            </el-table-column>
            <el-table-column label="已出库金额" prop="shippedAmount" width="100" align="right" />
            <el-table-column label="待出库（整）" width="130" align="center">
              <template #default="scope">
                {{ formatMainQty(scope.row.remainingQuantity, scope.row.packQty, scope.row.unit, scope.row.spec) }}
              </template>
            </el-table-column>
            <el-table-column label="待出库金额" prop="remainingAmount" width="100" align="right" />
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="关联订单" name="orders">
          <el-table :data="detailData.orders" border size="small">
            <el-table-column label="订单编号" prop="orderNo" width="160" />
            <el-table-column label="类别" prop="sourceType" width="80" align="center">
              <template #default="scope">
                {{ scope.row.sourceType === '0' ? '开单' : scope.row.sourceType === '1' ? '操作' : scope.row.sourceType === '2' ? '还款' : scope.row.sourceType === '3' ? '手动' : '-' }}
              </template>
            </el-table-column>
            <el-table-column label="客户姓名" prop="customerName" width="90" />
            <el-table-column label="门店名称" prop="storeName" width="100" show-overflow-tooltip />
            <el-table-column label="套餐名称" prop="packageName" width="120" show-overflow-tooltip />
            <el-table-column label="成交金额" prop="dealAmount" width="90" align="right" />
            <el-table-column label="实付金额" prop="paidAmount" width="90" align="right" />
            <el-table-column label="欠款金额" prop="owedAmount" width="90" align="right" />
            <el-table-column label="订单状态" prop="orderStatus" width="90" align="center">
              <template #default="scope">
                {{ scope.row.orderStatus === '0' ? '待确认' : scope.row.orderStatus === '1' ? '企业已审' : scope.row.orderStatus === '2' ? '财务已审' : scope.row.orderStatus === '3' ? '已取消' : '-' }}
              </template>
            </el-table-column>
            <el-table-column label="开单员工" prop="creatorUserName" width="90" />
            <el-table-column label="创建时间" prop="createTime" width="150" />
          </el-table>
        </el-tab-pane>
      </el-tabs>
    </el-dialog>

    <el-dialog title="统一出货" v-model="stockOutOpen" width="1200px" append-to-body>
      <el-form label-width="100px" style="margin-bottom: 12px">
        <el-form-item label="出库仓库" v-if="warehouseList.length > 0">
          <el-select v-model="stockOutWarehouseId" placeholder="请选择仓库" style="width: 240px">
            <el-option v-for="w in warehouseList" :key="w.warehouseId" :label="w.warehouseName" :value="w.warehouseId" />
          </el-select>
        </el-form-item>
      </el-form>
      <el-table ref="stockOutTableRef" :data="stockOutDetails" border size="small">
        <el-table-column label="货品名称" prop="productName" min-width="140" />
        <el-table-column label="单位类型" width="120" align="center">
          <template #default="scope">
            <el-select v-model="scope.row.unitType" @change="onStockOutUnitTypeChange(scope.$index)" style="width: 100%">
              <el-option label="主单位(整)" value="1" />
              <el-option label="副单位(拆)" value="2" />
            </el-select>
          </template>
        </el-table-column>
        <el-table-column label="换算/库存" width="140" align="center">
          <template #default="scope">
            <div v-if="scope.row.packQty > 1" style="color: #909399; font-size: 12px;">
              <div>1{{ getUnitLabel(scope.row.unit) }}={{ scope.row.packQty }}{{ getSpecLabel(scope.row.spec) }}</div>
              <div style="color: #67c23a;">待出库: {{ scope.row.remainingQuantity }}{{ getSpecLabel(scope.row.spec) }}</div>
            </div>
            <div v-else style="color: #67c23a; font-size: 12px;">待出库: {{ scope.row.remainingQuantity }}{{ getSpecLabel(scope.row.spec) }}</div>
          </template>
        </el-table-column>
        <el-table-column label="数量" width="140" align="center">
          <template #default="scope">
            <el-input-number v-model="scope.row.outQuantity" :min="0" :max="getStockOutMaxQty(scope.row)" size="small" style="width: 100%" @change="calcStockOutAmount(scope.$index)" />
          </template>
        </el-table-column>
        <el-table-column label="规格" width="80" align="center">
          <template #default="scope">
            <span>{{ scope.row.unitType === '1' ? getUnitLabel(scope.row.unit) : getSpecLabel(scope.row.spec) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="出货单价" width="120" align="center">
          <template #default="scope">
            <el-input-number v-model="scope.row.outSalePrice" :precision="2" :min="0" size="small" style="width: 100%" @change="calcStockOutAmount(scope.$index)" />
          </template>
        </el-table-column>
        <el-table-column label="金额" width="100" align="right">
          <template #default="scope">
            {{ scope.row.outAmount }}
          </template>
        </el-table-column>
      </el-table>
      <div style="margin-top: 16px; text-align: right; font-size: 14px;">
        <span>本次出库总数量：<b>{{ stockOutTotalDisplayQty }}</b></span>
        <span style="margin-left: 24px;">本次出库总金额：<b>¥{{ stockOutTotalAmount }}</b></span>
      </div>
      <template #footer>
        <el-button type="primary" @click="submitStockOut">确 定</el-button>
        <el-button @click="stockOutOpen = false">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="BusinessStockPrepare">
import { listStockPrepare, getStockPrepare, createStockOutFromPrepare } from "@/api/business/stockPrepare"
import { searchEnterprise } from "@/api/business/enterprise"
import { searchStore } from "@/api/business/store"
import { useWarehouse } from '@/composables/useWarehouse'

const { proxy } = getCurrentInstance()
const { biz_stock_prepare_status, biz_product_unit, biz_product_spec } = useDict("biz_stock_prepare_status", "biz_product_unit", "biz_product_spec")
const { currentWarehouseId, warehouseList, loadWarehouses } = useWarehouse()

const stockPrepareList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const detailOpen = ref(false)
const detailData = ref({})
const detailActiveTab = ref('items')
const stockOutOpen = ref(false)
const stockOutDetails = ref([])
const currentPrepareId = ref(undefined)
const stockOutTableRef = ref(null)
const stockOutWarehouseId = ref(null)

const enterpriseOptions = ref([])
const enterpriseLoading = ref(false)
const storeOptions = ref([])
const storeLoading = ref(false)

const data = reactive({
  queryParams: { pageNum: 1, pageSize: 10, enterpriseId: undefined, storeId: undefined, prepareNo: undefined, status: undefined }
})
const { queryParams } = toRefs(data)

const stockOutTotalDisplayQty = computed(() => {
  return stockOutDetails.value.filter(item => item.outQuantity > 0).map(item => {
    const label = item.unitType === '1' ? getUnitLabel(item.unit) : getSpecLabel(item.spec)
    return (item.outQuantity || 0) + label
  }).join(' + ') || '0'
})

const stockOutTotalAmount = computed(() => {
  return stockOutDetails.value.reduce((sum, item) => sum + parseFloat(item.outAmount || 0), 0).toFixed(2)
})

function getUnitLabel(value) { if (!value) return ''; const dict = biz_product_unit.value?.find(d => d.value === String(value)); return dict ? dict.label : '' }
function getSpecLabel(value) { if (!value) return ''; const dict = biz_product_spec.value?.find(d => d.value === String(value)); return dict ? dict.label : '' }

function formatMainQty(qty, packQty, unit, spec) {
  const unitLabel = getUnitLabel(unit)
  const specLabel = getSpecLabel(spec)
  const pq = packQty || 1
  if (pq > 1 && specLabel) {
    const mainQty = qty / pq
    const mainQtyStr = Number.isInteger(mainQty) ? mainQty : mainQty.toFixed(1).replace(/\.0$/, '')
    return mainQtyStr + unitLabel + '（' + qty + specLabel + '）'
  } else if (unitLabel) {
    return qty + unitLabel
  } else {
    return qty
  }
}

function calcMainTotalQty(items, field) {
  if (!items || items.length === 0) return 0
  return items.reduce((sum, item) => {
    const packQty = item.packQty || 1
    const qty = item[field] || 0
    return sum + (packQty > 1 ? qty / packQty : qty)
  }, 0)
}

function formatMainQtyFromTotal(totalQty, items) {
  if (!totalQty) return 0
  if (!items || items.length === 0) return totalQty
  // 逐个item换算后求和
  let mainQty = 0
  for (const item of items) {
    const packQty = item.packQty || 1
    mainQty += Math.floor((item.quantity || 0) / packQty)
  }
  return mainQty
}

function searchEnterpriseList(keyword) {
  enterpriseLoading.value = true
  searchEnterprise(keyword).then(response => {
    enterpriseOptions.value = response.data || []
  }).finally(() => {
    enterpriseLoading.value = false
  })
}

function searchStoreList(keyword) {
  storeLoading.value = true
  searchStore(keyword, queryParams.value.enterpriseId).then(response => {
    storeOptions.value = response.data || []
  }).finally(() => {
    storeLoading.value = false
  })
}

function handleEnterpriseChange(val) {
  queryParams.value.storeId = undefined
  storeOptions.value = []
  if (val) {
    searchStoreList('')
  }
}

watch(() => queryParams.value.enterpriseId, (val) => {
  if (!val) {
    queryParams.value.storeId = undefined
    storeOptions.value = []
  }
})

function getList() {
  loading.value = true
  listStockPrepare(queryParams.value).then(response => {
    stockPrepareList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

function handleExport() {
  proxy.download("business/stockPrepare/export", {
    ...queryParams.value,
  }, `stockPrepare_${new Date().getTime()}.xlsx`)
}

function handleQuery() { queryParams.value.pageNum = 1; getList() }
function resetQuery() { proxy.resetForm("queryRef"); handleQuery() }

function handleDetail(row) {
  getStockPrepare(row.prepareId).then(response => {
    detailData.value = response.data
    detailActiveTab.value = 'items'
    detailOpen.value = true
  })
}

function viewPlan(row) {
  proxy.$router.push({ path: '/business/planList', query: { planId: row.planId } })
}

function handleStockOut(row) {
  currentPrepareId.value = row.prepareId
  getStockPrepare(row.prepareId).then(response => {
    stockOutDetails.value = (response.data.items || []).map(item => {
      return {
        ...item,
        unitType: '1',
        outQuantity: 0,
        outSalePrice: item.mainSalePrice || 0,
        _mainPrice: item.mainSalePrice || 0,
        outAmount: '0.00'
      }
    })
    stockOutOpen.value = true
    loadWarehouses().then(() => {
      stockOutWarehouseId.value = currentWarehouseId.value
    })
  })
}

function getStockOutMaxQty(row) {
  if (row.unitType === '1' && row.packQty > 1) {
    return Math.floor(row.remainingQuantity / row.packQty)
  }
  return row.remainingQuantity
}

function onStockOutUnitTypeChange(index) {
  const item = stockOutDetails.value[index]
  if (item.unitType === '1') {
    item.outSalePrice = item._mainPrice || 0
  } else {
    item.outSalePrice = item.salePriceSpec || 0
  }
  item.outQuantity = 0
  calcStockOutAmount(index)
}

function calcStockOutAmount(index) {
  const item = stockOutDetails.value[index]
  item.outAmount = (item.outQuantity * item.outSalePrice).toFixed(2)
}

function submitStockOut() {
  const items = stockOutDetails.value.filter(item => item.outQuantity > 0).map(item => ({
    item_id: item.itemId,
    unit_type: item.unitType,
    original_quantity: item.outQuantity
  }))
  if (items.length === 0) {
    proxy.$modal.msgWarning("请至少填写一项出库数量")
    return
  }
  if (warehouseList.value.length > 0 && !stockOutWarehouseId.value) {
    proxy.$modal.msgWarning("请选择出库仓库")
    return
  }
  createStockOutFromPrepare({ prepareId: currentPrepareId.value, items, warehouseId: stockOutWarehouseId.value }).then(() => {
    proxy.$modal.msgSuccess("出库单创建成功")
    stockOutOpen.value = false
    getList()
  })
}

searchEnterpriseList('')
getList()
</script>
