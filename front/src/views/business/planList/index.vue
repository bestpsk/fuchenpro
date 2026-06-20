<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="企业名称" prop="enterpriseName">
        <el-input v-model="queryParams.enterpriseName" placeholder="请输入企业名称" clearable style="width: 160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="方案名称" prop="planName">
        <el-input v-model="queryParams.planName" placeholder="请输入方案名称" clearable style="width: 160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="审核状态" prop="auditStatus">
        <el-select v-model="queryParams.auditStatus" placeholder="全部" clearable style="width: 120px">
          <el-option label="草稿" value="0" />
          <el-option label="待审核" value="1" />
          <el-option label="已审核" value="2" />
          <el-option label="已完成" value="3" />
          <el-option label="已驳回" value="4" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8" style="margin-bottom: 15px">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAddPlan" v-hasPermi="['business:plan:add']">新增方案</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="Download" @click="handleExport" v-hasPermi="['business:plan:export']">导出</el-button>
      </el-col>
    </el-row>

    <el-table v-loading="loading" :data="planList">
      <el-table-column label="方案编号" prop="planNo" min-width="120" show-overflow-tooltip />
      <el-table-column label="企业名称" prop="enterpriseName" min-width="120" show-overflow-tooltip />
      <el-table-column label="方案名称" prop="planName" min-width="150" show-overflow-tooltip />
      <el-table-column label="回款比例" prop="commissionRate" align="center" width="90">
        <template #default="scope">{{ scope.row.commissionRate }}%</template>
      </el-table-column>
      <el-table-column label="方案金额" prop="planAmount" align="right" width="100" />
      <el-table-column label="配赠金额" prop="giftAmount" align="right" width="100" />
      <el-table-column label="剩余金额" prop="remainingAmount" align="right" width="100" />
      <el-table-column label="审核状态" prop="auditStatus" align="center" width="90">
        <template #default="scope">
          <el-tag :type="auditStatusType(scope.row.auditStatus)">{{ auditStatusLabel(scope.row.auditStatus) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="启用" prop="status" align="center" width="70">
        <template #default="scope">
          <el-switch v-model="scope.row.status" active-value="0" inactive-value="1" @change="(val) => handlePlanStatusChange(scope.row, val)" v-hasPermi="['business:plan:edit']" />
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="240" fixed="right">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleViewPlanDetail(scope.row)">详情</el-button>
          <el-button link type="warning" icon="Box" @click="handleOpenStockPrepare(scope.row)" v-hasPermi="['business:plan:edit']" :disabled="scope.row.auditStatus !== '2'">备货</el-button>
          <el-button link type="primary" icon="Edit" @click="handleEditPlan(scope.row)" v-hasPermi="['business:plan:edit']" v-if="scope.row.auditStatus === '0' || scope.row.auditStatus === '4'">编辑</el-button>
          <el-button link type="primary" icon="Check" @click="handleSubmitAudit(scope.row)" v-hasPermi="['business:plan:submitAudit']" v-if="scope.row.auditStatus === '0' || scope.row.auditStatus === '4'">提交审核</el-button>
          <el-button link type="primary" icon="Select" @click="handleAuditPlan(scope.row, true)" v-hasPermi="['business:plan:audit']" v-if="scope.row.auditStatus === '1'">通过</el-button>
          <el-button link type="danger" icon="CloseBold" @click="handleAuditPlan(scope.row, false)" v-hasPermi="['business:plan:audit']" v-if="scope.row.auditStatus === '1'">驳回</el-button>

        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="选择企业" v-model="enterpriseSelectOpen" width="500px" append-to-body>
      <el-table :data="enterpriseList" v-loading="enterpriseLoading" highlight-current-row @current-change="handleEnterpriseSelect" style="cursor: pointer">
        <el-table-column label="企业名称" prop="enterpriseName" />
        <el-table-column label="合作状态" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.status === '0' ? 'success' : 'info'">{{ scope.row.status === '0' ? '合作中' : '已停止' }}</el-tag>
          </template>
        </el-table-column>
      </el-table>
      <pagination v-show="enterpriseTotal > 0" :total="enterpriseTotal" v-model:page="enterpriseQueryParams.pageNum" v-model:limit="enterpriseQueryParams.pageSize" @pagination="getEnterpriseList" />
    </el-dialog>

    <el-dialog :title="planTitle" v-model="planOpen" width="1200px" append-to-body>
      <el-form ref="planRef" :model="planForm" :rules="planRules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="方案名称" prop="planName">
              <el-input v-model="planForm.planName" placeholder="请输入方案名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="分成比例(%)" prop="commissionRate">
              <el-input-number v-model="planForm.commissionRate" :precision="2" :min="0" :max="100" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="方案金额" prop="planAmount">
              <el-input-number v-model="planForm.planAmount" :precision="2" :min="0" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="配赠金额" prop="giftAmount">
              <el-input-number v-model="planForm.giftAmount" :precision="2" :min="0" controls-position="right" style="width: 100%" @change="onGiftAmountChange" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="生效日期" prop="effectiveDate">
              <el-date-picker v-model="planForm.effectiveDate" type="date" value-format="YYYY-MM-DD" placeholder="选择生效日期" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="失效日期" prop="expiryDate">
              <el-date-picker v-model="planForm.expiryDate" type="date" value-format="YYYY-MM-DD" placeholder="选择失效日期" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="剩余金额">
              <el-input-number v-model="planForm.remainingAmount" :precision="2" :min="0" controls-position="right" disabled style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="备注" prop="remark">
              <el-input v-model="planForm.remark" placeholder="请输入备注" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-divider content-position="left">配赠明细</el-divider>
        <el-table :data="planForm.items" border style="width: 100%" size="small">
          <el-table-column label="货品名称" min-width="130">
            <template #default="scope">
              <el-select v-model="scope.row.productId" placeholder="选择货品" filterable remote :remote-method="searchProduct" @focus="() => searchProduct('')" @change="(val) => onProductSelect(scope.$index, val)" style="width: 100%">
                <el-option v-for="p in productOptions" :key="p.productId" :label="p.productName" :value="p.productId" />
              </el-select>
            </template>
          </el-table-column>
          <el-table-column label="供货商">
            <template #default="scope">
              <span>{{ scope.row.supplierName || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column label="单位类型" min-width="120">
            <template #default="scope">
              <el-select v-model="scope.row.unitType" @change="onUnitTypeChange(scope.$index)" style="width: 100%">
                <el-option label="主单位-整" value="1" />
                <el-option label="副单位-拆" value="2" />
              </el-select>
            </template>
          </el-table-column>
          <el-table-column label="换算">
            <template #default="scope">
              <span v-if="scope.row.packQty > 1">1{{ scope.row.unitLabel }}={{ scope.row.packQty }}{{ scope.row.specLabel }}</span>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="数量">
            <template #default="scope">
              <el-input-number v-model="scope.row.quantity" :min="1" controls-position="right" @change="onItemQuantityChange(scope.$index)" style="width: 100%" />
            </template>
          </el-table-column>
          <el-table-column label="规格" width="60" align="center">
            <template #default="scope">
              <span>{{ scope.row.spec || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column label="单价" align="right">
            <template #default="scope">
              <span>{{ scope.row.salePrice || 0 }}</span>
            </template>
          </el-table-column>
          <el-table-column label="总金额" align="right">
            <template #default="scope">
              <span>{{ scope.row.amount || 0 }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="60" align="center">
            <template #default="scope">
              <el-button link type="danger" icon="Delete" @click="removePlanItem(scope.$index)" />
            </template>
          </el-table-column>
        </el-table>
        <el-button type="primary" link icon="Plus" @click="addPlanItem" style="margin-top: 10px">添加明细</el-button>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitPlanForm">确 定</el-button>
        <el-button @click="planOpen = false">取 消</el-button>
      </template>
    </el-dialog>

    <el-dialog title="方案详情" v-model="planDetailOpen" width="900px" append-to-body>
      <el-descriptions :column="3" border>
        <el-descriptions-item label="方案编号">{{ currentPlan.planNo }}</el-descriptions-item>
        <el-descriptions-item label="企业名称">{{ currentPlan.enterpriseName || currentPlan.enterprise?.enterpriseName }}</el-descriptions-item>
        <el-descriptions-item label="方案名称">{{ currentPlan.planName }}</el-descriptions-item>
        <el-descriptions-item label="分成比例">{{ currentPlan.commissionRate }}%</el-descriptions-item>
        <el-descriptions-item label="方案金额">{{ currentPlan.planAmount }}</el-descriptions-item>
        <el-descriptions-item label="配赠金额">{{ currentPlan.giftAmount }}</el-descriptions-item>
        <el-descriptions-item label="剩余金额">{{ currentPlan.remainingAmount }}</el-descriptions-item>
        <el-descriptions-item label="生效日期">{{ currentPlan.effectiveDate }}</el-descriptions-item>
        <el-descriptions-item label="失效日期">{{ currentPlan.expiryDate }}</el-descriptions-item>
        <el-descriptions-item label="审核状态">
          <el-tag :type="auditStatusType(currentPlan.auditStatus)">{{ auditStatusLabel(currentPlan.auditStatus) }}</el-tag>
        </el-descriptions-item>
      </el-descriptions>
      <el-divider content-position="left">操作记录</el-divider>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="创建人">{{ currentPlan.createBy || '-' }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ currentPlan.createTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="提交审核人">{{ currentPlan.submitBy || '-' }}</el-descriptions-item>
        <el-descriptions-item label="提交审核时间">{{ currentPlan.submitTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="审核人">{{ currentPlan.auditBy || '-' }}</el-descriptions-item>
        <el-descriptions-item label="审核时间">{{ currentPlan.auditTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="审核备注" :span="2">{{ currentPlan.auditRemark || '-' }}</el-descriptions-item>
      </el-descriptions>
      <el-tabs v-model="planDetailTab" style="margin-top: 12px;">
        <el-tab-pane label="配赠明细" name="items">
          <el-table :data="currentPlan.items || []" border size="small">
            <el-table-column label="货品名称" prop="productName" />
            <el-table-column label="供货商" prop="supplierName" />
            <el-table-column label="单位类型" width="80" align="center">
              <template #default="scope">{{ scope.row.unitType === '1' ? '主单位整' : '副单位拆' }}</template>
            </el-table-column>
            <el-table-column label="数量" prop="quantity" width="80" align="center" />
            <el-table-column label="规格" prop="spec" width="60" align="center" />
            <el-table-column label="单价" prop="salePrice" width="90" align="right" />
            <el-table-column label="总金额" prop="amount" width="100" align="right" />
            <el-table-column label="已出数量" prop="shippedQuantity" width="80" align="center" />
            <el-table-column label="剩余数量" prop="remainingQuantity" width="80" align="center" />
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="备货记录" name="stockPrepare">
          <el-table :data="stockPrepareList" border size="small" v-loading="stockPrepareLoading">
            <el-table-column label="备货编号" prop="prepareNo" min-width="120" show-overflow-tooltip />
            <el-table-column label="备货金额" prop="prepareAmount" width="100" align="right" />
            <el-table-column label="状态" prop="status" width="90" align="center">
              <template #default="scope">
                <el-tag :type="scope.row.status === '0' ? 'warning' : scope.row.status === '1' ? 'success' : 'info'">
                  {{ scope.row.status === '0' ? '备货中' : scope.row.status === '1' ? '已出库' : '已取消' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="创建时间" prop="createTime" width="160" align="center" />
          </el-table>
        </el-tab-pane>
      </el-tabs>

    </el-dialog>

    <!-- 备货对话框 -->
    <el-dialog title="方案备货" v-model="stockPrepareOpen" width="800px" append-to-body>
      <div v-if="stockPrepareItems.length > 0">
        <el-table :data="stockPrepareItems" border size="small">
          <el-table-column label="货品名称" prop="productName" min-width="120" />
          <el-table-column label="规格" prop="spec" width="80" align="center" />
          <el-table-column label="单位" prop="unitLabel" width="80" align="center" />
          <el-table-column label="出货价" prop="salePrice" width="90" align="right" />
          <el-table-column label="方案剩余数量" prop="remainingQuantity" width="110" align="center" />
          <el-table-column label="本次备货数量" width="140" align="center">
            <template #default="scope">
              <el-input-number v-model="scope.row.quantity" :min="0" :max="scope.row.remainingQuantity" controls-position="right" size="small" style="width: 120px" @change="onStockPrepareQuantityChange" />
            </template>
          </el-table-column>
          <el-table-column label="总价" width="100" align="right">
            <template #default="scope">
              {{ ((scope.row.salePrice || 0) * (scope.row.quantity || 0)).toFixed(2) }}
            </template>
          </el-table-column>
        </el-table>
      </div>
      <div v-else>
        <el-button type="primary" icon="Plus" @click="addStockPrepareManualItem">添加货品</el-button>
        <el-table :data="stockPrepareManualItems" border size="small" style="margin-top: 10px" v-if="stockPrepareManualItems.length > 0">
          <el-table-column label="货品名称" min-width="130">
            <template #default="scope">
              <el-select v-model="scope.row.productId" placeholder="选择货品" filterable remote :remote-method="searchProduct" @focus="() => searchProduct('')" @change="(val) => onStockPrepareProductSelect(scope.$index, val)" style="width: 100%">
                <el-option v-for="p in productOptions" :key="p.productId" :label="p.productName" :value="p.productId" />
              </el-select>
            </template>
          </el-table-column>
          <el-table-column label="单位类型" width="120">
            <template #default="scope">
              <el-select v-model="scope.row.unitType" @change="onStockPrepareUnitTypeChange(scope.$index)" style="width: 100%">
                <el-option label="主单位-整" value="1" />
                <el-option label="副单位-拆" value="2" />
              </el-select>
            </template>
          </el-table-column>
          <el-table-column label="规格" prop="spec" width="80" align="center" />
          <el-table-column label="出货价" prop="salePrice" width="90" align="right" />
          <el-table-column label="数量" width="120" align="center">
            <template #default="scope">
              <el-input-number v-model="scope.row.quantity" :min="1" controls-position="right" size="small" style="width: 100px" @change="onStockPrepareManualQuantityChange(scope.$index)" />
            </template>
          </el-table-column>
          <el-table-column label="总价" width="100" align="right">
            <template #default="scope">
              {{ ((scope.row.salePrice || 0) * (scope.row.quantity || 0)).toFixed(2) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="60" align="center">
            <template #default="scope">
              <el-button link type="danger" icon="Delete" @click="stockPrepareManualItems.splice(scope.$index, 1)" />
            </template>
          </el-table-column>
        </el-table>
      </div>
      <el-descriptions :column="2" border size="small">
        <el-descriptions-item label="方案配赠金额">{{ stockPreparePlan?.giftAmount || 0 }}</el-descriptions-item>
        <el-descriptions-item label="剩余出货金额">
          <span :style="{ color: stockPrepareRemainingAmount < 0 ? 'red' : '' }">{{ stockPrepareRemainingAmount.toFixed(2) }}</span>
        </el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button type="primary" @click="submitStockPrepare" :loading="stockPrepareSubmitting">确认备货</el-button>
        <el-button @click="stockPrepareOpen = false">取 消</el-button>
      </template>
    </el-dialog>


  </div>
</template>

<script setup name="PlanList">
/**
 * @description 方案列表页面（方案维度）- 方案查询/开立/审核
 * @description 以方案为维度展示所有方案，支持按企业名/方案名/审核状态筛选，
 * 提供方案开立（先选企业）、审核/提交/状态切换等功能
 */
import { listPlan, getPlan, addPlan, updatePlan, submitAuditPlan, auditPlan, changePlanStatus } from "@/api/business/plan"
import { listEnterprise } from "@/api/business/enterprise"
import { listProduct } from "@/api/wms/product"
import { createFromPlan, getActivePreparedAmount, listStockPrepare } from "@/api/business/stockPrepare"



const { proxy } = getCurrentInstance()

const { biz_product_unit, biz_product_spec } = useDict("biz_product_unit", "biz_product_spec")

function getUnitLabel(value) { if (!value) return ''; const dict = biz_product_unit.value?.find(d => d.value === value); return dict ? dict.label : '' }
function getSpecLabel(value) { if (!value) return ''; const dict = biz_product_spec.value?.find(d => d.value === value); return dict ? dict.label : '' }

const planList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const planOpen = ref(false)
const planTitle = ref("")
const planDetailOpen = ref(false)
const currentPlan = ref({})
const productOptions = ref([])
const enterpriseSelectOpen = ref(false)
const enterpriseList = ref([])
const enterpriseLoading = ref(false)
const enterpriseTotal = ref(0)
const giftAmountManuallyModified = ref(false)

// 备货相关
const planDetailTab = ref('items')
const stockPrepareOpen = ref(false)
const stockPrepareItems = ref([])
const stockPrepareManualItems = ref([])
const stockPrepareActiveAmount = ref(0)
const stockPrepareShippedAmount = ref(0)
const stockPrepareSubmitting = ref(false)
const stockPrepareList = ref([])
const stockPrepareLoading = ref(false)
const stockPreparePlan = ref(null)



const stockPrepareTotalAmount = computed(() => {
  if (stockPrepareItems.value.length > 0) {
    return stockPrepareItems.value.reduce((sum, item) => sum + (item.salePrice || 0) * (item.quantity || 0), 0)
  }
  return stockPrepareManualItems.value.reduce((sum, item) => sum + (item.salePrice || 0) * (item.quantity || 0), 0)
})

const stockPrepareRemainingAmount = computed(() => {
  const giftAmount = parseFloat(stockPreparePlan.value?.giftAmount) || 0
  return giftAmount - stockPrepareActiveAmount.value - stockPrepareShippedAmount.value - stockPrepareTotalAmount.value
})

const data = reactive({
  queryParams: { pageNum: 1, pageSize: 10, enterpriseName: undefined, planName: undefined, auditStatus: undefined },
  enterpriseQueryParams: { pageNum: 1, pageSize: 10, enterpriseName: undefined },
  planForm: {},
  planRules: {
    planName: [{ required: true, message: "方案名称不能为空", trigger: "blur" }],
    giftAmount: [{ required: true, message: "配赠金额不能为空", trigger: "blur" }]
  }
})

const { queryParams, enterpriseQueryParams, planForm, planRules } = toRefs(data)

function auditStatusType(status) {
  const map = { '0': 'info', '1': 'warning', '2': 'success', '3': '', '4': 'danger' }
  return map[status] || 'info'
}

function auditStatusLabel(status) {
  const map = { '0': '草稿', '1': '待审核', '2': '已审核', '3': '已完成', '4': '已驳回' }
  return map[status] || '未知'
}

function handleExport() {
  proxy.download("business/plan/export", {
    ...queryParams.value,
  }, `plan_${new Date().getTime()}.xlsx`)
}

function getList() {
  loading.value = true
  listPlan(queryParams.value).then(res => {
    planList.value = res.rows
    total.value = res.total
    loading.value = false
  })
}

function getEnterpriseList() {
  enterpriseLoading.value = true
  listEnterprise(enterpriseQueryParams.value).then(res => {
    enterpriseList.value = res.rows
    enterpriseTotal.value = res.total
    enterpriseLoading.value = false
  })
}

function handleQuery() { queryParams.value.pageNum = 1; getList() }
function resetQuery() { proxy.resetForm("queryRef"); handleQuery() }

function handleAddPlan() {
  enterpriseSelectOpen.value = true
  getEnterpriseList()
}

function handleEnterpriseSelect(row) {
  if (row) {
    enterpriseSelectOpen.value = false
    resetPlanForm()
    planForm.value.enterpriseId = row.enterpriseId
    planForm.value.planName = row.enterpriseName + ' ' + '0%方案'
    planOpen.value = true
    planTitle.value = "开方案 - " + row.enterpriseName
  }
}

function handleEditPlan(row) {
  giftAmountManuallyModified.value = false
  getPlan(row.planId).then(res => {
    planForm.value = { ...res.data, items: (res.data.items || []).map(item => ({ ...item })) }
    planOpen.value = true
    planTitle.value = "修改方案"
  })
}

function resetPlanForm() {
  giftAmountManuallyModified.value = false
  planForm.value = {
    planId: undefined, enterpriseId: undefined, planName: undefined,
    commissionRate: 0, planAmount: 0, giftAmount: 0, remainingAmount: 0,
    effectiveDate: undefined, expiryDate: undefined, remark: undefined, items: []
  }
  proxy.resetForm("planRef")
}

function onGiftAmountChange() {
  giftAmountManuallyModified.value = true
  planForm.value.remainingAmount = planForm.value.giftAmount
}

function calcGiftAmount() {
  if (giftAmountManuallyModified.value) return
  const planAmount = parseFloat(planForm.value.planAmount)
  const commissionRate = parseFloat(planForm.value.commissionRate)
  if (planAmount > 0 && commissionRate > 0) {
    planForm.value.giftAmount = Math.round(planAmount * 100 / commissionRate * 100) / 100
    planForm.value.remainingAmount = planForm.value.giftAmount
  }
}

watch(() => planForm.value.planAmount, () => calcGiftAmount())
watch(() => planForm.value.commissionRate, () => calcGiftAmount())

function addPlanItem() {
  planForm.value.items.push({
    productId: undefined, productName: '', supplierId: undefined, supplierName: '',
    unitType: '1', packQty: 1, quantity: 1, spec: '', salePrice: 0, amount: 0,
    unitLabel: '', specLabel: '',
    _mainPrice: null
  })
}

function removePlanItem(index) { planForm.value.items.splice(index, 1) }

function searchProduct(query) {
  listProduct({ productName: query || '', status: '0', pageNum: 1, pageSize: 20 }).then(res => {
    productOptions.value = res.rows || []
  })
}

function onProductSelect(index, productId) {
  const product = productOptions.value.find(p => p.productId === productId)
  if (product) {
    const item = planForm.value.items[index]
    item.productId = product.productId
    item.productName = product.productName
    item.supplierId = product.supplierId
    item.supplierName = product.supplierName || ''
    item.packQty = product.packQty || 1
    item.unitType = '1'
    item._mainPrice = product.salePrice || 0
    item.salePrice = product.salePrice || 0
    item.unitLabel = getUnitLabel(product.unit)
    item.specLabel = getSpecLabel(product.spec)
    onUnitTypeChange(index)
  }
}

function onUnitTypeChange(index) {
  const item = planForm.value.items[index]
  const packQty = item.packQty || 1

  if (item.unitType === '1') {
    if (item._mainPrice) {
      item.salePrice = item._mainPrice
    }
    item.spec = item.unitLabel || ''
  } else {
    if (!item._mainPrice && item.salePrice) {
      item._mainPrice = item.salePrice
    }
    if (item._mainPrice && packQty > 0) {
      item.salePrice = Math.round((item._mainPrice / packQty) * 100) / 100
    }
    item.spec = item.specLabel || ''
  }

  onItemQuantityChange(index)
}

function onItemQuantityChange(index) {
  const item = planForm.value.items[index]
  item.amount = (parseFloat(item.salePrice) || 0) * (parseInt(item.quantity) || 0)
}

function submitPlanForm() {
  proxy.$refs["planRef"].validate(valid => {
    if (valid) {
      if (planForm.value.planId != undefined) {
        updatePlan(planForm.value).then(() => { proxy.$modal.msgSuccess("修改成功"); planOpen.value = false; getList() })
      } else {
        addPlan(planForm.value).then(() => { proxy.$modal.msgSuccess("新增成功"); planOpen.value = false; getList() })
      }
    }
  })
}

function handleSubmitAudit(row) {
  proxy.$modal.confirm('确认提交审核？').then(() => {
    return submitAuditPlan(row.planId)
  }).then(() => { proxy.$modal.msgSuccess("提交成功"); getList() }).catch(() => {})
}

function handleAuditPlan(row, passed) {
  const text = passed ? '通过' : '驳回'
  proxy.$modal.confirm('确认' + text + '？').then(() => {
    return auditPlan({ planId: row.planId, passed })
  }).then(() => { proxy.$modal.msgSuccess(text + "成功"); getList() }).catch(() => {})
}

function handlePlanStatusChange(row, val) {
  const text = val === "0" ? "启用" : "停用"
  proxy.$modal.confirm('确认"' + text + '"该方案？').then(() => {
    return changePlanStatus(row.planId, val)
  }).then(() => { proxy.$modal.msgSuccess(text + "成功") }).catch(() => { row.status = val === "0" ? "1" : "0" })
}

function handleViewPlanDetail(row) {
  getPlan(row.planId).then(res => {
    currentPlan.value = res.data
    planDetailTab.value = 'items'
    planDetailOpen.value = true
    loadStockPrepareList(row.planId)
  })
}

// 备货相关方法
function loadStockPrepareList(planId) {
  stockPrepareLoading.value = true
  listStockPrepare({ planId }).then(res => {
    stockPrepareList.value = res.rows || []
    stockPrepareLoading.value = false
  }).catch(() => { stockPrepareLoading.value = false })
}

function handleOpenStockPrepare(row) {
  // 从列表行直接获取方案详情
  getPlan(row.planId).then(res => {
    const plan = res.data
    stockPreparePlan.value = plan
    const items = plan.items || []
    if (items.length > 0) {
      stockPrepareItems.value = items
        .filter(item => (item.remainingQuantity || 0) > 0)
        .map(item => ({
          planItemId: item.planItemId,
          productId: item.productId,
          productName: item.productName,
          spec: item.spec,
          unitLabel: item.unitType === '1' ? '主单位整' : '副单位拆',
          salePrice: item.salePrice,
          remainingQuantity: item.remainingQuantity,
          quantity: 0
        }))
      stockPrepareManualItems.value = []
    } else {
      stockPrepareItems.value = []
      stockPrepareManualItems.value = []
    }
    // 获取活跃备货金额
    getActivePreparedAmount(plan.planId).then(res2 => {
      stockPrepareActiveAmount.value = res2.data?.activePreparedAmount || 0
      stockPrepareShippedAmount.value = plan.shippedAmount || 0
    }).catch(() => {
      stockPrepareActiveAmount.value = 0
      stockPrepareShippedAmount.value = 0
    })
    stockPrepareOpen.value = true
  })
}

function onStockPrepareProductSelect(index, productId) {
  const product = productOptions.value.find(p => p.productId === productId)
  if (product) {
    const item = stockPrepareManualItems.value[index]
    item.productId = product.productId
    item.productName = product.productName
    item.packQty = product.packQty || 1
    item.unitType = '1'
    item._mainPrice = product.salePrice || 0
    item.salePrice = product.salePrice || 0
    item.unitLabel = getUnitLabel(product.unit)
    item.specLabel = getSpecLabel(product.spec)
    onStockPrepareUnitTypeChange(index)
  }
}

function onStockPrepareUnitTypeChange(index) {
  const item = stockPrepareManualItems.value[index]
  const packQty = item.packQty || 1
  if (item.unitType === '1') {
    if (item._mainPrice) { item.salePrice = item._mainPrice }
    item.spec = item.unitLabel || ''
  } else {
    if (!item._mainPrice && item.salePrice) { item._mainPrice = item.salePrice }
    if (item._mainPrice && packQty > 0) { item.salePrice = Math.round((item._mainPrice / packQty) * 100) / 100 }
    item.spec = item.specLabel || ''
  }
  onStockPrepareManualQuantityChange(index)
}

function onStockPrepareManualQuantityChange(index) {
  if (stockPrepareRemainingAmount.value < 0) {
    proxy.$modal.msgWarning('剩余出货金额不足，请减少备货数量')
  }
}

function onStockPrepareQuantityChange() {
  if (stockPrepareRemainingAmount.value < 0) {
    proxy.$modal.msgWarning('剩余出货金额不足，请减少备货数量')
  }
}

function addStockPrepareManualItem() {
  stockPrepareManualItems.value.push({
    productId: '',
    unitType: '1',
    spec: '',
    salePrice: 0,
    packQty: 1,
    quantity: 0,
  })
}

function submitStockPrepare() {
  const items = stockPrepareItems.value.length > 0 ? stockPrepareItems.value : stockPrepareManualItems.value
  const validItems = items.filter(item => item.quantity > 0)
  if (validItems.length === 0) {
    proxy.$modal.msgWarning('请至少选择一个货品且数量大于0')
    return
  }
  if (stockPrepareTotalAmount.value > stockPrepareRemainingAmount.value) {
    proxy.$modal.msgWarning('本次备货总金额不能超过剩余可用金额')
    return
  }
  stockPrepareSubmitting.value = true
  const submitItems = validItems.map(item => ({
    planItemId: item.planItemId,
    productId: item.productId,
    productName: item.productName,
    spec: item.spec,
    unitType: item.unitType,
    salePrice: item.salePrice,
    quantity: item.quantity
  }))
  createFromPlan(stockPreparePlan.value.planId, submitItems).then(() => {
    proxy.$modal.msgSuccess('备货成功，已自动创建出库单')
    stockPrepareOpen.value = false
    getList()
  }).catch(() => {}).finally(() => { stockPrepareSubmitting.value = false })
}

getList()
</script>
