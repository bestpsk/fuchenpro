<?php

namespace app\service;

use app\model\BizCardItem;
use app\model\BizCardItemProduct;
use app\service\DataScopeService;
use support\Db;

class BizCardItemService
{
    public function selectCardItemList($params = [])
    {
        $query = BizCardItem::with('products.product');
        // 统一关键字搜索（AppV3 传入 keyword，对名称/编码做 OR 匹配）
        if (!empty($params['keyword'])) {
            $keyword = $params['keyword'];
            $query->where(function ($q) use ($keyword) {
                $q->where('card_item_name', 'like', '%' . $keyword . '%')
                  ->orWhere('card_item_code', 'like', '%' . $keyword . '%');
            });
        }
        // PC 端两个字段独立查询（AND 逻辑）
        if (!empty($params['card_item_name'])) {
            $query->where('card_item_name', 'like', '%' . $params['card_item_name'] . '%');
        }
        if (!empty($params['card_item_code'])) {
            $query->where('card_item_code', 'like', '%' . $params['card_item_code'] . '%');
        }
        if (isset($params['category']) && $params['category'] !== '') {
            $query->where('category', $params['category']);
        }
        if (isset($params['status']) && $params['status'] !== '') {
            $query->where('status', $params['status']);
        }
        $pageNum = intval($params['page_num'] ?? 1);
        $pageSize = intval($params['page_size'] ?? 10);
        $result = $query->orderBy('card_item_id', 'desc')->paginate($pageSize, ['*'], 'page', $pageNum);
        return $result;
    }

    public function selectCardItemById($cardItemId)
    {
        return BizCardItem::with('products.product')->find($cardItemId);
    }

    public function searchCardItem($keyword = '', $params = [])
    {
        $query = BizCardItem::query()->where('status', '0');
        if (!empty($keyword)) {
            $query->where(function ($q) use ($keyword) {
                $q->where('card_item_name', 'like', '%' . $keyword . '%')
                  ->orWhere('card_item_code', 'like', '%' . $keyword . '%');
            });
        }
        return $query->orderBy('card_item_id', 'desc')->limit(50)->get();
    }

    public function insertCardItem($data)
    {
        return Db::transaction(function () use ($data) {
            $data['create_time'] = date('Y-m-d H:i:s');
            if (!empty($data['suggested_price']) && !empty($data['default_quantity']) && $data['default_quantity'] > 0) {
                $data['default_unit_price'] = round(floatval($data['suggested_price']) / intval($data['default_quantity']), 2);
            }
            $products = $data['products'] ?? [];
            unset($data['products']);
            $cardItem = BizCardItem::create($data);
            $this->syncProducts($cardItem->card_item_id, $products);
            return $cardItem;
        });
    }

    public function updateCardItem($data)
    {
        return Db::transaction(function () use ($data) {
            $data['update_time'] = date('Y-m-d H:i:s');
            if (isset($data['suggested_price']) && isset($data['default_quantity']) && intval($data['default_quantity']) > 0) {
                $data['default_unit_price'] = round(floatval($data['suggested_price']) / intval($data['default_quantity']), 2);
            }
            $products = $data['products'] ?? null;
            unset($data['products']);
            $updateData = array_intersect_key($data, array_flip((new BizCardItem())->getFillable()));
            $result = BizCardItem::where('card_item_id', $data['card_item_id'])->update($updateData);
            if ($products !== null) {
                $this->syncProducts($data['card_item_id'], $products);
            }
            return $result;
        });
    }

    public function deleteCardItemByIds($cardItemIds)
    {
        return Db::transaction(function () use ($cardItemIds) {
            BizCardItemProduct::whereIn('card_item_id', $cardItemIds)->delete();
            return BizCardItem::whereIn('card_item_id', $cardItemIds)->delete();
        });
    }

    private function syncProducts($cardItemId, $products)
    {
        BizCardItemProduct::where('card_item_id', $cardItemId)->delete();
        foreach ($products as $product) {
            BizCardItemProduct::create([
                'card_item_id' => $cardItemId,
                'product_id' => $product['product_id'],
                'unit_type' => $product['unit_type'] ?? '1',
                'pack_qty' => $product['pack_qty'] ?? 1,
                'quantity' => $product['quantity'] ?? 1,
                'remark' => $product['remark'] ?? null
            ]);
        }
    }
}
