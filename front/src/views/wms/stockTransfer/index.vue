<template>
  <div class="app-container">
    <WarehouseSelector @change="handleWarehouseChange" />
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="调拨单号" prop="transferNo">
        <el-input v-model="queryParams.transferNo" placeholder="请输入调拨单号" clearable style="width: 180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="源仓库" prop="fromWarehouseId">
        <el-select v-model="queryParams.fromWarehouseId" placeholder="请选择" clearable style="width: 140px">
          <el-option v-for="w in warehouseList" :key="w.warehouseId" :label="w.warehouseName" :value="w.warehouseId" />
        </el-select>
      </el-form-item>
      <el-form-item label="目标仓库" prop="toWarehouseId">
        <el-select v-model="queryParams.toWarehouseId" placeholder="请选择" clearable style="width: 140px">
          <el-option v-for="w in warehouseList" :key="w.warehouseId" :label="w.warehouseName" :value="w.warehouseId" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择" clearable style="width: 120px">
          <el-option v-for="dict in biz_doc_status" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['wms:stockTransfer:add']">新增调拨</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete" v-hasPermi="['wms:stockTransfer:remove']">删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="Download" @click="handleExport">导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="stockTransferList" @selection-change="handleSelectionChange" style="width: 100%">
      <el-table-column type="selection" width="50" align="center" />
      <el-table-column label="调拨单号" prop="transferNo" min-width="140" />
      <el-table-column label="源仓库" min-width="100" align="center">
        <template #default="scope">
          <span>{{ scope.row.fromWarehouseName || '-' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="目标仓库" min-width="100" align="center">
        <template #default="scope">
          <span>{{ scope.row.toWarehouseName || '-' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="总数量" min-width="100" align="center">
        <template #default="scope">
          {{ scope.row.totalQuantity || 0 }}
        </template>
      </el-table-column>
      <el-table-column label="调拨日期" prop="transferDate" min-width="100" align="center" />
      <el-table-column label="状态" prop="status" min-width="80" align="center">
        <template #default="scope">
          <dict-tag :options="biz_doc_status" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="创建时间" prop="createTime" min-width="130" align="center" />
      <el-table-column label="操作" min-width="220" align="center">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleView(scope.row)">详情</el-button>
          <el-button link type="primary" icon="Check" @click="handleConfirm(scope.row)" v-if="scope.row.status === '0'" v-hasPermi="['wms:stockTransfer:confirm']">确认</el-button>
          <el-button link type="warning" icon="RefreshLeft" @click="handleCancelConfirm(scope.row)" v-if="scope.row.status === '1'" v-hasPermi="['wms:stockTransfer:confirm']">取消确认</el-button>
          <el-button link type="danger" icon="Delete" @click="handleDelete(scope.row)" v-if="scope.row.status === '0'" v-hasPermi="['wms:stockTransfer:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 新增/修改调拨对话框 -->
    <el-dialog :title="dialogTitle" v-model="open" width="85%" append-to-body>
      <el-form ref="stockTransferRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="6">
            <el-form-item label="源仓库" prop="fromWarehouseId">
              <el-select v-model="form.fromWarehouseId" placeholder="请选择源仓库" :disabled="isView" style="width: 100%">
                <el-option v-for="w in warehouseList" :key="w.warehouseId" :label="w.warehouseName" :value="w.warehouseId" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="目标仓库" prop="toWarehouseId">
              <el-select v-model="form.toWarehouseId" placeholder="请选择目标仓库" :disabled="isView" style="width: 100%">
                <el-option v-for="w in warehouseList" :key="w.warehouseId" :label="w.warehouseName" :value="w.warehouseId" :disabled="w.warehouseId === form.fromWarehouseId" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="调拨日期" prop="transferDate">
              <el-date-picker v-model="form.transferDate" type="date" value-format="YYYY-MM-DD" placeholder="选择日期" :disabled="isView" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="备注" prop="remark">
              <el-input v-model="form.remark" placeholder="请输入备注" :disabled="isView" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-divider content-position="left">调拨明细</el-divider>
        <el-table :data="form.items" border style="width: 100%" v-if="!isView || form.items?.length">
          <el-table-column label="货品" min-width="200" align="center" header-align="center">
            <template #default="scope">
              <el-select v-if="!isView" v-model="scope.row.productId" placeholder="搜索货品" filterable remote :remote-method="searchProductList" :loading="productLoading" @change="onProductSelect(scope.$index)" style="width: 100%">
                <el-option v-for="item in productOptions" :key="item.productId" :label="item.productName + '(' + item.productCode + ')'" :value="item.productId" />
              </el-select>
              <span v-else>{{ scope.row.productName }}</span>
            </template>
          </el-table-column>
          <el-table-column label="库存信息" min-width="120" align="center" header-align="center">
            <template #default="scope">
              <span v-if="scope.row.stockInfo">{{ scope.row.stockInfo }}</span>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="单位类型" min-width="110" align="center" header-align="center">
            <template #default="scope">
              <el-select v-if="!isView" v-model="scope.row.unitType" placeholder="选择" @change="onUnitTypeChange(scope.$index)" style="width: 100%">
                <el-option label="主单位(整)" value="1" />
                <el-option label="副单位(拆)" value="2" />
              </el-select>
              <span v-else>{{ scope.row.unitType === '1' ? '主单位(整)' : '副单位(拆)' }}</span>
            </template>
          </el-table-column>
          <el-table-column label="换算" min-width="100" align="center" header-align="center">
            <template #default="scope">
              <span v-if="scope.row.packQty && scope.row.packQty > 1" style="color: #909399; font-size: 12px;">
                1{{ getUnitLabel(scope.row.unit) }}={{ scope.row.packQty }}{{ getSpecLabel(scope.row.spec) }}
              </span>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="数量" min-width="120" align="center" header-align="center">
            <template #default="scope">
              <el-input-number v-if="!isView" v-model="scope.row.quantity" :min="1" style="width: 100%" />
              <span v-else>{{ scope.row.unitType === '1' && scope.row.packQty > 1 ? (scope.row.originalQuantity || scope.row.quantity) : scope.row.quantity }}</span>
            </template>
          </el-table-column>
          <el-table-column label="规格" min-width="80" align="center" header-align="center">
            <template #default="scope">
              <span>{{ scope.row.unitType === '1' ? getUnitLabel(scope.row.unit) : getSpecLabel(scope.row.spec) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="60" align="center" header-align="center" v-if="!isView">
            <template #default="scope">
              <el-button link type="danger" icon="Delete" @click="removeItem(scope.$index)" />
            </template>
          </el-table-column>
        </el-table>
        <el-button v-if="!isView" type="primary" link icon="Plus" @click="addItem" style="margin-top: 10px">添加明细</el-button>
      </el-form>
      <template #footer v-if="!isView">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
      <template #footer v-else>
        <el-button @click="cancel">关 闭</el-button>
      </template>
    </el-dialog>

    <!-- 详情对话框 -->
    <el-dialog title="调拨单详情" v-model="detailOpen" width="70%" append-to-body>
      <el-descriptions :column="3" border>
        <el-descriptions-item label="调拨单号">{{ detailForm.transferNo }}</el-descriptions-item>
        <el-descriptions-item label="源仓库">{{ detailForm.fromWarehouseName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="目标仓库">{{ detailForm.toWarehouseName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="调拨日期">{{ detailForm.transferDate }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <dict-tag :options="biz_doc_status" :value="detailForm.status" />
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ detailForm.createTime }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="3">{{ detailForm.remark || '-' }}</el-descriptions-item>
      </el-descriptions>

      <el-divider content-position="left">调拨明细</el-divider>
      <el-table :data="detailForm.items" border style="width: 100%">
        <el-table-column label="序号" type="index" width="60" align="center" />
        <el-table-column label="货品名称" prop="productName" min-width="160" />
        <el-table-column label="单位类型" min-width="100" align="center">
          <template #default="scope">
            {{ scope.row.unitType === '1' ? '主单位(整)' : '副单位(拆)' }}
          </template>
        </el-table-column>
        <el-table-column label="数量" min-width="100" align="center">
          <template #default="scope">
            {{ scope.row.unitType === '1' && scope.row.packQty > 1 ? (scope.row.originalQuantity || scope.row.quantity) : scope.row.quantity }}
          </template>
        </el-table-column>
        <el-table-column label="规格" min-width="80" align="center">
          <template #default="scope">
            {{ scope.row.unitType === '1' ? getUnitLabel(scope.row.unit) : getSpecLabel(scope.row.spec) }}
          </template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button @click="detailOpen = false">关 闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="WmsStockTransfer">
/**
 * @description 调拨管理页面 - 调拨单CRUD与确认/取消确认
 * @description 提供调拨单增删改查、确认调拨（源仓库扣减、目标仓库增加）、取消确认调拨等功能
 */
import { listStockTransfer, getStockTransfer, delStockTransfer, addStockTransfer, confirmStockTransfer, cancelConfirmStockTransfer } from "@/api/wms/stockTransfer"
import { searchProduct, getProduct } from "@/api/wms/product"
import { getInventory } from "@/api/wms/inventory"
import { ElMessageBox } from 'element-plus'
import WarehouseSelector from '@/components/WarehouseSelector/index.vue'
import { useWarehouse } from '@/composables/useWarehouse'

const { proxy } = getCurrentInstance()
const { currentWarehouseId, warehouseList, loadWarehouses } = useWarehouse()
const { biz_doc_status, biz_product_unit, biz_product_spec } = useDict("biz_doc_status", "biz_product_unit", "biz_product_spec")

const stockTransferList = ref([])
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const multiple = ref(true)
const total = ref(0)
const dialogTitle = ref("")
const isView = ref(false)
const detailOpen = ref(false)
const detailForm = ref({})
const productOptions = ref([])
const productLoading = ref(false)

const data = reactive({
  form: { items: [] },
  queryParams: { pageNum: 1, pageSize: 10, transferNo: undefined, fromWarehouseId: undefined, toWarehouseId: undefined, status: undefined, warehouseId: undefined },
  rules: {
    fromWarehouseId: [{ required: true, message: "源仓库不能为空", trigger: "change" }],
    toWarehouseId: [{ required: true, message: "目标仓库不能为空", trigger: "change" }],
    transferDate: [{ required: true, message: "调拨日期不能为空", trigger: "change" }]
  }
})
const { queryParams, form, rules } = toRefs(data)

function getUnitLabel(value) {
  if (!value && value !== 0) return ''
  const strValue = String(value)
  const dict = biz_product_unit.value?.find(d => String(d.value) === strValue)
  if (dict) return dict.label
  return strValue
}

function getSpecLabel(value) {
  if (!value && value !== 0) return ''
  const strValue = String(value)
  const dict = biz_product_spec.value?.find(d => String(d.value) === strValue)
  if (dict) return dict.label
  return strValue
}

function getList() {
  loading.value = true
  const params = { ...queryParams.value }
  if (currentWarehouseId.value) params.warehouseId = currentWarehouseId.value
  listStockTransfer(params).then(response => {
    stockTransferList.value = response.rows || []
    total.value = response.total
    loading.value = false
  })
}

function handleQuery() { queryParams.value.pageNum = 1; getList() }
function resetQuery() { proxy.resetForm("queryRef"); handleQuery() }
function handleSelectionChange(selection) { ids.value = selection.map(item => item.transferId); multiple.value = !selection.length }

function handleWarehouseChange(warehouseId) {
  queryParams.value.warehouseId = warehouseId
  handleQuery()
}

function reset() {
  form.value = { transferId: undefined, fromWarehouseId: currentWarehouseId.value, toWarehouseId: undefined, transferDate: new Date().toISOString().slice(0, 10), remark: undefined, items: [] }
  productOptions.value = []
  proxy.resetForm("stockTransferRef")
}

function handleAdd() { reset(); isView.value = false; dialogTitle.value = "新增调拨单"; open.value = true }

async function loadProductOptionsForItems(items) {
  if (!items || items.length === 0) return
  const productIds = [...new Set(items.map(item => item.productId).filter(id => id))]
  if (productIds.length === 0) return
  try {
    const results = await Promise.all(productIds.map(id => getProduct(id)))
    productOptions.value = results.filter(r => r.data).map(r => r.data)
  } catch (e) {
    console.error('加载货品信息失败', e)
  }
}

function handleView(row) {
  getStockTransfer(row.transferId).then(response => {
    detailForm.value = response.data
    if (!detailForm.value.items) detailForm.value.items = []
    detailOpen.value = true
  })
}

function addItem() {
  form.value.items.push({
    productId: undefined,
    productName: undefined,
    spec: undefined,
    unit: undefined,
    packQty: 1,
    unitType: '1',
    quantity: 1,
    stockInfo: undefined,
    remark: undefined
  })
}

function removeItem(index) { form.value.items.splice(index, 1) }

function onProductSelect(index) {
  const product = productOptions.value.find(p => p.productId === form.value.items[index].productId)
  if (product) {
    form.value.items[index].productName = product.productName
    form.value.items[index].spec = product.spec
    form.value.items[index].unit = product.unit
    form.value.items[index].packQty = product.packQty || 1
    form.value.items[index].unitType = '1'
    form.value.items[index].quantity = 1
    // 查询源仓库库存信息
    if (form.value.fromWarehouseId) {
      loadStockInfo(index, product.productId)
    } else {
      form.value.items[index].stockInfo = undefined
    }
  }
}

function loadStockInfo(index, productId) {
  getInventory(productId, { warehouse_id: form.value.fromWarehouseId }).then(res => {
    const data = res.data
    if (data && data.quantity !== undefined) {
      const item = form.value.items[index]
      const totalQty = Number(data.quantity) || 0
      item.stockQuantity = totalQty
      const unitLabel = getUnitLabel(item.unit)
      const specLabel = getSpecLabel(item.spec)
      if (item.unitType === '1' && item.packQty > 1) {
        const mainQty = Math.floor(totalQty / item.packQty)
        item.stockInfo = `主单位${mainQty}${unitLabel}（共${totalQty}${specLabel}）`
      } else {
        item.stockInfo = `${totalQty}${specLabel}`
      }
    } else {
      form.value.items[index].stockInfo = '库存为0'
      form.value.items[index].stockQuantity = 0
    }
  }).catch(() => {
    form.value.items[index].stockInfo = undefined
    form.value.items[index].stockQuantity = 0
  })
}

function onUnitTypeChange(index) {
  const item = form.value.items[index]
  // 单位类型切换时重置数量为1
  item.quantity = 1
}

function searchProductList(keyword) {
  productLoading.value = true
  searchProduct(keyword).then(res => { productOptions.value = res.data || []; productLoading.value = false })
}

function validateForm() {
  if (form.value.fromWarehouseId && form.value.toWarehouseId && form.value.fromWarehouseId === form.value.toWarehouseId) {
    proxy.$modal.msgWarning("源仓库和目标仓库不能相同")
    return false
  }
  return true
}

function submitForm() {
  proxy.$refs["stockTransferRef"].validate(valid => {
    if (valid) {
      if (!validateForm()) return
      if (!form.value.items || form.value.items.length === 0) {
        proxy.$modal.msgWarning("请至少添加一条调拨明细")
        return
      }
      addStockTransfer(form.value).then(() => { proxy.$modal.msgSuccess("新增成功"); open.value = false; getList() })
    }
  })
}

function handleConfirm(row) {
  ElMessageBox.confirm('确认调拨后，将从源仓库扣减库存并计入目标仓库，是否继续？', '确认调拨', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    confirmStockTransfer(row.transferId).then(() => {
      proxy.$modal.msgSuccess('调拨确认成功')
      getList()
    })
  }).catch(() => {})
}

function handleCancelConfirm(row) {
  ElMessageBox.confirm('取消确认将把库存从目标仓库归还到源仓库，是否继续？', '取消确认', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    cancelConfirmStockTransfer(row.transferId).then(() => {
      proxy.$modal.msgSuccess('已取消确认')
      getList()
    })
  }).catch(() => {})
}

function handleDelete(row) {
  const transferIds = row.transferId || ids.value
  proxy.$modal.confirm('是否确认删除？').then(() => delStockTransfer(transferIds)).then(() => { getList(); proxy.$modal.msgSuccess("删除成功") }).catch(() => {})
}

function handleExport() {
  proxy.download("wms/stockTransfer/export", { ...queryParams.value }, `调拨_${new Date().getTime()}.xlsx`)
}

function cancel() { open.value = false; reset() }

onMounted(() => { loadWarehouses() })
getList()
</script>
