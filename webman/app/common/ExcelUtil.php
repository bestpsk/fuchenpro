<?php

namespace app\common;

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Style\Font;
use PhpOffice\PhpSpreadsheet\Cell\DataType;
use PhpOffice\PhpSpreadsheet\IOFactory;
use support\Response;

/**
 * Excel导入导出工具
 *
 * 基于PhpSpreadsheet实现Excel文件的导入导出功能，
 * 支持通过模型类注解定义导出字段、字典值转换、日期格式化、
 * 导入模板生成和数据批量导入解析
 */
class ExcelUtil
{
    // 分隔符常量
    const SEPARATOR = ',';

    const FORMULA_REGEX_STR = '=|-|\+|@';

    // 可能注入Excel公式的危险字符
    const FORMULA_STR = ['=', '-', '+', '@'];

    // 操作类型：0=全部 1=导出 2=导入
    const TYPE_ALL = 0;
    const TYPE_EXPORT = 1;
    const TYPE_IMPORT = 2;

    private $clazz;          // 关联的模型类名，用于获取字段定义
    private $fields = [];    // 解析后的Excel字段配置列表
    private $spreadsheet;    // PhpSpreadsheet工作簿实例
    private $sheet;          // 当前活动工作表
    private $sheetName;      // 工作表名称
    private $title;          // Excel标题行
    private $type;           // 当前操作类型（导出/导入）
    private $rownum = 0;     // 当前写入行号
    private $list = [];      // 待导出的数据列表

    public function __construct(string $clazz)
    {
        $this->clazz = $clazz;
    }

    // 导出Excel文件，根据模型字段定义生成带标题和表头的xlsx文件并下载
    public function exportExcel($list, string $sheetName, string $title = ''): Response
    {
        $this->list = $list ?? [];
        $this->sheetName = $sheetName;
        $this->title = $title;
        $this->type = self::TYPE_EXPORT;

        $this->createExcelField();
        $this->createWorkbook();
        $this->createTitle();
        $this->writeSheet();

        return $this->outputExcel($sheetName);
    }

    // 生成导入模板Excel文件（仅包含表头，无数据行）
    public function importTemplateExcel(string $sheetName, string $title = ''): Response
    {
        $this->list = [];
        $this->sheetName = $sheetName;
        $this->title = $title;
        $this->type = self::TYPE_IMPORT;

        $this->createExcelField();
        $this->createWorkbook();
        $this->createTitle();
        $this->writeSheet();

        return $this->outputExcel($sheetName);
    }

    // 解析上传的Excel文件，根据表头与模型字段映射关系提取数据，支持字典值反转和日期格式转换
    public function importExcel($file): array
    {
        if (!$file || !$file->isValid()) {
            throw new \Exception('上传文件无效');
        }

        $extension = strtolower($file->getUploadExtension());
        if (!in_array($extension, ['xlsx', 'xls'])) {
            throw new \Exception('文件格式不正确，仅支持xlsx和xls格式');
        }

        $this->type = self::TYPE_IMPORT;
        $this->createExcelField();

        $spreadsheet = IOFactory::load($file->getRealPath());
        $sheet = $spreadsheet->getActiveSheet();
        $rows = $sheet->getHighestRow();
        $columns = $sheet->getHighestColumn();

        $list = [];
        $cellMap = [];

        $headerRow = $sheet->getRowIterator(1)->current();
        foreach ($headerRow->getCellIterator() as $cell) {
            $value = $cell->getValue();
            if ($value !== null) {
                $cellMap[$value] = $cell->getColumn();
            }
        }

        $fieldsMap = [];
        foreach ($this->fields as $field) {
            $fieldName = $field['field'];
            $excelName = $field['name'];
            if (isset($cellMap[$excelName])) {
                $fieldsMap[$cellMap[$excelName]] = $field;
            }
        }

        for ($row = 2; $row <= $rows; $row++) {
            $entity = [];
            $isEmpty = true;

            foreach ($fieldsMap as $col => $field) {
                $cell = $sheet->getCell($col . $row);
                $value = $cell->getValue();

                if ($value !== null && $value !== '') {
                    $isEmpty = false;
                }

                $fieldName = $field['field'];
                $entity[$fieldName] = $this->convertValue($value, $field);
            }

            if (!$isEmpty) {
                $list[] = $entity;
            }
        }

        return $list;
    }

