# 出货明细布局优化计划

## 目标
调整 `shipment.vue` 出货明细的 item-body 布局，使：
- **第一行**：数量 + 单价（左右分布）
- **第二行**：折扣单价 + 总金额（左右分布）
- 纵向对齐，视觉整齐

## 当前布局（4行）
```
供货商 xxx    单位 xxx
数量 [- 1 +]  最多xx
单价 ¥xx      折扣单价 [input]
总金额 [input]
```

## 目标布局（3行）
```
供货商 xxx    单位 xxx
数量 [- 1 +]  最多xx    单价 ¥xx
折扣单价 [input]       总金额 [input]
```

## 修改文件
`f:\fuchen\AppV3\src\pages\business\plan\shipment.vue`

## 实施步骤

### 步骤1：修改模板（lines 74-92）

将原来的4行布局改为3行：

**第1行**（保持不变）：供货商 + 单位

**第2行**（合并数量行和单价行）：
- 左侧：数量标签 + 数量控件 + 最多提示
- 右侧：单价标签 + 单价值
- 使用 `justify-content: space-between` 左右分布

**第3行**（合并折扣单价和总金额）：
- 左侧：折扣单价标签 + 折扣单价输入框
- 右侧：总金额标签 + 总金额输入框
- 使用 `justify-content: space-between` 左右分布
- 保留分隔线样式

具体模板代码：
```html
<view class="item-body">
  <view class="item-info-row">
    <text class="item-label">供货商</text>
    <text class="item-value">{{ item.supplierName || '-' }}</text>
    <text class="item-label" style="margin-left: 20rpx;">单位</text>
    <text class="item-value">{{ getUnitTypeLabel(item) }}</text>
  </view>
  <view class="item-info-row item-row-between">
    <view class="item-left">
      <text class="item-label">数量</text>
      <view class="quantity-control">
        <view class="qty-btn" @click="changeQuantity(index, -1)"><u-icon name="minus" size="12" color="#86909C"></u-icon></view>
        <input class="qty-input" type="number" v-model.number="item.quantity" @input="onItemChange(index)" />
        <view class="qty-btn" @click="changeQuantity(index, 1)"><u-icon name="plus" size="12" color="#86909C"></u-icon></view>
      </view>
      <text v-if="item.planItemId" class="item-max">最多{{ item.maxQuantity }}</text>
    </view>
    <view class="item-right">
      <text class="item-label">单价</text>
      <text class="item-value price">¥{{ formatAmount(item.salePrice) }}</text>
    </view>
  </view>
  <view class="item-info-row item-row-between amount-row">
    <view class="item-left">
      <text class="item-label">折扣单价</text>
      <input class="discount-input" type="digit" v-model="item.discountPrice" @input="onItemChange(index)" />
    </view>
    <view class="item-right">
      <text class="item-label">总金额</text>
      <input class="amount-input" type="digit" v-model="item.amount" @input="onAmountChange(index)" />
    </view>
  </view>
</view>
```

### 步骤2：修改样式

新增/调整以下样式：

```scss
.item-row-between {
  justify-content: space-between;
}

.item-left {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.item-right {
  display: flex;
  align-items: center;
  gap: 8rpx;
}
```

同时调整 `amount-row` 的分隔线样式保持不变，`discount-input` 和 `amount-input` 宽度适当调整以适应新布局。

### 步骤3：验证

- 确认布局在移动端显示正常
- 确认数量加减、折扣单价输入、总金额输入功能正常
- 确认自动计算逻辑不受影响
