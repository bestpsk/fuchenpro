/**
 * @description 登录认证接口 - 登录/注册/验证码/用户信息
 * @description 提供用户登录、注册、获取用户信息、解锁屏幕、退出登录、获取验证码等认证相关接口
 */
import request from '@/utils/request'

/** 用户登录，提交账号密码和验证码，isToken=false表示不需要Token验证 */
export function login(username, password, code, uuid) {
  const data = {
    username,
    password,
    code,
    uuid
  }
  return request({
    url: '/login',
    headers: {
      isToken: false,
      repeatSubmit: false
    },
    method: 'post',
    data: data
  })
}

/** 用户注册，提交注册表单数据 */
export function register(data) {
  return request({
    url: '/register',
    headers: {
      isToken: false
    },
    method: 'post',
    data: data
  })
}

/** 获取当前登录用户的详细信息（角色/权限/用户资料） */
export function getInfo() {
  return request({
    url: '/getInfo',
    method: 'get'
  })
}

/** 解锁屏幕，验证密码后解除锁屏状态 */
export function unlockScreen(password) {
  return request({
    url: '/unlockscreen',
    method: 'post',
    data: { password }
  })
}

/** 退出登录，清除服务端Session */
export function logout() {
  return request({
    url: '/logout',
    method: 'post'
  })
}

/** 获取图形验证码，isToken=false表示不需要Token验证 */
export function getCodeImg() {
  return request({
    url: '/captchaImage',
    headers: {
      isToken: false
    },
    method: 'get',
    timeout: 20000
  })
}