<?php

namespace app\controller\monitor;

use support\Request;
use support\Db;
use app\common\AjaxResult;
use app\service\PermissionService;

class DataController
{
    public function getInfo(Request $request)
    {
        if (PermissionService::lacksPermi($request->loginUser, 'monitor:server:list')) {
            return json(['code' => 403, 'msg' => '没有操作权限']);
        }
        return AjaxResult::success('', [
            'data' => [
                'pool' => $this->getPoolInfo(),
                'database' => $this->getDbInfo(),
                'performance' => $this->getPerformance(),
                'innodb' => $this->getInnodbStatus(),
                'slowQueries' => $this->getSlowQueries(),
            ]
        ]);
    }

    private function query(string $sql)
    {
        return Db::select($sql);
    }

    private function queryOne(string $sql)
    {
        $result = Db::select($sql);
        return !empty($result) ? (array)$result[0] : [];
    }

    private function getStatusValue(string $name)
    {
        $result = $this->queryOne("SHOW STATUS LIKE '{$name}'");
        return isset($result['Value']) ? $result['Value'] : 0;
    }

    private function getVariablesValue(string $name)
    {
        $result = $this->queryOne("SHOW VARIABLES LIKE '{$name}'");
        return isset($result['Value']) ? $result['Value'] : '';
    }

    private function getPoolInfo()
    {
        $config = config('database.connections.mysql', []);
        $poolConfig = $config['pool'] ?? [];

        $threadsConnected = (int)$this->getStatusValue('Threads_connected');
        $maxConnections = (int)$this->getVariablesValue('max_connections');
        $threadsRunning = (int)$this->getStatusValue('Threads_running');

        return [
            'maxConnections' => $poolConfig['max_connections'] ?? 20,
            'minConnections' => $poolConfig['min_connections'] ?? 5,
            'waitTimeout' => $poolConfig['wait_timeout'] ?? 3,
            'idleTimeout' => $poolConfig['idle_timeout'] ?? 60,
            'heartbeatInterval' => $poolConfig['heartbeat_interval'] ?? 50,
            'mysqlMaxConnections' => $maxConnections,
            'activeConnections' => $threadsRunning,
            'currentConnections' => $threadsConnected,
            'idleConnections' => max(0, $threadsConnected - $threadsRunning),
            'connectionUsage' => $maxConnections > 0 ? round(($threadsConnected / $maxConnections) * 100, 2) : 0,
        ];
    }

    private function getDbInfo()
    {
        $config = config('database.connections.mysql', []);

        $version = $this->queryOne("SELECT VERSION() as v");
        $charset = $this->getVariablesValue('character_set_database');
        $collation = $this->getVariablesValue('collation_database');
        $uptime = (int)$this->getStatusValue('Uptime');

        return [
            'version' => $version['v'] ?? 'unknown',
            'host' => $config['host'] ?? '127.0.0.1',
            'port' => $config['port'] ?? '3306',
            'database' => $config['database'] ?? '',
            'username' => $config['username'] ?? '',
            'charset' => $charset ?: ($config['charset'] ?? 'utf8mb4'),
            'collation' => $collation ?: ($config['collation'] ?? 'utf8mb4_general_ci'),
            'uptime' => $this->formatUptime($uptime),
            'uptimeSeconds' => $uptime,
        ];
    }

    private function getPerformance()
    {
        $queries = (int)$this->getStatusValue('Queries');
        $uptime = (int)$this->getStatusValue('Uptime');
        $qps = $uptime > 0 ? round($queries / $uptime, 2) : 0;

        $commits = (int)$this->getStatusValue('Com_commit');
        $rollbacks = (int)$this->getStatusValue('Com_rollback');
        $tps = $uptime > 0 ? round(($commits + $rollbacks) / $uptime, 2) : 0;

        $slowQueries = (int)$this->getStatusValue('Slow_queries');
        $threadsConnected = (int)$this->getStatusValue('Threads_connected');
        $threadsRunning = (int)$this->getStatusValue('Threads_running');
        $connections = (int)$this->getStatusValue('Connections');
        $abortedConnects = (int)$this->getStatusValue('Aborted_connects');
        $bytesReceived = (int)$this->getStatusValue('Bytes_received');
        $bytesSent = (int)$this->getStatusValue('Bytes_sent');

        return [
            'qps' => $qps,
            'tps' => $tps,
            'totalQueries' => $queries,
            'slowQueries' => $slowQueries,
            'currentConnections' => $threadsConnected,
            'activeThreads' => $threadsRunning,
            'totalConnections' => $connections,
            'abortedConnects' => $abortedConnects,
            'bytesReceived' => $this->formatBytes($bytesReceived),
            'bytesSent' => $this->formatBytes($bytesSent),
        ];
    }

