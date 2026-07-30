<template>
  <view class="normal-login-container">
    <!-- 顶部装饰区域 -->
    <view class="top-decoration">
      <view class="decoration-circle circle-1"></view>
      <view class="decoration-circle circle-2"></view>
      <view class="decoration-circle circle-3"></view>
    </view>

    <!-- Logo 区域 -->
    <view class="logo-content">
      <text class="title">赛诺美生注册</text>
      <text class="subtitle">创建您的账号</text>
    </view>

    <!-- 表单区域 -->
    <view class="login-form-content">
      <view class="form-title">账号注册</view>

      <view class="input-item">
        <u-icon name="account" size="22" color="#3D6DF7" style="margin-left: 12px" />
        <input v-model="registerForm.username" class="input" type="text" placeholder="请输入账号" maxlength="30" />
      </view>

      <view class="input-item">
        <u-icon name="lock" size="22" color="#3D6DF7" style="margin-left: 12px" />
        <input v-model="registerForm.password" type="password" class="input" placeholder="请输入密码" maxlength="20" />
      </view>

      <view class="input-item">
        <u-icon name="lock" size="22" color="#3D6DF7" style="margin-left: 12px" />
        <input v-model="registerForm.confirmPassword" type="password" class="input" placeholder="请输入重复密码" maxlength="20" />
      </view>

      <view class="input-item captcha-row" v-if="captchaEnabled">
        <u-icon name="photo" size="22" color="#3D6DF7" style="margin-left: 12px" />
        <input v-model="registerForm.code" type="number" class="input captcha-input" placeholder="请输入验证码" maxlength="4" />
        <view class="login-code" @click="getCode">
          <image v-if="codeUrl" :src="codeUrl" class="login-code-img" mode="heightFix" />
          <view v-else class="login-code-placeholder">获取验证码</view>
        </view>
      </view>

      <view class="action-btn">
        <button @click="handleRegister" class="register-btn">注册</button>
      </view>

      <view class="reg">
        <text @click="handleUserLogin" class="uni-text-blue">使用已有账号登录</text>
      </view>
    </view>

    <!-- 底部品牌区域 -->
    <view class="bottom-section">
      <view class="brand-mark">
        <text class="brand-en">SYNOLIFE</text>
      </view>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 注册页 - 用户账号注册
 * @description 支持账号密码注册，包含验证码获取、表单校验（密码一致性）功能
 */
import { ref, onMounted } from 'vue'
import { getCodeImg, register } from '@/api/login'

const codeUrl = ref('')
const captchaEnabled = ref(true)
const registerForm = ref({
  username: '',
  password: '',
  confirmPassword: '',
  code: '',
  uuid: ''
})

onMounted(() => {
  getCode()
})

/** 跳转登录页 */
function handleUserLogin() {
  uni.navigateTo({ url: '/pages/login' })
}

/** 获取图形验证码，将base64图片绑定到页面并保存uuid用于注册校验 */
function getCode() {
  getCodeImg().then(res => {
    captchaEnabled.value = res.captchaEnabled === undefined ? true : res.captchaEnabled
    if (captchaEnabled.value) {
      codeUrl.value = 'data:image/gif;base64,' + res.img
      registerForm.value.uuid = res.uuid
    }
  })
}

/** 注册表单校验，检查账号、密码、确认密码和验证码是否填写完整且密码一致 */
async function handleRegister() {
  if (registerForm.value.username === '') {
    uni.showToast({ title: '请输入您的账号', icon: 'none' })
  } else if (registerForm.value.password === '') {
    uni.showToast({ title: '请输入您的密码', icon: 'none' })
  } else if (registerForm.value.confirmPassword === '') {
    uni.showToast({ title: '请再次输入您的密码', icon: 'none' })
  } else if (registerForm.value.password !== registerForm.value.confirmPassword) {
    uni.showToast({ title: '两次输入的密码不一致', icon: 'none' })
  } else if (registerForm.value.code === '' && captchaEnabled.value) {
    uni.showToast({ title: '请输入验证码', icon: 'none' })
  } else {
    uni.showLoading({ title: '注册中，请耐心等待...' })
    doRegister()
  }
}

/** 执行注册请求，成功后弹窗提示并跳转登录页，失败则刷新验证码 */
async function doRegister() {
  try {
    await register(registerForm.value)
    uni.hideLoading()
    uni.showModal({
      title: '系统提示',
      content: '恭喜你，您的账号 ' + registerForm.value.username + ' 注册成功！',
      success: function (res) {
        if (res.confirm) {
          uni.redirectTo({ url: '/pages/login' })
        }
      }
    })
  } catch {
    uni.hideLoading()
    if (captchaEnabled.value) {
      getCode()
    }
  }
}
</script>

