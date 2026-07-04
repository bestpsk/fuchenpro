<?php

namespace app\service;

use app\model\BizPlan;
use app\model\BizPlanItem;
use app\model\BizStockPrepare;
use app\model\BizEnterprise;
use app\service\DataScopeService;
use support\Db;

/**
 * 方案服务层，处理方案的增删改查、审核流程、金额管理和出货关联
 */
class BizPlanService
{
    public function selectEnterpriseList($params = [])
    {
        $query = BizEnterprise::where('status', '0');

        if (!empty($params['enterprise_name'])) {
            $query->where('enterprise_name', 'like', '%' . $params['enterprise_name'] . '%');
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        return $query->orderBy('enterprise_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
    }

    // 按条件分页查询方案列表，含企业名称和发货进度

    public function selectPlanList($params = [])
    {
        $query = BizPlan::with(['enterprise']);

        if (!empty($params['enterprise_id'])) {
            $query->where('enterprise_id', $params['enterprise_id']);
        }
        if (!empty($params['enterprise_name'])) {
            $query->whereHas('enterprise', function ($q) use ($params) {
                $q->where('enterprise_name', 'like', '%' . $params['enterprise_name'] . '%');
            });
        }
        if (!empty($params['plan_name'])) {
            $query->where('plan_name', 'like', '%' . $params['plan_name'] . '%');
        }
        if (!empty($params['keyword'])) {
            $kw = $params['keyword'];
            $query->where(function ($q) use ($kw) {
                $q->where('plan_name', 'like', '%' . $kw . '%')
                  ->orWhereHas('enterprise', function ($eq) use ($kw) {
                      $eq->where('enterprise_name', 'like', '%' . $kw . '%');
                  });
            });
        }
        if (isset($params['audit_status']) && $params['audit_status'] !== '') {
            $query->where('audit_status', $params['audit_status']);
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }

        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $result = $query->orderBy('plan_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
        
        foreach ($result as $plan) {
            $plan->enterprise_name = $plan->enterprise ? $plan->enterprise->enterprise_name : null;
        }
        
        return $result;
    }

    // 根据ID查询方案详情，含明细列表
    public function selectPlanById($planId)
    {
        $plan = BizPlan::with(['items.product', 'enterprise'])->find($planId);
        if ($plan) {
            $plan->enterprise_name = $plan->enterprise ? $plan->enterprise->enterprise_name : null;
        }
        return $plan;
    }

    public function generatePlanNo()
    {
        $date = date('Ymd');
        $key = 'plan_no:' . $date;
        $seq = \support\Redis::incr($key);
        \support\Redis::expire($key, 86400);
        return 'PL' . $date . str_pad($seq, 3, '0', STR_PAD_LEFT);
    }

    // 新增方案，生成方案编号并计算金额

    public function insertPlan($data)
    {
        return Db::transaction(function () use ($data) {
            $data['plan_no'] = $this->generatePlanNo();
            $data['remaining_amount'] = $data['gift_amount'] ?? 0;
            $data['shipped_amount'] = 0;
            $data['audit_status'] = '0';
            $data['create_time'] = date('Y-m-d H:i:s');

            $items = $data['items'] ?? [];
            unset($data['items']);

            $plan = BizPlan::create($data);

            if (!empty($items)) {
                $this->syncPlanItems($plan->plan_id, $items);
            }

            return $plan;
        });
    }

    // 更新方案信息

    public function updatePlan($data)
    {
        return Db::transaction(function () use ($data) {
            $plan = BizPlan::find($data['plan_id']);
            if (!$plan) {
                return false;
            }

            if (in_array($plan->audit_status, ['2', '3'])) {
                return false;
            }

            $items = $data['items'] ?? [];
            unset($data['items']);

            $data['remaining_amount'] = ($data['gift_amount'] ?? $plan->gift_amount) - $plan->shipped_amount;
            if ($data['remaining_amount'] < 0) {
                throw new \Exception('赠送金额不能小于已发货金额');
            }
            $data['update_time'] = date('Y-m-d H:i:s');

            $fillable = [
                'plan_name', 'commission_rate', 'plan_amount', 'gift_amount',
                'remaining_amount', 'effective_date', 'expiry_date',
                'status', 'remark', 'update_by', 'update_time'
            ];
            $updateData = array_intersect_key($data, array_flip($fillable));

            $result = BizPlan::where('plan_id', $data['plan_id'])->update($updateData);

            if (!empty($items)) {
                $this->syncPlanItems($data['plan_id'], $items);
            }

            return $result;
        });
    }

    private function syncPlanItems($planId, $items)
    {
        BizPlanItem::where('plan_id', $planId)->delete();

        foreach ($items as $item) {
            $item['plan_id'] = $planId;
            $unitType = $item['unit_type'] ?? ($item['unitType'] ?? '1');
            $packQty = intval($item['pack_qty'] ?? ($item['packQty'] ?? 1));
            $quantity = intval($item['quantity'] ?? 0);
            $salePrice = floatval($item['sale_price'] ?? ($item['salePrice'] ?? 0));

            // 统一转为副单位（最小单位）存储，与备货/出库逻辑一致
            if ($unitType === '1' && $packQty > 1) {
                $quantity = $quantity * $packQty;
                $salePrice = $salePrice / $packQty;
            }
            $item['quantity'] = $quantity;
            $item['sale_price'] = $salePrice;
            $item['remaining_quantity'] = $quantity;
            $item['shipped_quantity'] = 0;
            if (isset($item['amount']) === false) {
                $item['amount'] = bcmul($quantity, $salePrice, 2);
            }
            BizPlanItem::create($item);
        }
    }

    // 批量删除方案，同时删除关联明细和发货单

    public function deletePlanByIds($planIds)
    {
        return Db::transaction(function () use ($planIds) {
            foreach ($planIds as $planId) {
                $plan = BizPlan::find($planId);
                if ($plan && !in_array($plan->audit_status, ['0', '4'])) {
                    throw new \Exception('方案"' . $plan->plan_name . '"不可删除');
                }
            }
            BizPlanItem::whereIn('plan_id', $planIds)->delete();
            return BizPlan::whereIn('plan_id', $planIds)->delete();
        });
    }

    public function submitAudit($planId, $submitBy = '')
    {
        $plan = BizPlan::find($planId);
        if (!$plan || !in_array($plan->audit_status, ['0', '4'])) {
            return false;
        }
        return BizPlan::where('plan_id', $planId)->update([
            'audit_status' => '1',
            'submit_by' => $submitBy,
            'submit_time' => date('Y-m-d H:i:s'),
            'update_time' => date('Y-m-d H:i:s')
        ]);
    }

    public function audit($data)
    {
        $planId = $data['plan_id'];
        $passed = $data['passed'] ?? true;
        $auditRemark = $data['audit_remark'] ?? '';

        $plan = BizPlan::find($planId);
        if (!$plan || $plan->audit_status !== '1') {
            return false;
        }

        $updateData = [
            'audit_by' => $data['audit_by'] ?? '',
            'audit_time' => date('Y-m-d H:i:s'),
            'audit_remark' => $auditRemark,
            'update_time' => date('Y-m-d H:i:s')
        ];

        if ($passed) {
            $updateData['audit_status'] = '2';
        } else {
            $updateData['audit_status'] = '4';
        }

        return BizPlan::where('plan_id', $planId)->update($updateData);
    }

    // 修改方案状态

    public function changeStatus($planId, $status, $statusChangeBy = '')
    {
        return BizPlan::where('plan_id', $planId)->update([
            'status' => $status,
            'status_change_by' => $statusChangeBy,
            'status_change_time' => date('Y-m-d H:i:s'),
            'update_time' => date('Y-m-d H:i:s')
        ]);
    }

    public function updateShippedAmount($planId, $amount)
    {
        $plan = BizPlan::find($planId);
        if (!$plan) {
            return false;
        }

        BizPlan::where('plan_id', $planId)->increment('shipped_amount', $amount);
        BizPlan::where('plan_id', $planId)->decrement('remaining_amount', $amount);

        // 刷新后检查是否需要更新状态
        $plan->refresh();
        if (bccomp($plan->remaining_amount, 0, 2) <= 0) {
            BizPlan::where('plan_id', $planId)->update([
                'remaining_amount' => 0,
                'audit_status' => '3',
                'update_time' => date('Y-m-d H:i:s')
            ]);
        }

        return true;
    }

    public function updateItemShippedQuantity($planItemId, $quantity)
    {
        BizPlanItem::where('item_id', $planItemId)->increment('shipped_quantity', $quantity);
        return true;
    }

    /**
     * 获取方案下活跃备货的总金额（已备货未出库金额）
     * 活跃备货 = status IN (0,1) 的备货记录
     * @param int $planId 方案ID
     * @return float 已备货未出库金额
     */
    public function getActivePreparedAmount($planId)
    {
        return BizStockPrepare::where('plan_id', $planId)
            ->whereIn('status', [0, 1])
            ->selectRaw('COALESCE(SUM(total_amount - shipped_amount), 0) as active_amount')
            ->value('active_amount');
    }
}
