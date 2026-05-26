# 修复：删除 attendance 分组残留的旧"打卡"记录

## 根因确认

数据库查询结果证实：
```
31 | attendance | 打卡      ← 原始SQL创建的（旧，需删除）
42 | attendance | 考勤打卡   ← 后续新增的（保留）
```

`attendance` 分组有**两个重复的打卡菜单**：
- "打卡"(id=31) → 原始 `create_app_menu_config.sql` 创建
- "考勤打卡"(id=42) → 后续 `add_app_menu_groups.sql` 新增

之前只删了 `quick` 分组的"打卡"，完全漏掉了 `attendance` 分组中的旧记录。

## 修复方案

### 执行SQL
```sql
DELETE FROM app_menu_config WHERE id = 31;
```

删除后 attendance 分组只剩：考勤打卡、考勤记录、考勤规则、考勤配置（4个）

## 影响范围
- 考勤管理分组 → 不再显示"打卡"，只有"考勤打卡"
- 常用功能/首页 → 动态计算时不再包含"打卡"
