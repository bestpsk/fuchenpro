<?php

namespace app\job;

/**
 * 示例定时任务类
 *
 * 用于测试定时任务"立即执行"功能。
 * invoke_target 填写示例：
 *   - TestJob@run
 *   - TestJob@runWithParams('hello', 123, true)
 */
class TestJob
{
    /**
     * 无参示例方法
     */
    public static function run()
    {
        return 'TestJob executed successfully at ' . date('Y-m-d H:i:s');
    }

    /**
     * 带参示例方法
     */
    public static function runWithParams($msg, $count, $flag)
    {
        return "TestJob params: msg={$msg}, count={$count}, flag=" . ($flag ? 'true' : 'false');
    }
}
