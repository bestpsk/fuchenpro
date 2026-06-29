<?php

namespace app\service;

use app\model\BizStockIn;
use app\model\BizStockInItem;
use app\model\BizStockOut;
use app\model\BizStockOutItem;
use app\model\BizInventory;
use app\model\BizProduct;
use app\service\DataScopeService;
use support\Db;

/**
 * 仓储报表服务层，提供入库汇总、出库汇总、库存收发存和产品流水明细等报表查询
 */
class BizWmsReportService
{
    public function stockInSummary($params = [])
    {
        $query = BizStockInItem::query()
            ->join('biz_stock_in', 'biz_stock_in_item.stock_in_id', '=', 'biz_stock_in.stock_in_id')
            ->join('biz_product', 'biz_stock_in_item.product_id', '=', 'biz_product.product_id')
            ->where('biz_stock_in.status', '1');
        if (!empty($params['stock_in_date_start'])) {
            $query->where('biz_stock_in.stock_in_date', '>=', $params['stock_in_date_start']);
        }
        if (!empty($params['stock_in_date_end'])) {
            $query->where('biz_stock_in.stock_in_date', '<=', $params['stock_in_date_end']);
        }
        if (!empty($params['supplier_id'])) {
            $query->where('biz_stock_in.supplier_id', $params['supplier_id']);
        }
        if (isset($params['category']) && $params['category'] !== '') {
            $query->where('biz_product.category', $params['category']);
        }
        if (!empty($params['warehouse_id'])) {
            $query->where('biz_stock_in.warehouse_id', $params['warehouse_id']);
        }
        // 进销存数据属于公共数据，不受数据权限约束
        // if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
        //     $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
        //     $query->where(function ($q) use ($visibleUserIds) {
        //         $q->whereIn('biz_stock_in.operator_id', $visibleUserIds)
        //           ->orWhereNull('biz_stock_in.operator_id');
        //     });
        // }
        $authorizedWhIds = BizWarehouseService::getAuthorizedWarehouseIds($params['login_user'] ?? null);
        if ($authorizedWhIds !== null) {
            $query->whereIn('biz_stock_in.warehouse_id', $authorizedWhIds);
        }
        $results = $query->groupBy([
                'biz_stock_in_item.product_id',
                'biz_stock_in_item.product_name',
                'biz_product.category',
                'biz_product.unit',
                'biz_product.spec',
                'biz_product.pack_qty',
            ])
            ->selectRaw(
                'biz_stock_in_item.product_id, ' .
                'biz_stock_in_item.product_name, ' .
                'biz_product.category, ' .
                'biz_product.unit, ' .
                'biz_product.spec, ' .
                'biz_product.pack_qty, ' .
                'SUM(biz_stock_in_item.quantity) as total_quantity, ' .
                'SUM(biz_stock_in_item.amount) as total_amount'
            )
            ->get();
        return $results;
    }

    public function stockOutSummary($params = [])
    {
        $query = BizStockOutItem::query()
            ->join('biz_stock_out', 'biz_stock_out_item.stock_out_id', '=', 'biz_stock_out.stock_out_id')
            ->join('biz_product', 'biz_stock_out_item.product_id', '=', 'biz_product.product_id')
            ->whereIn('biz_stock_out.status', ['1', '2', '3']);
        if (!empty($params['stock_out_date_start'])) {
            $query->where('biz_stock_out.stock_out_date', '>=', $params['stock_out_date_start']);
        }
        if (!empty($params['stock_out_date_end'])) {
            $query->where('biz_stock_out.stock_out_date', '<=', $params['stock_out_date_end']);
        }
        if (!empty($params['enterprise_id'])) {
            $query->where('biz_stock_out.enterprise_id', $params['enterprise_id']);
        }
        if (isset($params['category']) && $params['category'] !== '') {
            $query->where('biz_product.category', $params['category']);
        }
        if (!empty($params['warehouse_id'])) {
            $query->where(function($q) use ($params) {
                $q->where('biz_stock_out.warehouse_id', $params['warehouse_id'])
                  ->orWhereNull('biz_stock_out.warehouse_id');
            });
        }
        // 进销存数据属于公共数据，不受数据权限约束
        // if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
        //     $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
        //     $query->where(function ($q) use ($visibleUserIds) {
        //         $q->whereIn('biz_stock_out.responsible_id', $visibleUserIds)
        //           ->orWhereNull('biz_stock_out.responsible_id');
        //     });
        // }
        $authorizedWhIds = BizWarehouseService::getAuthorizedWarehouseIds($params['login_user'] ?? null);
        if ($authorizedWhIds !== null) {
            $query->whereIn('biz_stock_out.warehouse_id', $authorizedWhIds);
        }
        $results = $query->groupBy([
                'biz_stock_out_item.product_id',
                'biz_stock_out_item.product_name',
                'biz_product.category',
                'biz_product.unit',
                'biz_product.spec',
                'biz_product.pack_qty',
            ])
            ->selectRaw(
                'biz_stock_out_item.product_id, ' .
                'biz_stock_out_item.product_name, ' .
                'biz_product.category, ' .
                'biz_product.unit, ' .
                'biz_product.spec, ' .
                'biz_product.pack_qty, ' .
                'SUM(biz_stock_out_item.quantity) as total_quantity, ' .
                'SUM(biz_stock_out_item.amount) as total_amount'
            )
            ->get();
        return $results;
    }

