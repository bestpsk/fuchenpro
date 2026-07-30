<template>
  <div class="app-container">
    <WarehouseSelector @change="handleWarehouseChange" />
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="出库单号" prop="stockOutNo">
        <el-input v-model="queryParams.stockOutNo" placeholder="请输入出库单号" clearable style="width: 160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="出库类型" prop="stockOutType">
        <el-select v-model="queryParams.stockOutType" placeholder="请选择" clearable style="width: 140px">
          <el-option v-for="dict in biz_stock_out_type" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择" clearable style="width: 120px">
          <el-option label="待确认" value="0" />
          <el-option label="已确认(待发货)" value="1" />
          <el-option label="已发货" value="2" />
          <el-option label="已完成" value="3" />
        </el-select>
      </el-form-item>
      <el-form-item label="出库日期">
        <el-date-picker v-model="dateRange" type="daterange" range-separator="-" start-placeholder="开始" end-placeholder="结束" value-format="YYYY-MM-DD" style="width: 240px" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['wms:stockOut:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete" v-hasPermi="['wms:stockOut:remove']">删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="Download" @click="handleExport">导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="stockOutList" @selection-change="handleSelectionChange" style="width: 100%">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="出库单号" prop="stockOutNo" min-width="140" />
      <el-table-column label="出库类型" prop="stockOutType" min-width="90" align="center">
        <template #default="scope">
          <dict-tag :options="biz_stock_out_type" :value="scope.row.stockOutType" />
        </template>
      </el-table-column>
      <el-table-column label="仓库" min-width="90" align="center">
        <template #default="scope">
          <span>{{ scope.row.warehouseName || '-' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="出库企业" prop="enterpriseName" min-width="90" show-overflow-tooltip />
      <el-table-column label="对接员工" prop="contactEmployeeName" min-width="80" align="center" />
      <el-table-column label="出库员工" prop="responsibleName" min-width="80" align="center" />
      <el-table-column label="总数量" min-width="160" align="center">
        <template #default="scope">
          {{ formatQuantity(scope.row) }}
        </template>
      </el-table-column>
      <el-table-column label="总金额" prop="totalAmount" min-width="100" align="right" />
      <el-table-column label="出库日期" prop="stockOutDate" min-width="100" align="center" />
      <el-table-column label="状态" prop="status" min-width="110" align="center">
        <template #default="scope">
          <el-tag :type="statusTagType(scope.row.status)">{{ statusLabel(scope.row.status) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="来源标识" min-width="100" align="center">
        <template #default="scope">
          <span v-if="scope.row.prepareId">备货出库</span>
          <span v-else-if="scope.row.planId">方案出货</span>
          <span v-else>手动创建</span>
        </template>
      </el-table-column>
      <el-table-column label="发货方式" min-width="90" align="center">
        <template #default="scope">
          {{ shipTypeLabel(scope.row.shipType) }}
        </template>
      </el-table-column>
      <el-table-column label="物流信息" min-width="160" align="center">
        <template #default="scope">
          <span v-if="scope.row.shipType == 2 && scope.row.logisticsCompany">{{ scope.row.logisticsCompany }} {{ scope.row.logisticsNo }}</span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" min-width="260" align="center">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleView(scope.row)">查看</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-if="scope.row.status === '0'" v-hasPermi="['wms:stockOut:edit']">修改</el-button>
          <el-button link type="danger" icon="Delete" @click="handleDelete(scope.row)" v-if="scope.row.status === '0'" v-hasPermi="['wms:stockOut:remove']">删除</el-button>
          <el-button link type="success" icon="Check" @click="handleConfirm(scope.row)" v-if="scope.row.status === '0'" v-hasPermi="['wms:stockOut:confirm']">确认出库</el-button>
          <el-button link type="warning" icon="RefreshLeft" @click="handleCancelConfirm(scope.row)" v-if="scope.row.status === '1'" v-hasPermi="['wms:stockOut:confirm']">取消确认</el-button>
          <el-button link type="primary" icon="Van" @click="handleShip(scope.row)" v-if="scope.row.status === '1'" v-hasPermi="['wms:stockOut:ship']">发货</el-button>
          <el-button link type="success" icon="CircleCheck" @click="handleConfirmReceipt(scope.row)" v-if="scope.row.status === '2'" v-hasPermi="['wms:stockOut:receipt']">确认收货</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="dialogTitle" v-model="open" width="80%" append-to-body>
      <el-form ref="stockOutRef" :model="form" :rules="rules" label-width="100px">
        <el-row :gutter="0">
          <el-col :span="6">
            <el-form-item label="出库类型" prop="stockOutType">
              <el-select v-model="form.stockOutType" placeholder="请选择" :disabled="isView" style="width: 100%">
                <el-option v-for="dict in biz_stock_out_type" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="仓库" prop="warehouseId">
              <el-select v-model="form.warehouseId" placeholder="请选择仓库" :disabled="isView" style="width: 100%">
                <el-option v-for="w in warehouseList" :key="w.warehouseId" :label="w.warehouseName" :value="w.warehouseId" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="对象类型" prop="outTargetType">
              <el-select v-model="form.outTargetType" placeholder="请选择" :disabled="isView" style="width: 100%" @change="onTargetTypeChange">
                <el-option label="企业出库" value="1" />
                <el-option label="员工领用" value="2" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="6" v-if="form.outTargetType === '1'">
            <el-form-item label="出库企业" prop="enterpriseId">
              <el-select v-if="!isView" v-model="form.enterpriseId" placeholder="搜索企业" filterable remote :remote-method="searchEnterpriseList" :loading="enterpriseLoading" style="width: 100%" @change="onEnterpriseSelect">
                <el-option v-for="item in enterpriseOptions" :key="item.enterpriseId" :label="item.enterpriseName" :value="item.enterpriseId" />
              </el-select>
              <el-input v-else :model-value="form.enterpriseName || '-'" disabled />
            </el-form-item>
          </el-col>
          <el-col :span="6" v-if="form.outTargetType === '2'">
            <el-form-item label="领用员工" prop="responsibleId">
              <el-select v-if="!isView" v-model="form.responsibleId" placeholder="搜索员工" filterable remote :remote-method="searchEmployeeList" :loading="employeeLoading" style="width: 100%" @change="onEmployeeSelect">
                <el-option v-for="item in employeeOptions" :key="item.userId" :label="item.userName + (item.deptName ? '(' + item.deptName + ')' : '')" :value="item.userId" />
              </el-select>
              <el-input v-else :model-value="form.responsibleName || '-'" disabled />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="0">
          <el-col :span="6" v-if="form.outTargetType === '1'">
            <el-form-item label="对接员工">
              <el-select v-if="!isView" v-model="form.contactEmployeeId" placeholder="选择对接员工(可选)" filterable remote :remote-method="searchEmployeeList" :loading="employeeLoading" style="width: 100%" @change="onContactEmployeeSelect">
                <el-option v-for="item in employeeOptions" :key="item.userId" :label="item.userName + (item.deptName ? '(' + item.deptName + ')' : '')" :value="item.userId" />
              </el-select>
              <el-input v-else :model-value="form.contactEmployeeName || '-'" disabled />
            </el-form-item>
          </el-col>
          <el-col :span="6" v-if="form.outTargetType === '2'">
            <el-form-item label="目标企业">
              <el-select v-if="!isView" v-model="form.enterpriseId" placeholder="搜索企业(可选)" filterable remote :remote-method="searchEnterpriseList" :loading="enterpriseLoading" style="width: 100%" @change="onEnterpriseSelect">
                <el-option v-for="item in enterpriseOptions" :key="item.enterpriseId" :label="item.enterpriseName" :value="item.enterpriseId" />
              </el-select>
              <el-input v-else :model-value="form.enterpriseName || '-'" disabled />
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="发货方式" prop="shipType">
              <el-select v-if="!isView" v-model="form.shipType" placeholder="请选择" style="width: 100%">
                <el-option label="无需发货" value="0" />
                <el-option label="自提" value="1" />
                <el-option label="物流" value="2" />
              </el-select>
              <el-input v-else :model-value="shipTypeLabel(form.shipType)" disabled />
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="出库日期" prop="stockOutDate">
              <el-date-picker v-model="form.stockOutDate" type="date" value-format="YYYY-MM-DD" placeholder="选择日期" :disabled="isView" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="备注" prop="remark">
              <el-input v-model="form.remark" placeholder="请输入备注" :disabled="isView" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row v-if="isView && form.shipType == 2 && (form.logisticsCompany || form.logisticsNo || form.shipmentDate || form.receiptDate)">
          <el-col :span="6">
            <el-form-item label="物流公司">
              <el-input :model-value="form.logisticsCompany || '-'" disabled />
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="物流单号">
              <el-input :model-value="form.logisticsNo || '-'" disabled />
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="发货日期">
              <el-input :model-value="form.shipmentDate || '-'" disabled />
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="收货日期">
              <el-input :model-value="form.receiptDate || '-'" disabled />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row v-if="isView && form.shipmentImages" :gutter="20" style="margin-top: 10px">
          <el-col :span="24">
            <el-form-item label="发货图片">
              <el-image v-for="(img, idx) in parseImages(form.shipmentImages)" :key="idx" :src="img" :preview-src-list="parseImages(form.shipmentImages)" style="width: 100px; height: 100px; margin-right: 8px" fit="cover" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-divider content-position="left">出库明细</el-divider>
        <el-table :data="form.items" border style="width: 100%" v-if="!isView || form.items?.length">
          <el-table-column label="货品" min-width="150" align="center" header-align="center">
            <template #default="scope">
              <el-select v-if="!isView" v-model="scope.row.productId" placeholder="搜索货品" filterable remote :remote-method="searchProductList" :loading="productLoading" @change="onProductSelect(scope.$index)" style="width: 100%">
                <el-option v-for="item in productOptions" :key="item.productId" :label="item.productName + '(' + item.productCode + ')'" :value="item.productId" />
              </el-select>
              <span v-else>{{ scope.row.productName }}</span>
            </template>
          </el-table-column>
          <el-table-column label="供货商" min-width="100" align="center" header-align="center">
            <template #default="scope">
              <span>{{ scope.row.supplierName || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column label="单位类型" min-width="90" align="center" header-align="center">
            <template #default="scope">
              <el-select v-if="!isView" v-model="scope.row.unitType" placeholder="选择" @change="onUnitTypeChange(scope.$index)" style="width: 100%">
                <el-option label="主单位(整)" value="1" />
                <el-option label="副单位(拆)" value="2" />
              </el-select>
              <span v-else>{{ scope.row.unitType === '1' ? '主单位(整)' : '副单位(拆)' }}</span>
            </template>
          </el-table-column>
          <el-table-column label="换算/库存" min-width="100" align="center" header-align="center">
            <template #default="scope">
              <div v-if="scope.row.packQty && scope.row.packQty > 1" style="color: #909399; font-size: 12px;">
                <div>1{{ getUnitLabel(scope.row.unit) }}={{ scope.row.packQty }}{{ getSpecLabel(scope.row.spec) }}</div>
                <div v-if="scope.row.inventoryQty !== undefined" style="color: #67c23a;">库存: {{ scope.row.inventoryQty }}{{ getSpecLabel(scope.row.spec) }}</div>
              </div>
              <div v-else-if="scope.row.inventoryQty !== undefined" style="color: #67c23a; font-size: 12px;">库存: {{ scope.row.inventoryQty }}{{ getSpecLabel(scope.row.spec) }}</div>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="数量" min-width="100" align="center" header-align="center">
            <template #default="scope">
              <el-input-number v-if="!isView" v-model="scope.row.quantity" :min="1" @change="calcAmount(scope.$index)" style="width: 100%" />
              <span v-else>{{ scope.row.originalQuantity || scope.row.quantity || 0 }}</span>
            </template>
          </el-table-column>
          <el-table-column label="规格" min-width="60" align="center" header-align="center">
            <template #default="scope">
              <span>{{ scope.row.unitType === '1' ? getUnitLabel(scope.row.unit) : getSpecLabel(scope.row.spec) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="出货单价" min-width="110" align="center" header-align="center">
            <template #default="scope">
              <el-input-number v-if="!isView" v-model="scope.row.salePrice" :precision="2" :min="0" @change="calcAmount(scope.$index)" style="width: 100%" />
              <span v-else>{{ formatItemPrice(scope.row) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="金额" min-width="80" align="center" header-align="center">
            <template #default="scope"><span>{{ scope.row.amount }}</span></template>
          </el-table-column>
          <el-table-column label="操作" width="60" align="center" header-align="center" v-if="!isView">
            <template #default="scope"><el-button link type="danger" icon="Delete" @click="removeItem(scope.$index)" /></template>
          </el-table-column>
        </el-table>
        <el-button v-if="!isView" type="primary" link icon="Plus" @click="addItem" style="margin-top: 10px">添加明细</el-button>
      </el-form>
      <template #footer v-if="!isView">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
      <template #footer v-else>
        <el-button type="primary" icon="Printer" @click="handlePrint">打 印</el-button>
        <el-button @click="cancel">关 闭</el-button>
      </template>
    </el-dialog>

    <el-dialog title="发货" v-model="shipDialogOpen" width="600px" append-to-body>
      <el-form ref="shipFormRef" :model="shipForm" :rules="shipRules" label-width="100px">
        <el-form-item label="发货方式" prop="shipType">
          <el-radio-group v-model="shipForm.shipType">
            <el-radio label="1">自提(无需物流)</el-radio>
            <el-radio label="2">物流发货</el-radio>
          </el-radio-group>
        </el-form-item>
        <template v-if="shipForm.shipType === '2'">
          <el-form-item label="物流公司" prop="logisticsCompany">
            <el-select v-model="shipForm.logisticsCompany" placeholder="请选择物流公司" filterable style="width: 100%">
              <el-option v-for="item in logistics_company" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </el-form-item>
          <el-form-item label="物流单号" prop="logisticsNo">
            <el-input v-model="shipForm.logisticsNo" placeholder="请输入物流单号" />
          </el-form-item>
        </template>
        <el-form-item label="发货图片">
          <el-upload :action="uploadUrl" list-type="picture-card" :file-list="shipFileList" :headers="uploadHeaders" :on-success="handleShipUploadSuccess" :on-remove="handleShipUploadRemove" :on-preview="handlePreview" accept="image/*">
            <el-icon><Plus /></el-icon>
          </el-upload>
        </el-form-item>
        <el-form-item label="发货备注">
          <el-input v-model="shipForm.remark" type="textarea" :rows="3" placeholder="请输入发货备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitShip">确 定</el-button>
        <el-button @click="shipDialogOpen = false">取 消</el-button>
      </template>
    </el-dialog>

    <el-dialog title="打印预览" v-model="printPreview" width="900px" append-to-body>
      <div class="print-preview-content" id="print-content">
        <div class="print-container">
          <div class="print-header"><h1>出 库 单</h1></div>
          <div class="print-info">
            <div class="info-row">
              <div class="info-item"><span>出库单号：</span>{{ form.stockOutNo }}</div>
              <div class="info-item"><span>出库日期：</span>{{ form.stockOutDate }}</div>
            </div>
            <div class="info-row">
              <div class="info-item"><span>出库类型：</span>{{ getDictLabel(biz_stock_out_type, form.stockOutType) }}</div>
              <div class="info-item"><span>对象类型：</span>{{ form.outTargetType === '1' ? '企业出库' : '员工领用' }}</div>
            </div>
            <div class="info-row">
              <div class="info-item" v-if="form.outTargetType === '1'"><span>出库企业：</span>{{ form.enterpriseName || '-' }}</div>
              <div class="info-item" v-else><span>领用员工：</span>{{ form.responsibleName || '-' }}</div>
              <div class="info-item"><span>对接员工：</span>{{ form.contactEmployeeName || '-' }}</div>
            </div>
            <div class="info-row" v-if="form.remark">
              <div class="info-item full"><span>备注：</span>{{ form.remark }}</div>
            </div>
          </div>
          <table class="print-table">
            <thead><tr><th width="40">序号</th><th width="22%">货品名称</th><th width="16%">换算</th><th width="12%">数量</th><th width="10%">规格</th><th width="14%">单价</th><th width="14%">金额</th></tr></thead>
            <tbody>
              <tr v-for="(item, index) in form.items" :key="index">
                <td align="center">{{ index + 1 }}</td>
                <td>{{ item.productName }}</td>
                <td align="center">{{ item.packQty > 1 ? '1' + getUnitLabel(item.unit) + '=' + item.packQty + getSpecLabel(item.spec) : '-' }}</td>
                <td align="center">{{ item.originalQuantity || item.quantity || 0 }}</td>
                <td align="center">{{ item.unitType === '1' ? getUnitLabel(item.unit) : getSpecLabel(item.spec) }}</td>
                <td align="right">{{ formatItemPrice(item) }}</td>
                <td align="right">{{ item.amount }}</td>
              </tr>
            </tbody>
            <tfoot><tr>
              <td colspan="6" align="right"><strong>合 计：{{ formatTotalQuantity(form) }}</strong></td>
              <td align="right"><strong>{{ form.totalAmount ? Number(form.totalAmount).toFixed(2) : '0.00' }}</strong></td>
            </tr></tfoot>
          </table>
          <div class="print-footer">
            <div class="footer-row">
              <div class="footer-item"><span>制单人：</span>{{ form.createBy || '' }}</div>
              <div class="footer-item"><span>经手人：</span></div>
              <div class="footer-item"><span>日期：</span>{{ form.stockOutDate }}</div>
            </div>
            <div class="footer-row sign-row">
              <div class="footer-item"><span>收货签字：</span></div>
              <div class="footer-item"><span>领用人签字：</span></div>
            </div>
          </div>
        </div>
      </div>
      <template #footer>
        <el-button type="primary" icon="Printer" @click="confirmPrint">确认打印</el-button>
        <el-button @click="printPreview = false">取消</el-button>
      </template>
    </el-dialog>

    <el-dialog title="图片预览" v-model="previewVisible" width="600px" append-to-body>
      <img :src="previewUrl" style="width: 100%" />
    </el-dialog>

    <!-- 出库仓库选择对话框 -->
    <el-dialog title="选择出库仓库" v-model="confirmWarehouseDialogVisible" width="400px" append-to-body>
      <el-form label-width="80px">
        <el-form-item label="出库仓库">
          <el-select v-model="confirmWarehouseId" placeholder="请选择仓库" style="width: 100%">
            <el-option v-for="w in confirmWarehouseOptions" :key="w.warehouseId" :label="w.warehouseName" :value="w.warehouseId" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="confirmWarehouseDialogVisible = false">取 消</el-button>
        <el-button type="primary" @click="confirmWithWarehouse">确认出库</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="WmsStockOut">
import { listStockOut, getStockOut, delStockOut, addStockOut, updateStockOut, confirmStockOut, cancelConfirmStockOut, shipStockOut, confirmReceiptStockOut } from "@/api/wms/stockOut"
import { ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { getToken } from '@/utils/auth'
import { searchProduct } from "@/api/wms/product"
import { searchEnterprise } from "@/api/business/enterprise"
import { searchEmployee } from "@/api/business/employeeConfig"
import { listWarehouse } from '@/api/wms/warehouse'
import WarehouseSelector from '@/components/WarehouseSelector/index.vue'
import { useWarehouse } from '@/composables/useWarehouse'

const { proxy } = getCurrentInstance()
const { currentWarehouseId, warehouseList, loadWarehouses } = useWarehouse()
const { biz_stock_out_type, biz_product_unit, biz_product_spec, logistics_company } = useDict("biz_stock_out_type", "biz_product_unit", "biz_product_spec", "logistics_company")

const stockOutList = ref([])
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const multiple = ref(true)
const total = ref(0)
const dialogTitle = ref("")
const isView = ref(false)
const printPreview = ref(false)
const dateRange = ref([])
const enterpriseOptions = ref([])
const enterpriseLoading = ref(false)
const employeeOptions = ref([])
const employeeLoading = ref(false)
const productOptions = ref([])
const productLoading = ref(false)
const shipDialogOpen = ref(false)
const currentShipRow = ref(null)
const shipFormRef = ref(null)
const shipFileList = ref([])
const previewVisible = ref(false)
const previewUrl = ref('')
const confirmWarehouseDialogVisible = ref(false)
const confirmWarehouseId = ref(null)
const confirmWarehouseOptions = ref([])
const confirmingStockOutId = ref(null)

const uploadUrl = import.meta.env.VITE_APP_BASE_API + '/common/upload'
const uploadHeaders = { Authorization: 'Bearer ' + getToken() }

const shipForm = ref({ shipType: '2', logisticsCompany: '', logisticsNo: '', shipmentImages: '', remark: '' })
const shipRules = {
  shipType: [{ required: true, message: "请选择发货方式", trigger: "change" }],
  logisticsCompany: [{ required: true, message: "请选择物流公司", trigger: "change" }],
  logisticsNo: [{ required: true, message: "请输入物流单号", trigger: "blur" }]
}

const data = reactive({
  form: { items: [] },
  queryParams: { pageNum: 1, pageSize: 10, stockOutNo: undefined, stockOutType: undefined, status: undefined, warehouseId: undefined },
  rules: {
    stockOutType: [{ required: true, message: "出库类型不能为空", trigger: "change" }],
    stockOutDate: [{ required: true, message: "出库日期不能为空", trigger: "change" }],
    outTargetType: [{ required: true, message: "对象类型不能为空", trigger: "change" }]
  }
})
const { queryParams, form, rules } = toRefs(data)

function statusLabel(status) {
  const map = { '0': '待确认', '1': '已确认(待发货)', '2': '已发货', '3': '已完成' }
  return map[status] || '未知'
}
function statusTagType(status) {
  const map = { '0': 'info', '1': 'warning', '2': '', '3': 'success' }
  return map[status] || 'info'
}
function shipTypeLabel(shipType) {
  const map = { '0': '无需发货', '1': '自提', '2': '物流' }
  return map[shipType] || '-'
}

function getUnitLabel(value) { if (!value) return ''; const dict = biz_product_unit.value?.find(d => d.value === String(value)); return dict ? dict.label : '' }
function getSpecLabel(value) { if (!value) return ''; const dict = biz_product_spec.value?.find(d => d.value === String(value)); return dict ? dict.label : '' }

function formatQuantity(row) {
  const items = row.items || []

  if (items.length === 0) {
    return row.totalQuantity || 0
  }

  if (items.length === 1) {
    const item = items[0]
    const packQty = row.display_pack_qty || item.packQty || 1
    const unitLabel = getUnitLabel(row.display_unit || item.unit)
    const totalQty = row.totalQuantity || 0

    if (packQty > 1 && unitLabel) {
      const mainQty = totalQty / packQty
      const mainQtyStr = Number.isInteger(mainQty) ? mainQty : mainQty.toFixed(1).replace(/\.0$/, '')
      return mainQtyStr + unitLabel
    } else if (unitLabel) {
      return totalQty + unitLabel
    } else {
      return totalQty
    }
  }

  const firstUnit = items[0].unit
  const isSameUnit = items.every(item => item.unit === firstUnit)

  if (isSameUnit) {
    const packQty = items[0].packQty || 1
    const unitLabel = getUnitLabel(firstUnit)
    const totalQty = row.totalQuantity || 0

    if (packQty > 1 && unitLabel) {
      const mainQty = totalQty / packQty
      const mainQtyStr = Number.isInteger(mainQty) ? mainQty : mainQty.toFixed(1).replace(/\.0$/, '')
      return mainQtyStr + unitLabel
    } else {
      return totalQty + (unitLabel || '')
    }
  } else {
    return items.length + '种'
  }
}

function formatItemQuantity(item) {
  const packQty = item.packQty || 1
  const unitLabel = getUnitLabel(item.unit)
  const specLabel = getSpecLabel(item.spec)
  const qty = item.quantity || 0
  if (packQty > 1 && specLabel) {
    const mainQty = qty / packQty
    const mainQtyStr = Number.isInteger(mainQty) ? mainQty : mainQty.toFixed(1).replace(/\.0$/, '')
    return mainQtyStr + unitLabel + '（' + qty + specLabel + '）'
  } else if (unitLabel) {
    return qty + unitLabel
  } else {
    return qty
  }
}

function formatItemQuantityForView(item) {
  const unitLabel = getUnitLabel(item.unit)
  const specLabel = getSpecLabel(item.spec)
  if (item.unitType === '1') {
    return (item.originalQuantity || item.quantity || 0) + unitLabel
  } else {
    return (item.originalQuantity || item.quantity || 0) + specLabel
  }
}

function formatItemPrice(item) {
  const unitLabel = getUnitLabel(item.unit)
  const specLabel = getSpecLabel(item.spec)
  const packQty = item.packQty || 1
  if (item.unitType === '1') {
    let price = item.salePrice || 0
    if (packQty > 1) {
      price = parseFloat((price * packQty).toFixed(2))
    }
    return price + '/' + (unitLabel || '')
  } else {
    return item.salePrice + '/' + (specLabel || '')
  }
}

function formatTotalQuantity(formData) {
  const firstItem = formData.items?.[0]
  if (!firstItem) return formData.totalQuantity || 0
  const packQty = firstItem.packQty || 1
  const unitLabel = getUnitLabel(firstItem.unit)
  const specLabel = getSpecLabel(firstItem.spec)
  const totalQty = formData.totalQuantity || 0
  if (packQty > 1 && specLabel) {
    const mainQty = totalQty / packQty
    const mainQtyStr = Number.isInteger(mainQty) ? mainQty : mainQty.toFixed(1).replace(/\.0$/, '')
    return mainQtyStr + unitLabel + '（' + totalQty + specLabel + '）'
  } else if (unitLabel) {
    return totalQty + unitLabel
  } else {
    return totalQty
  }
}

function getList() {
  loading.value = true
  const params = { ...queryParams.value }
  if (dateRange.value && dateRange.value.length === 2) { params.stockOutDateStart = dateRange.value[0]; params.stockOutDateEnd = dateRange.value[1] }
  if (currentWarehouseId.value) params.warehouseId = currentWarehouseId.value
  listStockOut(params).then(async response => {
    const rows = response.rows || []
    if (rows.length > 0) {
      await Promise.all(rows.map(row => {
        return getStockOut(row.stockOutId).then(res => {
          const data = res.data
          if (data && data.items && data.items.length > 0) {
            const firstItem = data.items[0]
            row.display_pack_qty = firstItem.packQty || 1
            row.display_unit = firstItem.unit
            row.display_spec = firstItem.spec
          }
        }).catch(() => {})
      }))
    }
    stockOutList.value = rows
    total.value = response.total
    loading.value = false
  })
}
function handleQuery() { queryParams.value.pageNum = 1; getList() }
function resetQuery() { dateRange.value = []; proxy.resetForm("queryRef"); handleQuery() }
function handleSelectionChange(selection) { ids.value = selection.map(item => item.stockOutId); multiple.value = !selection.length }

function handleWarehouseChange(warehouseId) {
  queryParams.value.warehouseId = warehouseId
  handleQuery()
}

function reset() {
  form.value = { stockOutId: undefined, stockOutType: "1", outTargetType: "1", shipType: "2", warehouseId: currentWarehouseId.value, enterpriseId: undefined, enterpriseName: undefined, contactEmployeeId: undefined, contactEmployeeName: undefined, responsibleId: undefined, responsibleName: undefined, stockOutDate: new Date().toISOString().slice(0, 10), remark: undefined, items: [] }
  enterpriseOptions.value = []; employeeOptions.value = []; productOptions.value = []
  proxy.resetForm("stockOutRef")
}

function handleAdd() { reset(); isView.value = false; dialogTitle.value = "新增出库单"; open.value = true }
function handleUpdate(row) { reset(); getStockOut(row.stockOutId).then(response => { const data = response.data || response; form.value = data; if (!form.value.items) form.value.items = []; form.value.shipType = String(form.value.shipType ?? '2'); form.value.items.forEach(item => { if (item.originalQuantity != null) { item.quantity = item.originalQuantity } if (item.unitType === '1' && item.packQty > 1) { item._mainPrice = Math.round(parseFloat(item.salePrice) * item.packQty * 100) / 100; item.salePrice = item._mainPrice; } else { item._mainPrice = parseFloat(item.salePrice) || 0; } }); if (data.enterpriseId && data.enterpriseName) { enterpriseOptions.value = [{ enterpriseId: data.enterpriseId, enterpriseName: data.enterpriseName }] } if (data.contactEmployeeId && data.contactEmployeeName) { employeeOptions.value = [{ userId: data.contactEmployeeId, userName: data.contactEmployeeName }] } if (data.responsibleId && data.responsibleName) { if (!employeeOptions.value.find(e => e.userId === data.responsibleId)) { employeeOptions.value.push({ userId: data.responsibleId, userName: data.responsibleName }) } } form.value.items.forEach(item => { if (item.productId && item.productName && !productOptions.value.find(p => p.productId === item.productId)) { productOptions.value.push({ productId: item.productId, productName: item.productName, productCode: item.productCode || '' }) } }); isView.value = false; dialogTitle.value = "修改出库单"; open.value = true }) }
function handleView(row) { reset(); getStockOut(row.stockOutId).then(response => { const data = response.data || response; form.value = data; if (!form.value.items) form.value.items = []; isView.value = true; dialogTitle.value = "查看出库单"; open.value = true }) }

function handleConfirm(row) {
  if (!row.warehouseId) {
    // 出库单未指定仓库，弹出仓库选择
    confirmingStockOutId.value = row.stockOutId
    confirmWarehouseId.value = null
    listWarehouse({ status: '0' }).then(res => {
      confirmWarehouseOptions.value = res.rows || res.data || []
    }).catch(() => { confirmWarehouseOptions.value = [] })
    confirmWarehouseDialogVisible.value = true
    return
  }
  proxy.$modal.confirm('确认出库后将减少库存数量，是否继续？').then(() => {
    return confirmStockOut(row.stockOutId)
  }).then(() => {
    proxy.$modal.msgSuccess("出库确认成功")
    getList()
  }).catch(() => {})
}

function confirmWithWarehouse() {
  if (!confirmWarehouseId.value) {
    proxy.$modal.msgWarning('请选择出库仓库')
    return
  }
  confirmWarehouseDialogVisible.value = false
  proxy.$modal.confirm('确认出库后将减少库存数量，是否继续？').then(() => {
    return confirmStockOut(confirmingStockOutId.value, confirmWarehouseId.value)
  }).then(() => {
    proxy.$modal.msgSuccess("出库确认成功")
    getList()
  }).catch(() => {})
}

function handleCancelConfirm(row) {
  proxy.$modal.confirm('确定要取消确认该出库单吗？取消后将恢复库存！').then(() => {
    return cancelConfirmStockOut(row.stockOutId)
  }).then(() => {
    proxy.$modal.msgSuccess('已取消确认')
    getList()
  }).catch(() => {})
}

function handleShip(row) {
  currentShipRow.value = row
  shipForm.value = { shipType: '2', logisticsCompany: '', logisticsNo: '', shipmentImages: '', remark: '' }
  shipFileList.value = []
  shipDialogOpen.value = true
  nextTick(() => { shipFormRef.value?.clearValidate() })
}

function handleShipUploadSuccess(response, file, fileList) {
  if (response.code === 200) {
    updateShipImages(fileList)
  }
}

function handleShipUploadRemove(file, fileList) {
  updateShipImages(fileList)
}

function updateShipImages(list) {
  const urls = list.map(f => {
    if (f.response && f.response.url) return f.response.url
    if (f.response && f.response.data && f.response.data.url) return f.response.data.url
    if (f.url && !f.url.startsWith('blob:')) return f.url
    return ''
  }).filter(url => url)
  shipForm.value.shipmentImages = JSON.stringify(urls)
}

function handlePreview(file) {
  const url = file.response?.url || file.response?.data?.url || file.url
  if (url && !url.startsWith('blob:')) {
    previewUrl.value = url
    previewVisible.value = true
  }
}

function parseImages(jsonStr) {
  if (!jsonStr) return []
  try {
    const parsed = JSON.parse(jsonStr)
    if (Array.isArray(parsed)) return parsed.filter(url => url && typeof url === 'string')
    return []
  } catch (e) { return [] }
}

function submitShip() {
  shipFormRef.value.validate(valid => {
    if (valid) {
      const data = { shipType: shipForm.value.shipType }
      if (shipForm.value.shipType === '2') {
        data.logisticsCompany = shipForm.value.logisticsCompany
        data.logisticsNo = shipForm.value.logisticsNo
      }
      if (shipForm.value.shipmentImages) data.shipmentImages = shipForm.value.shipmentImages
      if (shipForm.value.remark) data.remark = shipForm.value.remark
      shipStockOut(currentShipRow.value.stockOutId, data).then(() => {
        proxy.$modal.msgSuccess('发货成功')
        shipDialogOpen.value = false
        getList()
      }).catch(() => {})
    }
  })
}

function handleConfirmReceipt(row) {
  proxy.$modal.confirm('确认已收货？').then(() => {
    return confirmReceiptStockOut(row.stockOutId)
  }).then(() => {
    proxy.$modal.msgSuccess('确认收货成功')
    getList()
  }).catch(() => {})
}

function addItem() { form.value.items.push({ productId: undefined, productName: undefined, supplierId: undefined, supplierName: undefined, spec: undefined, unit: undefined, packQty: 1, unitType: '1', _prevUnitType: '1', quantity: 1, salePrice: 0, _mainPrice: 0, salePriceSpec: 0, inventoryQty: undefined, amount: 0, remark: undefined }) }
function removeItem(index) { form.value.items.splice(index, 1) }

function onProductSelect(index) {
  const product = productOptions.value.find(p => p.productId === form.value.items[index].productId)
  if (product) {
    form.value.items[index].productName = product.productName
    form.value.items[index].supplierId = product.supplierId
    form.value.items[index].supplierName = product.supplierName || '未知供货商'
    form.value.items[index].spec = product.spec
    form.value.items[index].unit = product.unit
    form.value.items[index].packQty = product.packQty || 1
    form.value.items[index].salePrice = product.salePrice || 0
    form.value.items[index]._mainPrice = product.salePrice || 0
    form.value.items[index].salePriceSpec = product.salePriceSpec || product.salePrice || 0
    form.value.items[index].inventoryQty = product.inventoryQty
    form.value.items[index].unitType = '1'
    calcAmount(index)
  }
}

function onUnitTypeChange(index) {
  // 单位类型切换仅切换显示状态，数值换算统一由后端处理
  calcAmount(index)
}

function calcAmount(index) { const item = form.value.items[index]; item.amount = (item.quantity * item.salePrice).toFixed(2) }
function onEnterpriseSelect(val) { const ent = enterpriseOptions.value.find(e => e.enterpriseId === val); if (ent) form.value.enterpriseName = ent.enterpriseName }
function onEmployeeSelect(val) { const emp = employeeOptions.value.find(e => e.userId === val); if (emp) form.value.responsibleName = emp.userName }
function onContactEmployeeSelect(val) { const emp = employeeOptions.value.find(e => e.userId === val); if (emp) form.value.contactEmployeeName = emp.userName }
function onTargetTypeChange(val) { form.value.enterpriseId = undefined; form.value.enterpriseName = undefined; form.value.responsibleId = undefined; form.value.responsibleName = undefined; form.value.contactEmployeeId = undefined; form.value.contactEmployeeName = undefined; if (val === '1') { form.value.shipType = '2' } else { form.value.shipType = undefined } }
function searchEnterpriseList(keyword) { enterpriseLoading.value = true; searchEnterprise(keyword).then(res => { enterpriseOptions.value = res.data || []; enterpriseLoading.value = false }) }
function searchEmployeeList(keyword) { employeeLoading.value = true; searchEmployee(keyword).then(res => { employeeOptions.value = res.data || []; employeeLoading.value = false }) }
function searchProductList(keyword) { productLoading.value = true; searchProduct(keyword).then(res => { productOptions.value = res.data || []; productLoading.value = false }) }

function submitForm() {
  proxy.$refs["stockOutRef"].validate(valid => {
    if (valid) {
      if (!form.value.items || form.value.items.length === 0) { proxy.$modal.msgWarning("请至少添加一条出库明细"); return }

      const submitData = { ...form.value }
      delete submitData.code
      delete submitData.msg
      submitData.outTargetType = form.value.outTargetType || '1'
      submitData.enterpriseId = form.value.enterpriseId || null
      submitData.enterpriseName = form.value.enterpriseName || null
      submitData.contactEmployeeId = form.value.contactEmployeeId || null
      submitData.contactEmployeeName = form.value.contactEmployeeName || null
      submitData.items = form.value.items.map(item => ({
        itemId: item.itemId || undefined,
        productId: item.productId,
        productName: item.productName,
        supplierId: item.supplierId || null,
        supplierName: item.supplierName || null,
        spec: item.spec || '',
        unit: item.unit || '',
        packQty: item.packQty || 1,
        unitType: item.unitType || '1',
        originalQuantity: Number(item.quantity) || 0,
        quantity: Number(item.quantity) || 0,
        salePrice: Number(item.salePrice) || 0,
        _mainPrice: Number(item._mainPrice) || 0,
        amount: parseFloat(item.amount) || 0,
        remark: item.remark
      }))

      if (form.value.stockOutId != undefined) { updateStockOut(submitData).then(() => { proxy.$modal.msgSuccess("修改成功"); open.value = false; getList() }) }
      else { addStockOut(submitData).then(() => { proxy.$modal.msgSuccess("新增成功"); open.value = false; getList() }) }
    }
  })
}
function handleDelete(row) { const stockOutIds = row.stockOutId || ids.value; proxy.$modal.confirm('是否确认删除？').then(() => delStockOut(stockOutIds)).then(() => { getList(); proxy.$modal.msgSuccess("删除成功") }).catch(() => {}) }
function handlePrint() { printPreview.value = true }
function confirmPrint() {
  const printContent = document.getElementById('print-content')
  if (!printContent) return
  const printWindow = window.open('', '_blank')
  printWindow.document.write(`<!DOCTYPE html><html><head><meta charset="UTF-8"><title>出库单 - ${form.value.stockOutNo}</title><style>*{margin:0;padding:0;box-sizing:border-box}body{font-family:SimSun,serif;font-size:11pt;color:#000;background:#fff;padding:8mm}.print-container{width:210mm;margin:0 auto}.print-header{text-align:center;margin-bottom:20px}.print-header h1{font-size:18pt;font-weight:bold;letter-spacing:10px}.print-info{margin-bottom:15px}.info-row{display:flex;margin-bottom:8px}.info-item{flex:1}.info-item.full{flex:2}.print-table{width:100%;border-collapse:collapse;margin-bottom:15px}.print-table th,.print-table td{border:1px solid #000;padding:4px 6px}.print-table th{background:#f5f5f5;font-weight:bold}.print-table tfoot td{background:#f9f9f9}.print-footer{margin-top:30px}.footer-row{display:flex;margin-bottom:15px}.footer-item{flex:1}.sign-row{margin-top:40px}@media print{body{padding:0}.print-container{width:100%}}</style></head><body>${printContent.innerHTML}</body></html>`)
  printWindow.document.close()
  printWindow.focus()
  setTimeout(() => { printWindow.print(); printWindow.close() }, 100)
}
function getDictLabel(dict, value) { if (!dict) return value; const item = dict.find(d => d.value === value); return item ? item.label : value }
function handleExport() {
  proxy.download("wms/stockOut/export", { ...queryParams.value, warehouseId: currentWarehouseId.value }, `出库_${new Date().getTime()}.xlsx`)
}

function cancel() { open.value = false; reset() }

onMounted(async () => {
  await loadWarehouses()
  getList()
})
</script>

<style scoped>
.print-preview-content { max-height: 60vh; overflow-y: auto; background: #f5f5f5; padding: 20px; }
.print-container { width: 210mm; margin: 0 auto; padding: 8mm; background: #fff; font-family: SimSun, serif; font-size: 11pt; color: #000; box-shadow: 0 2px 12px rgba(0,0,0,0.1); }
.print-header { text-align: center; margin-bottom: 20px; }
.print-header h1 { font-size: 18pt; font-weight: bold; margin: 0; letter-spacing: 10px; }
.print-info { margin-bottom: 15px; }
.info-row { display: flex; margin-bottom: 8px; }
.info-item { flex: 1; }
.info-item.full { flex: 2; }
.print-table { width: 100%; border-collapse: collapse; margin-bottom: 15px; }
.print-table th, .print-table td { border: 1px solid #000; padding: 4px 6px; }
.print-table th { background: #f5f5f5; font-weight: bold; }
.print-table tfoot td { background: #f9f9f9; }
.print-footer { margin-top: 30px; }
.footer-row { display: flex; margin-bottom: 15px; }
.footer-item { flex: 1; }
.sign-row { margin-top: 40px; }
</style>
