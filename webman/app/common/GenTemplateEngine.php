<?php

namespace app\common;

/**
 * 代码生成模板引擎
 *
 * 轻量级模板引擎，支持变量替换、条件判断(#if/#else/#end)、
 * 循环遍历(#foreach/#end)和工具方法调用($tool.xxx)，
 * 用于代码生成器将.vm模板文件渲染为PHP源代码
 */
class GenTemplateEngine
{
    private array $context = [];  // 模板变量上下文

    public function __construct(array $context = [])
    {
        $this->context = $context;
    }

    // 设置模板上下文变量
    public function setContext(string $key, $value): void
    {
        $this->context[$key] = $value;
    }

    // 渲染模板字符串，依次处理循环、条件、变量和方法调用
    public function render(string $template): string
    {
        $output = $template;
        $output = $this->processForeach($output);
        $output = $this->processIf($output);
        $output = $this->processVariables($output);
        $output = $this->processMethodCalls($output);
        return $output;
    }

    // 处理#foreach循环标签，遍历集合并为每个元素渲染循环体
    private function processForeach(string $template): string
    {
        $pattern = '/#foreach\s*\(\s*\$(\w+)\s+as\s+\$(\w+)\s*\)(.*?)#end/s';
        while (preg_match($pattern, $template, $matches, PREG_OFFSET_CAPTURE)) {
            $fullMatch = $matches[0][0];
            $collectionName = $matches[1][0];
            $itemName = $matches[2][0];
            $body = $matches[3][0];
            $offset = $matches[0][1];

            $collection = $this->context[$collectionName] ?? [];
            $replacement = '';
            $index = 0;
            foreach ($collection as $item) {
                $tempContext = $this->context;
                $this->context[$itemName] = $item;
                $this->context['foreachIndex'] = $index;
                $this->context['foreachCount'] = $index + 1;
                $this->context['foreachHasNext'] = $index < count($collection) - 1;
                $replacement .= $this->processVariables($body);
                $replacement = $this->processMethodCalls($replacement);
                $index++;
                $this->context = $tempContext;
            }

            $template = substr_replace($template, $replacement, $offset, strlen($fullMatch));
        }
        return $template;
    }

    // 处理#if/#elseif/#else/#end条件标签，根据条件表达式选择渲染分支
    private function processIf(string $template): string
    {
        $pattern = '/#if\s*\((.*?)\)(.*?)(#elseif\s*\((.*?)\)(.*?))*(#else(.*?))?#end/s';
        while (preg_match($pattern, $template, $matches, PREG_OFFSET_CAPTURE)) {
            $fullMatch = $matches[0][0];
            $offset = $matches[0][1];

            $condition = $matches[1][0];
            $ifBody = $matches[2][0];

            $elseBody = '';
            if (isset($matches[7])) {
                $elseBody = $matches[7][0];
            }

            $result = '';
            if ($this->evaluateCondition($condition)) {
                $result = $ifBody;
            } elseif ($elseBody !== '') {
                $result = $elseBody;
            }

            $template = substr_replace($template, $result, $offset, strlen($fullMatch));
        }
        return $template;
    }

    // 求值条件表达式，支持变量判断、属性访问、比较运算和逻辑运算
    private function evaluateCondition(string $condition): bool
    {
        $condition = trim($condition);

        if (preg_match('/^!\s*\$(\w+)$/', $condition, $matches)) {
            $varName = $matches[1];
            $value = $this->context[$varName] ?? null;
            return empty($value);
        }

        if (preg_match('/^\$(\w+)$/', $condition, $matches)) {
            $varName = $matches[1];
            $value = $this->context[$varName] ?? null;
            return !empty($value);
        }

        if (preg_match('/^\$(\w+)\.(\w+)$/', $condition, $matches)) {
            $objName = $matches[1];
            $propName = $matches[2];
            $obj = $this->context[$objName] ?? null;
            if (is_array($obj)) {
                $value = $obj[$propName] ?? null;
            } elseif (is_object($obj)) {
                $value = $obj->$propName ?? null;
            } else {
                $value = null;
            }
            return !empty($value);
        }

        if (preg_match('/^(.+?)\s*(==|!=|&&|\|\|)\s*(.+)$/', $condition, $matches)) {
            $left = $this->evaluateExpression(trim($matches[1]));
            $operator = $matches[2];
            $right = $this->evaluateExpression(trim($matches[3]));

            switch ($operator) {
                case '==': return $left == $right;
                case '!=': return $left != $right;
                case '&&': return $left && $right;
                case '||': return $left || $right;
            }
        }

        return false;
    }

