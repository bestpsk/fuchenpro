# 方案详情页布局调整计划

## 需求

修改方案详情页（`detail.vue`）的顶部布局：
- 移除独立的 `status-card` 卡片
- 方案编号（如 PL20260508001）显示在原"基本信息"标题的位置
- 审核状态标签与方案编号同一行，显示在最右侧
- 去掉"基本信息"文字

## 修改内容

### 文件：`AppV3/src/pages/business/plan/detail.vue`

#### 模板修改

将原来的：
```html
<view class="status-card">
  <view class="status-tag-large" :class="'status-' + planInfo.auditStatus">{{ getAuditStatusLabel(planInfo.auditStatus) }}</view>
  <text class="plan-no">{{ planInfo.planNo || '-' }}</text>
</view>

<view class="info-card">
  <view class="card-title">基本信息</view>
  <view class="info-body">
```

改为：
```html
<view class="info-card">
  <view class="card-header-row">
    <text class="plan-no">{{ planInfo.planNo || '-' }}</text>
    <view class="status-tag" :class="'status-' + planInfo.auditStatus">{{ getAuditStatusLabel(planInfo.auditStatus) }}</view>
  </view>
  <view class="info-body">
```

#### 样式修改

- 删除 `.status-card` 和 `.status-tag-large`、`.plan-no` 旧样式
- 新增 `.card-header-row` 样式（flex 布局，space-between）
- 新增 `.plan-no` 样式（左侧，大号加粗）
- 新增 `.status-tag` 样式（右侧标签，与列表页卡片中的状态标签风格一致）
