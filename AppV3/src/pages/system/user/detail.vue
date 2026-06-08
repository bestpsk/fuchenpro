<template>
  <view class="detail-container">
    <view v-if="loading" class="loading-wrap">
      <u-loading-icon size="40"></u-loading-icon>
    </view>
    <template v-else>
      <view class="info-card">
        <view class="card-title">
          <u-icon name="account-fill" size="18" color="#3D6DF7"></u-icon>
          <text>基本信息</text>
        </view>
        <view class="info-grid">
          <view class="info-item">
            <text class="info-label">用户姓名</text>
            <text class="info-value">{{ info.nickName || '-' }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">登录账号</text>
            <text class="info-value">{{ info.userName || '-' }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">归属部门</text>
            <text class="info-value">{{ info.dept ? info.dept.deptName : '-' }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">手机号码</text>
            <text class="info-value link" @click="callPhone(info.phonenumber)">{{ info.phonenumber || '-' }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">邮箱</text>
            <text class="info-value">{{ info.email || '-' }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">用户状态</text>
            <view class="status-tag" :class="info.status === '0' ? 'status-normal' : 'status-stop'">
              {{ info.status === '0' ? '正常' : '停用' }}
            </view>
          </view>
          <view class="info-item">
            <text class="info-label">性别</text>
            <text class="info-value">{{ sexLabel }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">岗位</text>
            <text class="info-value">{{ postNames || '无岗位' }}</text>
          </view>
          <view class="info-item full">
            <text class="info-label">角色</text>
            <text class="info-value">{{ roleNames || '无角色' }}</text>
          </view>
        </view>
      </view>

      <view class="info-card">
        <view class="card-title">
          <u-icon name="file-text-fill" size="18" color="#3D6DF7"></u-icon>
          <text>其他信息</text>
        </view>
        <view class="info-grid">
          <view class="info-item">
            <text class="info-label">创建者</text>
            <text class="info-value">{{ info.createBy || '-' }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">创建时间</text>
            <text class="info-value">{{ info.createTime || '-' }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">更新者</text>
            <text class="info-value">{{ info.updateBy || '-' }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">更新时间</text>
            <text class="info-value">{{ info.updateTime || '-' }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">最后登录IP</text>
            <text class="info-value">{{ info.loginIp || '-' }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">最后登录时间</text>
            <text class="info-value">{{ info.loginDate || '-' }}</text>
          </view>
          <view class="info-item full">
            <text class="info-label">备注</text>
            <text class="info-value">{{ info.remark || '-' }}</text>
          </view>
        </view>
      </view>

      <view v-if="info.userId !== 1" class="bottom-actions">
        <u-button v-if="checkPermi('system:user:edit')" type="primary" plain text="编辑" icon="edit-pen" @click="goEdit"></u-button>
        <u-button v-if="checkPermi('system:user:resetPwd')" type="warning" plain text="重置密码" icon="lock" @click="handleResetPwd"></u-button>
        <u-button v-if="checkPermi('system:user:edit')" type="success" plain text="分配角色" icon="account" @click="goAuthRole"></u-button>
      </view>
    </template>
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { getUser, resetUserPwd } from '@/api/system/user'
import { checkPermi } from '@/utils/permission'

const loading = ref(false)
const info = ref({})
const postOptions = ref([])
const roleOptions = ref([])
const userId = ref(null)

const sexMap = { '0': '男', '1': '女', '2': '未知' }
const sexLabel = computed(() => sexMap[info.value.sex] || '-')

const postNames = computed(() => {
  if (!postOptions.value.length || !info.value.postIds) return ''
  return postOptions.value.filter(p => info.value.postIds?.includes(p.postId)).map(p => p.postName).join('、') || ''
})

const roleNames = computed(() => {
  if (!roleOptions.value.length || !info.value.roleIds) return ''
  return roleOptions.value.filter(r => info.value.roleIds?.includes(r.roleId)).map(r => r.roleName).join('、') || ''
})

async function loadDetail() {
  if (!userId.value) return
  loading.value = true
  try {
    const res = await getUser(userId.value)
    info.value = res.data || {}
    postOptions.value = res.posts || []
    roleOptions.value = res.roles || []
    info.value.postIds = res.postIds || []
    info.value.roleIds = res.roleIds || []
  } catch (e) {
    console.error('获取用户信息失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

function goEdit() {
  uni.navigateTo({ url: `/pages/system/user/form?id=${userId.value}&mode=edit` })
}

function goAuthRole() {
  uni.navigateTo({ url: `/pages/system/user/authRole?userId=${userId.value}` })
}

function handleResetPwd() {
  uni.showModal({
    title: '重置密码',
    editable: true,
    placeholderText: `请输入「${info.value.userName}」的新密码`,
    success: async (res) => {
      if (res.confirm && res.content) {
        try {
          await resetUserPwd(userId.value, res.content)
          uni.showToast({ title: '重置成功', icon: 'success' })
        } catch (e) {
          console.error('重置密码失败:', e)
        }
      }
    }
  })
}

function callPhone(phone) {
  if (!phone) return
  uni.makePhoneCall({ phoneNumber: phone })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  userId.value = options.userId ? parseInt(options.userId) : null
  if (userId.value) {
    loadDetail()
  }
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.detail-container { min-height: 100vh; padding: 24rpx; padding-bottom: 140rpx; }

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
.info-item {
  width: 50%; padding: 12rpx 0;
  &.full { width: 100%; }
}
.info-label { display: block; font-size: 24rpx; color: #86909C; margin-bottom: 6rpx; }
.info-value { display: block; font-size: 28rpx; color: #1D2129; word-break: break-all; }
.info-value.link { color: #3D6DF7; }

.status-tag {
  display: inline-block; padding: 4rpx 14rpx; border-radius: 6rpx; font-size: 22rpx; font-weight: 500;
  &.status-normal { background: #E8FFEA; color: #00B42A; }
  &.status-stop { background: #FFF1F0; color: #F53F3F; }
}

.bottom-actions {
  position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx;
  display: flex; gap: 20rpx; z-index: 100;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 28rpx; font-weight: 600; }
}
</style>