    public function inventoryTurnover($params = [])
    {
        $query = BizProduct::query()
            ->leftJoin('biz_inventory', 'biz_product.product_id', '=', 'biz_inventory.product_id')
            ->where('biz_product.status', '0');
        if (isset($params['category']) && $params['category'] !== '') {
            $query->where('biz_product.category', $params['category']);
        }
        if (!empty($params['warehouse_id'])) {
            $query->where('biz_inventory.warehouse_id', $params['warehouse_id']);
        }
        // 进销存数据属于公共数据，不受数据权限约束
        // if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
        //     $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
        //     $query->whereExists(function ($q) use ($visibleUserIds) {
        //         $q->select(Db::raw(1))
        //             ->from('biz_stock_in_item')
        //             ->join('biz_stock_in', 'biz_stock_in_item.stock_in_id', '=', 'biz_stock_in.stock_in_id')
        //             ->whereColumn('biz_stock_in_item.product_id', 'biz_product.product_id')
        //             ->whereIn('biz_stock_in.operator_id', $visibleUserIds);
        //     });
        // }
        $authorizedWhIds = BizWarehouseService::getAuthorizedWarehouseIds($params['login_user'] ?? null);
        if ($authorizedWhIds !== null) {
            $query->whereIn('biz_inventory.warehouse_id', $authorizedWhIds);
        }
        $products = $query->select([
                'biz_product.product_id',
                'biz_product.product_name',
                'biz_product.product_code',
                'biz_product.category',
                'biz_product.unit',
                'biz_product.spec',
                'biz_product.pack_qty',
                'biz_inventory.quantity as current_quantity',
            ])
            ->get();
        $startDate = $params['start_date'] ?? date('Y-m-01');
        $endDate = $params['end_date'] ?? date('Y-m-d');
        foreach ($products as $product) {
            $stockInQty = BizStockInItem::query()
                ->join('biz_stock_in', 'biz_stock_in_item.stock_in_id', '=', 'biz_stock_in.stock_in_id')
                ->where('biz_stock_in.status', '1')
                ->where('biz_stock_in_item.product_id', $product->product_id)
                ->whereBetween('biz_stock_in.stock_in_date', [$startDate, $endDate]);
            if (!empty($params['warehouse_id'])) {
                $stockInQty->where('biz_stock_in.warehouse_id', $params['warehouse_id']);
            }
            $stockInQty = $stockInQty->sum('biz_stock_in_item.quantity');
            $stockOutQty = BizStockOutItem::query()
                ->join('biz_stock_out', 'biz_stock_out_item.stock_out_id', '=', 'biz_stock_out.stock_out_id')
                ->whereIn('biz_stock_out.status', ['1', '2', '3'])
                ->where('biz_stock_out_item.product_id', $product->product_id)
                ->whereBetween('biz_stock_out.stock_out_date', [$startDate, $endDate]);
            if (!empty($params['warehouse_id'])) {
                $stockOutQty->where(function($q) use ($params) {
                    $q->where('biz_stock_out.warehouse_id', $params['warehouse_id'])
                      ->orWhereNull('biz_stock_out.warehouse_id');
                });
            }
            $stockOutQty = $stockOutQty->sum('biz_stock_out_item.quantity');
            $product->period_in_quantity = intval($stockInQty);
            $product->period_out_quantity = intval($stockOutQty);
            $product->begin_quantity = intval($product->current_quantity) - intval($stockInQty) + intval($stockOutQty);
            $product->end_quantity = intval($product->current_quantity);
        }
        return $products;
    }

