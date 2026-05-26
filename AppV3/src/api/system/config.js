import request from '@/utils/request'

export function getConfigKey(configKey) {
  return request({ url: '/system/config/configKey/' + configKey, method: 'get' })
}

export function updateConfig(data) {
  return request({ url: '/system/config', method: 'put', data })
}

export function getWelcomeSlogan() {
  return request({ url: '/system/user/detail/welcomeSlogan', method: 'get' })
}

export function setWelcomeSlogan(welcomeSlogan) {
  return request({ url: '/system/user/detail/welcomeSlogan', method: 'put', data: { welcomeSlogan } })
}
