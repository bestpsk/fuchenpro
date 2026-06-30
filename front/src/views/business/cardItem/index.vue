<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="卡项名称" prop="cardItemName">
        <el-input v-model="queryParams.cardItemName" placeholder="请输入卡项名称" clearable style="width: 160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="卡项编码" prop="cardItemCode">
        <el-input v-model="queryParams.cardItemCode" placeholder="请输入卡项编码" clearable style="width: 160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="类别" prop="category">
        <el-select v-model="queryParams.category" placeholder="请选择类别" clearable style="width: 160px">
          <el-option v-for="dict in biz_card_item_category" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable style="width: 160px">
          <el-option v-for="dict in sys_normal_disable" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['business:cardItem:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="Edit" :disabled="single" @click="handleUpdate" v-hasPermi="['business:cardItem:edit']">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete" v-hasPermi="['business:cardItem:remove']">删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="Download" @click="handleExport" v-hasPermi="['business:cardItem:export']">导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="cardItemList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="50" align="center" />
      <el-table-column label="卡项编码" prop="cardItemCode" min-width="120" />
      <el-table-column label="卡项名称" prop="cardItemName" min-width="140" show-overflow-tooltip />
      <el-table-column label="类别" prop="category" min-width="95" align="center">
        <template #default="scope">
          <dict-tag :options="biz_card_item_category" :value="scope.row.category" />
        </template>
      </el-table-column>
      <el-table-column label="默认次数" prop="defaultQuantity" min-width="90" align="center" />
      <el-table-column label="建议成交价" prop="suggestedPrice" min-width="110" align="right" />
      <el-table-column label="默认单次价" prop="defaultUnitPrice" min-width="110" align="right" />
      <el-table-column label="状态" prop="status" min-width="70" align="center">
        <template #default="scope">
          <el-switch v-model="scope.row.status" active-value="0" inactive-value="1"
            @change="(val) => handleStatusChange(scope.row, val)" v-hasPermi="['business:cardItem:edit']" />
        </template>
      </el-table-column>
      <el-table-column label="操作" min-width="150" align="center">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['business:cardItem:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['business:cardItem:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="1100px" append-to-body>
      <el-form ref="cardItemRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="卡项名称" prop="cardItemName">
              <el-input v-model="form.cardItemName" placeholder="请输入卡项名称" @blur="onCardItemNameBlur" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="卡项编码" prop="cardItemCode">
              <el-input v-model="form.cardItemCode" placeholder="请输入卡项编码" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="类别" prop="category">
              <el-select v-model="form.category" placeholder="请选择类别" style="width: 100%">
                <el-option v-for="dict in biz_card_item_category" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="默认次数" prop="defaultQuantity">
              <el-input-number v-model="form.defaultQuantity" :min="1" style="width: 100%" @change="calcDefaultUnitPrice" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="建议成交价" prop="suggestedPrice">
              <el-input-number v-model="form.suggestedPrice" :precision="2" :min="0" style="width: 100%" @change="calcDefaultUnitPrice" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="默认单次价" prop="defaultUnitPrice">
              <el-input-number v-model="form.defaultUnitPrice" :precision="2" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-radio-group v-model="form.status">
                <el-radio v-for="dict in sys_normal_disable" :key="dict.value" :value="dict.value">{{ dict.label }}</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="备注" prop="remark">
              <el-input v-model="form.remark" type="textarea" placeholder="请输入备注" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>

      <el-divider content-position="left">关联货品</el-divider>
      <el-row :gutter="10" class="mb8">
        <el-col :span="1.5">
          <el-button type="primary" plain icon="Plus" @click="handleAddProduct">添加货品</el-button>
        </el-col>
        <el-col :span="1.5">
          <el-button type="danger" plain icon="Delete" :disabled="productMultiple" @click="handleDeleteProduct">删除</el-button>
        </el-col>
      </el-row>
      <el-table :data="form.cardItemProducts" @selection-change="handleProductSelectionChange" border size="small">
        <el-table-column type="selection" width="50" align="center" />
        <el-table-column label="货品名称" prop="productName" min-width="140" />
        <el-table-column label="货品编码" prop="productCode" min-width="120" />
        <el-table-column label="单位类型" min-width="130" align="center">
          <template #default="scope">
            <el-select v-model="scope.row.unitType" size="small" @change="onProductUnitTypeChange(scope.$index)">
              <el-option label="主单位-整" value="1" />
              <el-option label="副单位-拆" value="2" />
            </el-select>
          </template>
        </el-table-column>
        <el-table-column label="换算" min-width="100" align="center">
          <template #default="scope">
            <span v-if="scope.row.packQty > 1" style="color: #909399; font-size: 12px;">1{{ scope.row.unitLabel }}={{ scope.row.packQty }}{{ scope.row.specLabel }}</span>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="消耗数量" prop="quantity" min-width="140" align="center">
          <template #default="scope">
            <el-input-number v-model="scope.row.quantity" :min="1" size="small" style="width: 100%" @change="calcSuggestedPrice" />
          </template>
        </el-table-column>
        <el-table-column label="规格" min-width="80" align="center">
          <template #default="scope">
            <span>{{ scope.row.unitType === '1' ? scope.row.unitLabel : scope.row.specLabel }}</span>
          </template>
        </el-table-column>
        <el-table-column label="单价" min-width="100" align="right">
          <template #default="scope">
            <span>{{ scope.row.unitType === '1' ? (scope.row.salePrice || 0) : (scope.row.salePriceSpec || 0) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="总价" min-width="110" align="right">
          <template #default="scope">
            <span>{{ ((scope.row.unitType === '1' ? (scope.row.salePrice || 0) : (scope.row.salePriceSpec || 0)) * (scope.row.quantity || 0)).toFixed(2) }}</span>
          </template>
        </el-table-column>
      </el-table>

      <template #footer>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>

    <el-dialog title="选择货品" v-model="productSelectOpen" width="1200px" append-to-body>
      <el-form :inline="true">
        <el-form-item>
          <el-input v-model="productKeyword" placeholder="请输入货品名称搜索" clearable style="width: 240px" />
        </el-form-item>
      </el-form>
      <el-table :data="productSelectList" @selection-change="handleProductSelectChange" border size="small" max-height="300">
        <el-table-column type="selection" width="50" align="center" />
        <el-table-column label="货品编码" prop="productCode" min-width="100" />
        <el-table-column label="品名" prop="productName" min-width="120" />
        <el-table-column label="供货商" prop="supplierName" min-width="100" />
        <el-table-column label="类别" prop="category" min-width="80" align="center">
          <template #default="scope">
            <dict-tag :options="biz_product_category" :value="scope.row.category" />
          </template>
        </el-table-column>
        <el-table-column label="单位(整)" prop="unit" min-width="80" align="center">
          <template #default="scope">
            <dict-tag :options="biz_product_unit" :value="scope.row.unit" />
          </template>
        </el-table-column>
        <el-table-column label="规格(拆)" prop="spec" min-width="80" align="center">
          <template #default="scope">
            <dict-tag :options="biz_product_spec" :value="scope.row.spec" />
          </template>
        </el-table-column>
        <el-table-column label="包装数量" prop="packQty" min-width="100" align="center">
          <template #default="scope">
            <span>{{ scope.row.packQty || 1 }}{{ scope.row.spec ? getSpecLabel(scope.row.spec) : '' }}/{{ getUnitLabel(scope.row.unit) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="出货价(整)" prop="salePrice" min-width="100" align="right" />
        <el-table-column label="出货价(拆)" prop="salePriceSpec" min-width="100" align="right" />
      </el-table>
      <template #footer>
        <el-button type="primary" @click="confirmProductSelect">确 定</el-button>
        <el-button @click="productSelectOpen = false">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="BusinessCardItem">
import { listCardItem, getCardItem, delCardItem, addCardItem, updateCardItem } from "@/api/business/cardItem"
import { searchProduct } from "@/api/wms/product"
import { generateProductCode } from "@/utils/pinyin"

const { proxy } = getCurrentInstance()
const { sys_normal_disable, biz_card_item_category, biz_product_category, biz_product_unit, biz_product_spec } = useDict("sys_normal_disable", "biz_card_item_category", "biz_product_category", "biz_product_unit", "biz_product_spec")

const cardItemList = ref([])
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const title = ref("")
const productSelectOpen = ref(false)
const productKeyword = ref("")
const productSelectList = ref([])
const selectedProducts = ref([])
const productIds = ref([])
const productMultiple = ref(true)
let debounceTimer = null

const data = reactive({
  form: {},
  queryParams: { pageNum: 1, pageSize: 10, cardItemName: undefined, cardItemCode: undefined, category: undefined, status: undefined },
  rules: {
    cardItemName: [{ required: true, message: "卡项名称不能为空", trigger: "blur" }],
    cardItemCode: [{ required: true, message: "卡项编码不能为空", trigger: "blur" }],
    category: [{ required: true, message: "类别不能为空", trigger: "change" }],
    defaultQuantity: [{ required: true, message: "默认次数不能为空", trigger: "blur" }],
    suggestedPrice: [{ required: true, message: "建议成交价不能为空", trigger: "blur" }]
  }
})
const { queryParams, form, rules } = toRefs(data)

function getUnitLabel(value) { if (!value) return ''; const dict = biz_product_unit.value?.find(d => d.value === value); return dict ? dict.label : '' }
function getSpecLabel(value) { if (!value) return ''; const dict = biz_product_spec.value?.find(d => d.value === value); return dict ? dict.label : '' }

function calcSuggestedPrice() {
  const products = form.value.cardItemProducts || []
  let total = 0
  products.forEach(p => {
    const price = p.unitType === '1' ? (p.salePrice || 0) : (p.salePriceSpec || 0)
    total += price * (p.quantity || 0)
  })
  form.value.suggestedPrice = Math.round(total * 100) / 100
  calcDefaultUnitPrice()
}

function calcDefaultUnitPrice() {
  if (form.value.defaultQuantity && form.value.defaultQuantity > 0 && form.value.suggestedPrice) {
    form.value.defaultUnitPrice = Math.round((form.value.suggestedPrice / form.value.defaultQuantity) * 100) / 100
  }
}

function getList() {
  loading.value = true
  listCardItem(queryParams.value).then(response => {
    cardItemList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

function handleQuery() { queryParams.value.pageNum = 1; getList() }
function resetQuery() { proxy.resetForm("queryRef"); handleQuery() }
function handleSelectionChange(selection) { ids.value = selection.map(item => item.cardItemId); single.value = selection.length !== 1; multiple.value = !selection.length }

function reset() {
  form.value = { cardItemId: undefined, cardItemName: undefined, cardItemCode: undefined, category: undefined, defaultQuantity: 1, suggestedPrice: 0, defaultUnitPrice: 0, status: "0", remark: undefined, cardItemProducts: [] }
  proxy.resetForm("cardItemRef")
}

function handleAdd() { reset(); open.value = true; title.value = "添加卡项" }

function onCardItemNameBlur() {
  if (!form.value.cardItemCode && form.value.cardItemName) {
    form.value.cardItemCode = generateProductCode(form.value.cardItemName)
  }
}

function handleUpdate(row) {
  reset()
  const cardItemId = row.cardItemId || ids.value
  getCardItem(cardItemId).then(response => {
    form.value = response.data
    if (form.value.products && form.value.products.length > 0) {
      form.value.cardItemProducts = form.value.products.map(p => ({
        id: p.id,
        cardItemId: p.cardItemId,
        productId: p.productId,
        productName: p.product ? p.product.productName : '',
        productCode: p.product ? p.product.productCode : '',
        unitType: p.unitType || '1',
        packQty: p.packQty || (p.product ? p.product.packQty : 1) || 1,
        unitLabel: p.product ? getUnitLabel(p.product.unit) : '',
        specLabel: p.product ? getSpecLabel(p.product.spec) : '',
        salePrice: p.product ? p.product.salePrice || 0 : 0,
        salePriceSpec: p.product ? p.product.salePriceSpec || 0 : 0,
        quantity: p.quantity || 1,
        spec: p.unitType === '2' ? (p.product ? getSpecLabel(p.product.spec) : '') : (p.product ? getUnitLabel(p.product.unit) : '')
      }))
    } else {
      form.value.cardItemProducts = []
    }
    open.value = true; title.value = "修改卡项"
  })
}

function submitForm() {
  proxy.$refs["cardItemRef"].validate(valid => {
    if (valid) {
      const submitData = { ...form.value }
      submitData.products = (form.value.cardItemProducts || []).map(p => ({
        product_id: p.productId,
        unit_type: p.unitType,
        pack_qty: p.packQty,
        quantity: p.quantity || 1,
        remark: p.remark || null
      }))
      delete submitData.cardItemProducts
      if (form.value.cardItemId != undefined) {
        updateCardItem(submitData).then(() => { proxy.$modal.msgSuccess("修改成功"); open.value = false; getList() })
      } else {
        addCardItem(submitData).then(() => { proxy.$modal.msgSuccess("新增成功"); open.value = false; getList() })
      }
    }
  })
}

function handleExport() {
  proxy.download("business/cardItem/export", {
    ...queryParams.value,
  }, `cardItem_${new Date().getTime()}.xlsx`)
}

function handleDelete(row) {
  const cardItemIds = row.cardItemId || ids.value
  proxy.$modal.confirm('是否确认删除？').then(() => delCardItem(cardItemIds)).then(() => { getList(); proxy.$modal.msgSuccess("删除成功") }).catch(() => {})
}

function handleStatusChange(row, val) {
  const text = val === '0' ? '启用' : '停用'
  proxy.$modal.confirm('确认要"' + text + '""' + row.cardItemName + '"吗？').then(() => {
    return updateCardItem({ cardItemId: row.cardItemId, status: val })
  }).then(() => { proxy.$modal.msgSuccess(text + "成功") }).catch(() => {
    row.status = val === '0' ? '1' : '0'
  })
}

function cancel() { open.value = false; reset() }

function handleAddProduct() {
  productKeyword.value = ""
  productSelectList.value = []
  selectedProducts.value = []
  productSelectOpen.value = true
  searchProduct('').then(res => {
    productSelectList.value = res.data || []
  })
}

watch(productKeyword, (val) => {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => {
    searchProduct(val).then(res => {
      productSelectList.value = res.data || []
    })
  }, 500)
})

onBeforeUnmount(() => {
  clearTimeout(debounceTimer)
})

function handleProductSelectChange(selection) {
  selectedProducts.value = selection
}

function confirmProductSelect() {
  const existingIds = (form.value.cardItemProducts || []).map(p => p.productId)
  selectedProducts.value.forEach(product => {
    if (!existingIds.includes(product.productId)) {
      form.value.cardItemProducts.push({
        productId: product.productId,
        productName: product.productName,
        productCode: product.productCode,
        unitType: '1',
        packQty: product.packQty || 1,
        unitLabel: getUnitLabel(product.unit),
        specLabel: getSpecLabel(product.spec),
        salePrice: product.salePrice || 0,
        salePriceSpec: product.salePriceSpec || 0,
        quantity: 1,
        spec: getUnitLabel(product.unit),
        _prevUnitType: '1'
      })
    }
  })
  productSelectOpen.value = false
  calcSuggestedPrice()
}

function onProductUnitTypeChange(index) {
  const row = form.value.cardItemProducts[index]
  const packQty = row.packQty || 1
  if (row.unitType === '1') {
    // 从副单位切回主单位：数量除以packQty
    if (row._prevUnitType === '2' && packQty > 1) {
      row.quantity = Math.round(row.quantity / packQty)
    }
    row.spec = row.unitLabel || ''
  } else {
    // 从主单位切到副单位：数量乘以packQty
    if (row._prevUnitType === '1' && packQty > 1) {
      row.quantity = row.quantity * packQty
    }
    row.spec = row.specLabel || ''
  }
  row._prevUnitType = row.unitType
  calcSuggestedPrice()
}

function handleProductSelectionChange(selection) {
  productIds.value = selection.map(item => item.productId)
  productMultiple.value = !selection.length
}

function handleDeleteProduct() {
  form.value.cardItemProducts = form.value.cardItemProducts.filter(item => !productIds.value.includes(item.productId))
  calcSuggestedPrice()
}

getList()
</script>
