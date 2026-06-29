<template>
  <div class="app-container">
    <el-card class="header-card" shadow="never">
      <el-row :gutter="20" align="middle">
        <el-col :span="8">
          <div style="display: flex; align-items: center">
            <span class="stat-label" style="white-space: nowrap; margin-right: 8px">企业</span>
            <el-select v-model="currentEnterpriseId" placeholder="请选择企业" filterable @change="handleEnterpriseChange" style="width: 100%">
              <el-option v-for="item in enterpriseOptions" :key="item.enterpriseId" :label="item.enterpriseName" :value="item.enterpriseId" />
            </el-select>
          </div>
        </el-col>
        <el-col :span="8">
          <div style="display: flex; align-items: center">
            <span class="stat-label" style="white-space: nowrap; margin-right: 8px">门店</span>
            <el-select v-model="currentStoreId" placeholder="请选择门店" filterable @change="handleStoreChange" style="width: 100%">
              <el-option v-for="item in storeOptions" :key="item.storeId" :label="item.storeName" :value="item.storeId" />
            </el-select>
          </div>
        </el-col>
        <el-col :span="8">
          <div style="display: flex; align-items: center; gap: 12px">
            <el-select v-model="filterSatisfaction" placeholder="满意度" clearable style="width: 100px" @change="loadCustomerList">
              <el-option label="5星" value="5" />
              <el-option label="4星及以上" value="4" />
              <el-option label="3星及以上" value="3" />
              <el-option label="2星及以上" value="2" />
              <el-option label="1星及以上" value="1" />
            </el-select>
            <el-button v-if="currentEnterpriseId && storeOptions.length === 0" type="primary" plain icon="Plus" @click="handleQuickAddStore" v-hasPermi="['business:store:add']">创建门店</el-button>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <el-row :gutter="16" v-if="currentStoreId" style="margin-top: 12px">
      <el-col :span="5">
        <el-card shadow="never" class="customer-panel">
          <template #header>
            <div class="panel-header">
              <span>客户列表</span>
              <el-button type="primary" link icon="Plus" @click="handleAddCustomer" v-hasPermi="['business:customer:add']">新增</el-button>
            </div>
          </template>
          <el-input v-model="customerKeyword" placeholder="搜索客户" clearable prefix-icon="Search" @input="handleSearchCustomer" style="margin-bottom: 10px" />
          <div class="customer-list">
            <div v-for="item in customerList" :key="item.customerId" :class="['customer-item', currentCustomerId === item.customerId ? 'active' : '']" @click="handleSelectCustomer(item)">
              <div class="customer-header">
                <div class="customer-name-row">
                  <el-avatar :size="32" :src="item.avatar || undefined" :style="{ background: item.gender === '1' ? '#FF6B9D' : '#3D6DF7', fontSize: '14px' }" @error="() => { item.avatar = '' }">
                    {{ item.customerName ? item.customerName.charAt(0) : '' }}
                  </el-avatar>
                  <span class="customer-name">{{ item.customerName }}</span>
                  <el-button link type="primary" icon="Edit" size="small" @click.stop="handleEditCustomer(item)" style="margin-left: 4px" v-hasPermi="['business:customer:edit']" />
                </div>
                <div class="customer-tags">
                  <el-tag v-if="item.allExhausted" type="info" size="small">已用完</el-tag>
                  <dict-tag v-if="item.tag" :options="biz_customer_tag" :value="item.tag" size="small" />
                </div>
              </div>
              <div class="customer-stats">
                <div class="stat-row" v-if="item.dealAmount > 0 || item.avgSatisfaction">
                  <span class="stat-item stat-satisfaction" v-if="item.avgSatisfaction">
                    <span class="stat-label">满意度</span>
                    <el-rate :model-value="item.avgSatisfaction" disabled size="small" />
                  </span>
                  <span class="stat-item stat-amount" v-if="item.dealAmount > 0">
                    <span class="stat-label">成交</span>
                    <span class="stat-value highlight">¥{{ item.dealAmount }}</span>
                  </span>
                </div>
              </div>
            </div>
            <el-empty v-if="customerList.length === 0" description="暂无客户" :image-size="60" />
          </div>
        </el-card>
      </el-col>

      <el-col :span="19">
        <el-card shadow="never" v-if="currentCustomer">
          <template #header>
            <div class="panel-header">
              <span>{{ currentCustomer.customerName }} <el-tag size="small" v-if="currentCustomer.phone">{{ currentCustomer.phone }}</el-tag></span>
              <dict-tag v-if="currentCustomer.tag" :options="biz_customer_tag" :value="currentCustomer.tag" />
            </div>
          </template>
          <el-tabs v-model="activeTab">
            <el-tab-pane label="开单" name="order">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px">
                <div style="display: flex; align-items: center">
                  <span class="stat-label">套餐名称</span>
                  <el-input v-model="orderPackageName" placeholder="请输入套餐名称" clearable style="width: 240px; margin-left: 8px" />
                </div>
                <el-button v-if="canAddOrderItem" type="primary" plain icon="Plus" @click="addOrderItemRow" v-hasPermi="['business:sales:add']">添加品项</el-button>
              </div>
              <el-table :data="orderItems" border style="width: 100%" >
                <el-table-column label="品项" min-width="80">
                  <template #default="scope">
                    <el-select v-model="scope.row.cardItemId" filterable remote :remote-method="handleSearchCardItem" :loading="cardItemSearchLoading" placeholder="搜索卡项" clearable style="width: 100%" @focus="handleCardItemFocus" @change="(val) => onCardItemSelect(scope.$index, val)">
                      <el-option v-for="item in cardItemOptions" :key="item.cardItemId" :label="item.cardItemName" :value="item.cardItemId">
                        <span>{{ item.cardItemName }}</span>
                        <span style="float: right; color: #8492a6; font-size: 12px">{{ item.defaultQuantity }}次 ¥{{ item.suggestedPrice }}</span>
                      </el-option>
                    </el-select>
                  </template>
                </el-table-column>
                <el-table-column label="付款方式" width="120">
                  <template #default="scope">
                    <el-select v-model="scope.row.paymentMethod" size="small" @change="onItemPaymentMethodChange(scope.$index)" style="width: 100%">
                      <el-option v-for="dict in biz_payment_method" :key="dict.value" :label="dict.label" :value="dict.value" />
                    </el-select>
                  </template>
                </el-table-column>
                <el-table-column label="次数" width="100">
                  <template #default="scope">
                    <el-input-number v-model="scope.row.quantity" :min="1" :disabled="!packageQuantityEditable" controls-position="right"  style="width: 100%" />
                  </template>
                </el-table-column>
                <el-table-column label="成交金额" width="140">
                  <template #default="scope">
                    <el-input-number v-model="scope.row.dealAmount" :min="0" :precision="2" controls-position="right" style="width: 100%" :disabled="!packageDealAmountEditable || scope.row.paymentMethod === 'gift'" />
                  </template>
                </el-table-column>
                <el-table-column label="单次价" width="100" align="center">
                  <template #default="scope">
                    <span>{{ scope.row.quantity > 0 ? (scope.row.dealAmount / scope.row.quantity).toFixed(2) : '0.00' }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="实付金额" width="140">
                  <template #default="scope">
                    <el-input-number v-model="scope.row.paidAmount" :min="0" :precision="2" controls-position="right" style="width: 100%" :disabled="!packagePaidAmountEditable || scope.row.paymentMethod === 'gift'" />
                  </template>
                </el-table-column>
                <el-table-column label="欠款金额" width="100" align="center">
                  <template #default="scope">
                    <span>{{ (scope.row.dealAmount - scope.row.paidAmount).toFixed(2) }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="65" align="center">
                  <template #default="scope">
                    <el-button link type="danger" icon="Delete" @click="orderItems.splice(scope.$index, 1)" v-hasPermi="['business:sales:add']" />
                  </template>
                </el-table-column>
              </el-table>
              <div style="margin-top: 12px; display: flex; align-items: center; gap: 8px">
                <span class="stat-label" style="font-size:13px; white-space:nowrap">门店成交人</span>
                <el-input v-model="orderStoreDealer" placeholder="请输入门店成交人" clearable style="flex:1" size="small" />
              </div>
              <div style="margin-top: 12px; background: var(--el-fill-color-lighter); padding: 12px; border-radius: 4px">
                <div style="margin-bottom: 6px; font-size:13px">备注</div>
                <el-input v-model="orderCustomerFeedback" type="textarea" :rows="2" placeholder="请输入顾客反馈..." size="small" />
              </div>
              <el-row style="margin-top: 12px; text-align: right; background: var(--el-fill-color-lighter); padding: 10px 16px; border-radius: 4px">
                <el-col :span="24">
                  <span style="margin-right: 12px">合计: <b style="color: #409eff">{{ totalDealAmount }}</b> 元</span>
                  <el-button type="primary" @click="submitOrder" v-hasPermi="['business:sales:add']">提交订单</el-button>
                </el-col>
              </el-row>
            </el-tab-pane>

            <el-tab-pane label="操作" name="operation">
              <el-card shadow="never">
                <template #header>
                  <div class="panel-header">
                    <h4 style="margin: 0">持卡明细</h4>
                    <div style="display: flex; gap: 8px; align-items: center">
                      <el-button :type="showExhaustedItems ? 'warning' : 'info'" plain size="small" @click="showExhaustedItems = !showExhaustedItems">{{ showExhaustedItems ? '隐藏用完' : '显示用完' }}</el-button>
                      <el-button type="primary" plain size="small" @click="showTrialOperation">+ 体验操作</el-button>
                      <el-badge :value="selectedOperationItems.length" :hidden="selectedOperationItems.length === 0" class="item">
                        <el-button type="success" size="small" :disabled="selectedOperationItems.length === 0" @click="operationDrawerVisible = true">操作 ({{ selectedOperationItems.length }})</el-button>
                      </el-badge>
                    </div>
                  </div>
                </template>
                <template v-if="filteredPackageList.length > 0">
                  <el-collapse v-model="expandedPackages">
                    <el-collapse-item v-for="pkg in filteredPackageList" :key="pkg.packageId" :name="pkg.packageId">
                      <template #title>
                        <div class="package-group-header-inline">
                          <div class="pkg-title-row">
                            <el-icon style="margin-right: 4px; vertical-align: middle; color: #909399"><Wallet /></el-icon>
                            <span class="package-group-name">{{ pkg.packageName }}</span>
                            <el-tag :type="pkg.status === '2' ? 'info' : 'success'" size="small" style="margin-left: 6px">{{ pkg.status === '2' ? '已用完' : '使用中' }}</el-tag>
                            <span class="amount-inline">¥{{ Number(pkg.totalAmount || 0).toFixed(2) }}</span>
                            <span class="amount-inline paid">实付¥{{ Number(pkg.paidAmount || 0).toFixed(2) }}</span>
                            <span class="amount-inline owed" v-if="Number(pkg.owedAmount || 0) > 0">欠款¥{{ Number(pkg.owedAmount || 0).toFixed(2) }}</span>
                            <span v-if="pkg.remark" class="remark-inline">{{ pkg.remark }}</span>
                          </div>
                        </div>
                      </template>
                      <el-table ref="packageItemTableRef" :data="pkg.items || []" border size="small" @selection-change="(val) => handleOperationItemSelect(val, pkg)">
                        <el-table-column type="selection" width="45" :selectable="row => row.remainingQuantity > 0 && pkg.status !== '2'" />
                        <el-table-column label="品项" prop="productName" />
                        <el-table-column label="成交金额" prop="dealPrice" width="90" align="center" />
                        <el-table-column label="实付金额" prop="paidAmount" width="90" align="center" />
                        <el-table-column label="欠款金额" width="90" align="center">
                          <template #default="scope">{{ Number(scope.row.owedAmount || 0).toFixed(2) }}</template>
                        </el-table-column>
                        <el-table-column label="单次价" prop="unitPrice" width="80" align="center" />
                        <el-table-column label="总次数" prop="totalQuantity" width="70" align="center" />
                        <el-table-column label="已用" prop="usedQuantity" width="60" align="center" />
                        <el-table-column label="剩余" prop="remainingQuantity" width="60" align="center" />
                      </el-table>
                    </el-collapse-item>
                  </el-collapse>
                </template>
                <el-empty v-else description="暂无持卡数据" :image-size="60" />
              </el-card>

              <el-drawer v-model="operationDrawerVisible" title="持卡操作" size="680px" :destroy-on-close="false" :append-to-body="false">
                <el-table :data="selectedOperationItems" border size="small" style="margin-bottom: 12px">
                  <el-table-column label="套餐" prop="packageName" width="160" show-overflow-tooltip />
                  <el-table-column label="品项" prop="productName" />
                  <el-table-column label="单次价" prop="unitPrice" width="80" align="center" />
                  <el-table-column label="剩余" prop="remainingQuantity" width="60" align="center" />
                  <el-table-column label="操作次数" width="110">
                    <template #default="scope">
                      <el-input-number v-model="scope.row.operationQuantity" :min="1" :max="scope.row.remainingQuantity" controls-position="right" size="small" style="width: 100%" @change="val => calcItemConsumeAmount(scope.$index)" />
                    </template>
                  </el-table-column>
                  <el-table-column label="消耗金额" width="90" align="right">
                    <template #default="scope">
                      <span style="color: #409eff; font-weight: 500">{{ Number(scope.row.consumeAmount || 0).toFixed(2) }}</span>
                    </template>
                  </el-table-column>
                </el-table>
                <el-form :model="operationForm" label-width="80px" style="width: 100%">
                  <el-row :gutter="16">
                    <el-col :span="12">
                      <el-form-item label="操作时间">
                        <el-date-picker v-model="operationForm.operationDate" type="date" value-format="YYYY-MM-DD" placeholder="选择日期" style="width: 100%" />
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="操作人">
                        <el-select v-model="operationForm.operatorUserId" filterable @change="handleOperatorChange" style="width: 100%">
                          <el-option v-for="u in userOptions" :key="u.userId" :label="u.nick_name || u.nickName || u.userName || '未设置姓名'" :value="u.userId" />
                        </el-select>
                      </el-form-item>
                    </el-col>
                  </el-row>
                  <el-form-item label="满意度">
                    <el-rate v-model="operationForm.satisfaction" :colors="['#99A9BF', '#F7BA2A', '#FF9900']" />
                  </el-form-item>
                  <el-form-item label="顾客反馈">
                    <el-input v-model="operationForm.customerFeedback" type="textarea" :rows="2" />
                  </el-form-item>
                  <el-row :gutter="16">
                    <el-col :span="12">
                          <el-form-item label="操作前">
                            <image-upload :key="'op-before-' + operationDrawerVisible" v-model="operationForm.beforePhoto" :limit="2" :fileSize="5" width="60" height="60" />
                          </el-form-item>
                        </el-col>
                        <el-col :span="12">
                          <el-form-item label="操作后">
                            <image-upload :key="'op-after-' + operationDrawerVisible" v-model="operationForm.afterPhoto" :limit="2" :fileSize="5" width="60" height="60" />
                          </el-form-item>
                    </el-col>
                  </el-row>
                  <el-form-item label="备注">
                    <el-input v-model="operationForm.remark" type="textarea" :rows="2" />
                  </el-form-item>
                  <el-form-item style="text-align: right">
                    <el-button type="primary" @click="submitOperation('0')" v-hasPermi="['business:sales:operation']">提交持卡操作</el-button>
                  </el-form-item>
                </el-form>
              </el-drawer>

              <el-drawer v-model="trialDrawerVisible" title="体验操作" size="620px" :destroy-on-close="false" :append-to-body="false">
                <el-form :model="trialForm" label-width="80px" style="width: 100%">
                  <el-row :gutter="16">
                    <el-col :span="12">
                      <el-form-item label="操作时间">
                        <el-date-picker v-model="trialForm.operationDate" type="date" value-format="YYYY-MM-DD" placeholder="选择日期" style="width: 100%" />
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="操作项目">
                        <el-input v-model="trialForm.productName" placeholder="请输入操作项目" />
                      </el-form-item>
                    </el-col>
                  </el-row>
                  <el-row :gutter="16">
                    <el-col :span="12">
                      <el-form-item label="操作次数">
                        <el-input-number v-model="trialForm.operationQuantity" :min="1" controls-position="right" style="width: 100%" />
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="体验价">
                        <el-input-number v-model="trialForm.trialPrice" :min="0" :precision="2" controls-position="right" style="width: 100%" />
                      </el-form-item>
                    </el-col>
                  </el-row>
                  <el-row :gutter="16">
                    <el-col :span="12">
                      <el-form-item label="操作人">
                        <el-select v-model="trialForm.operatorUserId" filterable @change="handleTrialOperatorChange" style="width: 100%">
                          <el-option v-for="u in userOptions" :key="u.userId" :label="u.nick_name || u.nickName || u.userName || '未设置姓名'" :value="u.userId" />
                        </el-select>
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="满意度">
                        <el-rate v-model="trialForm.satisfaction" :colors="['#99A9BF', '#F7BA2A', '#FF9900']" />
                      </el-form-item>
                    </el-col>
                  </el-row>
                  <el-form-item label="顾客反馈">
                    <el-input v-model="trialForm.customerFeedback" type="textarea" :rows="2" />
                  </el-form-item>
                  <el-row :gutter="16">
                    <el-col :span="12">
                      <el-form-item label="操作前">
                        <image-upload :key="'trial-before-' + trialDrawerVisible" v-model="trialForm.beforePhoto" :limit="2" :fileSize="5" width="60" height="60" />
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="操作后">
                        <image-upload :key="'trial-after-' + trialDrawerVisible" v-model="trialForm.afterPhoto" :limit="2" :fileSize="5" width="60" height="60" />
                      </el-form-item>
                    </el-col>
                  </el-row>
                  <el-form-item label="备注">
                    <el-input v-model="trialForm.remark" type="textarea" :rows="2" />
                  </el-form-item>
                  <el-form-item>
                    <el-button type="warning" @click="submitOperation('1')" v-hasPermi="['business:sales:operation']">提交体验操作</el-button>
                    <el-button @click="trialDrawerVisible = false">取消</el-button>
                  </el-form-item>
                </el-form>
              </el-drawer>
            </el-tab-pane>

            <el-tab-pane label="欠款" name="arrears">
              <el-card shadow="never" style="margin-bottom: 16px">
                <template #header>
                  <div class="panel-header">
                    <h4 style="margin: 0">欠款套餐</h4>
                    <el-tag type="danger" size="small">共 {{ owedPackageList.length }} 笔欠款</el-tag>
                  </div>
                </template>
                <el-table :data="owedPackageList" border size="small" style="width: 100%" v-if="owedPackageList.length > 0">
                  <el-table-column label="套餐名称" prop="packageName" min-width="140" show-overflow-tooltip />
                  <el-table-column label="套餐编号" prop="packageNo" width="140" />
                  <el-table-column label="成交金额" width="110" align="right">
                    <template #default="scope">{{ Number(scope.row.totalAmount || 0).toFixed(2) }}</template>
                  </el-table-column>
                  <el-table-column label="已付金额" width="110" align="right">
                    <template #default="scope">
                      <span style="color: #67c23a">{{ Number(scope.row.paidAmount || 0).toFixed(2) }}</span>
                    </template>
                  </el-table-column>
                  <el-table-column label="欠款金额" width="110" align="right">
                    <template #default="scope">
                      <span style="color: #f56c6c; font-weight: 600">{{ Number(scope.row.owedAmount || 0).toFixed(2) }}</span>
                    </template>
                  </el-table-column>
                  <el-table-column label="创建时间" prop="createTime" width="160" />
                  <el-table-column label="操作" width="100" align="center" fixed="right">
                    <template #default="scope">
                      <el-button type="primary" size="small" @click="openRepayDialog(scope.row)" v-hasPermi="['business:sales:repayment']">还款</el-button>
                    </template>
                  </el-table-column>
                </el-table>
                <el-empty v-else description="暂无欠款记录" :image-size="60" />
              </el-card>

              <el-card shadow="never">
                <template #header>
                  <div class="panel-header">
                    <h4 style="margin: 0">还款记录</h4>
                  </div>
                </template>
                <el-table :data="repaymentRecordList" border size="small" style="width: 100%" v-if="repaymentRecordList.length > 0">
                  <el-table-column label="还款编号" prop="repaymentNo" width="160" />
                  <el-table-column label="套餐名称" prop="packageName" min-width="140" show-overflow-tooltip />
                  <el-table-column label="还款金额" width="110" align="right">
                    <template #default="scope">
                      <span style="color: #409eff; font-weight: 500">{{ Number(scope.row.repaymentAmount || 0).toFixed(2) }}</span>
                    </template>
                  </el-table-column>
                  <el-table-column label="支付方式" width="100" align="center">
                    <template #default="scope">
                      <el-tag size="small">{{ getPaymentMethodName(scope.row.paymentMethod) }}</el-tag>
                    </template>
                  </el-table-column>
                  <el-table-column label="状态" width="90" align="center">
                    <template #default="scope">
                      <el-tag :type="scope.row.status === '1' ? 'success' : scope.row.status === '2' ? 'info' : 'warning'" size="small">{{ getRepaymentStatusName(scope.row.status) }}</el-tag>
                    </template>
                  </el-table-column>
                  <el-table-column label="操作人" prop="creatorUserName" width="100" />
                  <el-table-column label="备注" prop="remark" min-width="120" show-overflow-tooltip />
                  <el-table-column label="创建时间" prop="createTime" width="160" />
                  <el-table-column label="操作" width="80" align="center" fixed="right">
                    <template #default="scope">
                      <el-button v-if="scope.row.status === '0'" v-hasPermi="['business:sales:repaymentAudit']" type="success" size="small" link @click="handleAuditRepayment(scope.row.repaymentId)">审核</el-button>
                    </template>
                  </el-table-column>
                </el-table>
                <el-empty v-else description="暂无还款记录" :image-size="60" />
              </el-card>
            </el-tab-pane>

            <el-tab-pane label="档案" name="archive">
              <div style="margin-bottom: 12px; display: flex; gap: 12px; align-items: center; flex-wrap: wrap">
                <el-button type="primary" size="small" icon="Plus" @click="handleAddArchive" v-hasPermi="['business:sales:archiveAdd']">新增档案</el-button>
                <el-select v-model="archiveFilterType" placeholder="类型" clearable size="small" style="width: 100px" @change="loadArchiveList">
                  <el-option label="开单" value="0" />
                  <el-option label="操作" value="1" />
                  <el-option label="还款" value="2" />
                  <el-option label="手动" value="3" />
                </el-select>
                <el-date-picker v-model="archiveDateRange" type="daterange" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" size="small" style="width: 200px" @change="loadArchiveList" />
              </div>
              <div v-if="archiveList.length > 0" class="archive-timeline">
                <div v-for="item in archiveList" :key="item.archiveId" class="archive-card">
                  <div class="archive-card-header">
                    <div class="archive-card-left">
                      <span class="archive-date">{{ item.archiveDate }}</span>
                      <el-tag :type="getSourceTypeTagType(item.sourceType)" size="small">{{ getSourceTypeLabel(item.sourceType) }}</el-tag>
                      <el-tag v-if="item.archiveType && item.archiveType !== 'sales'" type="info" size="small" style="margin-left: 4px">{{ getArchiveTypeLabel(item.archiveType) }}</el-tag>
                      <span v-if="item.operatorUserName" class="archive-operator">{{ item.operatorUserName }}</span>
                    </div>
                    <el-button v-if="item.sourceType === '3'" link type="danger" size="small" icon="Delete" @click="handleDeleteArchive(item)" v-hasPermi="['business:sales:archiveRemove']" />
                  </div>
                  <div class="archive-card-body">
                    <div class="archive-main">
                      <div v-if="parsePlanItems(item.planItems).length > 0" class="archive-plan-items">
                        <span class="archive-label">方案：</span>
                        <span v-for="(pi, idx) in parsePlanItems(item.planItems)" :key="idx">
                          {{ pi.name }}×{{ pi.quantity }}<template v-if="idx < parsePlanItems(item.planItems).length - 1">、</template>
                        </span>
                      </div>
                      <div class="archive-info-row">
                        <span v-if="item.amount > 0" class="archive-amount">金额：<b style="color: #409eff">¥{{ Number(item.amount).toFixed(2) }}</b></span>
                        <span v-if="item.satisfaction" class="archive-satisfaction">满意度：<el-rate :model-value="item.satisfaction" disabled size="small" /></span>
                      </div>
                      <div v-if="item.customerFeedback" class="archive-feedback">
                        <span class="archive-label">顾客反馈：</span><span>{{ item.customerFeedback }}</span>
                      </div>
                      <div v-if="item.remark" class="archive-remark">
                        <span class="archive-label">备注：</span><span>{{ item.remark }}</span>
                      </div>
                    </div>
                    <div v-if="parseArchivePhotos(item.photos).length > 0" class="archive-photos-right">
                      <el-image v-for="(url, idx) in parseArchivePhotos(item.photos)" :key="idx" :src="url" :preview-src-list="parseArchivePhotos(item.photos)" :initial-index="idx" fit="cover" style="width: 80px; height: 80px; border-radius: 6px; border: 1px solid #ebeef5" />
                    </div>
                  </div>
                </div>
              </div>
              <el-empty v-else description="暂无档案记录" :image-size="60" />
            </el-tab-pane>

            <el-tab-pane label="开单记录" name="orderRecord">
              <div style="margin-bottom: 12px; display: flex; gap: 12px; align-items: center; flex-wrap: wrap">
                <el-date-picker v-model="orderRecordDateRange" type="daterange" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" size="small" style="width: 200px" />
                <el-select v-model="orderRecordCreatorUserId" placeholder="销售人" clearable filterable size="small" style="width: 140px">
                  <el-option v-for="u in userOptions" :key="u.userId" :label="u.nick_name || u.nickName || u.userName || '未设置姓名'" :value="u.userId" />
                </el-select>
                <el-button type="primary" size="small" @click="loadOrderRecords">查询</el-button>
              </div>
              <el-table :data="orderRecordList" border size="small" style="width: 100%">
                <el-table-column label="套餐名称" prop="packageName" min-width="120" show-overflow-tooltip />
                <el-table-column label="订单编号" prop="orderNo" min-width="160" />
                <el-table-column label="品项" min-width="140">
                  <template #default="scope">
                    <span v-for="(item, idx) in (scope.row.items || [])" :key="idx">
                      {{ item.productName }}<template v-if="idx < (scope.row.items || []).length - 1">、</template>
                    </span>
                    <span v-if="!scope.row.items || scope.row.items.length === 0">-</span>
                  </template>
                </el-table-column>
                <el-table-column label="次数" min-width="80" align="center">
                  <template #default="scope">
                    {{ (scope.row.items || []).reduce((sum, item) => sum + (parseInt(item.quantity) || 0), 0) }}
                  </template>
                </el-table-column>
                <el-table-column label="成交金额" min-width="110" align="right">
                  <template #default="scope">{{ Number(scope.row.dealAmount || 0).toFixed(2) }}</template>
                </el-table-column>
                <el-table-column label="实付金额" min-width="110" align="right">
                  <template #default="scope">{{ Number(scope.row.paidAmount || 0).toFixed(2) }}</template>
                </el-table-column>
                <el-table-column label="欠款金额" min-width="110" align="right">
                  <template #default="scope">{{ Number(scope.row.owedAmount || 0).toFixed(2) }}</template>
                </el-table-column>
                <el-table-column label="付款方式" min-width="90" align="center">
                  <template #default="scope">
                    <dict-tag v-if="scope.row.paymentMethod" :options="biz_payment_method" :value="scope.row.paymentMethod" size="small" />
                    <span v-else>-</span>
                  </template>
                </el-table-column>
                <el-table-column label="门店成交人" prop="storeDealer" min-width="100" show-overflow-tooltip />
                <el-table-column label="成交员工" prop="creatorUserName" min-width="100" show-overflow-tooltip />
                <el-table-column label="备注" prop="remark" min-width="120" show-overflow-tooltip />
                <el-table-column label="创建时间" prop="createTime" min-width="160" />
              </el-table>
            </el-tab-pane>

            <el-tab-pane label="操作记录" name="operationRecord">
              <div style="margin-bottom: 12px; display: flex; gap: 12px; align-items: center; flex-wrap: wrap">
                <el-date-picker v-model="operationRecordDateRange" type="daterange" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" size="small" style="width: 200px" />
                <el-input v-model="operationRecordProductName" placeholder="操作品项" clearable size="small" style="width: 120px" />
                <el-select v-model="operationRecordOperatorUserId" placeholder="操作人" clearable filterable size="small" style="width: 120px">
                  <el-option v-for="u in userOptions" :key="u.userId" :label="u.nick_name || u.nickName || u.userName || '未设置姓名'" :value="u.userId" />
                </el-select>
                <el-select v-model="operationRecordSatisfaction" placeholder="满意度" clearable size="small" style="width: 100px">
                  <el-option v-for="i in 5" :key="i" :label="i + '星'" :value="i" />
                </el-select>
                <el-button type="primary" size="small" @click="loadOperationRecords">查询</el-button>
              </div>
              <el-table :data="operationRecordList" border size="small" style="width: 100%">
                <el-table-column label="类型" width="80" align="center">
                  <template #default="scope"><el-tag :type="scope.row.operationType === '1' ? 'warning' : 'primary'" size="small">{{ scope.row.operationType === '1' ? '体验' : '持卡' }}</el-tag></template>
                </el-table-column>
                <el-table-column label="套餐名称" min-width="140" show-overflow-tooltip>
                  <template #default="scope">
                    {{ scope.row.packageName || scope.row.packageNo || '-' }}
                  </template>
                </el-table-column>
                <el-table-column label="品项" prop="productName" min-width="100" show-overflow-tooltip />
                <el-table-column label="次数" prop="operationQuantity" width="60" align="center" />
                <el-table-column label="消耗/体验价" width="100" align="center">
                  <template #default="scope">{{ scope.row.operationType === '1' ? scope.row.trialPrice : scope.row.consumeAmount }}</template>
                </el-table-column>
                <el-table-column label="操作人" width="100" align="center">
                  <template #default="scope">
                    {{ getOperatorRealName(scope.row) }}
                  </template>
                </el-table-column>
                <el-table-column label="满意度" width="120" align="center">
                  <template #default="scope">
                    <el-rate 
                      :model-value="Number(scope.row.satisfaction || 0)" 
                      disabled 
                      size="small" 
                      v-if="scope.row.satisfaction !== null && scope.row.satisfaction !== undefined && scope.row.satisfaction !== ''"
                    />
                    <span v-else>-</span>
                  </template>
                </el-table-column>
                <el-table-column label="操作日期" prop="operationDate" width="110" />
              </el-table>
            </el-tab-pane>
          </el-tabs>

          <el-dialog title="还款" v-model="repayDialogVisible" width="500px" append-to-body>
            <el-form :model="repayForm" label-width="80px">
              <el-form-item label="套餐名称">
                <span>{{ repayForm.packageName || '-' }}</span>
              </el-form-item>
              <el-form-item label="欠款金额">
                <span style="color: #f56c6c; font-weight: 600">¥{{ Number(repayForm.owedAmount || 0).toFixed(2) }}</span>
              </el-form-item>
              <el-form-item label="还款金额" required>
                <el-input-number v-model="repayForm.repaymentAmount" :min="0.01" :max="Number(repayForm.owedAmount || 0)" :precision="2" controls-position="right" style="width: 100%" />
              </el-form-item>
              <el-form-item label="支付方式">
                <el-select v-model="repayForm.paymentMethod" style="width: 100%">
                  <el-option v-for="dict in biz_payment_method" :key="dict.value" :label="dict.label" :value="dict.value" />
                </el-select>
              </el-form-item>
              <el-form-item label="备注">
                <el-input v-model="repayForm.remark" type="textarea" :rows="2" placeholder="请输入备注" />
              </el-form-item>
            </el-form>
            <template #footer>
              <el-button type="primary" :loading="repaySubmitting" @click="submitRepay">确认还款</el-button>
              <el-button @click="repayDialogVisible = false">取消</el-button>
            </template>
          </el-dialog>

          <el-dialog title="新增档案" v-model="archiveDialogVisible" width="650px" append-to-body>
            <el-form :model="archiveForm" label-width="80px">
              <el-row :gutter="16">
                <el-col :span="12">
                  <el-form-item label="档案日期">
                    <el-date-picker v-model="archiveForm.archiveDate" type="date" value-format="YYYY-MM-DD" placeholder="选择日期" style="width: 100%" />
                  </el-form-item>
                </el-col>
                <el-col :span="12">
                  <el-form-item label="档案类型">
                    <el-select v-model="archiveForm.archiveType" placeholder="请选择档案类型" style="width: 100%">
                      <el-option v-for="dict in biz_archive_type.filter(d => ['preparation', 'after_sales'].includes(d.value))" :key="dict.value" :label="dict.label" :value="dict.value" />
                    </el-select>
                  </el-form-item>
                </el-col>
              </el-row>
              <el-row :gutter="16">
                <el-col :span="12">
                  <el-form-item label="操作人">
                    <el-select v-model="archiveForm.operatorUserId" filterable @change="(userId) => { const user = userOptions.find(u => u.userId === userId); if (user) archiveForm.operatorUserName = user.nick_name || user.nickName || user.userName || '' }" style="width: 100%">
                      <el-option v-for="u in userOptions" :key="u.userId" :label="u.nick_name || u.nickName || u.userName || '未设置姓名'" :value="u.userId" />
                    </el-select>
                  </el-form-item>
                </el-col>
                <el-col :span="12">
                  <el-form-item label="金额">
                    <el-input-number v-model="archiveForm.amount" :min="0" :precision="2" controls-position="right" style="width: 100%" />
                  </el-form-item>
                </el-col>
              </el-row>
              <el-divider content-position="left">方案项目</el-divider>
              <el-table :data="archiveForm.planItems" border size="small" style="width: 100%">
                <el-table-column label="品项名称" min-width="150">
                  <template #default="scope">
                    <el-input v-model="scope.row.name" placeholder="品项名称" />
                  </template>
                </el-table-column>
                <el-table-column label="次数" width="100">
                  <template #default="scope">
                    <el-input-number v-model="scope.row.quantity" :min="1" controls-position="right" style="width: 100%" />
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="60" align="center">
                  <template #default="scope">
                    <el-button link type="danger" icon="Delete" @click="removeArchiveItemRow(scope.$index)" />
                  </template>
                </el-table-column>
              </el-table>
              <el-button type="primary" link icon="Plus" @click="addArchiveItemRow" style="margin-top: 8px">添加品项</el-button>
              <el-form-item label="满意度" style="margin-top: 12px">
                <el-rate v-model="archiveForm.satisfaction" :colors="['#99A9BF', '#F7BA2A', '#FF9900']" />
              </el-form-item>
              <el-form-item label="照片">
                <image-upload v-model="archiveForm.photos" :limit="6" :fileSize="5" width="60" height="60" />
              </el-form-item>
              <el-form-item label="顾客反馈">
                <el-input v-model="archiveForm.customerFeedback" type="textarea" :rows="2" placeholder="请输入顾客反馈" />
              </el-form-item>
              <el-form-item label="备注">
                <el-input v-model="archiveForm.remark" type="textarea" :rows="2" placeholder="请输入备注" />
              </el-form-item>
            </el-form>
            <template #footer>
              <el-button type="primary" @click="submitArchiveForm">确 定</el-button>
              <el-button @click="archiveDialogVisible = false">取 消</el-button>
            </template>
          </el-dialog>
        </el-card>
        <el-card shadow="never" v-else>
          <el-empty description="请从左侧选择客户" :image-size="100" />
        </el-card>
      </el-col>
    </el-row>

    <el-dialog :title="customerDialogTitle" v-model="customerDialogVisible" width="500px" append-to-body>
      <el-form ref="customerFormRef" :model="customerForm" :rules="customerRules" label-width="80px">
        <el-form-item label="头像">
          <div style="display: flex; align-items: center; gap: 12px;">
            <el-avatar :size="56" :src="customerForm.avatar || undefined" :style="{ background: customerForm.gender === '1' ? '#FF6B9D' : '#3D6DF7', fontSize: '22px' }" @error="() => { customerForm.avatar = '' }">
              {{ customerForm.customerName ? customerForm.customerName.charAt(0) : '' }}
            </el-avatar>
            <el-upload
              action="#"
              :auto-upload="false"
              :show-file-list="false"
              :on-change="handleCustomerAvatarChange"
              accept="image/*"
            >
              <el-button size="small" type="primary" plain>选择图片</el-button>
            </el-upload>
          </div>
        </el-form-item>
        <el-form-item label="客户姓名" prop="customerName">
          <el-input v-model="customerForm.customerName" placeholder="请输入客户姓名" />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="customerForm.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="微信" prop="wechat">
          <el-input v-model="customerForm.wechat" placeholder="请输入微信" />
        </el-form-item>
        <el-row>
          <el-col :span="12">
            <el-form-item label="性别" prop="gender">
              <el-radio-group v-model="customerForm.gender">
                <el-radio value="0">男</el-radio>
                <el-radio value="1">女</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="年龄" prop="age">
              <el-input-number v-model="customerForm.age" :min="0" :max="150" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="客户标签" prop="tag">
          <el-select v-model="customerForm.tag" placeholder="请选择标签" clearable multiple style="width: 100%">
            <el-option v-for="dict in biz_customer_tag" :key="dict.value" :label="dict.label" :value="dict.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="customerForm.remark" type="textarea" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitCustomerForm">确 定</el-button>
        <el-button @click="customerDialogVisible = false">取 消</el-button>
      </template>
    </el-dialog>

    <el-dialog title="创建门店" v-model="storeDialogVisible" width="500px" append-to-body>
      <el-form ref="storeFormRef" :model="storeForm" :rules="storeRules" label-width="100px">
        <el-form-item label="门店名称" prop="storeName">
          <el-input v-model="storeForm.storeName" placeholder="请输入门店名称" />
        </el-form-item>
        <el-form-item label="门店负责人" prop="managerName">
          <el-input v-model="storeForm.managerName" placeholder="请输入门店负责人" />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="storeForm.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="地址" prop="address">
          <el-input v-model="storeForm.address" placeholder="请输入地址" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="storeForm.remark" type="textarea" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitQuickStore">确 定</el-button>
        <el-button @click="storeDialogVisible = false">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Sales">
/**
 * @description 销售开单页面 - 客户选择/开单/持卡操作/体验操作/还款/档案管理
 * @description 核心业务页面，提供企业→门店→客户三级联动选择、销售开单、
 * 持卡操作（消耗套餐品项）、体验操作（非套餐品项）、还款管理、客户档案管理等功能
 */
import { searchEnterprise as searchEnterpriseApi } from "@/api/business/enterprise"
import { searchStore, addStore } from "@/api/business/store"
import { searchCustomer, addCustomer, updateCustomer, getCustomer, uploadCustomerAvatar } from "@/api/business/customer"
import { addSalesOrder, listSalesOrder } from "@/api/business/salesOrder"
import { getPackageByCustomer } from "@/api/business/customerPackage"
import { addOperation, listOperation } from "@/api/business/operationRecord"
import { getOwedPackages, addRepayment, listRepayment, auditRepayment } from "@/api/business/repayment"
import { listArchive, addArchive, deleteArchive } from "@/api/business/customerArchive"
import { searchCardItem } from "@/api/business/cardItem"
import { listUser } from "@/api/system/user"
import { getConfigKey } from '@/api/system/config'
import useUserStore from '@/store/modules/user'

const userStore = useUserStore()
const { proxy } = getCurrentInstance()
const { biz_customer_tag, biz_archive_type, biz_payment_method } = useDict("biz_customer_tag", "biz_archive_type", "biz_payment_method")

const currentEnterpriseId = ref(null)
const currentStoreId = ref(null)
const currentCustomerId = ref(null)
const currentCustomer = ref(null)
const activeTab = ref('order')
const customerKeyword = ref('')
const filterSatisfaction = ref(null)
const showTrialForm = ref(false)
const operationDrawerVisible = ref(false)
const trialDrawerVisible = ref(false)
const expandedPackages = ref([])

const enterpriseOptions = ref([])
const storeOptions = ref([])
const customerList = ref([])
const packageList = ref([])
const userOptions = ref([])
const orderItems = ref([])
const orderStoreDealer = ref('')
const orderCustomerFeedback = ref('')
const orderPackageName = ref('')
const cardItemOptions = ref([])
const cardItemSearchLoading = ref(false)
const orderRecordList = ref([])
const operationRecordList = ref([])
const orderRecordDateRange = ref([])
const operationRecordDateRange = ref([])
const orderRecordCreatorUserId = ref(null)
const operationRecordProductName = ref('')
const operationRecordOperatorUserId = ref(null)
const operationRecordSatisfaction = ref(null)

const customerDialogVisible = ref(false)
const customerDialogTitle = ref('')
const storeDialogVisible = ref(false)
const customerForm = ref({})
const storeForm = ref({})

const operationForm = ref({
  operationDate: '', operatorUserId: null, operatorUserName: '',
  satisfaction: 5, customerFeedback: '', beforePhoto: '', afterPhoto: '', remark: ''
})

const trialForm = ref({
  productName: '', operationQuantity: 1, trialPrice: 0,
  operationDate: '', operatorUserId: null, operatorUserName: '',
  satisfaction: 5, customerFeedback: '', beforePhoto: '', afterPhoto: '', remark: ''
})

const selectedOperationItems = ref([])
const showExhaustedItems = ref(false)

const owedPackageList = ref([])
const repaymentRecordList = ref([])
const repayDialogVisible = ref(false)
const repaySubmitting = ref(false)
const repayForm = ref({
  packageId: null, packageNo: '', packageName: '',
  orderId: null, orderNo: '', owedAmount: 0,
  repaymentAmount: 0, paymentMethod: 'cash', remark: ''
})

const archiveList = ref([])
const archiveFilterType = ref('')
const archiveDateRange = ref([])
const archiveDialogVisible = ref(false)
const archiveForm = ref({})

const packageQuantityEditable = ref(true)
const packageDealAmountEditable = ref(true)
const packagePaidAmountEditable = ref(true)

const filteredPackageList = computed(() => {
  return packageList.value.filter(pkg => {
    if (pkg.status === '2' && !showExhaustedItems.value) return false
    return true
  })
})

function getOrderStatusName(status) {
  const map = { '0': '待确认', '1': '企业已审', '2': '财务已审', '4': '已取消' }
  return map[status] || '未知'
}

function parsePhotos(photoStr) {
  if (!photoStr) return []
  try {
    const parsed = JSON.parse(photoStr)
    return Array.isArray(parsed) ? parsed : [photoStr]
  } catch { return photoStr.split(',').filter(s => s.trim()) }
}

const customerRules = { customerName: [{ required: true, message: '客户姓名不能为空', trigger: 'blur' }] }
const storeRules = { storeName: [{ required: true, message: '门店名称不能为空', trigger: 'blur' }] }

const totalDealAmount = computed(() => orderItems.value.reduce((sum, item) => sum + parseFloat(item.dealAmount || 0), 0))
const canAddOrderItem = computed(() => {
  const roles = userStore.roles
  return !roles.includes('mother') && !roles.includes('母亲')
})

onMounted(() => {
  loadEnterpriseList()
  loadUserList()
  operationForm.value.operatorUserId = userStore.id
  operationForm.value.operatorUserName = userStore.nickName || ''
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
    // 读取失败时使用默认值（全部可编辑）
  }
}

function loadEnterpriseList() {
  searchEnterpriseApi('').then(res => {
    enterpriseOptions.value = res.data || []
    const savedEnterpriseId = sessionStorage.getItem('sales_enterpriseId')
    if (savedEnterpriseId) {
      currentEnterpriseId.value = Number(savedEnterpriseId)
      loadStoreList(savedEnterpriseId)
    }
  })
}

function loadUserList() {
  listUser({ pageSize: 200 }).then(res => { userOptions.value = res.rows || [] })
}

function handleEnterpriseChange(val) {
  currentStoreId.value = null
  storeOptions.value = []
  currentCustomer.value = null
  currentCustomerId.value = null
  customerList.value = []
  if (val) {
    loadStoreList(val)
    sessionStorage.setItem('sales_enterpriseId', val)
  } else {
    sessionStorage.removeItem('sales_enterpriseId')
  }
  sessionStorage.removeItem('sales_storeId')
}

function loadStoreList(enterpriseId) {
  searchStore('', enterpriseId).then(res => {
    storeOptions.value = res.data || []
    const savedStoreId = sessionStorage.getItem('sales_storeId')
    if (savedStoreId && storeOptions.value.length > 0) {
      currentStoreId.value = Number(savedStoreId)
      loadCustomerList()
    }
  })
}

function handleStoreChange() {
  currentCustomer.value = null
  currentCustomerId.value = null
  customerList.value = []
  if (currentStoreId.value) {
    loadCustomerList()
    sessionStorage.setItem('sales_storeId', currentStoreId.value)
  } else {
    sessionStorage.removeItem('sales_storeId')
  }
}

function loadCustomerList() {
  searchCustomer(customerKeyword.value, currentEnterpriseId.value, currentStoreId.value, '', filterSatisfaction.value).then(res => {
    customerList.value = res.data || []
  })
}

function handleSearchCustomer() { loadCustomerList() }

function handleSelectCustomer(item) {
  currentCustomerId.value = item.customerId
  currentCustomer.value = item
  activeTab.value = 'order'
  orderItems.value = []
  orderCustomerFeedback.value = ''
  orderStoreDealer.value = ''
  resetOperationForm()
  selectedOperationItems.value = []
  showTrialForm.value = false
  operationDrawerVisible.value = false
  trialDrawerVisible.value = false
  loadPackageList()
  loadOrderRecords()
  loadOperationRecords()
  loadOwedPackages()
  loadRepaymentRecords()
  loadArchiveList()
}

function addOrderItemRow() {
  orderItems.value.push({
    cardItemId: null, productName: '', quantity: 1, dealAmount: 0, paidAmount: 0, paymentMethod: 'cash'
  })
}

function handleCardItemFocus() {
  if (cardItemOptions.value.length === 0) {
    handleSearchCardItem('')
  }
}

function handleSearchCardItem(keyword) {
  cardItemSearchLoading.value = true
  searchCardItem(keyword || '').then(res => {
    cardItemOptions.value = res.data || []
  }).finally(() => {
    cardItemSearchLoading.value = false
  })
}

function onCardItemSelect(index, cardItemId) {
  const item = orderItems.value[index]
  if (!cardItemId) {
    item.cardItemId = null
    item.productName = ''
    item.quantity = 1
    item.dealAmount = 0
    return
  }
  const cardItem = cardItemOptions.value.find(c => c.cardItemId === cardItemId)
  if (cardItem) {
    item.cardItemId = cardItemId
    item.productName = cardItem.cardItemName
    item.quantity = cardItem.defaultQuantity || 1
    item.dealAmount = cardItem.suggestedPrice || 0
    item.paidAmount = item.dealAmount
  }
}

function onItemPaymentMethodChange(index) {
  if (orderItems.value[index].paymentMethod === 'gift') {
    orderItems.value[index].dealAmount = 0
    orderItems.value[index].paidAmount = 0
  }
}

function submitOrder() {
  if (orderItems.value.length === 0) return proxy.$modal.msgWarning('请添加品项')
  const hasEmpty = orderItems.value.some(i => !i.productName)
  if (hasEmpty) return proxy.$modal.msgWarning('请选择品项')

  const ent = enterpriseOptions.value.find(e => e.enterpriseId === currentEnterpriseId.value)
  const store = storeOptions.value.find(s => s.storeId === currentStoreId.value)
  const data = {
    customerId: currentCustomer.value.customerId,
    customerName: currentCustomer.value.customerName,
    enterpriseId: currentEnterpriseId.value,
    enterpriseName: ent?.enterpriseName,
    storeId: currentStoreId.value,
    storeName: store?.storeName,
    orderStatus: '0',
    packageName: orderPackageName.value,
    storeDealer: orderStoreDealer.value,
    customerFeedback: orderCustomerFeedback.value,
    remark: '',
    items: orderItems.value
  }
  addSalesOrder(data).then(() => {
    proxy.$modal.msgSuccess('开单成功')
    orderItems.value = []
    orderCustomerFeedback.value = ''
    orderStoreDealer.value = ''
    orderPackageName.value = ''
    loadPackageList()
    loadOrderRecords()
    loadCustomerList()
    loadArchiveList()
  })
}

function loadPackageList() {
  if (!currentCustomerId.value) return
  getPackageByCustomer(currentCustomerId.value).then(res => {
    packageList.value = res.data || []
    expandedPackages.value = packageList.value.map(p => p.packageId)
  })
}

function resetOperationForm() {
  operationForm.value = {
    operationDate: new Date().toISOString().slice(0, 10),
    operatorUserId: userStore.id,
    operatorUserName: userStore.nickName || '',
    satisfaction: 5, customerFeedback: '', beforePhoto: '', afterPhoto: '', remark: ''
  }
}

function handleOperationItemSelect(selection, pkg) {
  const existingItems = selectedOperationItems.value.filter(i => i.packageId !== pkg.packageId)
  const newItems = selection.map(item => ({
    ...item,
    packageId: pkg.packageId,
    packageName: pkg.packageName,
    packageNo: pkg.packageNo,
    operationQuantity: 1,
    consumeAmount: item.unitPrice
  }))
  selectedOperationItems.value = [...existingItems, ...newItems]
  showTrialForm.value = false
  trialDrawerVisible.value = false
  if (selectedOperationItems.value.length > 0) {
    operationDrawerVisible.value = true
  }
}

function calcItemConsumeAmount(index) {
  const item = selectedOperationItems.value[index]
  if (item) {
    item.consumeAmount = Math.round((item.unitPrice || 0) * item.operationQuantity * 100) / 100
  }
}

function handleOperatorChange(userId) {
  const user = userOptions.value.find(u => u.userId === userId)
  if (user) operationForm.value.operatorUserName = user.nick_name || user.nickName || user.userName || ''
}

function showTrialOperation() {
  trialForm.value = {
    productName: '', operationQuantity: 1, trialPrice: 0,
    operationDate: new Date().toISOString().slice(0, 10),
    operatorUserId: userStore.id,
    operatorUserName: userStore.nickName || '',
    satisfaction: 5, customerFeedback: '', beforePhoto: '', afterPhoto: '', remark: ''
  }
  showTrialForm.value = true
  trialDrawerVisible.value = true
  resetOperationForm()
  selectedOperationItems.value = []
}

function handleTrialOperatorChange(userId) {
  const user = userOptions.value.find(u => u.userId === userId)
  if (user) trialForm.value.operatorUserName = user.nick_name || user.nickName || user.userName || ''
}

function submitOperation(operationType) {
  const ent = enterpriseOptions.value.find(e => e.enterpriseId === currentEnterpriseId.value)
  const store = storeOptions.value.find(s => s.storeId === currentStoreId.value)

  if (operationType === '0') {
    if (selectedOperationItems.value.length === 0) return proxy.$modal.msgWarning('请选择操作品项')

    const batchId = 'OB' + new Date().toISOString().replace(/[-T:.Z]/g, '').substring(0, 14) + String(Math.floor(Math.random() * 10000)).padStart(4, '0')
    const promises = selectedOperationItems.value.map(item => {
      const data = {
        operationType: '0',
        customerId: currentCustomer.value.customerId,
        customerName: currentCustomer.value.customerName,
        packageId: item.packageId,
        packageNo: item.packageNo,
        operationBatchId: batchId,
        packageItemId: item.packageItemId,
        productName: item.productName,
        operationQuantity: item.operationQuantity,
        consumeAmount: item.consumeAmount,
        customerFeedback: operationForm.value.customerFeedback,
        satisfaction: operationForm.value.satisfaction,
        beforePhoto: operationForm.value.beforePhoto,
        afterPhoto: operationForm.value.afterPhoto,
        operatorUserId: operationForm.value.operatorUserId,
        operatorUserName: operationForm.value.operatorUserName,
        operationDate: operationForm.value.operationDate,
        enterpriseId: currentEnterpriseId.value,
        storeId: currentStoreId.value,
        remark: operationForm.value.remark
      }
      return addOperation(data)
    })
    Promise.all(promises).then(() => {
      proxy.$modal.msgSuccess('持卡操作提交成功')
      resetOperationForm()
      selectedOperationItems.value = []
      operationDrawerVisible.value = false
      loadPackageList()
      loadOperationRecords()
      loadArchiveList()
    })
  } else {
    if (!trialForm.value.productName) return proxy.$modal.msgWarning('请输入操作项目')

    const data = {
      operationType: '1',
      customerId: currentCustomer.value.customerId,
      customerName: currentCustomer.value.customerName,
      productName: trialForm.value.productName,
      operationQuantity: trialForm.value.operationQuantity,
      trialPrice: trialForm.value.trialPrice,
      customerFeedback: trialForm.value.customerFeedback,
      satisfaction: trialForm.value.satisfaction,
      beforePhoto: trialForm.value.beforePhoto,
      afterPhoto: trialForm.value.afterPhoto,
      operatorUserId: trialForm.value.operatorUserId,
      operatorUserName: trialForm.value.operatorUserName,
      operationDate: trialForm.value.operationDate,
      enterpriseId: currentEnterpriseId.value,
      storeId: currentStoreId.value,
      remark: trialForm.value.remark
    }
    addOperation(data).then(() => {
      proxy.$modal.msgSuccess('体验操作提交成功')
      showTrialForm.value = false
      trialDrawerVisible.value = false
      loadOperationRecords()
      loadArchiveList()
    })
  }
}

function loadOrderRecords() {
  if (!currentCustomerId.value) return
  const params = { customerId: currentCustomer.value.customerId, pageSize: 100 }
  if (orderRecordDateRange.value && orderRecordDateRange.value.length === 2) {
    params.startDate = orderRecordDateRange.value[0]
    params.endDate = orderRecordDateRange.value[1]
  }
  if (orderRecordCreatorUserId.value) {
    params.creatorUserId = orderRecordCreatorUserId.value
  }
  listSalesOrder(params).then(res => { orderRecordList.value = res.rows || [] })
}

function loadOperationRecords() {
  if (!currentCustomerId.value) return
  const params = { customerId: currentCustomer.value.customerId, pageSize: 100 }
  if (operationRecordDateRange.value && operationRecordDateRange.value.length === 2) {
    params.startDate = operationRecordDateRange.value[0]
    params.endDate = operationRecordDateRange.value[1]
  }
  if (operationRecordProductName.value) {
    params.productName = operationRecordProductName.value
  }
  if (operationRecordOperatorUserId.value) {
    params.operatorUserId = operationRecordOperatorUserId.value
  }
  if (operationRecordSatisfaction.value) {
    params.satisfaction = operationRecordSatisfaction.value
  }
  listOperation(params).then(res => {
    operationRecordList.value = res.rows || []
  })
}

function getOperatorRealName(row) {
  const userId = row.operatorUserId || row.operator_id || row.userId || row.user_id
  const userName = row.operatorUserName || row.operator_name || row.userName || row.user_name || row.createBy

  if (userName && userName !== '-' && userName !== 'null' && userName !== 'undefined') {
    return userName
  }

  if (userId) {
    const user = userOptions.value.find(u => u.userId === userId || u.id === userId)
    if (user) {
      const name = user.nickName || user.userName || '-'
      return name
    }
  }

  return userName || '-'
}

function loadOwedPackages() {
  if (!currentCustomerId.value) return
  getOwedPackages(currentCustomer.value.customerId).then(res => {
    owedPackageList.value = res.data || []
  })
}

function loadRepaymentRecords() {
  if (!currentCustomerId.value) return
  listRepayment({ customerId: currentCustomer.value.customerId, pageSize: 100 }).then(res => {
    repaymentRecordList.value = res.rows || []
  })
}

function openRepayDialog(pkg) {
  repayForm.value = {
    packageId: pkg.packageId,
    packageNo: pkg.packageNo,
    packageName: pkg.packageName,
    orderId: pkg.orderId,
    orderNo: pkg.orderNo,
    owedAmount: pkg.owedAmount,
    repaymentAmount: Number(pkg.owedAmount || 0),
    paymentMethod: 'cash',
    remark: ''
  }
  repayDialogVisible.value = true
}

function submitRepay() {
  if (!repayForm.value.repaymentAmount || repayForm.value.repaymentAmount <= 0) {
    return proxy.$modal.msgWarning('请输入有效的还款金额')
  }
  if (repayForm.value.repaymentAmount > Number(repayForm.value.owedAmount || 0)) {
    return proxy.$modal.msgWarning('还款金额不能超过欠款金额')
  }

  const ent = enterpriseOptions.value.find(e => e.enterpriseId === currentEnterpriseId.value)
  const store = storeOptions.value.find(s => s.storeId === currentStoreId.value)
  repaySubmitting.value = true
  addRepayment({
    customerId: currentCustomer.value.customerId,
    customerName: currentCustomer.value.customerName,
    packageId: repayForm.value.packageId,
    packageNo: repayForm.value.packageNo,
    packageName: repayForm.value.packageName,
    orderId: repayForm.value.orderId,
    orderNo: repayForm.value.orderNo,
    repaymentAmount: repayForm.value.repaymentAmount,
    repaymentType: '1',
    paymentMethod: repayForm.value.paymentMethod,
    remark: repayForm.value.remark,
    enterpriseId: currentEnterpriseId.value,
    enterpriseName: ent ? ent.enterpriseName : '',
    storeId: currentStoreId.value,
    storeName: store ? store.storeName : '',
    autoAudit: true
  }).then(() => {
    proxy.$modal.msgSuccess('还款成功')
    repayDialogVisible.value = false
    loadOwedPackages()
    loadRepaymentRecords()
    loadPackageList()
    loadArchiveList()
  }).catch(() => {
    proxy.$modal.msgError('还款失败')
  }).finally(() => {
    repaySubmitting.value = false
  })
}

function handleAuditRepayment(repaymentId) {
  proxy.$modal.confirm('确认审核该还款记录？审核后欠款金额将更新。').then(() => {
    auditRepayment(repaymentId).then(() => {
      proxy.$modal.msgSuccess('审核成功')
      loadOwedPackages()
      loadRepaymentRecords()
      loadPackageList()
    })
  }).catch(() => {})
}

function getPaymentMethodName(method) {
  const map = { cash: '现金', wechat: '微信', alipay: '支付宝', bank: '银行卡' }
  return map[method] || method || '-'
}

function getRepaymentStatusName(status) {
  const map = { '0': '待审核', '1': '已审核', '2': '已取消' }
  return map[status] || '未知'
}

function loadArchiveList() {
  if (!currentCustomerId.value) return
  const params = { customerId: currentCustomer.value.customerId, pageSize: 100 }
  if (archiveFilterType.value) params.sourceType = archiveFilterType.value
  if (archiveDateRange.value && archiveDateRange.value.length === 2) {
    params.startDate = archiveDateRange.value[0]
    params.endDate = archiveDateRange.value[1]
  }
  listArchive(params).then(res => { archiveList.value = res.rows || [] })
}

function getSourceTypeLabel(type) {
  const map = { '0': '开单', '1': '操作', '2': '还款', '3': '手动' }
  return map[type] || '未知'
}

function getSourceTypeTagType(type) {
  const map = { '0': '', '1': 'success', '2': 'warning', '3': 'info' }
  return map[type] || 'info'
}

function getArchiveTypeLabel(value) {
  const dict = biz_archive_type.value.find(d => d.value === value)
  return dict ? dict.label : value
}

function parsePlanItems(planItemsStr) {
  if (!planItemsStr) return []
  try {
    return JSON.parse(planItemsStr)
  } catch { return [] }
}

function parseArchivePhotos(photosStr) {
  if (!photosStr) return []
  try {
    const parsed = JSON.parse(photosStr)
    return Array.isArray(parsed) ? parsed.map(url => {
      if (!url) return null
      if (url.startsWith('http://') || url.startsWith('https://')) return url
      return '/profile/upload/' + url
    }).filter(Boolean) : []
  } catch {
    return photosStr.split(',').map(s => {
      s = s.trim()
      if (!s) return null
      if (s.startsWith('http') || s.startsWith('/profile/')) return s
      return '/profile/upload/' + s
    }).filter(Boolean)
  }
}

function handleAddArchive() {
  archiveForm.value = {
    customerId: currentCustomer.value.customerId,
    customerName: currentCustomer.value.customerName,
    enterpriseId: currentEnterpriseId.value,
    storeId: currentStoreId.value,
    archiveDate: new Date().toISOString().slice(0, 10),
    archiveType: 'preparation',
    planItems: [{ name: '', quantity: 1 }],
    amount: 0,
    satisfaction: 5,
    operatorUserId: userStore.id,
    operatorUserName: userStore.nickName || '',
    photos: '',
    customerFeedback: '',
    remark: ''
  }
  archiveDialogVisible.value = true
}

function addArchiveItemRow() {
  archiveForm.value.planItems.push({ name: '', quantity: 1 })
}

function removeArchiveItemRow(index) {
  archiveForm.value.planItems.splice(index, 1)
}

function submitArchiveForm() {
  const validItems = archiveForm.value.planItems.filter(i => i.name)
  const data = {
    ...archiveForm.value,
    planItems: validItems.length > 0 ? validItems : []
  }
  addArchive(data).then(() => {
    proxy.$modal.msgSuccess('新增档案成功')
    archiveDialogVisible.value = false
    loadArchiveList()
  })
}

function handleDeleteArchive(row) {
  proxy.$modal.confirm('确认删除该档案记录？').then(() => {
    deleteArchive(row.archiveId).then(() => {
      proxy.$modal.msgSuccess('删除成功')
      loadArchiveList()
    })
  }).catch(() => {})
}

function handleAddCustomer() {
  customerForm.value = { customerName: '', phone: '', wechat: '', gender: '0', age: null, tag: [], remark: '', avatar: '', avatarFile: null }
  customerDialogTitle.value = '新增客户'
  customerDialogVisible.value = true
}

async function handleEditCustomer(item) {
  try {
    const res = await getCustomer(item.customerId)
    const data = res.data || res
    customerForm.value = {
      customerId: data.customerId || data.customer_id,
      customerName: data.customerName || data.customer_name || '',
      phone: data.phone || '',
      wechat: data.wechat || '',
      gender: String(data.gender ?? '0'),
      age: data.age || null,
      tag: data.tag ? data.tag.split(',') : [],
      remark: data.remark || '',
      avatar: data.avatar || '',
      avatarFile: null
    }
    customerDialogTitle.value = '编辑客户'
    customerDialogVisible.value = true
  } catch (e) {
    console.error('加载客户详情失败:', e)
    proxy.$modal.msgError('加载客户信息失败')
  }
}

function handleCustomerAvatarChange(file) {
  if (file && file.raw) {
    customerForm.value.avatarFile = file.raw
    customerForm.value.avatar = URL.createObjectURL(file.raw)
  }
}

function submitCustomerForm() {
  proxy.$refs.customerFormRef.validate(valid => {
    if (valid) {
      const ent = enterpriseOptions.value.find(e => e.enterpriseId === currentEnterpriseId.value)
      const store = storeOptions.value.find(s => s.storeId === currentStoreId.value)
      const data = {
        ...customerForm.value,
        tag: customerForm.value.tag.join(','),
        enterpriseId: currentEnterpriseId.value,
        enterpriseName: ent?.enterpriseName,
        storeId: currentStoreId.value,
        storeName: store?.storeName
      }
      delete data.avatarFile
      if (data.avatar && (data.avatar.startsWith('blob:') || data.avatar.startsWith('data:'))) {
        delete data.avatar
      }
      const isEdit = !!customerForm.value.customerId
      const apiCall = isEdit ? updateCustomer(data) : addCustomer(data)
      apiCall.then(async res => {
        const customerId = isEdit ? customerForm.value.customerId : (res?.data?.customerId || res?.data?.customer_id)
        if (customerId && customerForm.value.avatarFile) {
          await uploadCustomerAvatar(customerId, customerForm.value.avatarFile)
        }
        proxy.$modal.msgSuccess(isEdit ? '修改成功' : '新增成功')
        customerDialogVisible.value = false
        if (customerForm.value.avatar && customerForm.value.avatar.startsWith('blob:')) {
          URL.revokeObjectURL(customerForm.value.avatar)
        }
        loadCustomerList()
        if (!isEdit && res.data && res.data.customerId) {
          handleSelectCustomer({ customerId: res.data.customerId, ...data })
        } else if (isEdit && currentCustomerId.value === customerForm.value.customerId) {
          handleSelectCustomer({ ...currentCustomer.value, ...data })
        }
      })
    }
  })
}

function handleQuickAddStore() {
  storeForm.value = { storeName: '', managerName: '', phone: '', address: '', remark: '' }
  storeDialogVisible.value = true
}

function submitQuickStore() {
  proxy.$refs.storeFormRef.validate(valid => {
    if (valid) {
      const ent = enterpriseOptions.value.find(e => e.enterpriseId === currentEnterpriseId.value)
      const data = {
        ...storeForm.value,
        enterpriseId: currentEnterpriseId.value,
        enterpriseName: ent?.enterpriseName,
        status: '0'
      }
      addStore(data).then(() => {
        proxy.$modal.msgSuccess('门店创建成功')
        storeDialogVisible.value = false
        loadStoreList(currentEnterpriseId.value)
      })
    }
  })
}
</script>

<style scoped>
.header-card { margin-bottom: 0 }
.customer-panel { height: calc(100vh - 200px); overflow: hidden; display: flex; flex-direction: column }
.customer-panel :deep(.el-card__body) { flex: 1; overflow-y: auto }
.panel-header { display: flex; justify-content: space-between; align-items: center }
.customer-list { display: flex; flex-direction: column; gap: 10px }
.customer-item {
  padding: 12px 14px;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  border: 1px solid #e4e7ed;
  background: var(--el-bg-color);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
  position: relative;
}
.customer-item:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.12);
  border-color: #a0cfff;
  background: linear-gradient(135deg, #f5f9ff 0%, #ffffff 100%);
}
.customer-item.active {
  background: linear-gradient(135deg, #ecf5ff 0%, #f0f7ff 100%);
  border-color: #409eff;
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.15);
}
.customer-item.active::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 3px;
  height: 60%;
  background: #409eff;
  border-radius: 0 2px 2px 0;
}
.customer-header { display: flex; justify-content: space-between; align-items: center; position: relative }
.customer-name-row { display: flex; align-items: center; gap: 8px }
.customer-name-row .el-avatar {
  border: 2px solid #fff;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
  flex-shrink: 0;
}
.customer-name {
  font-weight: 600;
  font-size: 15px;
  color: #303133;
  letter-spacing: 0.3px;
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.customer-name-row .el-button {
  opacity: 0;
  transition: opacity 0.2s;
}
.customer-item:hover .customer-name-row .el-button {
  opacity: 1;
}
.customer-tags {
  display: flex;
  align-items: center;
  gap: 4px;
  flex-shrink: 0;
}
.customer-tags :deep(.el-tag) {
  border-radius: 10px;
  font-size: 11px;
  padding: 0 8px;
  height: 20px;
  line-height: 20px;
}
.customer-stats {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px dashed #ebeef5;
}
.stat-row {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.stat-item { display: flex; align-items: center; gap: 4px }
.stat-label {
  color: #909399;
  font-size: 12px;
  white-space: nowrap;
}
.stat-value {
  color: #303133;
  font-weight: 500;
  font-size: 13px;
}
.stat-value.highlight {
  color: #409eff;
  font-weight: 600;
  background: linear-gradient(135deg, #409eff 0%, #66b1ff 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
.stat-satisfaction .el-rate {
  margin-left: 4px;
}

/* 特殊状态样式 */
.customer-tags :deep(.el-tag--info) {
  background: #fef0f0;
  border-color: #fde2e2;
  color: #f56c6c;
}
.customer-tags :deep(.el-tag--warning) {
  animation: pulse 2s infinite;
}
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

.section-title { font-size: 14px; font-weight: 500; color: #303133; padding-bottom: 8px; border-bottom: 1px solid #ebeef5; margin-bottom: 12px }

.package-group-header-inline { width: 100% }
.pkg-title-row { display: flex; align-items: center; gap: 8px; flex-wrap: wrap }
.pkg-remark-row { margin-top: -2px; padding-left: 0 }
.pkg-remark-row :deep(.el-text) { padding: 0 12px }
.package-group-name { font-weight: 500; font-size: 14px; color: #303133 }
.amount-inline { font-size: 12px; color: #606266;
  &.paid { color: #67c23a }
  &.owed { color: #f56c6c }
}
.remark-inline { font-size: 12px; color: #909399; margin-left: 8px; max-width: 300px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; vertical-align: middle }
.amount-item { white-space: nowrap }
.package-group-remark { margin-top: 4px; font-size: 12px }

.archive-timeline { display: flex; flex-direction: column; gap: 12px }
.archive-card { border: 1px solid #ebeef5; border-radius: 8px; padding: 12px 16px; transition: all 0.2s; background: var(--el-bg-color) }
.archive-card:hover { box-shadow: 0 2px 8px rgba(0,0,0,0.08) }
.archive-card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; padding-bottom: 8px; border-bottom: 1px solid #f0f0f0 }
.archive-card-left { display: flex; align-items: center; gap: 8px }
.archive-date { font-weight: 500; color: #303133; font-size: 14px }
.archive-operator { color: #909399; font-size: 12px }
.archive-card-body { font-size: 13px; color: #606266; display: flex; gap: 20px; align-items: flex-start }
.archive-main { flex: 1; display: flex; flex-direction: column; gap: 8px; min-width: 0 }
.archive-photos-right { flex-shrink: 0; display: flex; gap: 8px }
.archive-label { color: #909399; font-size: 12px; white-space: nowrap }
.archive-plan-items { display: flex; align-items: flex-start; gap: 4px }
.archive-info-row { display: flex; align-items: center; gap: 16px; flex-wrap: wrap }
.archive-amount { font-size: 13px }
.archive-satisfaction { display: flex; align-items: center; gap: 4px }
.archive-photos { display: flex; align-items: flex-start; gap: 4px }
.archive-photo-list { display: flex; gap: 6px; flex-wrap: wrap }
.archive-feedback { display: flex; align-items: flex-start; gap: 4px }
.archive-remark { display: flex; align-items: flex-start; gap: 4px }
</style>