    // 求值单个表达式，支持变量引用、字符串字面量、数字和布尔值
    private function evaluateExpression(string $expr)
    {
        $expr = trim($expr);
        if (preg_match('/^\$(\w+)$/', $expr, $matches)) {
            return $this->context[$matches[1]] ?? null;
        }
        if (preg_match('/^["\'](.+)["\']$/', $expr, $matches)) {
            return $matches[1];
        }
        if (is_numeric($expr)) {
            return $expr;
        }
        if ($expr === 'true') return true;
        if ($expr === 'false') return false;
        return $expr;
    }

    // 替换模板中的变量引用（$var、$var.prop、${var.prop}格式）
    private function processVariables(string $template): string
    {
        $template = preg_replace_callback('/\$\{([^}]+)\}/', function ($matches) {
            return $this->resolveVariable($matches[1]);
        }, $template);

        $template = preg_replace_callback('/\$(\w+)\.(\w+)/', function ($matches) {
            return $this->resolveProperty($matches[1], $matches[2]);
        }, $template);

        $template = preg_replace_callback('/\$(\w+)/', function ($matches) {
            $varName = $matches[1];
            if (isset($this->context[$varName])) {
                $value = $this->context[$varName];
                return is_array($value) || is_object($value) ? json_encode($value) : (string)$value;
            }
            return '$' . $varName;
        }, $template);

        return $template;
    }

    // 解析${expr}格式的点号分隔变量路径，逐层访问上下文数据
    private function resolveVariable(string $expr): string
    {
        $parts = explode('.', $expr);
        $value = $this->context[array_shift($parts)] ?? null;
        foreach ($parts as $part) {
            if (is_array($value)) {
                $value = $value[$part] ?? null;
            } elseif (is_object($value)) {
                $value = $value->$part ?? null;
            } else {
                return '';
            }
        }
        if ($value === null) return '';
        return is_array($value) || is_object($value) ? json_encode($value) : (string)$value;
    }

    // 解析$obj.prop格式的属性访问，从上下文中获取对象属性值
    private function resolveProperty(string $objName, string $propName): string
    {
        $obj = $this->context[$objName] ?? null;
        if (is_array($obj)) {
            $value = $obj[$propName] ?? null;
        } elseif (is_object($obj)) {
            $value = $obj->$propName ?? null;
        } else {
            return '$' . $objName . '.' . $propName;
        }
        if ($value === null) return '';
        return is_array($value) || is_object($value) ? json_encode($value) : (string)$value;
    }

    // 处理$tool工具方法调用（firstLowerCase首字母小写、snakeCase蛇形命名、appendPrefix追加前缀）
    private function processMethodCalls(string $template): string
    {
        $template = preg_replace_callback('/\$tool\.firstLowerCase\(([^)]+)\)/', function ($matches) {
            $arg = trim($matches[1]);
            $value = $this->evaluateExpression($arg);
            if (is_string($value) && strlen($value) > 0) {
                return lcfirst($value);
            }
            return '';
        }, $template);

        $template = preg_replace_callback('/\$tool\.snakeCase\(([^)]+)\)/', function ($matches) {
            $arg = trim($matches[1]);
            $value = $this->evaluateExpression($arg);
            if (is_string($value)) {
                return GenUtils::toSnakeCase($value);
            }
            return '';
        }, $template);

        $template = preg_replace_callback('/\$tool\.appendPrefix\(([^,]+),\s*([^)]+)\)/', function ($matches) {
            $arg1 = trim($matches[1]);
            $arg2 = trim($matches[2]);
            $value1 = $this->evaluateExpression($arg1);
            $value2 = $this->evaluateExpression($arg2);
            return $value1 . $value2;
        }, $template);

        return $template;
    }

    // 从文件读取模板内容并渲染，返回渲染结果字符串
    public static function renderFile(string $templatePath, array $context): string
    {
        if (!file_exists($templatePath)) {
            return '';
        }
        $template = file_get_contents($templatePath);
        $engine = new self($context);
        return $engine->render($template);
    }
}
