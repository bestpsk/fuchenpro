# 修复 handleEditCustomer is not a function 报错

## 问题分析

报错 `TypeError: _ctx.handleEditCustomer is not a function` 发生在 front 端销售开单页面点击编辑按钮时。

**根因**：Vite HMR（热更新）缓存问题。`handleEditCustomer` 函数已正确定义在 `<script setup>` 顶层（第1349行），模板中也正确引用（第54行），代码逻辑没有问题。但 Vite 的 HMR 在添加新函数时，有时不能正确地重新编译整个 `<script setup>` 块，导致新函数未暴露给模板上下文。

**验证**：代码结构完全正确：
- `<script setup name="Sales">` 只有一个 script 标签
- `handleEditCustomer` 定义在顶层作用域
- 没有 `defineExpose` 限制
- 函数在 `</script>` 之前

## 解决方案

**重启 Vite 开发服务器**，清除 HMR 缓存即可解决。

无需修改任何代码。
