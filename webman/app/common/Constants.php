<?php

namespace app\common;

/**
 * 系统全局常量定义
 *
 * 集中管理HTTP状态码、JWT令牌配置、Redis缓存键前缀、
 * 权限标识、菜单类型、通用状态、布局类型、时间常量和安全策略等常量
 */
class Constants
{
    // HTTP响应状态码
    const SUCCESS = 200;
    const WARN = 601;
    const ERROR = 500;
    const UNAUTHORIZED = 401;

    // JWT令牌配置
    const JWT_SECRET = ''; // 从环境变量读取，见 TokenService
    const JWT_ALGO = 'HS512';
    const TOKEN_EXPIRE = 300;           // 令牌有效期（分钟）
    const TOKEN_PREFIX = 'Bearer ';     // 令牌请求头前缀
    const LOGIN_USER_KEY = 'login_user_key';  // JWT中存储登录用户UUID的键名
    const JWT_USERNAME = 'sub';         // JWT中存储用户名的标准字段

    // Redis缓存键前缀
    const LOGIN_TOKEN_KEY = 'login_tokens:';    // 登录令牌缓存前缀
    const CAPTCHA_CODE_KEY = 'captcha_codes:';  // 验证码缓存前缀
    const SYS_CONFIG_KEY = 'sys_config:';       // 系统配置缓存前缀
    const SYS_DICT_KEY = 'sys_dict:';           // 字典数据缓存前缀
    const PWD_ERR_CNT_KEY = 'pwd_err_cnt:';     // 密码错误次数缓存前缀

    // 超级管理员与权限标识
    const SUPER_ADMIN_ROLE_ID = 1;      // 超级管理员角色ID
    const SUPER_ADMIN = 'admin';        // 超级管理员用户名
    const ALL_PERMISSION = '*:*:*';     // 全部权限标识

    // 菜单类型：M=目录 C=菜单 F=按钮
    const MENU_TYPE_DIR = 'M';
    const MENU_TYPE_MENU = 'C';
    const MENU_TYPE_BUTTON = 'F';

    // 通用状态：0=正常 1=停用 2=删除标记
    const NORMAL = '0';
    const DISABLE = '1';
    const DEL_FLAG = '2';

    // 路由布局类型
    const LAYOUT = 'Layout';           // 一级目录布局
    const PARENT_VIEW = 'ParentView';  // 二级目录布局
    const INNER_LINK = 'InnerLink';    // 内嵌链接布局

    // 时间常量（毫秒）
    const MILLIS_MINUTE = 60 * 1000;            // 一分钟的毫秒数
    const MILLIS_MINUTE_TWENTY = 20 * 60 * 1000; // 二十分钟的毫秒数（令牌自动续期阈值）
    const TOKEN_REFRESH_THRESHOLD = 20;  // 令牌自动续期阈值（分钟）

    // 安全策略
    const CAPTCHA_EXPIRE = 2;           // 验证码有效期（分钟）
    const PWD_ERR_MAX_COUNT = 5;        // 密码最大错误次数
    const PWD_ERR_LOCK_TIME = 10;       // 密码错误锁定时间（分钟）
}
