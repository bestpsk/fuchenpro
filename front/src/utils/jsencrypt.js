/**
 * @description RSA加密工具 - 前端敏感信息加密传输
 * @description 使用JSEncrypt库实现RSA非对称加密，用于登录密码等敏感信息的加密传输。
 * 加密流程：前端使用公钥加密 → 传输密文 → 后端使用私钥解密
 * 安全注意：私钥仅存储在后端，前端仅保留公钥用于加密
 */
import JSEncrypt from 'jsencrypt/bin/jsencrypt.min'

const publicKey = 'MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKoR8mX0rGKLqzcWmOzbfj64K8ZIgOdH\n' +
  'nzkXSOVOZbFu/TJhZ7rFAN+eaGkl3C4buccQd/EjEsj9ir7ijT7h96MCAwEAAQ=='

/**
 * 使用RSA公钥加密明文，用于登录密码等敏感信息传输前的加密
 * @param {string} txt - 需要加密的明文字符串（如登录密码）
 * @returns {string|false} 加密后的Base64密文，加密失败返回false
 */
export function encrypt(txt) {
  const encryptor = new JSEncrypt()
  encryptor.setPublicKey(publicKey)
  return encryptor.encrypt(txt)
}

/**
 * 使用Base64编码文本，用于Cookie等可逆存储场景
 * @param {string} txt - 需要编码的明文字符串
 * @returns {string} Base64编码后的字符串
 */
export function encryptTxt(txt) {
  return btoa(unescape(encodeURIComponent(txt)))
}

/**
 * 使用Base64解码文本，与encryptTxt配对使用
 * @param {string} txt - Base64编码的字符串
 * @returns {string} 解码后的明文字符串
 */
export function decryptTxt(txt) {
  return decodeURIComponent(escape(atob(txt)))
}
