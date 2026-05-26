# 修复系统管理-通知公告删除功能失败的问题

## 问题分析

通过对比用户管理模块和通知公告模块的代码，发现了问题所在：

1. **前端 API 调用**：`front/src/api/system/notice.js` 中使用的参数是 `noticeId`（单数）
2. **后端控制器接收**：`webman/app/controller/system/SysNoticeController.php` 中尝试获取的参数是 `noticeIds`（复数）
3. **参数不匹配**导致后端无法正确接收到要删除的公告ID，因此删除操作失败

## 修复方案

将前后端统一使用 `noticeIds` 参数：

1. 修改前端 API 调用，使用 `noticeIds` 作为参数名
2. 同时确保前端页面在调用时也正确传递参数

## 需要修改的文件

- `front/src/api/system/notice.js`
- `front/src/views/system/notice/index.vue`

## 修改内容

1. 在 `notice.js` 中，将 `delNotice` 函数的参数从 `noticeId` 改为 `noticeIds`
2. 在 `index.vue` 中，确保调用 `delNotice` 时传递正确的参数
