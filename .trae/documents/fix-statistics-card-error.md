# 修复 StatisticsCard.vue 编译错误

## 问题

`StatisticsCard.vue` 第47行报错：`Missing semicolon (47:1)`

Vite 的 vue/compiler-sfc 编译器报错，指向第49行的 `statsList` 定义处。

## 原因分析

文件内容语法看起来正常，可能是：
1. 文件写入时引入了不可见字符（BOM 或其他控制字符）
2. `<script setup>` 标签缺少 `lang` 属性或存在编码问题

## 修复方案

重写 `StatisticsCard.vue` 文件，确保无隐藏字符。