<style lang="scss" scoped>
page {
  background: linear-gradient(180deg, #3D6DF7 0%, #5B8FF9 30%, #FFFFFF 70%, #FFFFFF 100%);
  min-height: 100vh;
}

.normal-login-container {
  width: 100%;
  min-height: 100vh;
  padding: 0 32rpx 60rpx 32rpx;
  position: relative;
  overflow: hidden;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
}

/* 顶部装饰圆形 */
.top-decoration {
  position: absolute;
  top: -60rpx;
  left: 0;
  right: 0;
  height: 300rpx;
  pointer-events: none;

  .decoration-circle {
    position: absolute;
    border-radius: 50%;
    background: linear-gradient(135deg, rgba(61, 109, 247, 0.15), rgba(91, 143, 249, 0.08));
  }

  .circle-1 {
    width: 200rpx;
    height: 200rpx;
    top: 40rpx;
    left: -40rpx;
  }

  .circle-2 {
    width: 160rpx;
    height: 160rpx;
    top: 80rpx;
    right: 60rpx;
  }

  .circle-3 {
    width: 100rpx;
    height: 100rpx;
    top: 20rpx;
    left: 50%;
    transform: translateX(-50%);
  }
}

/* Logo 区域 */
.logo-content {
  width: 100%;
  text-align: center;
  padding-top: 120rpx;
  margin-bottom: 40rpx;
  display: flex;
  flex-direction: column;
  align-items: center;

  .title {
    font-size: 56rpx;
    font-weight: 700;
    color: #3D6DF7;
    letter-spacing: 4rpx;
  }

  .subtitle {
    font-size: 26rpx;
    color: #86909C;
    margin-top: 12rpx;
  }
}

/* 表单区域 */
.login-form-content {
  background: #FFFFFF;
  border-radius: 24rpx;
  padding: 40rpx 24rpx;
  box-shadow: 0 4rpx 24rpx rgba(61, 109, 247, 0.12);
  margin-bottom: 32rpx;
  box-sizing: border-box;
  width: 100%;

  .form-title {
    font-size: 32rpx;
    font-weight: 600;
    color: #1D2129;
    text-align: center;
    margin-bottom: 32rpx;
  }

  .input-item {
    margin: 24rpx 0;
    background: #F7F8FA;
    border: 2rpx solid #E5E6EB;
    height: 96rpx;
    border-radius: 24rpx;
    display: flex;
    align-items: center;
    transition: all 0.3s ease;
    box-sizing: border-box;
    width: 100%;
    padding-right: 24rpx;

    .input {
      flex: 1;
      font-size: 28rpx;
      line-height: 40rpx;
      text-align: left;
      padding-left: 12rpx;
    }

    .captcha-input {
      flex: 1;
    }
  }

  .captcha-row {
    padding-right: 0;

    .login-code {
      height: 96rpx;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 0 16rpx;
      flex-shrink: 0;

      .login-code-img {
        height: 72rpx;
        width: 180rpx;
        border-radius: 12rpx;
      }

      .login-code-placeholder {
        font-size: 26rpx;
        color: #3D6DF7;
        white-space: nowrap;
      }
    }
  }

  .register-btn {
    margin-top: 48rpx;
    height: 96rpx;
    line-height: 96rpx;
    background: linear-gradient(135deg, #3D6DF7, #5B8FF9);
    color: #ffffff;
    border-radius: 48rpx;
    font-size: 32rpx;
    font-weight: 600;
    box-shadow: 0 4rpx 16rpx rgba(61, 109, 247, 0.35);
    letter-spacing: 8rpx;

    &:active {
      opacity: 0.9;
      transform: scale(0.98);
    }
  }

  .reg {
    margin-top: 24rpx;
    text-align: center;
    font-size: 26rpx;

    .uni-text-blue {
      color: #3D6DF7;
    }
  }
}

/* 底部区域 */
.bottom-section {
  position: absolute;
  bottom: 40rpx;
  left: 0;
  right: 0;
  text-align: center;

  .brand-mark {
    margin-top: 40rpx;
    display: flex;
    justify-content: center;

    .brand-en {
      font-size: 22rpx;
      color: #C9CDD4;
      letter-spacing: 8rpx;
      font-weight: 400;
    }
  }
}
</style>