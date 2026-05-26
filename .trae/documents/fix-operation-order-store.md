# 操作订单企业名称和门店名称为空修复

## 一、问题分析

**现象**：操作的订单（OP开头）企业名称和门店名称都为空

**原因**：`createOperationOrder()` 方法直接从操作记录 `$record` 获取 `enterprise_name` 和 `store_name`，但操作记录表中这些字段可能为空。而 `getOperationRecordDetail()` 方法有完整的回退查询逻辑（从套餐→订单→客户依次查找），但创建订单时没有使用同样的逻辑。

**对比**：
- 查询详情时（第151-176行）：有回退逻辑 → 套餐表 → 订单表 → 客户表
- 创建订单时（第197-200行）：直接取 `$record` 字段 → 可能为空

## 二、修改内容

### 文件：`webman/app/service/BizOperationRecordService.php`

**位置**：`createOperationOrder()` 方法（第188行开始）

**修改**：在创建订单前，添加与详情查询相同的回退逻辑来获取企业名称和门店名称

```php
private function createOperationOrder($record, $data)
{
    $orderNo = $this->generateOperationOrderNo();
    $amount = floatval($record->consume_amount ?? 0) + floatval($record->trial_price ?? 0);

    // 获取企业名称和门店名称（带回退逻辑）
    $enterpriseName = $record->enterprise_name ?? '';
    $storeName = $record->store_name ?? '';

    if (empty($enterpriseName) || empty($storeName)) {
        if (!empty($record->package_id)) {
            $pkg = \app\model\BizCustomerPackage::where('package_id', $record->package_id)->first();
            if ($pkg) {
                if (empty($enterpriseName)) $enterpriseName = $pkg->enterprise_name ?? '';
                if (empty($storeName)) $storeName = $pkg->store_name ?? '';
                if (empty($storeName) && !empty($pkg->order_id)) {
                    $order = \app\model\BizSalesOrder::find($pkg->order_id);
                    if ($order) {
                        if (empty($enterpriseName)) $enterpriseName = $order->enterprise_name ?? '';
                        $storeName = $order->store_name ?? '';
                    }
                }
            }
        }
        if ((empty($enterpriseName) || empty($storeName)) && !empty($record->customer_id)) {
            $customer = \app\model\BizCustomer::find($record->customer_id);
            if ($customer) {
                if (empty($enterpriseName)) $enterpriseName = $customer->enterprise_name ?? '';
                if (empty($storeName)) $storeName = $customer->store_name ?? '';
            }
        }
    }

    $order = BizSalesOrder::create([
        ...
        'enterprise_name' => $enterpriseName,
        'store_name' => $storeName,
        ...
    ]);
}
```

## 三、修改文件清单

| 序号 | 文件路径 | 修改内容 |
|------|---------|---------|
| 1 | `webman/app/service/BizOperationRecordService.php` | createOperationOrder()方法增加企业/门店名称回退查询 |
