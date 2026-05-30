<template>
  <view class="auth-role-container">
    <view v-if="loading" class="loading-wrap">
      <u-loading-icon size="40"></u-loading-icon>
    </view>
    <template v-else>
      <view class="info-card">
        <view class="card-title">
          <u-icon name="account-fill" size="18" color="#3D6DF7"></u-icon>
          <text>用户信息</text>
        </view>
        <view class="info-grid">
          <view class="info-item">
            <text class="info-label">用户姓名</text>
            <text class="info-value">{{ userInfo.nickName || '-' }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">登录账号</text>
            <text class="info-value">{{ userInfo.userName || '-' }}</text>
          </view>
        </view>
      </view>

      <view class="info-card">
        <view class="card-title">
          <u-icon name="account" size="18" color="#3D6DF7"></u-icon>
          <text>角色列表</text>
        </view>
        <view class="role-list">
          <view
            v-for="item in roles"
            :key="item.roleId"
            class="role-item"
            :class="{ active: selectedRoleIds.includes(item.roleId), disabled: item.status === '1' }"
            @click="toggleRole(item)"
          >
            <view class="check-box" :class="{ checked: selectedRoleIds.includes(item.roleId) }">
              <u-icon v-if="selectedRoleIds.includes(item.roleId)" name="checkmark" size="12" color="#fff"></u-icon>
            </view>
            <view class="role-info">
              <text class="role-name">{{ item.roleName }}</text>
              <text class="role-key">{{ item.roleKey }}</text>
            </view>
            <view v-if="item.status === '1'" class="disabled-tag">停用</view>
          </view>
          <u-empty v-if="roles.length === 0" mode="data" text="暂无可分配角色" :marginTop="40"></u-empty>
        </view>
      </view>

      <view class="bottom-actions">
        <u-button type="info" plain text="返回" @click="goBack"></u-button>
        <u-button type="primary" text="提交" :loading="submitting" @click="submitForm"></u-button>
      </view>
    </template>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getAuthRole, updateAuthRole } from '@/api/system/user'

const loading = ref(false)
const submitting = ref(false)
const userId = ref(null)
const userInfo = ref({})
const roles = ref([])
const selectedRoleIds = ref([])

async function loadData() {
  if (!userId.value) return
  loading.value = true
  try {
    const res = await getAuthRole(userId.value)
    userInfo.value = res.user || {}
    roles.value = res.roles || []
    selectedRoleIds.value = roles.value.filter(r => r.flag).map(r => r.roleId)
  } catch (e) {
    console.error('获取角色授权数据失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

function toggleRole(item) {
  if (item.status === '1') return
  const idx = selectedRoleIds.value.indexOf(item.roleId)
  if (idx > -1) {
    selectedRoleIds.value.splice(idx, 1)
  } else {
    selectedRoleIds.value.push(item.roleId)
  }
}

async function submitForm() {
  submitting.value = true
  try {
    await updateAuthRole({
      userId: userId.value,
      roleIds: selectedRoleIds.value.join(',')
    })
    uni.showToast({ title: '授权成功', icon: 'success' })
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('授权失败:', e)
    const msg = e?.msg || e?.message || '授权失败，请重试'
    uni.showToast({ title: msg, icon: 'none', duration: 2000 })
  } finally {
    submitting.value = false
  }
}

function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.redirectTo({ url: '/pages/system/user/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  userId.value = options.userId ? parseInt(options.userId) : null
  if (userId.value) {
    loadData()
  }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.auth-role-container { min-height: 100vh; padding: 24rpx; padding-bottom: 140rpx; }

.loading-wrap { display: flex; justify-content: center; align-items: center; min-height: 60vh; }

.info-card {
  background: #fff; border-radius: 16rpx; padding: 28rpx; margin-bottom: 20rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}
.card-title {
  display: flex; align-items: center; gap: 10rpx; font-size: 30rpx; font-weight: 600;
  color: #1D2129; margin-bottom: 24rpx; padding-bottom: 16rpx; border-bottom: 1rpx solid #F2F3F5;
}
.info-grid { display: flex; flex-wrap: wrap; }
.info-item { width: 50%; padding: 12rpx 0; }
.info-label { display: block; font-size: 24rpx; color: #86909C; margin-bottom: 6rpx; }
.info-value { display: block; font-size: 28rpx; color: #1D2129; }

.role-list { display: flex; flex-direction: column; gap: 12rpx; }
.role-item {
  display: flex; align-items: center; gap: 16rpx; padding: 24rpx 20rpx;
  background: #F7F8FA; border-radius: 12rpx; transition: all 0.2s;
  &.active { background: #E8F0FE; }
  &.disabled { opacity: 0.5; }
}
.check-box {
  width: 40rpx; height: 40rpx; border-radius: 8rpx; border: 3rpx solid #C9CDD4;
  display: flex; align-items: center; justify-content: center; transition: all 0.2s; flex-shrink: 0;
  &.checked { background: #3D6DF7; border-color: #3D6DF7; }
}
.role-info { flex: 1; display: flex; flex-direction: column; gap: 4rpx; }
.role-name { font-size: 28rpx; color: #1D2129; font-weight: 500; }
.role-key { font-size: 24rpx; color: #86909C; }
.disabled-tag {
  padding: 4rpx 12rpx; border-radius: 4rpx; font-size: 22rpx;
  background: #FFF1F0; color: #F53F3F; flex-shrink: 0;
}

.bottom-actions {
  position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx;
  display: flex; gap: 20rpx; z-index: 100;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
