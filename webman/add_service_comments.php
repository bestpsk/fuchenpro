<?php
$comments = [
    // Business Services
    'BizEnterpriseService.php' => [
        'class' => "企业服务层，处理企业的增删改查、搜索和状态变更，支持拼音自动生成",
        'methods' => [
            'selectEnterpriseList' => '按条件分页查询企业列表，附加方案数量',
            'selectEnterpriseById' => '根据ID查询企业信息',
            'insertEnterprise' => '新增企业，自动生成拼音',
            'updateEnterprise' => '更新企业信息，名称变更时重新生成拼音',
            'selectEnterpriseForSearch' => '模糊搜索企业，按名称或拼音匹配',
            'getPinyin' => '将中文转换为拼音首字母',
            'deleteEnterpriseByIds' => '批量删除企业',
            'updateEnterpriseStatus' => '变更企业状态',
        ]
    ],
    'BizStoreService.php' => [
        'class' => "门店服务层，处理门店的增删改查和搜索，自动关联企业名称",
        'methods' => [
            'selectStoreList' => '按条件分页查询门店列表',
            'selectStoreById' => '根据ID查询门店信息',
            'insertStore' => '新增门店，自动填充企业名称',
            'updateStore' => '更新门店信息，企业变更时同步更新企业名',
            'selectStoreForSearch' => '模糊搜索门店，可限定企业ID',
            'deleteStoreByIds' => '批量删除门店',
        ]
    ],
    'BizSalesOrderService.php' => [
        'class' => "销售订单服务层，处理订单的增删改查、审核、自动生成客户套餐和写入客户档案",
        'methods' => [
            'selectOrderList' => '按条件分页查询销售订单列表，关联订单明细',
            'selectOrderById' => '根据ID查询订单及明细',
            'generateOrderNo' => '生成订单编号SO+日期+4位序号',
            'insertOrder' => '新增订单，自动生成套餐和客户档案',
            'updateOrder' => '更新订单及明细',
            'deleteOrderByIds' => '批量删除订单及明细',
            'enterpriseAudit' => '企业审核通过',
            'financeAudit' => '财务审核通过',
            'generatePackage' => '根据订单自动生成客户套餐及明细项',
        ]
    ],
    'BizPlanService.php' => [
        'class' => "方案服务层，处理方案的增删改查、审核流程、金额管理和出货关联",
        'methods' => [
            'selectEnterpriseList' => '查询企业列表用于方案关联',
            'selectPlanList' => '按条件分页查询方案列表',
            'selectPlanById' => '根据ID查询方案详情，关联明细和企业',
            'generatePlanNo' => '生成方案编号PL+日期+3位序号',
            'insertPlan' => '新增方案，初始化金额和明细',
            'updatePlan' => '更新方案，已审核不可修改',
            'deletePlanByIds' => '删除方案，仅待审核和已拒绝可删',
            'submitAudit' => '提交审核',
            'audit' => '审核方案，通过或拒绝',
            'changeStatus' => '变更方案状态',
            'updateShippedAmount' => '更新已发金额和剩余金额，剩余为0自动标记完成',
            'updateItemShippedQuantity' => '更新明细项已发数量和剩余数量',
        ]
    ],
    'BizRepaymentService.php' => [
        'class' => "还款服务层，处理还款记录的增删改查、审核和取消，自动更新套餐欠款金额",
        'methods' => [
            'selectRepaymentList' => '按条件分页查询还款记录列表',
            'selectOwedPackageList' => '查询客户欠款套餐列表',
            'selectRepaymentById' => '根据ID查询还款记录',
            'insertRepayment' => '新增还款，支持自动审核，使用事务',
            'updateRepayment' => '更新还款信息',
            'auditRepayment' => '审核还款，更新套餐欠款金额',
            'cancelRepayment' => '取消还款，同时取消关联订单',
        ]
    ],
    'BizScheduleService.php' => [
        'class' => "行程安排服务层，处理排班的增删改查、日历视图、员工和企业维度统计",
        'methods' => [
            'selectScheduleList' => '按条件分页查询排班列表，附加用户姓名和岗位',
            'selectScheduleById' => '根据ID查询排班记录',
            'selectScheduleByDateRange' => '按日期范围查询排班记录',
            'selectScheduleDates' => '查询指定用户某月的排班日期',
            'insertSchedule' => '新增单条排班',
            'insertScheduleBatch' => '批量新增排班',
            'updateSchedule' => '更新排班',
            'deleteScheduleByIds' => '批量删除排班',
            'selectEmployeeSchedule' => '查询员工排班视图，按日映射',
            'selectEnterpriseSchedule' => '查询企业排班视图，按日映射',
        ]
    ],
    'BizShipmentService.php' => [
        'class' => "出货服务层，处理出货单的增删改查、审核、发货、收货确认，自动更新方案金额和库存",
        'methods' => [
            'selectShipmentList' => '按条件分页查询出货单列表',
            'selectShipmentById' => '根据ID查询出货单详情',
            'generateShipmentNo' => '生成出货单编号SH+日期+3位序号',
            'insertShipment' => '新增出货单，校验方案状态和金额数量上限',
            'updateShipment' => '更新出货单，仅待审核可修改',
            'deleteShipmentByIds' => '删除出货单，仅待审核可删',
            'audit' => '审核出货单',
            'ship' => '发货，记录物流信息',
            'confirmReceipt' => '确认收货，更新方案金额和扣减库存',
            'changeStatus' => '变更出货单状态',
        ]
    ],
    'BizAttendanceConfigService.php' => [
        'class' => "考勤配置服务层，处理考勤配置的增删改查，按用户/部门/默认优先级匹配考勤规则",
        'methods' => [
            'selectConfigList' => '按条件分页查询考勤配置列表',
            'selectConfigById' => '根据ID查询考勤配置详情',
            'insertConfig' => '新增考勤配置',
            'updateConfig' => '更新考勤配置',
            'deleteConfigByIds' => '批量删除考勤配置',
            'getUserRule' => '获取用户适用的考勤规则，优先个人配置>部门配置>默认规则',
        ]
    ],
    'BizAttendanceRecordService.php' => [
        'class' => "考勤记录服务层，处理考勤打卡（内勤/外勤）、上下班判断、迟到早退计算和月度统计",
        'methods' => [
            'selectRecordList' => '按条件分页查询考勤记录列表',
            'selectRecordById' => '根据ID查询考勤记录',
            'getTodayRecord' => '查询用户今日考勤记录',
            'clock' => '通用打卡，校验距离并判断上下班',
            'clockIn' => '上班打卡，判断是否迟到',
            'clockOut' => '下班打卡，判断是否早退',
            'getTodayClockList' => '查询用户今日打卡流水',
            'getMonthStats' => '统计用户某月考勤情况',
        ]
    ],
    'BizAttendanceRuleService.php' => [
        'class' => "考勤规则服务层，处理考勤规则的增删改查",
        'methods' => [
            'selectRuleList' => '按条件分页查询考勤规则列表',
            'selectRuleById' => '根据ID查询考勤规则',
            'insertRule' => '新增考勤规则',
            'updateRule' => '更新考勤规则',
            'deleteRuleByIds' => '批量删除考勤规则',
            'getActiveRule' => '获取当前激活的考勤规则',
        ]
    ],
    'BizEmployeeConfigService.php' => [
        'class' => "员工配置服务层，处理员工工作配置的增删改查、排班状态和休息日期管理",
        'methods' => [
            'selectConfigList' => '按条件分页查询员工配置列表',
            'selectConfigById' => '根据ID查询员工配置',
            'selectConfigByUserId' => '根据用户ID查询员工配置',
            'insertConfig' => '新增员工配置',
            'updateConfig' => '更新员工配置',
            'updateSchedulable' => '更新是否可排班状态',
            'updateRestDates' => '更新休息日期',
            'deleteConfigByIds' => '批量删除员工配置',
            'getRestDatesByUserId' => '获取用户休息日期',
            'isRestDate' => '判断日期是否为用户休息日',
            'searchEmployee' => '模糊搜索员工',
        ]
    ],
    'BizInventoryService.php' => [
        'class' => "库存服务层，处理库存查询和库存预警，库存数据由入库/出库确认时自动更新",
        'methods' => [
            'selectInventoryList' => '按条件分页查询库存列表，支持预警模式',
            'selectWarnList' => '查询库存预警列表，库存量低于预警量',
            'selectInventoryByProductId' => '根据产品ID查询库存信息',
        ]
    ],
    'BizProductService.php' => [
        'class' => "货品服务层，处理货品的增删改查和搜索，新增货品时自动创建库存记录",
        'methods' => [
            'selectProductList' => '按条件分页查询货品列表，关联供应商和库存',
            'selectProductById' => '根据ID查询货品信息',
            'searchProduct' => '模糊搜索货品',
            'insertProduct' => '新增货品并自动创建库存记录',
            'updateProduct' => '更新货品信息，同步更新预警数量',
            'deleteProductByIds' => '批量删除货品及库存记录',
        ]
    ],
    'BizStockCheckService.php' => [
        'class' => "库存盘点服务层，处理盘点单的增删改查和确认，确认时按差异自动调整库存",
        'methods' => [
            'selectStockCheckList' => '按条件分页查询盘点单列表',
            'selectStockCheckById' => '根据ID查询盘点单详情',
            'generateStockCheckNo' => '生成盘点单编号PD+日期+3位序号',
            'insertStockCheck' => '新增盘点单，计算差异',
            'updateStockCheck' => '更新盘点单，已确认不可修改',
            'deleteStockCheckByIds' => '删除盘点单，已确认不可删',
            'confirmStockCheck' => '确认盘点，将差异应用到库存',
            'loadInventoryData' => '加载所有产品库存快照',
        ]
    ],
    'BizStockInService.php' => [
        'class' => "入库服务层，处理入库单的增删改查和确认，确认时自动累加库存",
        'methods' => [
            'selectStockInList' => '按条件分页查询入库单列表',
            'selectStockInById' => '根据ID查询入库单详情',
            'generateStockInNo' => '生成入库单编号RK+日期+3位序号',
            'insertStockIn' => '新增入库单，处理包装换算和金额计算',
            'updateStockIn' => '更新入库单，已确认不可修改',
            'deleteStockInByIds' => '删除入库单，已确认不可删',
            'confirmStockIn' => '确认入库，累加库存',
            'cancelConfirmStockIn' => '取消确认，扣减库存',
        ]
    ],
    'BizStockOutService.php' => [
        'class' => "出库服务层，处理出库单的增删改查和确认，确认时校验库存并扣减",
        'methods' => [
            'selectStockOutList' => '按条件分页查询出库单列表',
            'selectStockOutById' => '根据ID查询出库单详情',
            'generateStockOutNo' => '生成出库单编号CK+日期+3位序号',
            'insertStockOut' => '新增出库单，处理包装换算和金额计算',
            'updateStockOut' => '更新出库单，已确认不可修改',
            'deleteStockOutByIds' => '删除出库单，已确认不可删',
            'confirmStockOut' => '确认出库，校验库存并扣减',
            'cancelConfirmStockOut' => '取消确认，归还库存',
        ]
    ],
    'BizSupplierService.php' => [
        'class' => "供应商服务层，处理供应商的增删改查和搜索",
        'methods' => [
            'selectSupplierList' => '按条件分页查询供应商列表',
            'selectSupplierById' => '根据ID查询供应商信息',
            'searchSupplier' => '模糊搜索供应商',
            'insertSupplier' => '新增供应商',
            'updateSupplier' => '更新供应商信息',
            'deleteSupplierByIds' => '批量删除供应商',
        ]
    ],
    'BizWmsReportService.php' => [
        'class' => "仓储报表服务层，提供入库汇总、出库汇总、库存收发存和产品流水明细等报表查询",
        'methods' => [
            'stockInSummary' => '入库汇总报表，按产品维度统计',
            'stockOutSummary' => '出库汇总报表，按产品维度统计',
            'inventoryTurnover' => '库存收发存报表，计算期初/入库/出库/期末数量',
            'productFlow' => '产品流水明细，计算每次操作后结存',
        ]
    ],
    // System Services
    'TokenService.php' => [
        'class' => "JWT令牌服务层，负责令牌的创建、解析、验证、刷新和销毁，以及在线用户权限缓存刷新",
        'methods' => [
            '__construct' => '初始化JWT密钥和过期时间',
            'createToken' => '为登录用户创建JWT令牌并存储到Redis',
            'getLoginUser' => '从请求中解析JWT获取登录用户',
            'verifyToken' => '验证令牌有效期，不足20分钟自动续期',
            'refreshToken' => '刷新令牌，更新Redis中的登录信息',
            'removeToken' => '从Redis中删除令牌',
            'getToken' => '从Authorization头提取Bearer Token',
            'getUuidFromToken' => '从JWT令牌中解析UUID',
            'setUserAgent' => '设置用户代理信息：IP/地理位置/浏览器/OS',
            'refreshPermissionByRoleId' => '角色权限变更时刷新在线用户权限缓存',
            'fastUUID' => '生成快速随机UUID',
        ]
    ],
    'CaptchaService.php' => [
        'class' => "验证码服务层，负责数学运算验证码的生成和校验",
        'methods' => [
            'getCaptcha' => '获取验证码，生成数学运算图片并存入Redis',
            'validateCaptcha' => '校验验证码，从Redis比对后删除',
            'generateMathCaptcha' => '生成数学运算验证码图片，含干扰线',
        ]
    ],
    'PasswordService.php' => [
        'class' => "密码服务层，负责密码加密、验证和密码错误锁定策略",
        'methods' => [
            'encrypt' => '使用BCRYPT加密密码',
            'verify' => '验证密码与哈希是否匹配',
            'validate' => '校验登录密码，超限锁定账户',
            'isDefaultPassword' => '判断是否为默认初始密码',
        ]
    ],
    'PermissionService.php' => [
        'class' => "权限服务层，提供用户权限和角色的判断方法",
        'methods' => [
            'hasPermi' => '判断用户是否拥有指定权限',
            'lacksPermi' => '判断用户是否缺少指定权限',
            'hasAnyPermi' => '判断用户是否拥有任一权限',
            'hasRole' => '判断用户是否拥有指定角色',
            'lacksRole' => '判断用户是否缺少指定角色',
            'hasAnyRoles' => '判断用户是否拥有任一角色',
            'getUserRoles' => '获取用户所有角色的role_key列表',
        ]
    ],
    'DataScopeService.php' => [
        'class' => "数据权限服务层，根据用户角色的数据权限范围自动为查询添加过滤条件",
        'methods' => [
            'applyDataScope' => '根据数据权限范围添加过滤条件：1=全部/2=自定义/3=本部门/4=本部门及以下/5=仅本人',
        ]
    ],
    'RedisService.php' => [
        'class' => "Redis缓存服务层，封装Redis常用操作，支持字符串和哈希数据类型",
        'methods' => [
            'connection' => '获取Redis连接实例',
            'set' => '设置键值对，支持TTL和自动JSON编码',
            'get' => '获取键值，可选JSON解码',
            'delete' => '删除键',
            'has' => '判断键是否存在',
            'expire' => '设置过期时间',
            'keys' => '按模式匹配获取键列表',
            'hSet' => '设置哈希字段',
            'hGet' => '获取哈希字段',
            'hGetAll' => '获取哈希所有字段',
            'incr' => '自增',
            'decr' => '自减',
            'getInfo' => '获取Redis服务器信息',
            'dbSize' => '获取键数量',
            'commandCount' => '获取命令执行总数',
            'flushDb' => '清空当前数据库',
        ]
    ],
    'IpService.php' => [
        'class' => "IP地址服务层，根据IP查询地理位置信息",
        'methods' => [
            'getLocation' => '根据IP获取地理位置，内网返回"内网IP"，外网调用ip-api.com',
        ]
    ],
    'UserAgentService.php' => [
        'class' => "用户代理解析服务层，从User-Agent字符串中解析浏览器和操作系统信息",
        'methods' => [
            'getBrowser' => '解析浏览器类型',
            'getOS' => '解析操作系统类型',
        ]
    ],
    'SysUserService.php' => [
        'class' => "系统用户服务层，处理用户的增删改查、密码管理、唯一性校验和导入导出",
        'methods' => [
            'selectUserList' => '分页查询用户列表，支持数据权限过滤',
            'selectUserById' => '根据ID查询用户详情含关联',
            'selectUserByUserName' => '根据用户名查询用户',
            'insertUser' => '新增用户，加密密码并关联角色岗位',
            'updateUser' => '更新用户，先删后插角色岗位关联',
            'deleteUserByIds' => '批量软删除用户',
            'resetPwd' => '重置用户密码',
            'changeStatus' => '修改用户状态',
            'checkUserNameUnique' => '校验用户名唯一性',
            'checkPhoneUnique' => '校验手机号唯一性',
            'checkEmailUnique' => '校验邮箱唯一性',
            'updateUserProfile' => '更新用户个人资料',
            'insertUserRole' => '批量插入用户角色关联',
            'insertUserPost' => '批量插入用户岗位关联',
            'importUser' => '导入用户数据，支持新增和更新',
        ]
    ],
    'SysRoleService.php' => [
        'class' => "角色服务层，处理角色的增删改查、数据权限设置和用户授权管理",
        'methods' => [
            'selectRoleList' => '分页查询角色列表',
            'selectRoleById' => '根据ID查询角色',
            'selectAllRoles' => '查询所有正常状态角色',
            'insertRole' => '新增角色并关联菜单',
            'updateRole' => '更新角色，先删后插菜单关联',
            'deleteRoleByIds' => '批量软删除角色及关联数据',
            'authDataScope' => '设置角色数据权限范围',
            'changeStatus' => '修改角色状态',
            'selectRolePermissionByUserId' => '查询用户角色权限标识',
            'checkRoleNameUnique' => '校验角色名称唯一',
            'checkRoleKeyUnique' => '校验角色键唯一',
            'allocatedUserList' => '查询已分配角色的用户列表',
            'unallocatedUserList' => '查询未分配角色的用户列表',
            'cancelAuthUser' => '取消用户角色授权',
            'cancelAuthUserAll' => '批量取消用户角色授权',
            'selectAuthUserAll' => '批量授权用户角色',
            'insertRoleMenu' => '批量插入角色菜单关联',
            'insertRoleDept' => '批量插入角色部门关联',
        ]
    ],
    'SysMenuService.php' => [
        'class' => "菜单服务层，处理菜单的增删改查、菜单树构建和前端路由生成",
        'methods' => [
            'selectMenuList' => '查询菜单列表，非管理员只返回有权限的',
            'selectMenuTreeByUserId' => '根据用户ID获取菜单树',
            'selectMenuById' => '根据ID查询菜单',
            'insertMenu' => '新增菜单',
            'updateMenu' => '更新菜单',
            'deleteMenuById' => '删除菜单，存在子菜单不允许',
            'treeselect' => '获取菜单树下拉结构',
            'roleMenuTreeselect' => '获取角色菜单树及已勾选ID',
            'buildMenus' => '将菜单树构建为前端路由格式',
            'getChildPerms' => '递归获取子权限菜单',
            'buildMenuTree' => '递归构建菜单树',
            'getRouteName' => '获取路由名称',
            'isExternalLink' => '判断是否为外链',
            'getRouterPath' => '获取路由路径',
            'getComponent' => '获取组件路径',
            'isMenuFrame' => '判断是否为菜单内部嵌入',
            'isInnerLink' => '判断是否为内链',
            'innerLinkReplaceEach' => '内链URL路径转换',
        ]
    ],
    'SysDeptService.php' => [
        'class' => "部门服务层，处理部门的增删改查和树形结构构建",
        'methods' => [
            'selectDeptList' => '查询部门列表',
            'selectDeptById' => '根据ID查询部门',
            'insertDept' => '新增部门，自动计算祖级列表',
            'updateDept' => '更新部门，重新计算祖级列表',
            'deleteDeptById' => '删除部门，存在子部门或用户不允许',
            'deptTreeSelect' => '获取部门树下拉结构',
            'excludeChildDeptList' => '排除指定部门及子部门',
            'buildDeptTree' => '递归构建部门树',
            'buildDeptTreeSelect' => '递归构建部门树下拉结构',
        ]
    ],
    'SysPostService.php' => [
        'class' => "岗位服务层，处理岗位的增删改查",
        'methods' => [
            'selectPostList' => '分页查询岗位列表',
            'selectPostById' => '根据ID查询岗位',
            'selectPostAll' => '查询所有正常状态岗位',
            'insertPost' => '新增岗位',
            'updatePost' => '更新岗位',
            'deletePostByIds' => '批量删除岗位',
        ]
    ],
    'SysDictTypeService.php' => [
        'class' => "字典类型服务层，处理字典类型的增删改查和缓存管理",
        'methods' => [
            'selectDictTypeList' => '分页查询字典类型列表',
            'selectDictTypeById' => '根据ID查询字典类型',
            'insertDictType' => '新增字典类型并重置缓存',
            'updateDictType' => '更新字典类型，键值变更时同步更新字典数据',
            'deleteDictTypeByIds' => '批量删除字典类型及关联数据',
            'selectDictDataByType' => '根据类型查询字典数据，优先从缓存获取',
            'optionselect' => '获取字典类型下拉选择列表',
            'resetDictCache' => '重置字典缓存',
            'getDictLabel' => '根据字典值获取标签',
            'getDictValue' => '根据字典标签获取值',
        ]
    ],
    'SysDictDataService.php' => [
        'class' => "字典数据服务层，处理字典数据的增删改查和缓存管理",
        'methods' => [
            'selectDictDataList' => '分页查询字典数据列表',
            'selectDictDataById' => '根据ID查询字典数据',
            'insertDictData' => '新增字典数据并重置缓存',
            'updateDictData' => '更新字典数据并重置缓存',
            'deleteDictDataByIds' => '批量删除字典数据并重置缓存',
        ]
    ],
    'SysConfigService.php' => [
        'class' => "系统参数配置服务层，处理参数的增删改查和缓存管理",
        'methods' => [
            'selectConfigList' => '分页查询参数配置列表',
            'selectConfigById' => '根据ID查询参数配置',
            'selectConfigByKey' => '根据键名查询参数值，优先从缓存获取',
            'insertConfig' => '新增参数配置并写入缓存',
            'updateConfig' => '更新参数配置并更新缓存',
            'deleteConfigByIds' => '批量删除参数配置并删除缓存',
            'resetConfigCache' => '重置参数配置缓存',
            'selectCaptchaEnabled' => '查询是否开启验证码功能',
        ]
    ],
    'SysNoticeService.php' => [
        'class' => "通知公告服务层，处理通知的增删改查、已读标记和已读用户查询",
        'methods' => [
            'selectNoticeList' => '分页查询通知列表',
            'selectNoticeById' => '根据ID查询通知',
            'insertNotice' => '新增通知',
            'updateNotice' => '更新通知',
            'deleteNoticeByIds' => '批量删除通知及阅读记录',
            'listTop' => '获取最新10条通知并标记已读状态',
            'markRead' => '标记通知已读',
            'markReadAll' => '标记所有未读通知已读',
            'readUsersList' => '分页查询已读用户列表',
        ]
    ],
    'SysOperLogService.php' => [
        'class' => "操作日志服务层，处理操作日志的查询、新增和清理",
        'methods' => [
            'selectOperLogList' => '分页查询操作日志列表',
            'insertOperLog' => '新增操作日志',
            'deleteOperLogByIds' => '批量删除操作日志',
            'cleanOperLog' => '清空操作日志表',
        ]
    ],
    'SysLogininforService.php' => [
        'class' => "登录日志服务层，处理登录日志的查询、新增、清理和用户解锁",
        'methods' => [
            'selectLogininforList' => '分页查询登录日志列表',
            'insertLogininfor' => '新增登录日志',
            'deleteLogininforByIds' => '批量删除登录日志',
            'cleanLogininfor' => '清空登录日志表',
            'unlock' => '解锁用户，清除密码错误计数缓存',
        ]
    ],
    'SysJobService.php' => [
        'class' => "定时任务服务层，处理定时任务的增删改查、状态变更和立即执行",
        'methods' => [
            'selectJobList' => '分页查询定时任务列表',
            'selectJobById' => '根据ID查询定时任务',
            'insertJob' => '新增定时任务',
            'updateJob' => '更新定时任务',
            'deleteJobByIds' => '批量删除定时任务',
            'changeStatus' => '修改定时任务状态',
            'run' => '立即执行一次定时任务并记录日志',
        ]
    ],
    'SysJobLogService.php' => [
        'class' => "任务执行日志服务层，处理任务日志的查询和清理",
        'methods' => [
            'selectJobLogList' => '分页查询任务执行日志列表',
            'deleteJobLogByIds' => '批量删除任务执行日志',
            'cleanJobLog' => '清空任务执行日志表',
        ]
    ],
    'SysUserOnlineService.php' => [
        'class' => "在线用户服务层，查询在线用户列表和强制下线",
        'methods' => [
            'selectOnlineList' => '查询在线用户列表，遍历Redis登录令牌',
            'forceLogout' => '强制退出用户，删除Redis令牌',
        ]
    ],
    'SysUserDetailService.php' => [
        'class' => "用户详情服务层，处理用户扩展详情的查询、新增和更新",
        'methods' => [
            'selectDetailByUserId' => '根据用户ID查询扩展详情',
            'insertDetail' => '新增用户详情',
            'updateDetail' => '更新用户详情，按user_id找不到则自动新增',
            'deleteDetailByUserId' => '根据用户ID删除详情',
        ]
    ],
    'HrUserSalaryService.php' => [
        'class' => "薪资管理服务层，处理用户薪资的增删改查和薪资层级配置",
        'methods' => [
            'selectSalaryTypeList' => '查询薪资类型列表',
            'selectSalaryTypeById' => '根据ID查询薪资类型',
            'selectUserSalaryList' => '查询用户薪资列表含关联',
            'selectUserSalaryById' => '根据ID查询薪资详情含关联',
            'insertUserSalary' => '新增用户薪资及层级配置',
            'updateUserSalary' => '更新用户薪资及层级配置',
            'deleteUserSalaryByIds' => '批量删除用户薪资及层级',
            'saveTiers' => '批量保存薪资层级明细',
        ]
    ],
    'GenTableService.php' => [
        'class' => "代码生成服务层，处理数据库表导入、代码生成配置、模板渲染和代码下载",
        'methods' => [
            'selectGenTableList' => '分页查询代码生成表列表',
            'selectGenTableById' => '根据ID查询代码生成表含列信息',
            'selectDbTableList' => '查询数据库中未导入的表列表',
            'importGenTable' => '导入数据库表到代码生成器',
            'deleteGenTableByIds' => '批量删除代码生成表及列',
            'updateGenTable' => '更新代码生成表及列配置',
            'synchDb' => '同步数据库表结构',
            'previewCode' => '预览生成代码',
            'generateCode' => '根据模板渲染代码',
            'downloadCode' => '批量生成代码并打包ZIP',
            'prepareContext' => '准备模板渲染上下文数据',
            'getTemplateList' => '获取模板列表',
            'getFileName' => '根据模板名生成输出文件名',
        ]
    ],
];