    // 导入时将Excel单元格值转换为模型字段值，支持表达式反转、字典反转和日期格式处理
    private function convertValue($value, array $field)
    {
        if ($value === null) {
            return null;
        }

        if (!empty($field['readConverterExp'])) {
            $value = $this->reverseByExp($value, $field['readConverterExp']);
        }

        if (!empty($field['dictType'])) {
            $value = $this->reverseDictByExp($value, $field['dictType']);
        }

        if (!empty($field['dateFormat']) && $value !== null) {
            if (is_numeric($value)) {
                $date = \PhpOffice\PhpSpreadsheet\Shared\Date::excelToDateTimeObject($value);
                $value = $date->format('Y-m-d H:i:s');
            }
        }

        return $value;
    }

    // 从模型类的getExcelFields方法解析字段配置，按导入/导出类型过滤并排序
    private function createExcelField(): void
    {
        $this->fields = [];
        if (method_exists($this->clazz, 'getExcelFields')) {
            $fields = call_user_func([$this->clazz, 'getExcelFields']);
            foreach ($fields as $fieldName => $config) {
                $fieldType = $config['type'] ?? 'all';
                if ($this->type === self::TYPE_EXPORT) {
                    if ($fieldType === 'import') {
                        continue;
                    }
                } elseif ($this->type === self::TYPE_IMPORT) {
                    if ($fieldType === 'export') {
                        continue;
                    }
                }

                $this->fields[] = array_merge([
                    'field' => $fieldName,
                    'name' => $fieldName,
                    'width' => 16,
                    'height' => 14,
                    'dateFormat' => '',
                    'dictType' => '',
                    'readConverterExp' => '',
                    'cellType' => 'string',
                    'type' => 'all',
                    'prompt' => '',
                    'combo' => [],
                ], $config);
            }
        }

        usort($this->fields, function ($a, $b) {
            $sortA = $a['sort'] ?? PHP_INT_MAX;
            $sortB = $b['sort'] ?? PHP_INT_MAX;
            return $sortA <=> $sortB;
        });
    }

    // 创建PhpSpreadsheet工作簿和工作表实例
    private function createWorkbook(): void
    {
        $this->spreadsheet = new Spreadsheet();
        $this->sheet = $this->spreadsheet->getActiveSheet();
        $this->sheet->setTitle($this->sheetName);
        $this->rownum = 0;
    }

