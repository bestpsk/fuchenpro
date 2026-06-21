<?php

namespace app\middleware;

use Webman\MiddlewareInterface;
use Webman\Http\Request;
use Webman\Http\Response;
use app\model\SysOperLog;
use app\common\LoginUser;
use support\Log;

/**
 * 操作日志中间件
 *
 * 自动记录POST/PUT/DELETE请求的操作日志到sys_oper_log表，
 * 包括操作人、请求路径、请求参数、响应结果、耗时、IP地址和地理位置等信息。
 * GET请求和未登录请求不记录日志
 */
class LogMiddleware implements MiddlewareInterface
{
    // 处理请求并记录操作日志，仅记录已登录用户的POST/PUT/DELETE操作
    public function process(Request $request, callable $handler): Response
    {
        $startTime = microtime(true);
        $response = $handler($request);
        $costTime = round((microtime(true) - $startTime) * 1000);

        $method = $request->method();
        if (!in_array($method, ['POST', 'PUT', 'DELETE'])) {
            return $response;
        }

        $loginUser = $request->loginUser ?? null;
        if (!$loginUser) {
            return $response;
        }

        try {
            $operLog = new SysOperLog();
            $operLog->title = $this->getTitle($request->path());
            $operLog->business_type = $this->getBusinessType($method);
            $operLog->method = $request->path();
            $operLog->request_method = $method;
            $operLog->operator_type = 1;
            $operLog->oper_name = $loginUser->user ? $loginUser->user->user_name : '';

            // 隔离 dept 懒加载，避免加载失败导致整条日志不记录
            try {
                $operLog->dept_name = $loginUser->user && $loginUser->user->dept ? $loginUser->user->dept->dept_name : '';
            } catch (\Throwable $e) {
                $operLog->dept_name = '';
            }

            $operLog->oper_url = $request->fullUrl();
            $operLog->oper_ip = $request->getRealIp();
            $operLog->oper_location = \app\service\IpService::getLocation($request->getRealIp());

            $params = $request->all();
            unset($params['password'], $params['oldPassword'], $params['newPassword']);
            $operLog->oper_param = mb_substr(json_encode($params, JSON_UNESCAPED_UNICODE), 0, 2000);

            $responseData = json_decode($response->rawBody(), true);
            if ($responseData) {
                $operLog->json_result = mb_substr(json_encode($responseData, JSON_UNESCAPED_UNICODE), 0, 2000);
                $operLog->status = ($responseData['code'] ?? 500) === 200 ? 0 : 1;
                if ($operLog->status === 1) {
                    $operLog->error_msg = $responseData['msg'] ?? '';
                }
            }

            $operLog->cost_time = $costTime;
            $operLog->oper_time = date('Y-m-d H:i:s');
            $operLog->save();
        } catch (\Throwable $e) {
            Log::error('LogMiddleware error: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
        }

        return $response;
    }

    // 根据请求路径匹配操作模块标题（如/system/user → 用户管理）
    private function getTitle($path)
    {
        $titles = [
            '/system/user/detail' => '用户详情',
            '/system/user' => '用户管理',
            '/system/role' => '角色管理',
            '/system/menu' => '菜单管理',
            '/system/dept' => '部门管理',
            '/system/post' => '岗位管理',
            '/system/dict' => '字典管理',
            '/system/config' => '参数管理',
            '/system/notice' => '通知公告',
            '/system/appMenu' => 'APP菜单管理',
            '/system/banner' => '轮播图管理',
            '/monitor/online' => '在线用户',
            '/monitor/job' => '定时任务',
            '/monitor/logininfor' => '登录日志',
            '/monitor/operlog' => '操作日志',
            '/monitor/cache' => '缓存监控',
            '/monitor/server' => '服务监控',
            '/tool/gen' => '代码生成',
            '/business/enterprise' => '企业管理',
            '/business/store' => '门店管理',
            '/business/customer' => '客户管理',
            '/business/sales' => '销售管理',
            '/business/package' => '套餐管理',
            '/business/operation' => '操作记录',
            '/business/repayment' => '还款管理',
            '/business/cardItem' => '卡项管理',
            '/business/stockPrepare' => '备货管理',
            '/business/archive' => '档案管理',
            '/business/plan' => '方案管理',
            '/business/schedule' => '排班管理',
            '/business/employeeConfig' => '员工配置',
            '/business/attendance' => '考勤管理',
            '/finance/planAudit' => '方案审核',
            '/finance/reimbursement' => '报销管理',
            '/wms/supplier' => '供货商管理',
            '/wms/warehouse' => '仓库管理',
            '/wms/product' => '货品管理',
            '/wms/stockIn' => '入库管理',
            '/wms/stockOut' => '出库管理',
            '/wms/inventory' => '库存查看',
            '/wms/stockCheck' => '库存盘点',
            '/wms/stockTransfer' => '调拨管理',
            '/wms/report' => '进销存报表',
            '/hr/salary' => '薪资管理',
            '/admin/feedback' => '反馈管理',
        ];

        foreach ($titles as $prefix => $title) {
            if (str_starts_with($path, $prefix)) {
                return $title;
            }
        }
        return '系统操作';
    }

    // 将HTTP请求方法映射为业务操作类型（POST=新增 PUT=修改 DELETE=删除）
    private function getBusinessType($method)
    {
        return match ($method) {
            'POST' => 1,
            'PUT' => 2,
            'DELETE' => 3,
            default => 0,
        };
    }
}
