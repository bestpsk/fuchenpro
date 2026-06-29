<template>
  <div class="app-container">
    <WarehouseSelector @change="handleWarehouseChange" />
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="盘点单号" prop="stockCheckNo">
        <el-input v-model="queryParams.stockCheckNo" placeholder="请输入盘点单号" clearable style="width: 160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择" clearable style="width: 120px">
          <el-option v-for="dict in biz_doc_status" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="盘点日期">
        <el-date-picker v-model="dateRange" type="daterange" range-separator="-" start-placeholder="开始" end-placeholder="结束" value-format="YYYY-MM-DD" style="width: 240px" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['wms:stockCheck:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete" v-hasPermi="['wms:stockCheck:remove']">删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="stockCheckList" @selection-change="handleSelectionChange" style="width: 100%">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="盘点单号" prop="stockCheckNo" min-width="140" />
      <el-table-column label="盘点日期" prop="checkDate" min-width="100" align="center" />
      <el-table-column label="盘点总数量" prop="totalQuantity" min-width="110" align="center" />
      <el-table-column label="差异数量" prop="totalDiffQuantity" min-width="100" align="center">
        <template #default="scope">
          <span :style="{ color: scope.row.totalDiffQuantity > 0 ? '#67C23A' : scope.row.totalDiffQuantity < 0 ? '#F56C6C' : '' }">{{ scope.row.totalDiffQuantity > 0 ? '+' : '' }}{{ scope.row.totalDiffQuantity }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作人" prop="operatorName" min-width="90" align="center" />
      <el-table-column label="状态" prop="status" min-width="80" align="center">
        <template #default="scope">
          <dict-tag :options="biz_doc_status" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="创建时间" prop="createTime" min-width="150" align="center" />
      <el-table-column label="操作" min-width="200" align="center">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleView(scope.row)">查看</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-if="scope.row.status === '0'" v-hasPermi="['wms:stockCheck:edit']">修改</el-button>
          <el-button link type="primary" icon="Check" @click="handleConfirm(scope.row)" v-if="scope.row.status === '0'" v-hasPermi="['wms:stockCheck:confirm']">确认</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-if="scope.row.status === '0'" v-hasPermi="['wms:stockCheck:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="dialogTitle" v-model="open" width="1300px" append-to-body>
      <el-form ref="stockCheckRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="8">
            <el-form-item label="仓库" prop="warehouseId">
              <el-select v-model="form.warehouseId" placeholder="请选择仓库" :disabled="isView" @change="onDialogWarehouseChange" style="width: 100%">
                <el-option v-for="w in warehouseList" :key="w.warehouseId" :label="w.warehouseName" :value="w.warehouseId" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="盘点日期" prop="checkDate">
              <el-date-picker v-model="form.checkDate" type="date" value-format="YYYY-MM-DD" placeholder="选择日期" :disabled="isView" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="备注" prop="remark">
              <el-input v-model="form.remark" placeholder="请输入备注" :disabled="isView" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-divider content-position="left">
          <span>盘点明细</span>
          <el-input v-model="searchKeyword" placeholder="搜索品名/编码..." clearable style="width: 200px; margin-left: 20px; vertical-align: middle;" />
        </el-divider>
        <el-table :data="filteredItems" border style="width: 100%">
          <el-table-column label="品名" prop="productName" min-width="140" />
          <el-table-column label="单位类型" min-width="140" align="center">
            <template #default="scope">
              <template v-if="!isView">
                <el-select v-model="scope.row.unitType" placeholder="请选择" @change="onUnitTypeChange(scope.$index)" style="width: 100%">
                  <el-option label="主单位(整)" value="1" />
                  <el-option label="副单位(拆)" value="2" />
                </el-select>
              </template>
              <span v-else>{{ scope.row.unitType === '1' ? '主单位(整)' : scope.row.unitType === '2' ? '副单位(拆)' : '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column label="换算" min-width="90" align="center">
            <template #default="scope">
              <span v-if="scope.row.packQty > 1">1{{ getUnitLabel(scope.row.unit) }}={{ scope.row.packQty }}{{ getSpecLabel(scope.row.spec) }}</span>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="系统库存" min-width="130" align="center">
            <template #default="scope">
              <span>{{ formatItemQuantity(scope.row, scope.row.systemQuantity) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="实际数量" min-width="150" align="center">
            <template #default="scope">
              <el-input-number v-if="!isView" v-model="scope.row.actualQuantity" :min="0" :step="1" @change="calcDiff(scope.$index)" style="width: 100%" />
              <span v-else>{{ formatItemQuantity(scope.row, scope.row.actualQuantity) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="规格" min-width="80" align="center">
            <template #default="scope">
              <span v-if="scope.row.unitType === '1'">{{ getUnitLabel(scope.row.unit) }}</span>
              <span v-else>{{ getSpecLabel(scope.row.spec) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="差异数量" min-width="120" align="center">
            <template #default="scope">
              <span :style="{ color: scope.row.diffQuantity > 0 ? '#67C23A' : scope.row.diffQuantity < 0 ? '#F56C6C' : '' }">{{ formatDiffQuantity(scope.row) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="生产日期" min-width="110" align="center" header-align="center">
            <template #default="scope">
              <el-date-picker v-if="!isView" v-model="scope.row.productionDate" type="date" value-format="YYYY-MM-DD" placeholder="选择日期" style="width: 100%" />
              <span v-else>{{ scope.row.productionDate || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column label="到期日期" min-width="110" align="center" header-align="center">
            <template #default="scope">
              <el-date-picker v-if="!isView" v-model="scope.row.expiryDate" type="date" value-format="YYYY-MM-DD" placeholder="选择日期" style="width: 100%" />
              <span v-else :style="{ color: isExpiringSoon(scope.row.expiryDate) ? '#e6a23c' : (isExpired(scope.row.expiryDate) ? '#f56c6c' : '') }">{{ scope.row.expiryDate || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column label="备注" min-width="180">
            <template #default="scope">
              <el-input v-if="!isView" v-model="scope.row.remark" placeholder="备注" />
              <span v-else>{{ scope.row.remark }}</span>
            </template>
          </el-table-column>
        </el-table>
      </el-form>
      <template #footer v-if="!isView">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
      <template #footer v-else>
        <el-button @click="cancel">关 闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="WmsStockCheck">
/**
 * @description 盘点管理页面 - 盘点单CRUD与确认/加载库存
 * @description 提供盘点单增删改查、确认盘点（差异调整到库存）、加载当前库存数据等功能
 */
import { listStockCheck, getStockCheck, delStockCheck, addStockCheck, updateStockCheck, confirmStockCheck, loadInventoryData } from "@/api/wms/stockCheck"
import WarehouseSelector from '@/components/WarehouseSelector/index.vue'
import { useWarehouse } from '@/composables/useWarehouse'

const { proxy } = getCurrentInstance()
const { currentWarehouseId, warehouseList, loadWarehouses } = useWarehouse()
const { biz_doc_status, biz_product_unit, biz_product_spec } = useDict("biz_doc_status", "biz_product_unit", "biz_product_spec")

const stockCheckList = ref([])
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const multiple = ref(true)
const total = ref(0)
const dialogTitle = ref("")
const isView = ref(false)
const dateRange = ref([])
const searchKeyword = ref('')

const data = reactive({
  form: { items: [] },
  queryParams: { pageNum: 1, pageSize: 10, stockCheckNo: undefined, status: undefined, warehouseId: undefined },
  rules: { checkDate: [{ required: true, message: "盘点日期不能为空", trigger: "change" }] }
})
const { queryParams, form, rules } = toRefs(data)

function getUnitLabel(value) { if (!value) return ''; const dict = biz_product_unit.value?.find(d => d.value === String(value)); return dict ? dict.label : '' }
function getSpecLabel(value) { if (!value) return ''; const dict = biz_product_spec.value?.find(d => d.value === String(value)); return dict ? dict.label : '' }

const filteredItems = computed(() => {
  const keyword = searchKeyword.value.trim().toLowerCase()
  if (!keyword) return form.value.items || []
  return (form.value.items || []).filter(item =>
    (item.productName || '').toLowerCase().includes(keyword) ||
    (item.productCode || '').toLowerCase().includes(keyword)
  )
})

function formatItemQuantity(item, qty) {
  const packQty = item.packQty || 1
  const unitLabel = getUnitLabel(item.unit)
  const specLabel = getSpecLabel(item.spec)
  const unitType = item.unitType || '2'
  qty = qty || 0
  if (unitType === '1') {
    if (packQty > 1 && specLabel) {
      const mainQty = qty
      const subQty = Math.round(qty * packQty)
      const mainQtyStr = Number.isInteger(mainQty) ? mainQty : mainQty.toFixed(1).replace(/\.0$/, '')
      return mainQtyStr + unitLabel + '（' + subQty + specLabel + '）'
    } else if (unitLabel) {
      return qty + unitLabel
    } else {
      return qty
    }
  } else {
    if (specLabel) {
      return qty + specLabel
    } else if (unitLabel) {
      return qty + unitLabel
    } else {
      return qty
    }
  }
}

function formatDiffQuantity(item) {
  const diff = item.diffQuantity || 0
  if (diff === 0) return '0'
  const prefix = diff > 0 ? '+' : ''
  const packQty = item.packQty || 1
  const unitLabel = getUnitLabel(item.unit)
  const specLabel = getSpecLabel(item.spec)
  const unitType = item.unitType || '2'
  if (packQty > 1 && specLabel) {
    if (unitType === '1') {
      // diff是主单位数量
      const mainQty = diff
      const subQty = Math.round(diff * packQty)
      const mainQtyStr = Number.isInteger(mainQty) ? mainQty : mainQty.toFixed(1).replace(/\.0$/, '')
      return prefix + mainQtyStr + unitLabel + '（' + prefix + subQty + specLabel + '）'
    } else {
      // diff是副单位数量
      const mainQty = diff / packQty
      const mainQtyStr = Number.isInteger(mainQty) ? mainQty : mainQty.toFixed(1).replace(/\.0$/, '')
      return prefix + mainQtyStr + unitLabel + '（' + prefix + Math.round(diff) + specLabel + '）'
    }
  } else if (unitLabel) {
    return prefix + diff + unitLabel
  } else {
    return prefix + diff
  }
}

function getList() {
  loading.value = true
  const params = { ...queryParams.value }
  if (dateRange.value && dateRange.value.length === 2) {
    params.checkDateStart = dateRange.value[0]
    params.checkDateEnd = dateRange.value[1]
  }
  if (currentWarehouseId.value) params.warehouseId = currentWarehouseId.value
  listStockCheck(params).then(response => {
    stockCheckList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

function handleQuery() { queryParams.value.pageNum = 1; getList() }
function resetQuery() { dateRange.value = []; proxy.resetForm("queryRef"); handleQuery() }
function handleSelectionChange(selection) { ids.value = selection.map(item => item.stockCheckId); multiple.value = !selection.length }

function handleWarehouseChange(warehouseId) {
  queryParams.value.warehouseId = warehouseId
  handleQuery()
}

function isExpiringSoon(expiryDate) {
  if (!expiryDate) return false
  const now = new Date()
  const expiry = new Date(expiryDate)
  const daysLeft = Math.ceil((expiry - now) / (1000 * 60 * 60 * 24))
  return daysLeft > 0 && daysLeft <= 30
}

function isExpired(expiryDate) {
  if (!expiryDate) return false
  return new Date(expiryDate) < new Date(new Date().toISOString().slice(0, 10))
}

function reset() {
  form.value = { stockCheckId: undefined, checkDate: new Date().toISOString().slice(0, 10), warehouseId: currentWarehouseId.value, remark: undefined, items: [] }
  proxy.resetForm("stockCheckRef")
}

function handleAdd() {
  reset()
  loadInventoryData(form.value.warehouseId || currentWarehouseId.value).then(res => {
    form.value.items = (res.data || []).map(item => ({ ...item, unitType: item.unitType || '2', _prevUnitType: item.unitType || '2', _rawSystemQty: item.systemQuantity, _rawActualQty: item.systemQuantity, actualQuantity: item.systemQuantity, diffQuantity: 0 }))
    isView.value = false; dialogTitle.value = "新增盘点单"; open.value = true
  })
}

function onDialogWarehouseChange(warehouseId) {
  loadInventoryData(warehouseId).then(res => {
    form.value.items = (res.data || []).map(item => ({ ...item, unitType: item.unitType || '2', _prevUnitType: item.unitType || '2', _rawSystemQty: item.systemQuantity, _rawActualQty: item.systemQuantity, actualQuantity: item.systemQuantity, diffQuantity: 0 }))
  })
}

function handleUpdate(row) {
  reset()
  getStockCheck(row.stockCheckId).then(response => {
    form.value = response.data
    if (!form.value.items) form.value.items = []
    form.value.items.forEach(item => { item._prevUnitType = item.unitType || '2'; item._rawSystemQty = item.systemQuantity; item._rawActualQty = item.actualQuantity })
    isView.value = false; dialogTitle.value = "修改盘点单"; open.value = true
  })
}

function handleView(row) {
  reset()
  getStockCheck(row.stockCheckId).then(response => {
    form.value = response.data
    if (!form.value.items) form.value.items = []
    form.value.items.forEach(item => { item._prevUnitType = item.unitType || '2' })
    isView.value = true; dialogTitle.value = "查看盘点单"; open.value = true
  })
}

function handleConfirm(row) {
  proxy.$modal.confirm('确认盘点后将调整库存数量，是否继续？').then(() => confirmStockCheck(row.stockCheckId)).then(() => { getList(); proxy.$modal.msgSuccess("盘点确认成功") }).catch(() => {})
}

function calcDiff(index) {
  const item = form.value.items[index]
  item.diffQuantity = item.actualQuantity - item.systemQuantity
  // 同步更新备份字段（根据当前单位类型换算回副单位）
  const packQty = item.packQty || 1
  if (item.unitType === '1' && packQty > 1) {
    item._rawActualQty = Math.round(item.actualQuantity * packQty * 100) / 100
  } else {
    item._rawActualQty = item.actualQuantity
  }
}

function onUnitTypeChange(index) {
  const item = form.value.items[index]
  const newUnitType = item.unitType
  const packQty = item.packQty || 1

  // 从备份字段重新计算，避免反复乘除导致浮点精度丢失
  const rawSystemQty = item._rawSystemQty
  const rawActualQty = item._rawActualQty

  if (newUnitType === '1') {
    // 主单位：副单位数量除以packQty
    item.systemQuantity = packQty > 1 ? Math.round(rawSystemQty / packQty * 100) / 100 : rawSystemQty
    item.actualQuantity = packQty > 1 ? Math.round(rawActualQty / packQty * 100) / 100 : rawActualQty
  } else {
    // 副单位：直接使用备份值（备份值始终为副单位）
    item.systemQuantity = rawSystemQty
    item.actualQuantity = rawActualQty
  }

  item._prevUnitType = newUnitType
  calcDiff(index)
}

function convertToMinUnit(item) {
  const qty = item.actualQuantity || 0
  const unitType = item.unitType || '2'
  const packQty = item.packQty || 1
  if (unitType === '1' && packQty > 1) {
    return Math.round(qty * packQty)
  }
  return qty
}

function convertSystemQtyToMinUnit(item) {
  const qty = item.systemQuantity || 0
  const unitType = item.unitType || '2'
  const packQty = item.packQty || 1
  if (unitType === '1' && packQty > 1) {
    return Math.round(qty * packQty)
  }
  return qty
}

function submitForm() {
  proxy.$refs["stockCheckRef"].validate(valid => {
    if (valid) {
      if (!form.value.items || form.value.items.length === 0) { proxy.$modal.msgWarning("盘点明细不能为空"); return }
      const submitData = { ...form.value, items: form.value.items.map(item => ({ ...item, productionDate: item.productionDate || undefined, expiryDate: item.expiryDate || undefined, actualQuantity: convertToMinUnit(item), systemQuantity: convertSystemQtyToMinUnit(item) })) }
      if (form.value.stockCheckId != undefined) {
        updateStockCheck(submitData).then(() => { proxy.$modal.msgSuccess("修改成功"); open.value = false; getList() })
      } else {
        addStockCheck(submitData).then(() => { proxy.$modal.msgSuccess("新增成功"); open.value = false; getList() })
      }
    }
  })
}

function handleDelete(row) {
  const stockCheckIds = row.stockCheckId || ids.value
  proxy.$modal.confirm('是否确认删除？').then(() => delStockCheck(stockCheckIds)).then(() => { getList(); proxy.$modal.msgSuccess("删除成功") }).catch(() => {})
}

function cancel() { open.value = false; reset() }

onMounted(async () => {
  await loadWarehouses()
  getList()
})
</script>