    // 创建Excel标题行，合并单元格并设置居中加粗样式
    private function createTitle(): void
    {
        if (!empty($this->title)) {
            $row = $this->sheet->getRowDimension(1);
            $row->setRowHeight(30);

            $cell = $this->sheet->getCell('A1');
            $cell->setValue($this->title);
            $cell->getStyle()->getFont()->setBold(true)->setSize(16);
            $cell->getStyle()->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);

            $lastCol = count($this->fields) - 1;
            if ($lastCol > 0) {
                $this->sheet->mergeCells('A1:' . $this->getColumnLetter($lastCol) . '1');
            }
            $this->rownum = 1;
        }
    }

    // 写入表头行（蓝色背景白色加粗字体），导出模式下追加数据行
    private function writeSheet(): void
    {
        $headerRow = $this->rownum + 1;
        $colIndex = 0;

        foreach ($this->fields as $field) {
            $colLetter = $this->getColumnLetter($colIndex);
            $cell = $this->sheet->getCell($colLetter . $headerRow);
            $cell->setValue($field['name']);

            $style = $cell->getStyle();
            $style->getFont()->setBold(true);
            $style->getFill()->setFillType(Fill::FILL_SOLID);
            $style->getFill()->getStartColor()->setRGB('4F81BD');
            $style->getFont()->getColor()->setRGB('FFFFFF');
            $style->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
            $style->getAlignment()->setVertical(Alignment::VERTICAL_CENTER);

            $this->sheet->getColumnDimension($colLetter)->setWidth($field['width'] ?? 16);

            $colIndex++;
        }

        $this->rownum = $headerRow;

        if ($this->type === self::TYPE_EXPORT && !empty($this->list)) {
            $this->fillExcelData();
        }
    }

    // 逐行填充导出数据，支持日期格式化、表达式转换、字典翻译，对公式注入字符添加制表符前缀
    private function fillExcelData(): void
    {
        foreach ($this->list as $item) {
            $this->rownum++;
            $colIndex = 0;

            $itemArray = is_object($item) ? $item->toArray() : $item;

            foreach ($this->fields as $field) {
                $colLetter = $this->getColumnLetter($colIndex);
                $cell = $this->sheet->getCell($colLetter . $this->rownum);

                $fieldName = $field['field'];
                $value = $itemArray[$fieldName] ?? null;

                if ($value !== null) {
                    if (!empty($field['dateFormat']) && $value !== null) {
                        if ($value instanceof \DateTime) {
                            $value = $value->format($field['dateFormat']);
                        } elseif (is_string($value)) {
                            $date = strtotime($value);
                            if ($date !== false) {
                                $value = date($field['dateFormat'], $date);
                            }
                        }
                    }

                    if (!empty($field['readConverterExp'])) {
                        $value = $this->convertByExp($value, $field['readConverterExp']);
                    }

                    if (!empty($field['dictType'])) {
                        $value = $this->convertDictByExp($value, $field['dictType']);
                    }

                    $cellValue = (string)$value;
                    if (preg_match('/^' . self::FORMULA_REGEX_STR . '/', $cellValue)) {
                        $cellValue = "\t" . $cellValue;
                    }

                    $cell->setValue($cellValue);
                }

                $style = $cell->getStyle();
                $style->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
                $style->getAlignment()->setVertical(Alignment::VERTICAL_CENTER);
                $style->getBorders()->getAllBorders()->setBorderStyle(Border::BORDER_THIN);

                $colIndex++;
            }
        }
    }

    // 将工作簿写入临时文件并以流式响应下载
    private function outputExcel(string $filename): Response
    {
        $writer = new Xlsx($this->spreadsheet);

        $tempFile = tempnam(sys_get_temp_dir(), 'excel_');
        $writer->save($tempFile);

        $downloadFilename = $this->encodingFilename($filename);

        $response = new Response(200, [
            'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'Content-Disposition' => 'attachment;filename="' . $downloadFilename . '"',
            'Cache-Control' => 'max-age=0',
        ], file_get_contents($tempFile));

        unlink($tempFile);

        return $response;
    }

    // 生成唯一文件名，避免中文文件名乱码
    private function encodingFilename(string $filename): string
    {
        return uniqid() . '_' . $filename . '.xlsx';
    }

    // 将数字索引转换为Excel列字母（0=A, 1=B, ...）
    private function getColumnLetter(int $index): string
    {
        $letter = '';
        while ($index >= 0) {
            $letter = chr($index % 26 + 65) . $letter;
            $index = intval($index / 26) - 1;
        }
        return $letter;
    }

    // 导出时根据表达式配置将字段值转换为显示文本（如"0=男,1=女"转为"男"）
    public static function convertByExp($propertyValue, string $converterExp, string $separator = ','): string
    {
        $propertyString = '';
        $convertSource = explode($separator, $converterExp);

        foreach ($convertSource as $item) {
            $itemArray = explode('=', $item, 2);
            if (count($itemArray) !== 2) {
                continue;
            }

            if (strpos((string)$propertyValue, $separator) !== false) {
                foreach (explode($separator, (string)$propertyValue) as $value) {
                    if ($itemArray[0] === $value) {
                        $propertyString .= $itemArray[1] . $separator;
                        break;
                    }
                }
            } else {
                if ($itemArray[0] === (string)$propertyValue) {
                    return $itemArray[1];
                }
            }
        }

        return rtrim($propertyString, $separator);
    }

    // 导入时根据表达式配置将显示文本反向转换为字段值（如"男"转为"0"）
    public static function reverseByExp($propertyValue, string $converterExp, string $separator = ','): string
    {
        $propertyString = '';
        $convertSource = explode($separator, $converterExp);

        foreach ($convertSource as $item) {
            $itemArray = explode('=', $item, 2);
            if (count($itemArray) !== 2) {
                continue;
            }

            if (strpos((string)$propertyValue, $separator) !== false) {
                foreach (explode($separator, (string)$propertyValue) as $value) {
                    if ($itemArray[1] === $value) {
                        $propertyString .= $itemArray[0] . $separator;
                        break;
                    }
                }
            } else {
                if ($itemArray[1] === (string)$propertyValue) {
                    return $itemArray[0];
                }
            }
        }

        return rtrim($propertyString, $separator);
    }

    // 导出时根据字典类型将字典值转换为字典标签
    public static function convertDictByExp($dictValue, string $dictType, string $separator = ','): string
    {
        return SysDictTypeService::getDictLabel($dictType, (string)$dictValue, $separator);
    }

    // 导入时根据字典类型将字典标签反向转换为字典值
    public static function reverseDictByExp($dictLabel, string $dictType, string $separator = ','): string
    {
        return SysDictTypeService::getDictValue($dictType, (string)$dictLabel, $separator);
    }
}
