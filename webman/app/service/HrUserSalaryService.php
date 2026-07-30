<?php

namespace app\service;

use app\model\HrSalaryType;
use app\model\HrUserSalary;
use app\model\HrSalaryTier;
use support\Db;

/**
 * 薪资管理服务层，处理用户薪资的增删改查和薪资层级配置
 */
class HrUserSalaryService
{
    public function selectSalaryTypeList($params = [])
    {
        $query = HrSalaryType::query();
        if (!empty($params['status'])) {
            $query->where('status', $params['status']);
        }
        return $query->orderBy('type_id', 'asc')->get();
    }

    public function selectSalaryTypeById($typeId)
    {
        return HrSalaryType::find($typeId);
    }

    public function selectUserSalaryList($userId)
    {
        return HrUserSalary::with(['salaryType', 'tiers'])
            ->where('user_id', $userId)
            ->orderBy('salary_id', 'asc')
            ->get();
    }

    public function selectUserSalaryById($salaryId)
    {
        return HrUserSalary::with(['salaryType', 'tiers'])->find($salaryId);
    }

    public function insertUserSalary($data)
    {
        return Db::transaction(function () use ($data) {
            $data['create_time'] = date('Y-m-d H:i:s');
            $tierConfig = $data['tier_config'] ?? null;
            $tiers = $data['tiers'] ?? [];
            unset($data['tier_config'], $data['tiers']);

            $salary = HrUserSalary::create($data);

            if (!empty($tierConfig)) {
                $salary->tier_config = $tierConfig;
                $salary->save();
            }

            if (!empty($tiers)) {
                $this->saveTiers($salary->salary_id, $tiers);
            }

            return $salary;
        });
    }

    public function updateUserSalary($data)
    {
        return Db::transaction(function () use ($data) {
            $salary = HrUserSalary::find($data['salary_id']);
            if (!$salary) {
                return false;
            }
            $data['update_time'] = date('Y-m-d H:i:s');
            $tierConfig = $data['tier_config'] ?? null;
            $tiers = $data['tiers'] ?? [];
            unset($data['tier_config'], $data['tiers'], $data['salary_id']);

            $salary->fill($data)->save();

            if ($tierConfig !== null) {
                $salary->tier_config = $tierConfig;
                $salary->save();
            }

            if (!empty($tiers)) {
                HrSalaryTier::where('salary_id', $salary->salary_id)->delete();
                $this->saveTiers($salary->salary_id, $tiers);
            }

            return true;
        });
    }

    public function deleteUserSalaryByIds($salaryIds)
    {
        HrSalaryTier::whereIn('salary_id', $salaryIds)->delete();
        return HrUserSalary::whereIn('salary_id', $salaryIds)->delete();
    }

    private function saveTiers($salaryId, $tiers)
    {
        foreach ($tiers as $index => $tier) {
            $tier['salary_id'] = $salaryId;
            $tier['tier_level'] = $index + 1;
            $tier['create_time'] = date('Y-m-d H:i:s');
            HrSalaryTier::create($tier);
        }
    }
}