$baseDir = __DIR__ . '/app/service/';
$count = 0;

foreach ($comments as $filename => $config) {
    $filepath = $baseDir . $filename;
    if (!file_exists($filepath)) {
        echo "SKIP: $filename not found\n";
        continue;
    }

    $content = file_get_contents($filepath);

    if (strpos($content, '/**') !== false && strpos($content, '服务层') !== false) {
        echo "SKIP: $filename already has class comment\n";
        continue;
    }

    $classComment = "/**\n * {$config['class']}\n */\n";
    $content = preg_replace('/(class\s+\w+)/', $classComment . '$1', $content, 1, $replaced);
    if (!$replaced) {
        echo "WARN: Could not add class comment to $filename\n";
        continue;
    }

    foreach ($config['methods'] as $method => $desc) {
        $patterns = [
            '/(\n)(\s+public\s+function\s+' . preg_quote($method, '/') . '\s*\()/',
            '/(\n)(\s+public\s+static\s+function\s+' . preg_quote($method, '/') . '\s*\()/',
            '/(\n)(\s+private\s+function\s+' . preg_quote($method, '/') . '\s*\()/',
            '/(\n)(\s+private\s+static\s+function\s+' . preg_quote($method, '/') . '\s*\()/',
        ];
        foreach ($patterns as $pattern) {
            $newContent = preg_replace($pattern, '$1$2// ' . $desc . "\n$2", $content, 1, $methodReplaced);
            if ($methodReplaced) {
                $content = $newContent;
                break;
            }
        }
    }

    file_put_contents($filepath, $content);
    $count++;
    echo "DONE: $filename\n";
}

echo "\nTotal files processed: $count\n";
