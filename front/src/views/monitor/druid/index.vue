<template>
  <div class="app-container">
    <el-row :gutter="10">
      <el-col :span="12" class="card-box">
        <el-card>
          <template #header><Connection style="width: 1em; height: 1em; vertical-align: middle;" /> <span style="vertical-align: middle;">连接池信息</span></template>
          <div class="el-table el-table--enable-row-hover el-table--medium">
            <table cellspacing="0" style="width: 100%;">
              <thead>
                <tr>
                  <th class="el-table__cell is-leaf"><div class="cell">属性</div></th>
                  <th class="el-table__cell is-leaf"><div class="cell">值</div></th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">应用最大连接数</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.pool?.maxConnections }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">应用最小连接数</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.pool?.minConnections }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">MySQL最大连接数</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.pool?.mysqlMaxConnections }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">当前连接数</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.pool?.currentConnections }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">活跃连接数</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.pool?.activeConnections }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">空闲连接数</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.pool?.idleConnections }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">连接使用率</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell" :class="{'text-danger': data.pool?.connectionUsage > 80}">{{ data.pool?.connectionUsage }}%</div></td>
                </tr>
              </tbody>
            </table>
          </div>
        </el-card>
      </el-col>

      <el-col :span="12" class="card-box">
        <el-card>
          <template #header><Coin style="width: 1em; height: 1em; vertical-align: middle;" /> <span style="vertical-align: middle;">性能指标</span></template>
          <div class="el-table el-table--enable-row-hover el-table--medium">
            <table cellspacing="0" style="width: 100%;">
              <thead>
                <tr>
                  <th class="el-table__cell is-leaf"><div class="cell">属性</div></th>
                  <th class="el-table__cell is-leaf"><div class="cell">值</div></th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">QPS（每秒查询数）</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.performance?.qps }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">TPS（每秒事务数）</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.performance?.tps }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">总查询数</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.performance?.totalQueries }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">慢查询数</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell" :class="{'text-danger': data.performance?.slowQueries > 0}">{{ data.performance?.slowQueries }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">当前连接数</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.performance?.currentConnections }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">活跃线程数</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.performance?.activeThreads }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">总连接次数</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.performance?.totalConnections }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">中断连接数</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell" :class="{'text-danger': data.performance?.abortedConnects > 10}">{{ data.performance?.abortedConnects }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">入站流量</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.performance?.bytesReceived }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">出站流量</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.performance?.bytesSent }}</div></td>
                </tr>
              </tbody>
            </table>
          </div>
        </el-card>
      </el-col>

      <el-col :span="24" class="card-box">
        <el-card>
          <template #header><Coin style="width: 1em; height: 1em; vertical-align: middle;" /> <span style="vertical-align: middle;">数据库信息</span></template>
          <div class="el-table el-table--enable-row-hover el-table--medium">
            <table cellspacing="0" style="width: 100%;table-layout:fixed;">
              <tbody>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">MySQL版本</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.database?.version }}</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">数据库主机</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.database?.host }}:{{ data.database?.port }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">数据库名称</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.database?.database }}</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">字符集</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.database?.charset }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">排序规则</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.database?.collation }}</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">运行时间</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.database?.uptime }}</div></td>
                </tr>
              </tbody>
            </table>
          </div>
        </el-card>
      </el-col>

      <el-col :span="24" class="card-box">
        <el-card>
          <template #header><DataAnalysis style="width: 1em; height: 1em; vertical-align: middle;" /> <span style="vertical-align: middle;">InnoDB状态</span></template>
          <div class="el-table el-table--enable-row-hover el-table--medium">
            <table cellspacing="0" style="width: 100%;">
              <thead>
                <tr>
                  <th class="el-table__cell is-leaf"><div class="cell">属性</div></th>
                  <th class="el-table__cell is-leaf"><div class="cell">值</div></th>
                  <th class="el-table__cell is-leaf"><div class="cell">属性</div></th>
                  <th class="el-table__cell is-leaf"><div class="cell">值</div></th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">缓冲池大小</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.innodb?.bufferPoolSize }}</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">缓冲池命中率</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell" :class="{'text-danger': data.innodb?.hitRate < 90}">{{ data.innodb?.hitRate }}%</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">数据页</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.innodb?.pagesData }}</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">空闲页</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.innodb?.pagesFree }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">脏页数</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.innodb?.pagesDirty }}</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">脏页比例</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell" :class="{'text-danger': data.innodb?.dirtyRatio > 30}">{{ data.innodb?.dirtyRatio }}%</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">逻辑读请求</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.innodb?.readRequests }}</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">磁盘读取</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.innodb?.diskReads }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">数据读取量</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.innodb?.dataRead }}</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">数据写入量</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.innodb?.dataWritten }}</div></td>
                </tr>
                <tr>
                  <td class="el-table__cell is-leaf"><div class="cell">行锁等待次数</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell" :class="{'text-danger': data.innodb?.rowLockWaits > 0}">{{ data.innodb?.rowLockWaits }}</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">平均行锁等待(ms)</div></td>
                  <td class="el-table__cell is-leaf"><div class="cell">{{ data.innodb?.avgRowLockTime }}</div></td>
                </tr>
              </tbody>
            </table>
          </div>
        </el-card>
      </el-col>

      <el-col :span="24" class="card-box">
        <el-card>
          <template #header><List style="width: 1em; height: 1em; vertical-align: middle;" /> <span style="vertical-align: middle;">进程列表</span>
            <el-tag v-if="data.slowQueries?.slowQueryLogEnabled" type="success" size="small" style="margin-left: 10px;">慢查询日志已开启（阈值: {{ data.slowQueries?.longQueryTime }}s）</el-tag>
            <el-tag v-else type="info" size="small" style="margin-left: 10px;">慢查询日志未开启</el-tag>
          </template>
          <el-table :data="data.slowQueries?.processList || []" style="width: 100%" border size="small">
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="user" label="用户" width="100" />
            <el-table-column prop="host" label="主机" width="180" />
            <el-table-column prop="db" label="数据库" width="120" />
            <el-table-column prop="command" label="命令" width="100" />
            <el-table-column prop="time" label="时间(s)" width="90">
              <template #default="scope">
                <span :class="{'text-danger': scope.row.time > 5}">{{ scope.row.time }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="state" label="状态" width="180" show-overflow-tooltip />
            <el-table-column prop="info" label="SQL语句" show-overflow-tooltip />
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { getDataMonitor } from '@/api/monitor/data'
import { Connection, Coin, DataAnalysis, List } from '@element-plus/icons-vue'

const data = ref({})
const { proxy } = getCurrentInstance()

function getList() {
  proxy.$modal.loading("正在加载数据监控数据，请稍候！")
  getDataMonitor().then(response => {
    data.value = response.data
    proxy.$modal.closeLoading()
  })
}

getList()
</script>

<style scoped>
.text-danger {
  color: #f56c6c;
  font-weight: bold;
}
</style>
