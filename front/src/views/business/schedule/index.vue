<template>
  <div class="app-container">
    <el-tabs v-model="activeTab" @tab-change="handleTabChange">
      <el-tab-pane label="员工行程" name="employee">
        <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
          <el-form-item label="年月" prop="yearMonth">
            <el-date-picker v-model="queryParams.yearMonth" type="month" placeholder="选择年月" value-format="YYYY-MM" style="width: 160px" @change="handleQuery" />
          </el-form-item>
          <el-form-item label="员工姓名" prop="userName">
            <el-input v-model="queryParams.userName" placeholder="请输入员工姓名" clearable style="width: 160px" @keyup.enter="handleQuery" />
          </el-form-item>
          <el-form-item label="企业名称" prop="enterpriseName">
            <el-input v-model="queryParams.enterpriseName" placeholder="请输入企业名称" clearable style="width: 160px" @keyup.enter="handleQuery" />
          </el-form-item>
          <el-form-item label="下店目的" prop="purpose">
            <el-select v-model="queryParams.purpose" placeholder="请选择下店目的" clearable style="width: 140px">
              <el-option v-for="dict in biz_schedule_purpose" :key="dict.value" :label="dict.label" :value="dict.value" />
            </el-select>
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-select v-model="queryParams.status" placeholder="行程状态" clearable style="width: 120px">
              <el-option v-for="dict in biz_schedule_status" :key="dict.value" :label="dict.label" :value="dict.value" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
            <el-button icon="Refresh" @click="resetQuery">重置</el-button>
          </el-form-item>
        </el-form>

        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5">
            <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['business:schedule:add']">新增</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button type="warning" plain icon="Download" @click="handleExport" v-hasPermi="['business:schedule:export']">导出</el-button>
          </el-col>
          <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
        </el-row>

        <!-- 日历网格 - Div布局 -->
        <div class="calendar-grid" ref="calendarGridRef">
          <!-- 表头 -->
          <div class="header-row">
            <div class="name-header">员工姓名</div>
            <div class="days-header">
              <div v-for="day in daysInMonth" :key="day" class="day-header">{{ day }}日</div>
            </div>
          </div>

          <!-- 数据行 -->
          <div v-for="(row, rowIndex) in scheduleData" :key="rowIndex" class="data-row">
            <div class="name-cell">
              <div class="name-text">{{ row.userName }}</div>
              <el-tag v-if="row.postName" size="small" type="info" class="post-tag">{{ row.postName }}</el-tag>
            </div>
            <div
              class="days-container"
              @mousedown.prevent="handleRowMouseDown($event, row, rowIndex)"
              @mouseup.prevent="handleRowMouseUp"
              @mouseleave="handleMouseLeave"
            >
              <div
                v-for="day in daysInMonth"
                :key="'d-' + rowIndex + '-' + day"
                :class="['day-cell', { selected: isSelectedDay(rowIndex, day), 'rest-day': isRestDayForUser(row.userId, day), 'leave-day': isLeaveDayForUser(row.userId, day) }]"
                :style="getRestInfo(row.userId, day) ? { background: getRestInfo(row.userId, day).color + '22' } : (getLeaveInfo(row.userId, day) ? { background: getLeaveInfo(row.userId, day).color + '22' } : {})"
                :data-day="day"
                @mouseenter="handleCellEnter(rowIndex, day)"
                @click.stop="handleCellClick(row, day)"
              >
                <span v-if="getRestInfo(row.userId, day)" class="rest-label" :style="{ color: getRestInfo(row.userId, day).color, background: getRestInfo(row.userId, day).color + '1A', border: '1px solid ' + getRestInfo(row.userId, day).color + '40' }">{{ getRestInfo(row.userId, day).typeName }}</span>
                <span v-else-if="getLeaveInfo(row.userId, day)" class="leave-label" :style="{ color: getLeaveInfo(row.userId, day).color, background: getLeaveInfo(row.userId, day).color + '1A', border: '1px solid ' + getLeaveInfo(row.userId, day).color + '40' }">{{ getLeaveInfo(row.userId, day).label }}</span>
              </div>
              <template v-for="(merged, mIdx) in getMergedSchedules(row)" :key="'m-' + rowIndex + '-' + merged.startDay">
                <div
                  class="schedule-block"
                  :class="'purpose-' + merged.purpose + ' status-' + merged.status"
                  :style="getScheduleBlockStyle(merged)"
                  @click.stop="handleScheduleClick(merged)"
                >
                  <el-tooltip :content="getScheduleTooltip(merged)" placement="top" effect="dark" :show-after="200">
                    <span class="block-text">{{ merged.enterpriseName }}</span>
                  </el-tooltip>
                </div>
              </template>
            </div>
          </div>
        </div>

        <!-- 排班列表 -->
        <div class="schedule-list-section mt-4">
          <h4>排班列表</h4>
          <el-table :data="processedScheduleList" border size="small" max-height="280" table-layout="fixed">
            <el-table-column label="员工" prop="userName" min-width="100" />
            <el-table-column label="职位" prop="postName" min-width="100" />
            <el-table-column label="企业" prop="enterpriseName" min-width="130" show-overflow-tooltip />
            <el-table-column label="下店目的" min-width="90">
              <template #default="scope"><dict-tag :options="biz_schedule_purpose" :value="scope.row.purpose" /></template>
            </el-table-column>
            <el-table-column label="状态" min-width="85">
              <template #default="scope"><dict-tag :options="biz_schedule_status" :value="scope.row.status" /></template>
            </el-table-column>
            <el-table-column label="排班日期" min-width="180">
              <template #default="scope">
                <el-tag v-for="(date, idx) in scope.row.dates" :key="idx" size="small" class="date-tag mx-1">{{ date.slice(5) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="140" fixed="right">
              <template #default="scope">
                <el-button link type="primary" size="small" @click="handleGroupEdit(scope.row)" v-hasPermi="['business:schedule:edit']">编辑</el-button>
                <el-button link type="danger" size="small" @click="handleGroupDelete(scope.row)" v-hasPermi="['business:schedule:remove']">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <el-tab-pane label="企业排班" name="enterprise">
        <el-form :model="queryParams" ref="queryRef2" :inline="true" v-show="showSearch" label-width="68px">
          <el-form-item label="年月" prop="yearMonth">
            <el-date-picker v-model="queryParams.yearMonth" type="month" placeholder="选择年月" value-format="YYYY-MM" style="width: 160px" @change="handleQuery" />
          </el-form-item>
          <el-form-item label="企业名称" prop="enterpriseName">
            <el-input v-model="queryParams.enterpriseName" placeholder="请输入企业名称" clearable style="width: 160px" @keyup.enter="handleQuery" />
          </el-form-item>
          <el-form-item label="员工姓名" prop="userName">
            <el-input v-model="queryParams.userName" placeholder="请输入员工姓名" clearable style="width: 160px" @keyup.enter="handleQuery" />
          </el-form-item>
          <el-form-item label="下店目的" prop="purpose">
            <el-select v-model="queryParams.purpose" placeholder="请选择下店目的" clearable style="width: 140px">
              <el-option v-for="dict in biz_schedule_purpose" :key="dict.value" :label="dict.label" :value="dict.value" />
            </el-select>
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-select v-model="queryParams.status" placeholder="行程状态" clearable style="width: 120px">
              <el-option v-for="dict in biz_schedule_status" :key="dict.value" :label="dict.label" :value="dict.value" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
            <el-button icon="Refresh" @click="resetQuery">重置</el-button>
          </el-form-item>
        </el-form>

        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5">
            <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['business:schedule:add']">新增</el-button>
          </el-col>
          <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
        </el-row>

        <!-- 日历网格 - 企业排班 -->
        <div class="calendar-grid" ref="calendarGridRef2">
          <div class="header-row">
            <div class="name-header">企业名称</div>
            <div class="days-header">
              <div v-for="day in daysInMonth" :key="day" class="day-header">{{ day }}日</div>
            </div>
          </div>
          <div v-for="(row, rowIndex) in scheduleData" :key="rowIndex" class="data-row">
            <div class="name-cell">
              <div class="name-text">{{ row.enterpriseName }}</div>
            </div>
            <div
              class="days-container"
              @mousedown.prevent="handleRowMouseDown($event, row, rowIndex)"
              @mouseup.prevent="handleRowMouseUp"
              @mouseleave="handleMouseLeave"
            >
              <div
                v-for="day in daysInMonth"
                :key="'d-' + rowIndex + '-' + day"
                :class="['day-cell', { selected: isSelectedDay(rowIndex, day) }]"
                :data-day="day"
                @mouseenter="handleCellEnter(rowIndex, day)"
                @click.stop="handleCellClick(row, day)"
              />
              <template v-for="(merged, mIdx) in getMergedSchedules(row)" :key="'m-' + rowIndex + '-' + merged.startDay">
                <div
                  class="schedule-block"
                  :class="'purpose-' + merged.purpose + ' status-' + merged.status"
                  :style="getScheduleBlockStyle(merged)"
                  @click.stop="handleScheduleClick(merged)"
                >
                  <el-tooltip :content="getScheduleTooltip(merged)" placement="top" effect="dark" :show-after="200">
                    <span class="block-text">{{ merged.userName }}</span>
                  </el-tooltip>
                </div>
              </template>
            </div>
          </div>
        </div>

        <!-- 排班列表 -->
        <div class="schedule-list-section mt-4">
          <h4>排班列表</h4>
          <el-table :data="processedScheduleList" border size="small" max-height="280" table-layout="fixed">
            <el-table-column label="企业" prop="enterpriseName" min-width="130" show-overflow-tooltip />
            <el-table-column label="员工" prop="userName" min-width="100" />
            <el-table-column label="职位" prop="postName" min-width="100" />
            <el-table-column label="下店目的" min-width="90">
              <template #default="scope"><dict-tag :options="biz_schedule_purpose" :value="scope.row.purpose" /></template>
            </el-table-column>
            <el-table-column label="状态" min-width="85">
              <template #default="scope"><dict-tag :options="biz_schedule_status" :value="scope.row.status" /></template>
            </el-table-column>
            <el-table-column label="排班日期" min-width="180">
              <template #default="scope">
                <el-tag v-for="(date, idx) in scope.row.dates" :key="idx" size="small" class="date-tag mx-1">{{ date.slice(5) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="140" fixed="right">
              <template #default="scope">
                <el-button link type="primary" size="small" @click="handleGroupEdit(scope.row)" v-hasPermi="['business:schedule:edit']">编辑</el-button>
                <el-button link type="danger" size="small" @click="handleGroupDelete(scope.row)" v-hasPermi="['business:schedule:remove']">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <!-- Tab 3: 排班设置（左部门树 + 右员工列表，借鉴用户管理布局） -->
      <el-tab-pane label="排班设置" name="config">
        <div v-show="activeTab === 'config'" class="tree-sidebar-manage-wrap config-layout">
          <tree-panel
            title="组织机构"
            :tree-data="deptOptions"
            search-placeholder="请输入部门名称"
            storage-key="schedule-config-dept-sidebar"
            :defaultExpandAll="true"
            @node-click="handleDeptNodeClick"
            @refresh="getDeptTree"
            ref="deptTreeRef"
          />
          <div class="tree-sidebar-content">
            <div class="content-inner">
              <el-form :model="configQueryParams" ref="configQueryRef" :inline="true" v-show="showSearch" label-width="80px">
                <el-form-item label="员工姓名" prop="userName">
                  <el-input v-model="configQueryParams.userName" placeholder="请输入员工姓名" clearable style="width: 180px" @keyup.enter="queryConfig" />
                </el-form-item>
                <el-form-item label="排班显示" prop="isSchedulable">
                  <el-select v-model="configQueryParams.isSchedulable" placeholder="全部" clearable style="width: 120px">
                    <el-option label="显示" value="1" />
                    <el-option label="隐藏" value="0" />
                  </el-select>
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" icon="Search" @click="queryConfig">搜索</el-button>
                  <el-button icon="Refresh" @click="resetConfigQuery">重置</el-button>
                </el-form-item>
              </el-form>

              <el-row :gutter="10" class="mb8">
                <right-toolbar v-model:showSearch="showSearch" @queryTable="queryConfig"></right-toolbar>
              </el-row>

              <el-alert
                title="只有在下方启用为'显示'状态的员工，才会出现在'员工行程'和'企业排班'tab 的日历格子中"
                type="info"
                :closable="false"
                show-icon
                style="margin-bottom: 12px"
              />

              <el-table v-loading="configLoading" :data="employeeConfigList" border>
                <el-table-column label="员工姓名" align="center" prop="userName" min-width="100">
                  <template #default="scope">{{ scope.row.nickName || scope.row.userName }}</template>
                </el-table-column>
                <el-table-column label="部门" align="center" prop="deptName" min-width="120" show-overflow-tooltip />
                <el-table-column label="岗位" align="center" prop="postName" min-width="100" />
                <el-table-column label="手机号" align="center" prop="phonenumber" min-width="120" />
                <el-table-column label="排班显示" align="center" prop="isSchedulable" min-width="140">
                  <template #default="scope">
                    <el-switch
                      v-model="scope.row.isSchedulable"
                      active-value="1"
                      inactive-value="0"
                      active-text="显示"
                      inactive-text="隐藏"
                      @change="handleSchedulableChange(scope.row)"
                    />
                  </template>
                </el-table-column>
                <el-table-column label="休息日" align="center" min-width="200">
                  <template #default="scope">
                    <div v-if="scope.row.restDates && scope.row.restDates.length > 0">
                      <el-tag v-for="(d, idx) in scope.row.restDates" :key="idx" size="small" type="info" style="margin: 2px">{{ typeof d === 'string' ? d.substring(5) : d.date.substring(5) }}</el-tag>
                    </div>
                    <span v-else style="color: #999">未配置</span>
                  </template>
                </el-table-column>
                <el-table-column label="操作" align="center" min-width="100" v-hasPermi="['business:employeeConfig:edit']">
                  <template #default="scope">
                    <el-button link type="primary" @click="openRestDateDialog(scope.row)">配置休息日</el-button>
                  </template>
                </el-table-column>
              </el-table>

              <pagination
                v-show="configTotal > 0"
                :total="configTotal"
                v-model:page="configQueryParams.pageNum"
                v-model:limit="configQueryParams.pageSize"
                @pagination="queryConfig"
              />
            </div>
          </div>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- 添加/修改行程对话框 -->
    <el-dialog :title="title" v-model="open" width="680px" append-to-body destroy-on-close>
      <el-form ref="scheduleRef" :model="form" :rules="rules" label-width="80px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="员工" prop="userIds" v-if="activeTab === 'employee'">
              <el-select v-model="form.userIds" multiple filterable collapse-tags collapse-tags-tooltip placeholder="请选择员工" style="width: 100%">
                <el-option v-for="user in userList" :key="user.userId" :label="user.nickName || user.userName" :value="user.userId" />
              </el-select>
            </el-form-item>
            <el-form-item label="企业" prop="enterpriseId" v-else>
              <el-select v-model="form.enterpriseId" filterable remote :remote-method="searchEnterprise" :loading="searchLoading" placeholder="请搜索企业" style="width: 100%" @change="handleEnterpriseChange">
                <el-option v-for="ent in filteredEnterpriseList" :key="ent.enterpriseId" :label="ent.enterpriseName" :value="ent.enterpriseId" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="企业" prop="enterpriseId" v-if="activeTab === 'employee'">
              <el-select v-model="form.enterpriseId" filterable remote :remote-method="searchEnterprise" :loading="searchLoading" placeholder="请搜索企业" style="width: 100%" @change="handleEnterpriseChange">
                <el-option v-for="ent in filteredEnterpriseList" :key="ent.enterpriseId" :label="ent.enterpriseName" :value="ent.enterpriseId" />
              </el-select>
            </el-form-item>
            <el-form-item label="员工" prop="userIds" v-else>
              <el-select v-model="form.userIds" multiple filterable collapse-tags collapse-tags-tooltip placeholder="请选择员工" style="width: 100%">
                <el-option v-for="user in userList" :key="user.userId" :label="user.nickName || user.userName" :value="user.userId" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="排班日期" prop="selectedDates">
              <el-date-picker
                v-model="form.selectedDates"
                type="dates"
                placeholder="选择一个或多个日期（可分散点选）"
                value-format="YYYY-MM-DD"
                style="width: 100%"
                :disabled-date="disabledDate"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="下店目的" prop="purpose">
              <el-radio-group v-model="form.purpose">
                <el-radio-button v-for="dict in biz_schedule_purpose" :key="dict.value" :value="dict.value">{{ dict.label }}</el-radio-button>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="状态" prop="status">
              <el-radio-group v-model="form.status">
                <el-radio-button v-for="dict in biz_schedule_status" :key="dict.value" :value="dict.value">{{ dict.label }}</el-radio-button>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="备注" prop="remark">
              <el-input v-model="form.remark" type="textarea" :rows="2" placeholder="请输入备注" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 行程详情对话框 -->
    <el-dialog title="行程详情" v-model="detailOpen" width="500px" append-to-body>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="员工姓名">{{ currentSchedule.userName }}</el-descriptions-item>
        <el-descriptions-item label="企业名称">{{ currentSchedule.enterpriseName }}</el-descriptions-item>
        <el-descriptions-item label="行程日期">{{ currentSchedule.scheduleDate }}</el-descriptions-item>
        <el-descriptions-item label="下店目的"><dict-tag :options="biz_schedule_purpose" :value="currentSchedule.purpose" /></el-descriptions-item>
        <el-descriptions-item label="状态"><dict-tag :options="biz_schedule_status" :value="currentSchedule.status" /></el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ parseTime(currentSchedule.createTime) }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ currentSchedule.remark || '无' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="handleEdit" v-hasPermi="['business:schedule:edit']">编 辑</el-button>
          <el-button type="danger" @click="handleDelete" v-hasPermi="['business:schedule:remove']">删 除</el-button>
          <el-button @click="detailOpen = false">关 闭</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 休息日配置对话框（增强版：休假类型选择器+日历标注） -->
    <el-dialog title="配置休息日" v-model="restDateOpen" width="640px" append-to-body @open="onRestDialogOpen">
      <div style="margin-bottom: 16px">
        <span style="color: #666">员工：</span>
        <span style="font-weight: bold">{{ restDateUserName }}</span>
      </div>

      <!-- 休假类型选择器 -->
      <div style="margin-bottom: 16px">
        <div style="font-size: 14px; color: #333; margin-bottom: 8px">
          <el-icon style="vertical-align: -2px; color: #3D6DF7"><Calendar /></el-icon>
          休息日类型
        </div>
        <div style="display: flex; flex-wrap: wrap; gap: 8px">
          <el-tag
            v-for="t in leaveTypes"
            :key="t.typeId"
            :type="String(selectedTypeId) === String(t.typeId) ? 'primary' : 'info'"
            :effect="String(selectedTypeId) === String(t.typeId) ? 'dark' : 'plain'"
            style="cursor: pointer"
            @click="onTypeSelect(t.typeId, t.typeName)"
          >{{ t.typeName }}</el-tag>
          <span v-if="leaveTypes.length === 0" style="color: #909399; font-size: 12px">暂无休假类型，请到休假管理-休假类型添加</span>
        </div>
      </div>

      <!-- 图例 -->
      <div v-if="allRestTypeList.length > 0" class="rest-type-legend">
        <div v-for="t in allRestTypeList" :key="t.type" class="rest-type-legend-item">
          <span class="rest-type-legend-dot"></span>
          <span class="rest-type-legend-text">{{ t.name }} {{ t.count }}天</span>
        </div>
      </div>

      <!-- 月份导航 -->
      <div class="rest-cal-month-bar">
        <el-button link icon="ArrowLeft" @click="changeRestMonth(-1)"></el-button>
        <span class="rest-cal-month-text">{{ restCalendarMonth }}</span>
        <el-button link icon="ArrowRight" @click="changeRestMonth(1)"></el-button>
      </div>

      <!-- 自定义日历网格 -->
      <div class="rest-calendar-grid">
        <div class="rest-cal-weekday" v-for="w in weekdays" :key="w">{{ w }}</div>
        <div
          v-for="cell in calendarCells"
          :key="cell.key"
          class="rest-cal-cell"
          :class="{
            'rest-cal-empty': !cell.date,
            'rest-cal-selected': cell.selected,
            'rest-cal-rotated': cell.restType && cell.restType !== 'custom',
          }"
          @click="onCellClick(cell)"
        >
          <template v-if="cell.date">
            <span class="rest-cal-day">{{ cell.day }}</span>
            <span v-if="cell.restType" class="rest-cal-tag">
              {{ cell.restTypeName }}
            </span>
          </template>
        </div>
      </div>

      <!-- 已选日期列表 -->
      <div style="margin-top: 16px">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px">
          <span style="font-size: 14px; color: #333">已选休息日（{{ customDateList.length }}天）</span>
          <span style="font-size: 12px; color: #999">点击日历格子选择/取消日期</span>
        </div>
        <div v-if="customDateList.length > 0" style="display: flex; flex-wrap: wrap; gap: 6px">
          <el-tag
            v-for="item in customDateList"
            :key="item.date"
            size="small"
            closable
            @close="removeCustomDate(item.date)"
            style="margin: 2px"
          >{{ item.date.substring(5) }} <span style="color: #3D6DF7; margin-left: 4px">{{ item.typeName }}</span></el-tag>
        </div>
        <el-empty v-else description="点击日历选择休息日" :image-size="40" style="padding: 10px 0" />
      </div>

      <template #footer>
        <el-button @click="restDateOpen = false">取 消</el-button>
        <el-button type="primary" :loading="restSaving" @click="submitRestDates">确 定</el-button>
      </template>
    </el-dialog>

  </div>
</template>

<script setup name="Schedule">
/**
 * @description 行程管理页面 - 员工下店排班/甘特图/拖拽排班/排班设置
 * @description 提供按月查看员工/企业排班甘特图、拖拽选择日期批量添加行程、
 * 行程编辑/删除、排班设置（员工是否在行程格子中显示）等功能
 */
import { listSchedule, getSchedule, getEmployeeSchedule, getEnterpriseSchedule, addSchedule, addScheduleBatch, updateSchedule, delSchedule, getScheduleDates } from "@/api/business/schedule"
import { listUser, deptTreeSelect } from "@/api/system/user"
import { listEnterprise, searchEnterprise as searchEnterpriseApi } from "@/api/business/enterprise"
import { listEmployeeConfig, updateSchedulable, saveRestDates, getAllRestDatesAll, getAllRestDatesBatch } from "@/api/business/employeeConfig"
import { getLeaveCalendar, listAllLeaveType } from "@/api/business/leave"
import TreePanel from "@/components/TreePanel"

const { proxy } = getCurrentInstance()
const { sys_normal_disable, biz_schedule_purpose, biz_schedule_status } = useDict("sys_normal_disable", "biz_schedule_purpose", "biz_schedule_status")

const activeTab = ref("employee")
const scheduleData = ref([])
const processedScheduleList = ref([])
const open = ref(false)
const detailOpen = ref(false)
const configLoading = ref(false)
const configTotal = ref(0)
const searchLoading = ref(false)
const showSearch = ref(true)
const title = ref("")
const daysInMonth = ref(31)
const tableHeight = ref(450)
const userList = ref([])
const enterpriseList = ref([])
const filteredEnterpriseList = ref([])
const employeeConfigList = ref([])
const scheduleListData = ref([])
const restDateMap = ref({})
const leaveDateMap = ref({})
const currentSchedule = ref({})
const deptOptions = ref(undefined)

const isDragging = ref(false)
const dragStartInfo = ref(null)
const dragEndInfo = ref(null)
const selectedDays = ref(new Set())
const bookedDates = ref([])

// 禁用已安排日期（同员工同企业，排除当前行程自身日期）
function disabledDate(date) {
  const dateStr = date.toISOString().slice(0, 10)
  return bookedDates.value.includes(dateStr)
}

// 加载已安排日期（从已加载的当月排班列表中计算，排除当前行程自身日期）
function loadBookedDates(userId, enterpriseId, originalDates) {
  if (!userId || !enterpriseId) { bookedDates.value = []; return }
  bookedDates.value = scheduleListData.value
    .filter(item =>
      item.userId === userId &&
      item.enterpriseId === enterpriseId &&
      !originalDates.includes(item.scheduleDate)
    )
    .map(item => item.scheduleDate)
}

const data = reactive({
  form: {},
  queryParams: {
    yearMonth: new Date().toISOString().slice(0, 7),
    userName: undefined,
    enterpriseName: undefined,
    purpose: undefined,
    status: undefined
  },
  configQueryParams: {
    pageNum: 1,
    pageSize: 50,
    userName: undefined,
    deptId: undefined,
    isSchedulable: undefined
  },
  rules: {
    userIds: [{ required: true, message: "请选择员工", trigger: "change", type: 'array' }],
    enterpriseId: [{ required: true, message: "请选择企业", trigger: "change" }],
    selectedDates: [{ required: true, message: "请选择排班日期", trigger: "change", type: 'array' }],
    purpose: [{ required: true, message: "下店目的不能为空", trigger: "change" }]
  }
})

const { queryParams, form, rules, configQueryParams } = toRefs(data)

function getList() {
  const [year, month] = queryParams.value.yearMonth.split('-')
  const startDate = `${year}-${month}-01`
  const endDate = `${year}-${month}-${new Date(year, month, 0).getDate()}`
  daysInMonth.value = new Date(year, month, 0).getDate()

  const params = { startDate, endDate, userName: queryParams.value.userName, enterpriseName: queryParams.value.enterpriseName, purpose: queryParams.value.purpose, status: queryParams.value.status }

  if (activeTab.value === 'employee') {
    getEmployeeSchedule(params).then(response => {
      scheduleData.value = response.data || []
      getScheduleList(params)
      // 必须在 scheduleData 填充后再加载休息日和请假数据，否则 userIds 为空
      loadRestDateMap()
      loadLeaveDateMap()
    })
  } else if (activeTab.value === 'enterprise') {
    getEnterpriseSchedule(params).then(response => {
      scheduleData.value = response.data || []
      getScheduleList(params)
    })
  }
}

function getScheduleList(params) {
  listSchedule({ ...params, pageNum: 1, pageSize: 500 }).then(response => {
    scheduleListData.value = response.rows || []
    processScheduleListGroup()
  })
}

function processScheduleListGroup() {
  if (!scheduleListData.value.length) { processedScheduleList.value = []; return }
  
  const uniqueList = []
  const dateMap = new Map()
  scheduleListData.value.forEach(item => {
    const dedupeKey = `${item.userId}_${item.enterpriseId}_${item.scheduleDate}_${item.purpose}`
    if (!dateMap.has(dedupeKey)) {
      dateMap.set(dedupeKey, item)
      uniqueList.push(item)
    }
  })
  
  const grouped = {}
  uniqueList.forEach(item => {
    const status = String(item.status || '1')
    const key = `${item.userId}_${item.enterpriseId}_${item.purpose}_${status}`
    
    if (!grouped[key]) {
      grouped[key] = {
        userId: item.userId, userName: item.userName, postName: item.postName || '',
        enterpriseId: item.enterpriseId, enterpriseName: item.enterpriseName,
        purpose: item.purpose, status: status, dates: []
      }
    }
    if (!grouped[key].dates.includes(item.scheduleDate)) {
      grouped[key].dates.push(item.scheduleDate)
    }
  })
  
  processedScheduleList.value = Object.values(grouped)
}

/** 兼容后端数组格式：取 schedules[day] 的首元素（单对象场景直接返回） */
function getScheduleOfDay(schedules, day) {
  const arr = schedules?.[day]
  if (!arr) return null
  return Array.isArray(arr) ? arr[0] : arr
}

function getMergedSchedules(row) {
  if (!row.schedules) return []
  const schedules = row.schedules
  const merged = []
  let currentMerge = null

  for (let day = 1; day <= daysInMonth.value; day++) {
    const schedule = getScheduleOfDay(schedules, day)
    if (!schedule) {
      if (currentMerge) { merged.push(currentMerge); currentMerge = null }
      continue
    }

    if (!currentMerge) {
      currentMerge = { startDay: day, endDay: day, span: 1, ...schedule }
    } else if (
      schedule.purpose === currentMerge.purpose &&
      schedule.enterpriseId === currentMerge.enterpriseId &&
      schedule.status !== '4' &&
      day === currentMerge.endDay + 1
    ) {
      currentMerge.endDay = day
      currentMerge.span++
    } else {
      merged.push(currentMerge)
      currentMerge = { startDay: day, endDay: day, span: 1, ...schedule }
    }
  }
  if (currentMerge) merged.push(currentMerge)
  return merged
}

function getScheduleBlockStyle(merged) {
  const totalDays = daysInMonth.value
  const leftPercent = ((merged.startDay - 1) / totalDays) * 100
  const widthPercent = (merged.span / totalDays) * 100
  return { left: `${leftPercent}%`, width: `${widthPercent}%` }
}

function getUserList() {
  listUser({ pageNum: 1, pageSize: 1000, status: '0' }).then(response => { userList.value = response.rows || [] })
}

function getEnterpriseList() {
  listEnterprise({ pageNum: 1, pageSize: 1000, status: '0' }).then(response => {
    enterpriseList.value = response.rows || []
    filteredEnterpriseList.value = response.rows || []
  })
}

function searchEnterprise(query) {
  if (!query) { filteredEnterpriseList.value = enterpriseList.value; return }
  searchLoading.value = true
  searchEnterpriseApi(query).then(response => { filteredEnterpriseList.value = response.rows || []; searchLoading.value = false }).catch(() => { searchLoading.value = false })
}

function handleTabChange() {
  if (activeTab.value === 'config') {
    queryConfig()
  } else {
    getList()
  }
}

function handleQuery() { getList() }

function resetQuery() {
  proxy.resetForm("queryRef")
  queryParams.value.yearMonth = new Date().toISOString().slice(0, 7)
  handleQuery()
}

function cancel() { open.value = false; reset() }

function reset() {
  form.value = { scheduleId: undefined, userIds: [], userId: undefined, userName: undefined, enterpriseId: undefined, enterpriseName: undefined, selectedDates: [], purpose: undefined, status: "1", remark: undefined, scheduleIds: [], originalDates: [], originalUserIds: [] }
  bookedDates.value = []
  proxy.resetForm("scheduleRef")
}

function handleExport() {
  proxy.download("business/schedule/export", {
    ...queryParams.value,
  }, `schedule_${new Date().getTime()}.xlsx`)
}

function handleAdd() { reset(); open.value = true; title.value = "添加行程" }

function canSelectCell(schedule) { return !schedule || schedule.status === '4' }

function handleRowMouseDown(event, row, rowIndex) {
  const target = event.target
  const cell = target.closest('.day-cell')
  if (!cell) return

  const day = parseInt(cell.getAttribute('data-day'))
  if (activeTab.value === 'employee' && isUnavailableDay(row.userId, day)) return
  const schedule = getScheduleOfDay(row.schedules, day)
  if (!canSelectCell(schedule)) return

  isDragging.value = true
  dragStartInfo.value = { row, rowIndex, day }
  dragEndInfo.value = { row, rowIndex, day }
  selectedDays.value.clear()
  selectedDays.value.add(`${rowIndex}-${day}`)
}

function handleCellEnter(rowIndex, day) {
  if (!isDragging.value || !dragStartInfo.value) return
  if (dragStartInfo.value.rowIndex !== rowIndex) return

  const startDay = Math.min(dragStartInfo.value.day, day)
  const endDay = Math.max(dragStartInfo.value.day, day)

  selectedDays.value.clear()
  for (let d = startDay; d <= endDay; d++) {
    if (activeTab.value === 'employee' && isUnavailableDay(dragStartInfo.value.row.userId, d)) {
      selectedDays.value.clear()
      return
    }
    const sched = getScheduleOfDay(dragStartInfo.value.row.schedules, d)
    if (!canSelectCell(sched)) {
      selectedDays.value.clear()
      return
    }
    selectedDays.value.add(`${rowIndex}-${d}`)
  }

  dragEndInfo.value = { row: dragStartInfo.value.row, rowIndex, day }
}

function handleRowMouseUp() {
  if (!isDragging.value || !dragStartInfo.value || selectedDays.value.size < 1) {
    isDragging.value = false
    dragStartInfo.value = null
    dragEndInfo.value = null
    selectedDays.value.clear()
    return
  }

  const [year, month] = queryParams.value.yearMonth.split('-')
  const startDay = Math.min(dragStartInfo.value.day, dragEndInfo.value.day)
  const endDay = Math.max(dragStartInfo.value.day, dragEndInfo.value.day)

  reset()
  // 拖拽选择的是连续日期区间，展开为 selectedDates 数组
  const draggedDates = []
  for (let d = startDay; d <= endDay; d++) {
    draggedDates.push(`${year}-${month}-${String(d).padStart(2, '0')}`)
  }
  form.value.selectedDates = draggedDates

  if (activeTab.value === 'employee') {
    form.value.userIds = [dragStartInfo.value.row.userId]
    form.value.userName = dragStartInfo.value.row.userName
  } else {
    form.value.enterpriseId = dragStartInfo.value.row.enterpriseId
    form.value.enterpriseName = dragStartInfo.value.row.enterpriseName
  }

  open.value = true
  title.value = "添加行程"
  isDragging.value = false
  dragStartInfo.value = null
  dragEndInfo.value = null
  selectedDays.value.clear()
}

function handleMouseLeave() {}

function handleCellClick(row, day) {
  if (isDragging.value) return
  const schedule = getScheduleOfDay(row.schedules, day)
  if (schedule && schedule.status !== '4') handleScheduleClick(schedule)
}

function isSelectedDay(rowIndex, day) {
  return selectedDays.value.has(`${rowIndex}-${day}`)
}

function handleScheduleClick(schedule) { currentSchedule.value = schedule; detailOpen.value = true }

function handleEdit() {
  detailOpen.value = false
  reset()
  const schedule = currentSchedule.value

  const relatedSchedules = scheduleListData.value.filter(item =>
    item.userId === schedule.userId &&
    item.enterpriseId === schedule.enterpriseId &&
    item.purpose === schedule.purpose &&
    String(item.status) === String(schedule.status)
  ).sort((a, b) => a.scheduleDate.localeCompare(b.scheduleDate))

  const selectedDates = relatedSchedules.map(item => item.scheduleDate)
  const scheduleIds = relatedSchedules.map(item => item.scheduleId)

  form.value = {
    ...schedule,
    userIds: [schedule.userId],
    selectedDates: [...selectedDates],
    status: String(schedule.status),
    scheduleIds: [...scheduleIds],
    originalDates: [...selectedDates],
    originalUserIds: [schedule.userId]
  }
  loadBookedDates(schedule.userId, schedule.enterpriseId, selectedDates)
  open.value = true
  title.value = "修改行程"
}

function handleDelete() {
  // 按 userId+enterpriseId+purpose+status 找出同一行程的所有日期记录
  const schedule = currentSchedule.value
  const ids = scheduleListData.value.filter(item =>
    item.userId === schedule.userId &&
    item.enterpriseId === schedule.enterpriseId &&
    item.purpose === schedule.purpose &&
    String(item.status) === String(schedule.status)
  ).map(item => item.scheduleId)

  proxy.$modal.confirm(`是否确认删除该行程（共${ids.length}天）？`).then(() => delSchedule(ids.join(','))).then(() => {
    detailOpen.value = false
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

function handleGroupEdit(row) {
  reset()
  // 按 userId+enterpriseId+purpose+status 精确匹配当前分组行对应的排班记录，
  // 装配 selectedDates/scheduleIds/originalDates 支持差量更新，
  // 避免落入新增分支触发冲突检测导致编辑提交报错。
  const relatedSchedules = scheduleListData.value.filter(item =>
    item.userId === row.userId &&
    item.enterpriseId === row.enterpriseId &&
    item.purpose === row.purpose &&
    String(item.status) === String(row.status)
  ).sort((a, b) => a.scheduleDate.localeCompare(b.scheduleDate))

  const selectedDates = relatedSchedules.map(item => item.scheduleDate)
  const scheduleIds = relatedSchedules.map(item => item.scheduleId)

  form.value = {
    userIds: [row.userId],
    userId: row.userId,
    userName: row.userName,
    enterpriseId: row.enterpriseId,
    enterpriseName: row.enterpriseName,
    selectedDates: [...selectedDates],
    purpose: row.purpose,
    status: String(row.status),
    scheduleId: scheduleIds[0],
    scheduleIds: [...scheduleIds],
    originalDates: [...selectedDates],
    originalUserIds: [row.userId]
  }
  loadBookedDates(row.userId, row.enterpriseId, selectedDates)
  open.value = true
  title.value = "修改行程"
}

function handleGroupDelete(row) {
  proxy.$modal.confirm(`是否确认删除 ${row.userName} 在 ${row.enterpriseName} 的所有排班？`).then(() => {
    const ids = scheduleListData.value.filter(item => item.userId === row.userId && item.enterpriseId === row.enterpriseId && item.purpose === row.purpose).map(item => item.scheduleId)
    if (ids.length) return delSchedule(ids.join(','))
  }).then(() => { getList(); proxy.$modal.msgSuccess("删除成功") }).catch(() => {})
}

function handleEnterpriseChange(enterpriseId) {
  const enterprise = [...enterpriseList.value, ...filteredEnterpriseList.value].find(e => e.enterpriseId === enterpriseId)
  if (enterprise) form.value.enterpriseName = enterprise.enterpriseName
}

function submitForm() {
  proxy.$refs["scheduleRef"].validate(valid => {
    if (!valid) return

    // 校验 selectedDates 非空
    if (!form.value.selectedDates || form.value.selectedDates.length === 0) {
      proxy.$modal.msgError("请至少选择一个排班日期")
      return
    }

    // 前端冲突预检（排除当前行程自身日期）
    const conflictDates = form.value.selectedDates.filter(
      date => bookedDates.value.includes(date) && !form.value.originalDates.includes(date)
    )
    if (conflictDates.length > 0) {
      proxy.$modal.msgError(`以下日期已有排班安排：${conflictDates.join('、')}`)
      return
    }

    const userIds = form.value.userIds?.length ? form.value.userIds : [form.value.userId].filter(Boolean)

    // 构造 scheduleList（每个日期每个用户一条记录）
    const scheduleList = []
    form.value.selectedDates.forEach(scheduleDate => {
      userIds.forEach(userId => {
        const user = userList.value.find(u => u.userId === userId)
        scheduleList.push({
          userId: userId,
          userName: user?.nickName || user?.userName || form.value.userName,
          enterpriseId: form.value.enterpriseId,
          enterpriseName: form.value.enterpriseName,
          scheduleDate: scheduleDate,
          purpose: form.value.purpose,
          status: form.value.status,
          remark: form.value.remark
        })
      })
    })

    if (form.value.scheduleIds && form.value.scheduleIds.length > 0) {
      // 编辑模式：判断员工是否变化
      const origUserIds = (form.value.originalUserIds || []).slice().sort((a, b) => a - b)
      const curUserIds = [...userIds].sort((a, b) => a - b)
      const userChanged = JSON.stringify(origUserIds) !== JSON.stringify(curUserIds)

      if (userChanged) {
        // 员工有变化：先删后增
        doFullReplace(scheduleList)
      } else {
        // 员工无变化：差量更新日期
        const newDates = form.value.selectedDates.filter(d => !form.value.originalDates.includes(d))
        const removedDates = form.value.originalDates.filter(d => !form.value.selectedDates.includes(d))
        const keptDates = form.value.selectedDates.filter(d => form.value.originalDates.includes(d))
        doDiffUpdate(newDates, removedDates, keptDates, scheduleList)
      }
    } else {
      // 新增模式：批量新增
      addScheduleBatch(scheduleList).then(() => {
        proxy.$modal.msgSuccess("新增成功")
        open.value = false
        getList()
      })
    }
  })
}

// 先删除原有记录，再批量新增（员工有变化时使用）
async function doFullReplace(scheduleList) {
  try {
    if (form.value.scheduleIds && form.value.scheduleIds.length > 0) {
      await delSchedule(form.value.scheduleIds.join(','))
    }
    await addScheduleBatch(scheduleList)
    proxy.$modal.msgSuccess("修改成功")
    open.value = false
    getList()
  } catch (e) {
    proxy.$modal.msgError("修改失败：" + (e.msg || e.message || e))
  }
}

// 差量更新三步走：删除移除的、新增新选的、更新保留的（不传 scheduleDate）
async function doDiffUpdate(newDates, removedDates, keptDates, scheduleList) {
  try {
    // 1. 删除被移除日期对应的记录
    if (removedDates.length > 0) {
      const removedIds = removedDates.map(date => {
        const idx = form.value.originalDates.indexOf(date)
        return form.value.scheduleIds[idx]
      }).filter(Boolean)
      if (removedIds.length > 0) {
        await delSchedule(removedIds.join(','))
      }
    }

    // 2. 新增新选中的日期
    if (newDates.length > 0) {
      const newSchedules = scheduleList.filter(item => newDates.includes(item.scheduleDate))
      await addScheduleBatch(newSchedules)
    }

    // 3. 更新保留日期的非日期字段（不传 scheduleDate，避免日期字段被误改）
    if (keptDates.length > 0) {
      const keptIds = keptDates.map(date => form.value.scheduleIds[form.value.originalDates.indexOf(date)]).filter(Boolean)
      for (const id of keptIds) {
        await updateSchedule({
          scheduleId: id,
          userId: form.value.userId || form.value.userIds[0],
          userName: form.value.userName,
          enterpriseId: form.value.enterpriseId,
          enterpriseName: form.value.enterpriseName,
          purpose: form.value.purpose,
          status: form.value.status,
          remark: form.value.remark
        })
      }
    }

    proxy.$modal.msgSuccess("修改成功")
    open.value = false
    getList()
  } catch (e) {
    proxy.$modal.msgError("修改失败：" + (e.msg || e.message || e))
  }
}

function getScheduleTooltip(schedule) {
  const pMap = { '1': '爆卡', '2': '销售', '3': '售后', '4': '业务' }
  const sMap = { '1': '已预约', '2': '服务中', '3': '已完成', '4': '已取消' }
  return `企业：${schedule.enterpriseName}\n员工：${schedule.userName}\n目的：${pMap[schedule.purpose]}\n状态：${sMap[schedule.status]}\n备注：${schedule.remark || '无'}`
}

function queryConfig() {
  configLoading.value = true
  listEmployeeConfig(configQueryParams.value).then(response => {
    employeeConfigList.value = response.rows || []
    configTotal.value = response.total || 0
    configLoading.value = false
  }).catch(() => { configLoading.value = false })
}

function resetConfigQuery() {
  proxy.resetForm("configQueryRef")
  configQueryParams.value = { pageNum: 1, pageSize: 50, userName: undefined, deptId: undefined, isSchedulable: undefined }
  queryConfig()
}

/** 查询部门下拉树结构 */
function getDeptTree() {
  deptTreeSelect().then(response => {
    deptOptions.value = response.data
  })
}

/** 部门树节点单击事件 */
function handleDeptNodeClick(data) {
  configQueryParams.value.deptId = data.id
  queryConfig()
}

async function handleSchedulableChange(row) {
  try {
    await updateSchedulable(row.userId, row.isSchedulable)
    proxy.$modal.msgSuccess("更新成功")
  } catch (error) { row.isSchedulable = row.isSchedulable === '1' ? '0' : '1'; proxy.$modal.msgError("更新失败") }
}

// ==================== 休息日配置（增强版：休假类型选择器+日历标注） ====================
const restDateOpen = ref(false)
const restDateUserId = ref(null)
const restDateUserName = ref('')
const restSaving = ref(false)

// 休假类型列表
const leaveTypes = ref([])
// 当前选择的休假类型
const selectedTypeId = ref(null)
const selectedTypeName = ref('')
// 所有休息日数据（含轮休/请假/自定义/法定假日），用于日历标注
const allRestDateMap = ref({})
const allRestTypeList = ref([])
// 自定义休息日 map: {dateStr: {date, typeId, typeName}}
const customDateMap = ref({})

const weekdays = ['日', '一', '二', '三', '四', '五', '六']

// 当前日历月份
const restCalendarMonth = ref('')

// 已选自定义休息日列表（排序后展示）
const customDateList = computed(() => {
  return Object.values(customDateMap.value).sort((a, b) => a.date.localeCompare(b.date))
})

// 日历网格单元格
const calendarCells = computed(() => {
  const [year, month] = restCalendarMonth.value.split('-').map(Number)
  const firstDay = new Date(year, month - 1, 1)
  const lastDay = new Date(year, month, 0)
  const firstDayWeek = firstDay.getDay()
  const daysInMonth = lastDay.getDate()

  const cells = []
  // 前置空格
  for (let i = 0; i < firstDayWeek; i++) {
    cells.push({ key: `empty-${i}`, date: null, day: '', selected: false })
  }
  // 日期格子
  for (let day = 1; day <= daysInMonth; day++) {
    const dateStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
    const restInfo = allRestDateMap.value[dateStr]
    const isCustomSelected = !!customDateMap.value[dateStr]
    cells.push({
      key: dateStr,
      date: dateStr,
      day,
      selected: isCustomSelected,
      restType: restInfo?.type || '',
      restTypeName: restInfo?.typeName || '',
      restColor: restInfo?.color || ''
    })
  }
  return cells
})

/** 打开休息日配置弹窗 */
function openRestDateDialog(row) {
  restDateUserId.value = row.userId
  restDateUserName.value = row.nickName || row.userName
  selectedTypeId.value = null
  selectedTypeName.value = ''
  allRestDateMap.value = {}
  allRestTypeList.value = []
  customDateMap.value = {}
  leaveTypes.value = []
  restCalendarMonth.value = queryParams.value.yearMonth
  restDateOpen.value = true
}

/** 切换日历月份（上一月/下一月），customDateMap 和 allRestDateMap 已含全部数据无需重新请求 */
function changeRestMonth(delta) {
  const [y, m] = restCalendarMonth.value.split('-').map(Number)
  const d = new Date(y, m - 1 + delta, 1)
  restCalendarMonth.value = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
}

/** 弹窗打开后加载数据（使用全量接口，支持跨月查看和已存日期回显） */
async function onRestDialogOpen() {
  const userId = restDateUserId.value
  if (!userId) return
  try {
    const [typeRes, allRes] = await Promise.all([
      listAllLeaveType(),
      getAllRestDatesAll(userId)
    ])
    leaveTypes.value = (typeRes.data || []).filter(t => t.status === '0' || t.status === 0 || t.status === undefined)

    const allData = allRes.data || {}
    const dates = allData.dates || []
    const map = {}
    dates.forEach(item => { map[item.date] = item })
    allRestDateMap.value = map
    allRestTypeList.value = allData.typeList || []

    // 提取已有自定义休息日（type === 'custom'）
    const customMap = {}
    dates.forEach(item => {
      if (item.type === 'custom') {
        customMap[item.date] = {
          date: item.date,
          typeId: item.typeId ?? null,
          typeName: item.typeName || ''
        }
      }
    })
    customDateMap.value = customMap
  } catch (e) {
    console.error('加载休息日数据失败:', e)
  }
}

/** 选择休假类型 */
function onTypeSelect(typeId, typeName) {
  selectedTypeId.value = typeId
  selectedTypeName.value = typeName
}

/** 点击日历单元格选择/取消日期 */
function onCellClick(cell) {
  if (!cell.date) return
  const restInfo = allRestDateMap.value[cell.date]
  // 已有轮休/请假/假日的日期不允许选择（仅标注参考）
  if (restInfo && restInfo.type !== 'custom') return

  const newMap = { ...customDateMap.value }
  if (newMap[cell.date]) {
    delete newMap[cell.date]
  } else {
    if (!selectedTypeId.value) {
      proxy.$modal.msgWarning('请先选择休息日类型')
      return
    }
    newMap[cell.date] = {
      date: cell.date,
      typeId: selectedTypeId.value,
      typeName: selectedTypeName.value
    }
  }
  customDateMap.value = newMap
}

/** 移除单个自定义休息日 */
function removeCustomDate(date) {
  const newMap = { ...customDateMap.value }
  delete newMap[date]
  customDateMap.value = newMap
}

/** 保存休息日配置 */
async function submitRestDates() {
  // 验证：每个日期必须有类型
  const restDates = Object.values(customDateMap.value)
  if (restDates.length > 0) {
    const noType = restDates.find(item => !item.typeId)
    if (noType) {
      proxy.$modal.msgError('日期 ' + noType.date + ' 未选择休息日类型，请重新选择')
      return
    }
  }
  restSaving.value = true
  try {
    const submitData = restDates.map(item => ({
      date: item.date,
      typeId: item.typeId,
      typeName: item.typeName
    }))
    await saveRestDates(restDateUserId.value, submitData)
    proxy.$modal.msgSuccess("保存成功")
    restDateOpen.value = false
    queryConfig()
  } catch (e) {
    proxy.$modal.msgError(e.message || "保存失败")
  } finally {
    restSaving.value = false
  }
}

async function loadRestDateMap() {
  try {
    const userIds = scheduleData.value.map(r => r.userId).filter(Boolean)
    if (!userIds.length) {
      restDateMap.value = {}
      return
    }
    // 使用批量API获取所有休息日（含轮休/请假/自定义/法定假日），带类型信息
    const res = await getAllRestDatesBatch(userIds, queryParams.value.yearMonth)
    const arr = res.data || []
    const map = {}
    arr.forEach(item => {
      const userMap = {}
      ;(item.dates || []).forEach(d => {
        userMap[d.date] = d
      })
      map[item.userId] = userMap
    })
    restDateMap.value = map
  } catch (e) {
    console.error('加载休息日数据失败:', e)
    restDateMap.value = {}
  }
}

function isRestDayForUser(userId, day) {
  if (!userId || !day) return false
  const userMap = restDateMap.value[userId]
  if (!userMap) return false
  const [y, m] = queryParams.value.yearMonth.split('-')
  const dateStr = `${y}-${m}-${String(day).padStart(2, '0')}`
  return !!userMap[dateStr]
}

function getRestInfo(userId, day) {
  if (!userId || !day) return null
  const userMap = restDateMap.value[userId]
  if (!userMap) return null
  const [y, m] = queryParams.value.yearMonth.split('-')
  const dateStr = `${y}-${m}-${String(day).padStart(2, '0')}`
  return userMap[dateStr] || null
}

async function loadLeaveDateMap() {
  try {
    const userIds = scheduleData.value.map(r => r.userId).filter(Boolean)
    if (!userIds.length) {
      leaveDateMap.value = {}
      return
    }
    const res = await getLeaveCalendar({ yearMonth: queryParams.value.yearMonth, userIds: userIds.join(',') })
    leaveDateMap.value = res.data || {}
  } catch (e) {
    console.error('加载请假数据失败:', e)
  }
}

function getLeaveInfo(userId, day) {
  if (!userId || !day) return null
  const leaves = leaveDateMap.value[userId]
  if (!leaves || !Array.isArray(leaves)) return null
  const [y, m] = queryParams.value.yearMonth.split('-')
  const dateStr = `${y}-${m}-${String(day).padStart(2, '0')}`
  return leaves.find(l => l.date === dateStr) || null
}

function isLeaveDayForUser(userId, day) {
  return getLeaveInfo(userId, day) !== null
}

function isUnavailableDay(userId, day) {
  return isRestDayForUser(userId, day) || isLeaveDayForUser(userId, day)
}

function handleMouseUp() {
  if (isDragging.value) {
    isDragging.value = false
    dragStartInfo.value = null
    dragEndInfo.value = null
    selectedDays.value.clear()
  }
}

onMounted(() => {
  getList()
  getUserList()
  getEnterpriseList()
  getDeptTree()
  tableHeight.value = window.innerHeight - 320

  document.addEventListener('mouseup', handleMouseUp)
})

onBeforeUnmount(() => {
  document.removeEventListener('mouseup', handleMouseUp)
})
</script>

<style scoped>
.app-container { padding: 20px; }

/* 日历网格样式 */
.calendar-grid {
  border: 1px solid #e4e7ed;
  border-radius: 6px;
  overflow-x: auto;
  background: var(--el-bg-color);
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.header-row {
  display: flex;
  background: linear-gradient(135deg, #f5f7fa 0%, #e8ecf1 100%);
  border-bottom: 2px solid #e4e7ed;
  position: sticky;
  top: 0;
  z-index: 10;
}

.name-header {
  width: 120px;
  min-width: 120px;
  padding: 12px 8px;
  text-align: center;
  font-weight: 600;
  font-size: 13px;
  color: #1f2329;
  border-right: 2px solid #e4e7ed;
  background: linear-gradient(135deg, #fafafa 0%, #f0f2f5 100%);
  position: sticky;
  left: 0;
  z-index: 10;
}

.days-header {
  display: flex;
  flex: 1;
}

.day-header {
  flex: 1;
  min-width: 0;
  padding: 8px 2px;
  text-align: center;
  font-size: 12px;
  color: #606266;
  border-right: 1px solid #ebeef5;
}

.data-row {
  display: flex;
  border-bottom: 1px solid #ebeef5;
  min-height: 56px;
  transition: background-color 0.2s ease;
}

.data-row:hover {
  background-color: var(--el-fill-color-lighter);
}

.data-row:last-child { border-bottom: none; }

.name-cell {
  width: 120px;
  min-width: 120px;
  padding: 10px 6px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border-right: 2px solid #e4e7ed;
  background: linear-gradient(180deg, #fafafa 0%, #f5f5f5 100%);
  position: sticky;
  left: 0;
  z-index: 5;
}

.name-text {
  font-size: 13px;
  font-weight: 500;
  color: #303133;
  margin-bottom: 4px;
}

.post-tag {
  font-size: 10px;
  transform: scale(0.9);
}

.days-container {
  display: flex;
  flex: 1;
  position: relative;
  min-width: 0;
}

.day-cell {
  flex: 1;
  min-width: 0;
  min-height: 52px;
  border-right: 1px solid #ebeef5;
  cursor: crosshair;
  transition: all 0.15s ease;
  position: relative;
  align-self: stretch;
}

.day-cell:hover:not(.selected):not(.rest-day):not(.leave-day) {
  background-color: #e6f7ff;
  box-shadow: inset 0 0 0 1px #91d5ff;
}

.day-cell.selected {
  background-color: #91d5ff !important;
  border: 2px solid #1890ff !important;
  box-sizing: border-box;
  z-index: 3;
  animation: pulse-selected 1.5s ease-in-out infinite;
}

@keyframes pulse-selected {
  0%, 100% { background-color: #91d5ff; }
  50% { background-color: #69c0ff; }
}

.day-cell.rest-day {
  cursor: not-allowed;
  display: flex;
  align-items: center;
  justify-content: center;
}

.rest-label {
  position: absolute;
  top: 2px;
  bottom: 2px;
  left: 2px;
  right: 2px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  font-weight: 600;
  border-radius: 3px;
  padding: 1px 5px;
  line-height: 16px;
}

.day-cell.leave-day {
  cursor: not-allowed;
  display: flex;
  align-items: center;
  justify-content: center;
}

.leave-label {
  position: absolute;
  top: 2px;
  bottom: 2px;
  left: 2px;
  right: 2px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  font-weight: 600;
  border-radius: 3px;
  padding: 1px 5px;
  line-height: 16px;
}

.schedule-block {
  position: absolute;
  top: 2px;
  bottom: 2px;
  border-radius: 3px;
  z-index: 2;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 11px;
  font-weight: 600;
  cursor: pointer;
  padding: 0 6px;
  overflow: hidden;
  transition: all 0.2s ease;
  box-shadow: 0 1px 3px rgba(0,0,0,0.12);
}

.schedule-block:hover {
  opacity: 0.92;
  box-shadow: 0 3px 10px rgba(0,0,0,0.25);
  z-index: 4;
  transform: translateY(-1px);
}

.block-text {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 100%;
  display: block;
}

.purpose-1 { background-color: #F56C6C; }
.purpose-2 { background-color: #67C23A; }
.purpose-3 { background-color: #E6A23C; }
.purpose-4 { background-color: #409EFF; }

.status-4 {
  opacity: 0.6;
  border: 2px dashed #c0c4cc;
  background-image: repeating-linear-gradient(
    45deg,
    transparent,
    transparent 4px,
    rgba(255,255,255,.3) 4px,
    rgba(255,255,255,.3) 8px
  );
}

/* 排班列表 */
.schedule-list-section {
  margin-top: 20px;
  padding: 20px;
  background: linear-gradient(135deg, #fafbfc 0%, #f5f7fa 100%);
  border-radius: 8px;
  border: 1px solid #e4e7ed;
  box-shadow: 0 2px 12px rgba(0,0,0,0.04);
}
.schedule-list-section h4 {
  margin: 0 0 16px 0;
  font-size: 15px;
  font-weight: 600;
  color: #1f2329;
  padding-bottom: 12px;
  border-bottom: 2px solid #e4e7ed;
}
.date-tag {
  margin: 3px 4px 3px 0;
  font-weight: 500;
}

/* 休息日期 - 精致圆点标记样式已随死代码删除 */

/* 排班设置 tab 样式 - 左树右表布局 */
.config-layout.tree-sidebar-manage-wrap {
  min-height: calc(100vh - 220px);
}

/* 休息日配置弹窗 - 自定义日历网格 */
.rest-cal-month-bar {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
  margin-bottom: 12px;
}
.rest-cal-month-text {
  font-size: 15px;
  font-weight: 600;
  color: #303133;
  min-width: 90px;
  text-align: center;
}
.rest-calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
  background: #f5f7fa;
  border-radius: 8px;
  padding: 8px;
}
.rest-cal-weekday {
  text-align: center;
  font-size: 12px;
  font-weight: 600;
  color: #909399;
  padding: 6px 0;
}
.rest-cal-cell {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 56px;
  background: #fff;
  border-radius: 6px;
  border: 2px solid transparent;
  cursor: pointer;
  transition: all 0.2s;
}
.rest-cal-cell:hover {
  border-color: #c0c4cc;
}
.rest-cal-empty {
  background: transparent;
  cursor: default;
  pointer-events: none;
}
.rest-cal-empty:hover {
  border-color: transparent;
}
.rest-cal-selected {
  background: #3D6DF7;
  border-color: #3D6DF7;
  .rest-cal-day { color: #fff; font-weight: 600; }
  .rest-cal-tag { color: rgba(255,255,255,0.9) !important; }
}
.rest-cal-rotated {
  background: #fdf6ec;
  cursor: default;
  &:hover { border-color: transparent; }
}
.rest-cal-day {
  font-size: 14px;
  color: #303133;
  font-weight: 500;
}
.rest-cal-tag {
  font-size: 10px;
  color: #3D6DF7;
  margin-top: 2px;
  white-space: nowrap;
}
.rest-type-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  padding: 10px 12px;
  background: #f5f7fa;
  border-radius: 8px;
  margin-bottom: 16px;
}
.rest-type-legend-item {
  display: flex;
  align-items: center;
  gap: 4px;
}
.rest-type-legend-dot {
  display: inline-block;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #3D6DF7;
}
.rest-type-legend-text {
  font-size: 12px;
  color: #666;
}
</style>
