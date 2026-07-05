<template>
  <div class="app-container">
    <el-tabs v-model="queryParams.prepareType" @tab-change="handleQuery" style="margin-bottom: 12px">
      <el-tab-pane label="全部" name="" />
      <el-tab-pane label="订单备货" name="order" />
      <el-tab-pane label="方案备货" name="plan" />
    </el-tabs>
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
        <el-button type="primary" plain icon="Box" @click="handleOpenStockPrepare" v-hasPermi="['business:plan:edit']">方案备货</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="ShoppingCart" @click="handleOpenOrderPrepare">订单备货</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="Download" @click="handleExport" v-hasPermi="['business:stockPrepare:export']">导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="stockPrepareList">
      <el-table-column label="企业名称" prop="enterpriseName" min-width="140" show-overflow-tooltip />
      <el-table-column label="来源" min-width="140" align="center">
        <template #default="scope">
          <span v-if="scope.row.planId" class="link-type" @click="viewPlan(scope.row)">{{ scope.row.planNo }}</span>
          <span v-else>订单备货</span>
        </template>
      </el-table-column>
      <el-table-column label="门店名称" prop="storeName" min-width="120" show-overflow-tooltip />
      <el-table-column label="备货进度" min-width="100" align="center">
        <template #default="scope">
          {{ scope.row.prepareProgress || '-' }}
        </template>
      </el-table-column>
      <el-table-column label="货品种类数" min-width="100" align="center">
        <template #default="scope">
          {{ scope.row.productCount || 0 }}
        </template>
      </el-table-column>
      <el-table-column label="总数量（整）" min-width="130" align="center">
        <template #default="scope">
          {{ calcMainTotalQty(scope.row.items, 'quantity') }}
        </template>
      </el-table-column>
      <el-table-column label="总金额" prop="totalAmount" min-width="110" align="right">
        <template #default="scope">
          ¥{{ scope.row.totalAmount }}
        </template>
      </el-table-column>
      <el-table-column label="已出库数量（整）" min-width="140" align="center">
        <template #default="scope">
          {{ calcMainTotalQty(scope.row.items, 'shippedQuantity') }}
        </template>
      </el-table-column>
      <el-table-column label="已出库金额" prop="shippedAmount" min-width="110" align="right">
        <template #default="scope">
          ¥{{ scope.row.shippedAmount }}
        </template>
      </el-table-column>
      <el-table-column label="待出库数量（整）" min-width="140" align="center">
        <template #default="scope">
          {{ calcMainTotalQty(scope.row.items, 'remainingQuantity') }}
        </template>
      </el-table-column>
      <el-table-column label="待出库金额" prop="pendingAmount" min-width="110" align="right">
        <template #default="scope">
          ¥{{ scope.row.pendingAmount }}
        </template>
      </el-table-column>
      <el-table-column label="状态" prop="status" min-width="90" align="center">
        <template #default="scope">
          <dict-tag :options="biz_stock_prepare_status" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="240" align="center">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleDetail(scope.row)">详情</el-button>
          <el-button link type="primary" icon="Sell" @click="handleStockOut(scope.row)" v-if="scope.row.status !== '2' && scope.row.status !== '3'" v-hasPermi="['business:stockPrepare:createStockOut']">出库</el-button>
          <el-button link type="danger" icon="CircleClose" @click="handleCancel(scope.row)" v-if="scope.row.status === '0'">取消</el-button>
          <el-button link type="danger" icon="Delete" @click="handleDelete(scope.row)" v-if="scope.row.status === '3'" v-hasPermi="['business:stockPrepare:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="备货详情" v-model="detailOpen" width="1400px" append-to-body>
      <el-tabs v-model="detailActiveTab">
        <el-tab-pane label="库存明细" name="items">
          <el-table :data="detailData.items" border size="small">
            <el-table-column label="货品名称" prop="productName" min-width="140" />
            <el-table-column label="单位(整)" min-width="80" align="center">
              <template #default="scope">
                <dict-tag :options="biz_product_unit" :value="scope.row.unit" />
              </template>
            </el-table-column>
            <el-table-column label="规格(拆)" min-width="80" align="center">
              <template #default="scope">
                <dict-tag :options="biz_product_spec" :value="scope.row.spec" />
              </template>
            </el-table-column>
            <el-table-column label="换算" min-width="120" align="center">
              <template #default="scope">
                <span v-if="scope.row.packQty > 1">1{{ getUnitLabel(scope.row.unit) }}={{ scope.row.packQty }}{{ getSpecLabel(scope.row.spec) }}</span>
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column label="出货价(整)" prop="mainSalePrice" min-width="100" align="right" />
            <el-table-column label="出货价(拆)" prop="salePriceSpec" min-width="100" align="right" />
            <el-table-column label="数量（整）" min-width="130" align="center">
              <template #default="scope">
                {{ formatMainQty(scope.row.quantity, scope.row.packQty, scope.row.unit, scope.row.spec) }}
              </template>
            </el-table-column>
            <el-table-column label="金额" prop="amount" min-width="100" align="right" />
            <el-table-column label="已出库（整）" min-width="130" align="center">
              <template #default="scope">
                {{ formatMainQty(scope.row.shippedQuantity, scope.row.packQty, scope.row.unit, scope.row.spec) }}
              </template>
            </el-table-column>
            <el-table-column label="已出库金额" prop="shippedAmount" min-width="100" align="right" />
            <el-table-column label="待出库（整）" min-width="130" align="center">
              <template #default="scope">
                {{ formatMainQty(scope.row.remainingQuantity, scope.row.packQty, scope.row.unit, scope.row.spec) }}
              </template>
            </el-table-column>
            <el-table-column label="待出库金额" prop="remainingAmount" min-width="100" align="right" />
          </el-table>
        </el-tab-pane>
        <el-tab-pane :label="detailData.planId ? '关联方案' : '关联订单'" name="orders">
          <el-descriptions v-if="detailData.planId" :column="2" border size="small">
            <el-descriptions-item label="方案编号">{{ detailData.planNo }}</el-descriptions-item>
            <el-descriptions-item label="方案名称">{{ detailData.planName }}</el-descriptions-item>
            <el-descriptions-item label="方案金额">¥{{ detailData.planAmount || 0 }}</el-descriptions-item>
            <el-descriptions-item label="配赠金额">¥{{ detailData.giftAmount || 0 }}</el-descriptions-item>
            <el-descriptions-item label="已出库金额">¥{{ detailData.shippedAmount || 0 }}</el-descriptions-item>
            <el-descriptions-item label="剩余可备金额">¥{{ detailData.remainingAmount || 0 }}</el-descriptions-item>
          </el-descriptions>
          <el-table v-else :data="detailData.orders" border size="small">
            <el-table-column label="订单编号" prop="orderNo" min-width="160" />
            <el-table-column label="类别" prop="sourceType" min-width="80" align="center">
              <template #default="scope">
                {{ scope.row.sourceType === '0' ? '开单' : scope.row.sourceType === '1' ? '操作' : scope.row.sourceType === '2' ? '还款' : scope.row.sourceType === '3' ? '手动' : '-' }}
              </template>
            </el-table-column>
            <el-table-column label="客户姓名" prop="customerName" min-width="90" />
            <el-table-column label="门店名称" prop="storeName" min-width="100" show-overflow-tooltip />
            <el-table-column label="套餐名称" prop="packageName" min-width="120" show-overflow-tooltip />
            <el-table-column label="成交金额" prop="dealAmount" min-width="90" align="right" />
            <el-table-column label="实付金额" prop="paidAmount" min-width="90" align="right" />
            <el-table-column label="欠款金额" prop="owedAmount" min-width="90" align="right" />
            <el-table-column label="订单状态" prop="orderStatus" min-width="90" align="center">
              <template #default="scope">
                {{ scope.row.orderStatus === '0' ? '待确认' : scope.row.orderStatus === '1' ? '企业已审' : scope.row.orderStatus === '2' ? '财务已审' : scope.row.orderStatus === '3' ? '已取消' : '-' }}
              </template>
            </el-table-column>
            <el-table-column label="开单员工" prop="creatorUserName" min-width="90" />
            <el-table-column label="创建时间" prop="createTime" min-width="150" />
          </el-table>
        </el-tab-pane>
      </el-tabs>
    </el-dialog>

    <el-dialog title="统一出货" v-model="stockOutOpen" width="1200px" append-to-body>
      <el-form label-width="100px" style="margin-bottom: 12px">
        <el-form-item label="出库仓库">
          <el-select v-model="stockOutWarehouseId" placeholder="请选择仓库" style="width: 240px" :disabled="warehouseList.length === 0">
            <el-option v-for="w in warehouseList" :key="w.warehouseId" :label="w.warehouseName" :value="w.warehouseId" />
          </el-select>
          <span v-if="warehouseList.length === 0" style="margin-left: 12px; color: #f56c6c; font-size: 12px;">您没有仓库权限，请联系管理员分配仓库后再出库</span>
        </el-form-item>
      </el-form>
      <el-table ref="stockOutTableRef" :data="stockOutDetails" border size="small">
        <el-table-column label="货品名称" prop="productName" min-width="140" />
        <el-table-column label="单位类型" min-width="120" align="center">
          <template #default="scope">
            <el-select v-model="scope.row.unitType" @change="onStockOutUnitTypeChange(scope.$index)" style="width: 100%">
              <el-option label="主单位(整)" value="1" />
              <el-option label="副单位(拆)" value="2" />
            </el-select>
          </template>
        </el-table-column>
        <el-table-column label="换算/库存" min-width="140" align="center">
          <template #default="scope">
            <div v-if="scope.row.packQty > 1" style="color: #909399; font-size: 12px;">
              <div>1{{ getUnitLabel(scope.row.unit) }}={{ scope.row.packQty }}{{ getSpecLabel(scope.row.spec) }}</div>
              <div style="color: #67c23a;">待出库: {{ scope.row.remainingQuantity }}{{ getSpecLabel(scope.row.spec) }}</div>
            </div>
            <div v-else style="color: #67c23a; font-size: 12px;">待出库: {{ scope.row.remainingQuantity }}{{ getSpecLabel(scope.row.spec) }}</div>
          </template>
        </el-table-column>
        <el-table-column label="数量" min-width="140" align="center">
          <template #default="scope">
            <el-input-number v-model="scope.row.outQuantity" :min="0" :max="getStockOutMaxQty(scope.row)" size="small" style="width: 100%" @change="calcStockOutAmount(scope.$index)" />
          </template>
        </el-table-column>
        <el-table-column label="规格" min-width="80" align="center">
          <template #default="scope">
            <span>{{ scope.row.unitType === '1' ? getUnitLabel(scope.row.unit) : getSpecLabel(scope.row.spec) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="出货单价" min-width="120" align="center">
          <template #default="scope">
            <el-input-number v-model="scope.row.outSalePrice" :precision="2" :min="0" size="small" style="width: 100%" @change="calcStockOutAmount(scope.$index)" />
          </template>
        </el-table-column>
        <el-table-column label="金额" min-width="100" align="right">
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

    <!-- 方案备货对话框 -->
    <el-dialog title="方案备货" v-model="stockPrepareOpen" width="900px" append-to-body>
      <el-form :inline="true" :model="planQueryParams" style="margin-bottom: 12px">
        <el-form-item label="企业名称">
          <el-input v-model="planQueryParams.enterpriseName" placeholder="请输入企业名称" clearable style="width: 180px" @keyup.enter="handlePlanQuery" />
        </el-form-item>
        <el-form-item label="方案名称">
          <el-input v-model="planQueryParams.planName" placeholder="请输入方案名称" clearable style="width: 180px" @keyup.enter="handlePlanQuery" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="Search" @click="handlePlanQuery">搜索</el-button>
          <el-button icon="Refresh" @click="resetPlanQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table v-loading="planLoading" :data="planOptions" size="small" highlight-current-row @current-change="onPlanRowSelect">
        <el-table-column label="选择" width="55" align="center">
          <template #default="scope">
            <el-radio v-model="stockPreparePlanId" :value="scope.row.planId">&nbsp;</el-radio>
          </template>
        </el-table-column>
        <el-table-column label="企业名称" prop="enterpriseName" min-width="140" show-overflow-tooltip />
        <el-table-column label="方案名称" prop="planName" min-width="140" show-overflow-tooltip />
        <el-table-column label="方案编号" prop="planNo" min-width="120" />
        <el-table-column label="配赠金额" prop="giftAmount" min-width="100" align="right" />
        <el-table-column label="审核状态" min-width="90" align="center">
          <template #default>
            <el-tag type="success" size="small">已审核</el-tag>
          </template>
        </el-table-column>
      </el-table>
      <pagination v-show="planTotal > 0" :total="planTotal" v-model:page="planQueryParams.pageNum" v-model:limit="planQueryParams.pageSize" @pagination="searchPlanList" />
      <div style="margin-top: 16px">
      <div v-if="stockPrepareItems.length > 0">
        <el-table :data="stockPrepareItems" border size="small">
          <el-table-column label="货品名称" prop="productName" min-width="120" />
          <el-table-column label="单位类型" min-width="120">
            <template #default="scope">
              <el-select v-model="scope.row.unitType" @change="onStockPreparePlanUnitTypeChange(scope.$index)" style="width: 100%">
                <el-option label="主单位(整)" value="1" />
                <el-option label="副单位(拆)" value="2" />
              </el-select>
            </template>
          </el-table-column>
          <el-table-column label="换算/剩余" min-width="160" align="center">
            <template #default="scope">
              <div v-if="scope.row.packQty > 1" style="color: #909399; font-size: 12px;">
                <div>1{{ getUnitLabel(scope.row.unit) }}={{ scope.row.packQty }}{{ getSpecLabel(scope.row.specKey) }}</div>
                <div style="color: #67c23a;">剩余: {{ formatRemainingDisplay(scope.row) }}</div>
              </div>
              <div v-else style="color: #67c23a; font-size: 12px;">剩余: {{ scope.row.remainingQuantity }}{{ getSpecLabel(scope.row.specKey) }}</div>
            </template>
          </el-table-column>
          <el-table-column label="规格" min-width="80" align="center">
            <template #default="scope">
              <span>{{ scope.row.unitType === '1' ? getUnitLabel(scope.row.unit) : getSpecLabel(scope.row.specKey) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="出货价" prop="salePrice" min-width="90" align="right" />
          <el-table-column label="本次备货数量" min-width="140" align="center">
            <template #default="scope">
              <el-input-number v-model="scope.row.quantity" :min="0" :max="scope.row.displayMaxQuantity" controls-position="right" size="small" style="width: 120px" @change="onStockPrepareQuantityChange" />
            </template>
          </el-table-column>
          <el-table-column label="总价" min-width="100" align="right">
            <template #default="scope">
              {{ ((scope.row.salePrice || 0) * (scope.row.quantity || 0)).toFixed(2) }}
            </template>
          </el-table-column>
        </el-table>
      </div>
      <div v-if="stockPreparePlanId" style="margin-top: 16px;">
        <el-button type="primary" icon="Plus" @click="addStockPrepareManualItem">添加货品</el-button>
        <el-table :data="stockPrepareManualItems" border size="small" style="margin-top: 10px" v-if="stockPrepareManualItems.length > 0">
          <el-table-column label="货品名称" min-width="130">
            <template #default="scope">
              <el-select v-model="scope.row.productId" placeholder="选择货品" filterable remote :remote-method="searchProduct" @focus="() => searchProduct('')" @change="(val) => onStockPrepareProductSelect(scope.$index, val)" style="width: 100%">
                <el-option v-for="p in productOptions" :key="p.productId" :label="p.productName" :value="p.productId" />
              </el-select>
            </template>
          </el-table-column>
          <el-table-column label="单位类型" min-width="120">
            <template #default="scope">
              <el-select v-model="scope.row.unitType" @change="onStockPrepareUnitTypeChange(scope.$index)" style="width: 100%">
                <el-option label="主单位-整" value="1" />
                <el-option label="副单位-拆" value="2" />
              </el-select>
            </template>
          </el-table-column>
          <el-table-column label="规格" prop="spec" min-width="80" align="center" />
          <el-table-column label="出货价" prop="salePrice" min-width="90" align="right" />
          <el-table-column label="数量" min-width="120" align="center">
            <template #default="scope">
              <el-input-number v-model="scope.row.quantity" :min="1" controls-position="right" size="small" style="width: 100px" @change="onStockPrepareManualQuantityChange(scope.$index)" />
            </template>
          </el-table-column>
          <el-table-column label="总价" min-width="100" align="right">
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
      <el-descriptions :column="2" border size="small" v-if="stockPreparePlan">
        <el-descriptions-item label="方案配赠金额">¥{{ stockPreparePlan?.giftAmount || 0 }}</el-descriptions-item>
        <el-descriptions-item label="已出库金额">¥{{ stockPrepareShippedAmount || 0 }}</el-descriptions-item>
        <el-descriptions-item label="备货中金额">¥{{ stockPrepareActiveAmount || 0 }}</el-descriptions-item>
        <el-descriptions-item label="剩余可备货金额">
          <span :style="{ color: stockPrepareRemainingAmount < 0 ? '#f56c6c' : '#67c23a' }">¥{{ stockPrepareRemainingAmount.toFixed(2) }}</span>
        </el-descriptions-item>
      </el-descriptions>
      </div>
      <template #footer>
        <el-button type="primary" @click="submitStockPrepare" :loading="stockPrepareSubmitting">确认备货</el-button>
        <el-button @click="stockPrepareOpen = false">取 消</el-button>
      </template>
    </el-dialog>

    <!-- 订单备货对话框 -->
    <el-dialog title="选择订单备货" v-model="orderPrepareOpen" width="900px" append-to-body>
      <el-form :inline="true" :model="orderQueryParams" style="margin-bottom: 12px">
        <el-form-item label="订单编号">
          <el-input v-model="orderQueryParams.orderNo" placeholder="请输入" clearable style="width: 160px" @keyup.enter="handleOrderQuery" />
        </el-form-item>
        <el-form-item label="客户名称">
          <el-input v-model="orderQueryParams.customerName" placeholder="请输入" clearable style="width: 160px" @keyup.enter="handleOrderQuery" />
        </el-form-item>
        <el-form-item label="备货状态">
          <el-radio-group v-model="orderQueryParams.prepareStatus" @change="handleOrderQuery">
            <el-radio-button label="">全部</el-radio-button>
            <el-radio-button label="unprepared">未备货</el-radio-button>
            <el-radio-button label="prepared">已备货</el-radio-button>
          </el-radio-group>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="Search" @click="handleOrderQuery">搜索</el-button>
          <el-button icon="Refresh" @click="resetOrderQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table v-loading="orderLoading" :data="orderList" size="small" @selection-change="handleOrderSelectionChange" ref="orderTableRef">
        <el-table-column type="selection" width="45" :selectable="canSelectOrder" />
        <el-table-column label="订单编号" prop="orderNo" min-width="140" />
        <el-table-column label="客户" prop="customerName" min-width="100" show-overflow-tooltip />
        <el-table-column label="企业" prop="enterpriseName" min-width="120" show-overflow-tooltip />
        <el-table-column label="门店" prop="storeName" min-width="120" show-overflow-tooltip />
        <el-table-column label="成交金额" prop="dealAmount" min-width="100" align="right" />
        <el-table-column label="备货状态" min-width="80" align="center">
          <template #default="scope">
            <el-tag v-if="scope.row.prepareStatus === '1'" type="info" size="small">已备货</el-tag>
            <el-tag v-else type="success" size="small">未备货</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" prop="createTime" min-width="160" />
      </el-table>
      <pagination v-show="orderTotal > 0" :total="orderTotal" v-model:page="orderQueryParams.pageNum" v-model:limit="orderQueryParams.pageSize" @pagination="getOrderList" />
      <template #footer>
        <div style="text-align: right">
          <span style="float: left; line-height: 32px; color: #909399;">已选 {{ selectedOrderIds.length }} 单</span>
          <el-button @click="orderPrepareOpen = false">取 消</el-button>
          <el-button type="primary" :disabled="selectedOrderIds.length === 0" :loading="batchPrepareLoading" @click="handleBatchPrepare">批量备货</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="BusinessStockPrepare">
import { listStockPrepare, getStockPrepare, createStockOutFromPrepare, createFromPlan, getActivePreparedAmount, orderListForPrepare, createFromOrder, batchCreateFromOrder, cancelPrepare, deleteStockPrepare } from "@/api/business/stockPrepare"
import { searchEnterprise } from "@/api/business/enterprise"
import { searchStore } from "@/api/business/store"
import { listPlan, getPlan } from "@/api/business/plan"
import { listProduct } from "@/api/wms/product"
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

// 方案备货相关
const stockPrepareOpen = ref(false)
const stockPreparePlanId = ref(undefined)
const stockPreparePlan = ref(null)
const stockPrepareItems = ref([])
const stockPrepareManualItems = ref([])
const stockPrepareActiveAmount = ref(0)
const stockPrepareShippedAmount = ref(0)
const stockPrepareSubmitting = ref(false)
const planOptions = ref([])
const planLoading = ref(false)
const planTotal = ref(0)
const planQueryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  enterpriseName: '',
  planName: '',
  auditStatus: '2'
})
const productOptions = ref([])

const stockPrepareTotalAmount = computed(() => {
  const planAmount = stockPrepareItems.value.reduce((sum, item) => sum + (parseFloat(item.salePrice) || 0) * (parseFloat(item.quantity) || 0), 0)
  const manualAmount = stockPrepareManualItems.value.reduce((sum, item) => sum + (parseFloat(item.salePrice) || 0) * (parseFloat(item.quantity) || 0), 0)
  return planAmount + manualAmount
})

const stockPrepareRemainingAmount = computed(() => {
  const giftAmount = parseFloat(stockPreparePlan.value?.giftAmount) || 0
  return giftAmount - stockPrepareActiveAmount.value - stockPrepareShippedAmount.value
})

const data = reactive({
  queryParams: { pageNum: 1, pageSize: 10, enterpriseId: undefined, storeId: undefined, prepareNo: undefined, status: undefined, prepareType: '' }
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

// ===== 订单备货相关 =====
const orderPrepareOpen = ref(false)
const orderLoading = ref(false)
const orderList = ref([])
const orderTotal = ref(0)
const orderQueryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  orderNo: '',
  customerName: '',
  prepareStatus: ''
})
const selectedOrderIds = ref([])
const batchPrepareLoading = ref(false)
const orderTableRef = ref(null)

function handleOpenOrderPrepare() {
  resetOrderQuery()
  selectedOrderIds.value = []
  orderPrepareOpen.value = true
  getOrderList()
}

function handleOrderQuery() {
  orderQueryParams.pageNum = 1
  getOrderList()
}

function resetOrderQuery() {
  orderQueryParams.pageNum = 1
  orderQueryParams.orderNo = ''
  orderQueryParams.customerName = ''
  orderQueryParams.prepareStatus = ''
}

function getOrderList() {
  orderLoading.value = true
  orderListForPrepare(orderQueryParams).then(response => {
    orderList.value = response.rows
    orderTotal.value = response.total
  }).finally(() => {
    orderLoading.value = false
  })
}

// 已备货的行不可勾选
function canSelectOrder(row) {
  return row.prepareStatus !== '1'
}

function handleOrderSelectionChange(selection) {
  selectedOrderIds.value = selection.map(item => item.orderId)
}

function handleBatchPrepare() {
  if (selectedOrderIds.value.length === 0) return
  proxy.$modal.confirm('确认为选中的 ' + selectedOrderIds.value.length + ' 个订单创建备货吗？').then(() => {
    batchPrepareLoading.value = true
    return batchCreateFromOrder(selectedOrderIds.value)
  }).then(response => {
    // 后端 AjaxResult::success 将关联数组 merge 到响应顶层且转驼峰
    const successCount = response.successCount || 0
    const skippedCount = response.skippedCount || 0
    const failedCount = response.failedCount || 0
    let msg = '成功 ' + successCount + ' 个'
    if (skippedCount > 0) msg += '，跳过 ' + skippedCount + ' 个'
    if (failedCount > 0) msg += '，失败 ' + failedCount + ' 个'
    proxy.$modal.msgSuccess(msg)
    // 先清空选中、关闭弹窗，再刷新列表，防止刷新过程中用户重复操作
    selectedOrderIds.value = []
    orderPrepareOpen.value = false
    getList()
  }).catch((err) => {
    // 只吞掉用户取消确认的异常，其他异常显示错误提示
    if (err !== 'cancel' && err !== 'close') {
      proxy.$modal.msgError(err.message || '批量备货失败')
    }
  }).finally(() => {
    batchPrepareLoading.value = false
  })
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

function handleCancel(row) {
  proxy.$modal.confirm('确认取消备货单「' + row.prepareNo + '」吗？取消后可重新备货。').then(() => {
    cancelPrepare(row.prepareId).then(() => {
      proxy.$modal.msgSuccess('取消成功')
      getList()
    })
  }).catch(() => {})
}

function handleDelete(row) {
  proxy.$modal.confirm('确认删除备货单「' + row.prepareNo + '」吗？删除后不可恢复。').then(() => {
    deleteStockPrepare(row.prepareId).then(() => {
      proxy.$modal.msgSuccess('删除成功')
      getList()
    })
  }).catch(() => {})
}

function handleStockOut(row) {
  currentPrepareId.value = row.prepareId
  getStockPrepare(row.prepareId).then(response => {
    stockOutDetails.value = (response.data.items || []).map(item => {
      const packQty = item.packQty || 1
      const maxQty = packQty > 1 ? Math.floor(item.remainingQuantity / packQty) : item.remainingQuantity
      const outSalePrice = item.mainSalePrice || 0
      return {
        ...item,
        unitType: '1',
        outQuantity: maxQty,
        outSalePrice: outSalePrice,
        _mainPrice: outSalePrice,
        outAmount: (maxQty * outSalePrice).toFixed(2)
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
    itemId: item.itemId,
    unitType: item.unitType,
    originalQuantity: item.outQuantity
  }))
  if (items.length === 0) {
    proxy.$modal.msgWarning("请至少填写一项出库数量")
    return
  }
  if (warehouseList.value.length === 0) {
    proxy.$modal.msgWarning("您没有仓库权限，无法出库，请联系管理员分配仓库")
    return
  }
  if (!stockOutWarehouseId.value) {
    proxy.$modal.msgWarning("请选择出库仓库")
    return
  }
  createStockOutFromPrepare({ prepareId: currentPrepareId.value, items, warehouseId: stockOutWarehouseId.value }).then(() => {
    proxy.$modal.msgSuccess("出库单创建成功")
    stockOutOpen.value = false
    getList()
  })
}

// ============ 方案备货相关方法 ============
function searchPlanList() {
  planLoading.value = true
  return listPlan(planQueryParams).then(res => {
    planOptions.value = res.rows || []
    planTotal.value = res.total || 0
  }).finally(() => {
    planLoading.value = false
  })
}

function handlePlanQuery() {
  planQueryParams.pageNum = 1
  searchPlanList()
}

function resetPlanQuery() {
  planQueryParams.enterpriseName = ''
  planQueryParams.planName = ''
  planQueryParams.pageNum = 1
  searchPlanList()
}

function onPlanRowSelect(row) {
  if (row) {
    stockPreparePlanId.value = row.planId
    onPlanSelect(row.planId)
  }
}

function handleOpenStockPrepare() {
  stockPreparePlanId.value = undefined
  stockPreparePlan.value = null
  stockPrepareItems.value = []
  stockPrepareManualItems.value = []
  stockPrepareActiveAmount.value = 0
  stockPrepareShippedAmount.value = 0
  resetPlanQuery()
  stockPrepareOpen.value = true
}

function onPlanSelect(planId) {
  if (!planId) {
    stockPreparePlan.value = null
    stockPrepareItems.value = []
    stockPrepareManualItems.value = []
    stockPrepareActiveAmount.value = 0
    stockPrepareShippedAmount.value = 0
    return
  }
  getPlan(planId).then(res => {
    const plan = res.data
    stockPreparePlan.value = plan
    const items = plan.items || []
    if (items.length > 0) {
      stockPrepareItems.value = items
        .filter(item => (item.remainingQuantity || 0) > 0)
        .map(item => {
          const unitType = String(item.unitType || '1')
          const packQty = Number(item.packQty) || 1
          const remainingQuantity = Number(item.remainingQuantity) || 0
          // 后端 biz_plan_item.sale_price 恒为副单位价（由 BizPlanService::syncPlanItems 统一归一化）
          const backendSalePrice = Number(item.salePrice) || 0
          // 主单位价：packQty>1 时 = 后端价 * packQty；否则 = 后端价
          const mainPrice = packQty > 1
            ? Math.round(backendSalePrice * packQty * 100) / 100
            : backendSalePrice
          // 按当前单位类型决定显示价
          const displayPrice = unitType === '1' ? mainPrice : backendSalePrice
          // 根据单位类型计算显示用最大数量
          const displayMaxQuantity = unitType === '1' && packQty > 1
            ? Math.floor(remainingQuantity / packQty)
            : remainingQuantity
          return {
            planItemId: item.planItemId,
            productId: item.productId,
            productName: item.productName,
            unitType: unitType,
            packQty: packQty,
            unit: item.product?.unit,
            specKey: item.product?.spec,
            spec: item.spec,
            salePrice: displayPrice,
            _mainPrice: mainPrice,
            remainingQuantity: remainingQuantity,
            displayMaxQuantity: displayMaxQuantity,
            quantity: 0
          }
        })
      stockPrepareManualItems.value = []
    } else {
      stockPrepareItems.value = []
      stockPrepareManualItems.value = []
    }
    getActivePreparedAmount(plan.planId).then(res2 => {
      stockPrepareActiveAmount.value = res2.data?.activePreparedAmount || 0
      stockPrepareShippedAmount.value = plan.shippedAmount || 0
    }).catch(() => {
      stockPrepareActiveAmount.value = 0
      stockPrepareShippedAmount.value = 0
    })
  })
}

function searchProduct(query) {
  listProduct({ productName: query || '', status: '0', pageNum: 1, pageSize: 20 }).then(res => {
    productOptions.value = res.rows || []
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
  if (stockPrepareTotalAmount.value > stockPrepareRemainingAmount.value) {
    proxy.$modal.msgWarning('剩余出货金额不足，请减少备货数量')
  }
}

function onStockPrepareQuantityChange() {
  if (stockPrepareTotalAmount.value > stockPrepareRemainingAmount.value) {
    proxy.$modal.msgWarning('剩余出货金额不足，请减少备货数量')
  }
}

// 方案明细切换单位类型：转换出货价与显示最大数量
function onStockPreparePlanUnitTypeChange(index) {
  const item = stockPrepareItems.value[index]
  const packQty = item.packQty || 1
  if (item.unitType === '1') {
    // 切换到主单位：还原主单位价，最大数量为 remainingQuantity / packQty
    item.salePrice = item._mainPrice || 0
    item.displayMaxQuantity = packQty > 1 ? Math.floor(item.remainingQuantity / packQty) : item.remainingQuantity
  } else {
    // 切换到副单位：计算副单位价，最大数量为 remainingQuantity
    const subPrice = item._mainPrice && packQty > 0 ? Math.round((item._mainPrice / packQty) * 100) / 100 : item.salePrice
    item.salePrice = subPrice
    item.displayMaxQuantity = item.remainingQuantity
  }
  // 数量超出新上限时重置为 0
  if (Number(item.quantity) > Number(item.displayMaxQuantity)) {
    item.quantity = 0
  }
  onStockPrepareQuantityChange()
}

// 格式化方案剩余数量显示
function formatRemainingDisplay(row) {
  const packQty = row.packQty || 1
  const unitLabel = getUnitLabel(row.unit)
  const specLabel = getSpecLabel(row.specKey)
  if (row.unitType === '1' && packQty > 1 && unitLabel && specLabel) {
    const mainQty = Math.floor(row.remainingQuantity / packQty)
    return mainQty + unitLabel + '（' + row.remainingQuantity + specLabel + '）'
  }
  return row.remainingQuantity + (specLabel || unitLabel || '')
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
  const items = [...stockPrepareItems.value, ...stockPrepareManualItems.value]
  const validItems = items.filter(item => item.quantity > 0)
  if (validItems.length === 0) {
    proxy.$modal.msgWarning('请至少选择一个货品且数量大于0')
    return
  }
  if (stockPrepareTotalAmount.value > stockPrepareRemainingAmount.value) {
    proxy.$modal.msgWarning(`本次备货金额 ${stockPrepareTotalAmount.value.toFixed(2)} 超过剩余可备货金额 ${stockPrepareRemainingAmount.value.toFixed(2)}`)
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
    proxy.$modal.msgSuccess('备货成功')
    stockPrepareOpen.value = false
    queryParams.value.prepareType = 'plan'
    getList()
  }).catch(() => {}).finally(() => { stockPrepareSubmitting.value = false })
}

searchEnterpriseList('')
getList()

// 从方案管理页面跳转过来时，自动打开方案备货对话框并预选方案
const route = proxy.$route
if (route.query.prepareType === 'plan' && route.query.planId) {
  queryParams.value.prepareType = 'plan'
  getList()
  stockPreparePlanId.value = Number(route.query.planId)
  nextTick(() => {
    searchPlanList().then(() => {
      onPlanSelect(stockPreparePlanId.value)
      stockPrepareOpen.value = true
    })
  })
}
</script>