    private function getInnodbStatus()
    {
        $pagesTotal = (int)$this->getStatusValue('Innodb_buffer_pool_pages_total');
        $pagesData = (int)$this->getStatusValue('Innodb_buffer_pool_pages_data');
        $pagesFree = (int)$this->getStatusValue('Innodb_buffer_pool_pages_free');
        $pagesDirty = (int)$this->getStatusValue('Innodb_buffer_pool_pages_dirty');
        $pagesMisc = (int)$this->getStatusValue('Innodb_buffer_pool_pages_misc');

        $readRequests = (int)$this->getStatusValue('Innodb_buffer_pool_read_requests');
        $reads = (int)$this->getStatusValue('Innodb_buffer_pool_reads');
        $hitRate = $readRequests > 0 ? round((($readRequests - $reads) / $readRequests) * 100, 2) : 100;

        $dataReads = (int)$this->getStatusValue('Innodb_data_reads');
        $dataWrites = (int)$this->getStatusValue('Innodb_data_writes');
        $dataRead = (int)$this->getStatusValue('Innodb_data_read');
        $dataWritten = (int)$this->getStatusValue('Innodb_data_written');

        $rowLockWaits = (int)$this->getStatusValue('Innodb_row_lock_waits');
        $rowLockTime = (int)$this->getStatusValue('Innodb_row_lock_time');

        $bufferPoolSize = $this->getVariablesValue('innodb_buffer_pool_size');
        $bufferPoolSizeBytes = (int)$bufferPoolSize;

        return [
            'bufferPoolSize' => $this->formatBytes($bufferPoolSizeBytes),
            'bufferPoolSizeBytes' => $bufferPoolSizeBytes,
            'pagesTotal' => $pagesTotal,
            'pagesData' => $pagesData,
            'pagesFree' => $pagesFree,
            'pagesDirty' => $pagesDirty,
            'pagesMisc' => $pagesMisc,
            'dirtyRatio' => $pagesData > 0 ? round(($pagesDirty / $pagesData) * 100, 2) : 0,
            'hitRate' => $hitRate,
            'readRequests' => $readRequests,
            'diskReads' => $reads,
            'dataReads' => $dataReads,
            'dataWrites' => $dataWrites,
            'dataRead' => $this->formatBytes($dataRead),
            'dataWritten' => $this->formatBytes($dataWritten),
            'rowLockWaits' => $rowLockWaits,
            'avgRowLockTime' => $rowLockWaits > 0 ? round(($rowLockTime / 1000) / $rowLockWaits, 2) : 0,
        ];
    }

    private function getSlowQueries()
    {
        $slowQueryLog = $this->getVariablesValue('slow_query_log');
        $longQueryTime = $this->getVariablesValue('long_query_time');

        $processlist = $this->query("SHOW FULL PROCESSLIST");
        $list = [];
        foreach ($processlist as $row) {
            $row = (array)$row;
            if (isset($row['Command']) && $row['Command'] !== 'Daemon') {
                $list[] = [
                    'id' => $row['Id'] ?? 0,
                    'user' => $row['User'] ?? '',
                    'host' => $row['Host'] ?? '',
                    'db' => $row['db'] ?? '',
                    'command' => $row['Command'] ?? '',
                    'time' => $row['Time'] ?? 0,
                    'state' => $row['State'] ?? '',
                    'info' => isset($row['Info']) ? mb_substr($row['Info'], 0, 200) : '',
                ];
            }
        }

        usort($list, function ($a, $b) {
            return $b['time'] - $a['time'];
        });

        return [
            'slowQueryLogEnabled' => $slowQueryLog === 'ON',
            'longQueryTime' => $longQueryTime,
            'processList' => array_slice($list, 0, 10),
        ];
    }

    private function formatUptime($seconds)
    {
        $days = floor($seconds / 86400);
        $hours = floor(($seconds % 86400) / 3600);
        $minutes = floor(($seconds % 3600) / 60);
        $secs = $seconds % 60;

        $result = [];
        if ($days > 0) $result[] = $days . '天';
        if ($hours > 0) $result[] = $hours . '小时';
        if ($minutes > 0) $result[] = $minutes . '分钟';
        $result[] = $secs . '秒';

        return implode('', $result);
    }

    private function formatBytes($bytes)
    {
        if ($bytes <= 0) return '0 B';
        $units = ['B', 'KB', 'MB', 'GB', 'TB'];
        $i = 0;
        while ($bytes >= 1024 && $i < count($units) - 1) {
            $bytes /= 1024;
            $i++;
        }
        return round($bytes, 2) . ' ' . $units[$i];
    }
}
