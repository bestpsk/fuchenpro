# AppV3 数据概览统计功能完善

## 需求分析

1. 数据概览需要展示3项真实统计数据：**成交客数**、**成交金额**、**操作客数**（今日+本月）
2. 数据概览标题右侧新增"更多"按钮，跳转到数据统计页面
3. 当前数据为硬编码假数据，需要后端实现统计接口

## 统计指标定义

| 指标 | 含义 | 数据来源 |
|------|------|---------|
| 成交客数 | 有成交订单的不同客户数 | `biz_sales_order` 中 `order_status='1'` 的不同 `customer_id` 数量 |
| 成交金额 | 成交订单的总金额 | `biz_sales_order` 中 `order_status='1'` 的 `deal_amount` 合计 |
| 操作客数 | 有操作记录的不同客户数 | `biz_operation_record` 中不同 `customer_id` 数量 |

## 修改文件清单

| 序号 | 文件 | 操作 |
|------|------|------|
| 1 | `webman/app/controller/AppHomeController.php` | 新建 |
| 2 | `webman/app/service/HomeStatsService.php` | 新建 |
| 3 | `webman/config/route.php` | 修改（追加路由） |
| 4 | `AppV3/src/components/home/StatisticsCard.vue` | 修改（3项+更多按钮） |
| 5 | `AppV3/src/pages/index.vue` | 修改（调用真实接口） |

## 实施步骤

### 步骤1：创建后端统计 Service

**文件**：`webman/app/service/HomeStatsService.php`

```php
class HomeStatsService
{
    public static function getTodayStats($userId)
    {
        $today = date('Y-m-d');
        $monthStart = date('Y-m-01');

        // 成交客数：今日/本月有成交订单的不同客户数
        $todayDealCustomers = BizSalesOrder::where('order_status', '1')
            ->where('creator_user_id', $userId)
            ->whereDate('create_time', $today)
            ->distinct()->count('customer_id');

        $monthDealCustomers = BizSalesOrder::where('order_status', '1')
            ->where('creator_user_id', $userId)
            ->where('create_time', '>=', $monthStart . ' 00:00:00')
            ->distinct()->count('customer_id');

        // 成交金额：今日/本月成交订单的总 deal_amount
        $todayDealAmount = BizSalesOrder::where('order_status', '1')
            ->where('creator_user_id', $userId)
            ->whereDate('create_time', $today)
            ->sum('deal_amount');

        $monthDealAmount = BizSalesOrder::where('order_status', '1')
            ->where('creator_user_id', $userId)
            ->where('create_time', '>=', $monthStart . ' 00:00:00')
            ->sum('deal_amount');

        // 操作客数：今日/本月有操作记录的不同客户数
        $todayOperationCustomers = BizOperationRecord::where('operator_user_id', $userId)
            ->whereDate('operation_date', $today)
            ->distinct()->count('customer_id');

        $monthOperationCustomers = BizOperationRecord::where('operator_user_id', $userId)
            ->where('operation_date', '>=', $monthStart)
            ->distinct()->count('customer_id');

        return [
            'dealCustomerCount' => ['today' => $todayDealCustomers, 'month' => $monthDealCustomers],
            'dealAmount' => ['today' => $todayDealAmount, 'month' => $monthDealAmount],
            'operationCustomerCount' => ['today' => $todayOperationCustomers, 'month' => $monthOperationCustomers],
        ];
    }
}
```

### 步骤2：创建后端 Controller

**文件**：`webman/app/controller/AppHomeController.php`

```php
class AppHomeController
{
    public function stats(Request $request)
    {
        $userId = $request->loginUser->user->user_id;
        $result = HomeStatsService::getTodayStats($userId);
        return AjaxResult::success($result);
    }
}
```

### 步骤3：注册后端路由

**文件**：`webman/config/route.php`

```php
Route::get('/home/stats', [app\controller\AppHomeController::class, 'stats']);
```

### 步骤4：修改 StatisticsCard 组件

**文件**：`AppV3/src/components/home/StatisticsCard.vue`

改动：
1. 卡片标题右侧添加"更多"按钮（替换刷新按钮）
2. 统计项从4项改为3项：成交客数、成交金额、操作客数
3. 点击"更多"跳转到数据统计页面
4. emit `refresh` 事件给父组件重新拉取数据

### 步骤5：修改首页调用真实接口

**文件**：`AppV3/src/pages/index.vue`

改动：
1. `loadHomeData()` 中调用 `getTodayStats()` API 获取真实数据
2. 将后端返回的数据映射为 StatisticsCard 所需的格式
3. 下拉刷新时重新调用接口
