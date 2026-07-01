<?php

namespace app\controller\tool;

use support\Request;
use app\service\GenTableService;
use app\service\PermissionService;
use app\common\AjaxResult;
use app\common\TableDataInfo;

/**
 * 代码生成器控制器
 *
 * 负责代码生成器的表导入、编辑、预览、下载和批量生成等功能，
 * 支持从数据库表导入结构、编辑生成配置、预览生成代码、下载生成代码ZIP包
 */
class GenController
{
    // 分页查询已导入的代码生成表列表
    public function list(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'tool:gen:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new GenTableService();
        $result = $service->selectGenTableList($request->all());
        return TableDataInfo::result($result->items(), $result->total());
    }

    // 根据ID获取代码生成表详情（含列配置）
    public function getInfo(Request $request)
    {
        $parts = explode('/', $request->path());
        $tableId = intval(end($parts));
        $service = new GenTableService();
        $table = $service->selectGenTableById($tableId);
        if (!$table) return AjaxResult::error('表不存在');
        return AjaxResult::success($table);
    }

    // 分页查询数据库中未导入的表列表
    public function dbList(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'tool:gen:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $service = new GenTableService();
        $result = $service->selectDbTableList($request->all());
        return TableDataInfo::result($result['rows'], $result['total']);
    }

    // 从数据库导入指定表到代码生成器（支持批量导入）
    public function importTable(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'tool:gen:add')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $tableNames = $request->post('tables', '');
        if (is_string($tableNames)) {
            $tableNames = explode(',', $tableNames);
        }
        $service = new GenTableService();
        $service->importGenTable($tableNames);
        return AjaxResult::success();
    }

    // 修改代码生成表配置（含表信息和列信息）
    public function edit(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'tool:gen:edit')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $data = $request->post();
        $service = new GenTableService();
        $service->updateGenTable($data);
        return AjaxResult::success();
    }

    // 批量删除代码生成表配置
    public function remove(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'tool:gen:remove')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $tableIds = explode(',', $request->input('tableIds', ''));
        $tableIds = array_map('intval', array_filter($tableIds));
        $service = new GenTableService();
        return AjaxResult::toAjax($service->deleteGenTableByIds($tableIds) ? 1 : 0);
    }

    // 预览指定表的生成代码（返回各模板文件的内容）
    public function preview(Request $request)
    {
        $parts = explode('/', $request->path());
        $tableId = intval(end($parts));
        $service = new GenTableService();
        $data = $service->previewCode($tableId);
        return AjaxResult::success($data);
    }

    // 同步数据库表结构到代码生成配置（更新列信息）
    public function synchDb(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'tool:gen:code')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $tableName = end($parts);
        $service = new GenTableService();
        $service->synchDb($tableName);
        return AjaxResult::success();
    }

    // 下载指定表的生成代码ZIP包
    public function download(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'tool:gen:code')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $parts = explode('/', $request->path());
        $tableName = end($parts);
        $service = new GenTableService();
        $tempFile = $service->downloadCode([$tableName]);
        return response()->download($tempFile, $tableName . '.zip')->deleteFileAfterSend(true);
    }

    // 批量生成代码并下载ZIP包
    public function batchGenCode(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'tool:gen:code')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        $tableNames = $request->input('tables', '');
        if (is_string($tableNames)) {
            $tableNames = explode(',', $tableNames);
        }
        $tableNames = array_filter($tableNames);
        if (empty($tableNames)) {
            return AjaxResult::error('请选择要生成的表');
        }
        $service = new GenTableService();
        $tempFile = $service->downloadCode($tableNames);
        return response()->download($tempFile, 'ruoyi.zip')->deleteFileAfterSend(true);
    }
}