    public function productFlow($params = [])
    {
        $productId = $params['product_id'] ?? 0;
        if (!$productId) {
            return [];
        }
        $product = BizProduct::find($productId);
        $productInfo = $product ? [
            'unit' => $product->unit,
            'spec' => $product->spec,
            'pack_qty' => $product->pack_qty ?? 1,
        ] : ['unit' => null, 'spec' => null, 'pack_qty' => 1];
        $flows = [];
        $stockInItems = BizStockInItem::query()
            ->join('biz_stock_in', 'biz_stock_in_item.stock_in_id', '=', 'biz_stock_in.stock_in_id')
            ->where('biz_stock_in.status', '1')
            ->where('biz_stock_in_item.product_id', $productId);
        if (!empty($params['flow_date_start'])) {
            $stockInItems->where('biz_stock_in.stock_in_date', '>=', $params['flow_date_start']);
        }
        if (!empty($params['flow_date_end'])) {
            $stockInItems->where('biz_stock_in.stock_in_date', '<=', $params['flow_date_end']);
        }
        if (!empty($params['warehouse_id'])) {
            $stockInItems->where('biz_stock_in.warehouse_id', $params['warehouse_id']);
        }
        // 进销存数据属于公共数据，不受数据权限约束
        // if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
        //     $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
        //     $stockInItems->where(function ($q) use ($visibleUserIds) {
        //         $q->whereIn('biz_stock_in.operator_id', $visibleUserIds)
        //           ->orWhereNull('biz_stock_in.operator_id');
        //     });
        // }
        $authorizedWhIds = BizWarehouseService::getAuthorizedWarehouseIds($params['login_user'] ?? null);
        if ($authorizedWhIds !== null) {
            $stockInItems->whereIn('biz_stock_in.warehouse_id', $authorizedWhIds);
        }
        $stockInList = $stockInItems->select([
                'biz_stock_in.stock_in_no as doc_no',
                'biz_stock_in.stock_in_date as flow_date',
                'biz_stock_in_item.quantity',
                'biz_stock_in_item.amount',
                Db::raw("'入库' as flow_type"),
            ])->get();
        foreach ($stockInList as $item) {
            $item->unit = $productInfo['unit'];
            $item->spec = $productInfo['spec'];
            $item->pack_qty = $productInfo['pack_qty'];
            $flows[] = $item;
        }
        $stockOutItems = BizStockOutItem::query()
            ->join('biz_stock_out', 'biz_stock_out_item.stock_out_id', '=', 'biz_stock_out.stock_out_id')
            ->whereIn('biz_stock_out.status', ['1', '2', '3'])
            ->where('biz_stock_out_item.product_id', $productId);
        if (!empty($params['flow_date_start'])) {
            $stockOutItems->where('biz_stock_out.stock_out_date', '>=', $params['flow_date_start']);
        }
        if (!empty($params['flow_date_end'])) {
            $stockOutItems->where('biz_stock_out.stock_out_date', '<=', $params['flow_date_end']);
        }
        if (!empty($params['warehouse_id'])) {
            $stockOutItems->where(function($q) use ($params) {
                $q->where('biz_stock_out.warehouse_id', $params['warehouse_id'])
                  ->orWhereNull('biz_stock_out.warehouse_id');
            });
        }
        // 进销存数据属于公共数据，不受数据权限约束
        // if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
        //     $visibleUserIds2 = DataScopeService::getVisibleUserIds($params['login_user']);
        //     $stockOutItems->where(function ($q) use ($visibleUserIds2) {
        //         $q->whereIn('biz_stock_out.responsible_id', $visibleUserIds2)
        //           ->orWhereNull('biz_stock_out.responsible_id');
        //     });
        // }
        if ($authorizedWhIds !== null) {
            $stockOutItems->whereIn('biz_stock_out.warehouse_id', $authorizedWhIds);
        }
        $stockOutList = $stockOutItems->select([
                'biz_stock_out.stock_out_no as doc_no',
                'biz_stock_out.stock_out_date as flow_date',
                'biz_stock_out_item.quantity',
                'biz_stock_out_item.amount',
                Db::raw("'出库' as flow_type"),
            ])->get();
        foreach ($stockOutList as $item) {
            $item->unit = $productInfo['unit'];
            $item->spec = $productInfo['spec'];
            $item->pack_qty = $productInfo['pack_qty'];
            $flows[] = $item;
        }
        usort($flows, function ($a, $b) {
            return strcmp($a['flow_date'], $b['flow_date']);
        });
        $balance = 0;
        foreach ($flows as &$flow) {
            if ($flow['flow_type'] === '入库') {
                $balance += intval($flow['quantity']);
            } else {
                $balance -= intval($flow['quantity']);
            }
            $flow['balance'] = $balance;
        }
        unset($flow);
        $flows = array_reverse($flows);
        return $flows;
    }

    public function expiryInventory($params)
    {
        $query = BizStockInItem::from('biz_stock_in_item as sii')
            ->join('biz_product as p', 'sii.product_id', '=', 'p.product_id')
            ->join('biz_stock_in as si', 'sii.stock_in_id', '=', 'si.stock_in_id')
            ->whereRaw('sii.quantity > sii.shipped_quantity')
            ->whereNotNull('sii.expiry_date')
            ->where('si.status', '1'); // 只统计已确认的入库单

        // 仓库筛选
        if (!empty($params['warehouse_id'])) {
            $query->where('si.warehouse_id', $params['warehouse_id']);
        }

        // 到期状态筛选
        if (!empty($params['expiry_status'])) {
            $today = date('Y-m-d');
            switch ($params['expiry_status']) {
                case 'expired':
                    $query->where('sii.expiry_date', '<', $today);
                    break;
                case '30':
                    $query->where('sii.expiry_date', '>=', $today)
                          ->where('sii.expiry_date', '<=', date('Y-m-d', strtotime('+30 days')));
                    break;
                case '60':
                    $query->where('sii.expiry_date', '>', date('Y-m-d', strtotime('+30 days')))
                          ->where('sii.expiry_date', '<=', date('Y-m-d', strtotime('+60 days')));
                    break;
                case '90':
                    $query->where('sii.expiry_date', '>', date('Y-m-d', strtotime('+60 days')))
                          ->where('sii.expiry_date', '<=', date('Y-m-d', strtotime('+90 days')));
                    break;
                case 'normal':
                    $query->where('sii.expiry_date', '>', date('Y-m-d', strtotime('+90 days')));
                    break;
            }
        }

        // 进销存数据属于公共数据，不受数据权限约束
        // if (!empty($params['login_user']) && !$params['login_user']->isAdmin()) {
        //     $visibleUserIds = DataScopeService::getVisibleUserIds($params['login_user']);
        //     $query->where(function ($q) use ($visibleUserIds) {
        //         $q->whereIn('si.operator_id', $visibleUserIds)
        //           ->orWhereNull('si.operator_id');
        //     });
        // }
        $authorizedWhIds = BizWarehouseService::getAuthorizedWarehouseIds($params['login_user'] ?? null);
        if ($authorizedWhIds !== null) {
            $query->whereIn('si.warehouse_id', $authorizedWhIds);
        }

        $items = $query->select([
                'sii.item_id',
                'si.stock_in_no',
                'si.warehouse_id',
                'sii.product_id',
                'p.product_name',
                'p.category',
                'sii.quantity',
                'sii.shipped_quantity',
                Db::raw('sii.quantity - sii.shipped_quantity as remaining_quantity'),
                'sii.production_date',
                'sii.expiry_date',
                Db::raw('DATEDIFF(sii.expiry_date, CURDATE()) as remaining_days'),
            ])
            ->orderBy('remaining_days', 'asc')
            ->get();

        // 计算到期状态
        $result = $items->map(function ($item) {
            $remainingDays = intval($item->remaining_days);
            if ($remainingDays <= 0) {
                $item->expiry_status = 'expired';
                $item->expiry_status_text = '已过期';
            } elseif ($remainingDays <= 30) {
                $item->expiry_status = '30';
                $item->expiry_status_text = '30天内到期';
            } elseif ($remainingDays <= 60) {
                $item->expiry_status = '60';
                $item->expiry_status_text = '60天内到期';
            } elseif ($remainingDays <= 90) {
                $item->expiry_status = '90';
                $item->expiry_status_text = '90天内到期';
            } else {
                $item->expiry_status = 'normal';
                $item->expiry_status_text = '正常';
            }
            return $item;
        });

        return $result;
    }
}
