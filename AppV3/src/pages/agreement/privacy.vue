<template>
  <view class="agreement-page">
    <view class="page-header">
      <view class="back-btn" @click="goBack">
        <u-icon name="arrow-left" size="20" color="#1D2129" />
      </view>
      <text class="page-title">隐私政策</text>
    </view>

    <scroll-view scroll-y class="content-scroll">
      <view class="content">
        <view class="agreement-section">
          <text class="section-title">一、信息收集</text>
          <text class="section-content">为提供更好的服务，我们会收集以下信息：</text>
          <text class="section-content">1.1 您主动提供的信息：账号、姓名、联系方式、企业/门店信息等</text>
          <text class="section-content">1.2 系统自动收集的信息：设备信息、位置信息（考勤打卡）、操作日志等</text>
        </view>

        <view class="agreement-section">
          <text class="section-title">二、信息使用</text>
          <text class="section-content">2.1 用于为您提供服务及改进服务质量</text>
          <text class="section-content">2.2 用于身份验证和安全保护</text>
          <text class="section-content">2.3 法律法规要求的其他用途</text>
        </view>

        <view class="agreement-section">
          <text class="section-title">三、信息共享</text>
          <text class="section-content">我们承诺不会出售或出租您的个人信息给第三方，除非：</text>
          <text class="section-content">3.1 获得您的明确同意</text>
          <text class="section-content">3.2 法律法规要求</text>
          <text class="section-content">3.3 为完成您要求的特定服务</text>
        </view>

        <view class="agreement-section">
          <text class="section-title">四、信息存储</text>
          <text class="section-content">4.1 您的信息存储在中华人民共和国境内</text>
          <text class="section-content">4.2 我们采取技术措施保障信息安全</text>
          <text class="section-content">4.3 超过保存期限的信息将被删除或匿名化处理</text>
        </view>

        <view class="agreement-section">
          <text class="section-title">五、您的权利</text>
          <text class="section-content">5.1 查阅、复制您的个人信息</text>
          <text class="section-content">5.2 更正或补充错误信息</text>
          <text class="section-content">5.3 删除您的个人信息</text>
          <text class="section-content">5.4 撤回授权同意</text>
        </view>

        <view class="agreement-section">
          <text class="section-title">六、Cookie 使用</text>
          <text class="section-content">我们使用 Cookie 和类似技术来识别您的身份、保障账号安全、改善服务体验。</text>
        </view>

        <view class="agreement-section">
          <text class="section-title">七、未成年人保护</text>
          <text class="section-content">本系统面向企业用户，不直接面向未成年人。如发现未成年人信息，我们会立即删除。</text>
        </view>

        <view class="agreement-section">
          <text class="section-title">八、政策更新</text>
          <text class="section-content">我们可能根据业务调整更新本政策，更新后将通过系统公告通知您。</text>
        </view>

        <view class="agreement-section">
          <text class="section-title">九、联系我们</text>
          <text class="section-content">如有隐私相关问题，请联系：</text>
          <text class="section-content">联系电话：19512187797</text>
          <text class="section-content">微信号：best-pengpeng</text>
        </view>

        <view class="agreement-footer">
          <text>本政策最终解释权归本公司所有</text>
          <text>更新日期：2026年6月</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
/**
 * @description 隐私政策页面
 */
function goBack() {
  uni.navigateBack()
}
</script>

<style lang="scss" scoped>
.agreement-page {
  min-height: 100vh;
  background: #F5F7FA;
  display: flex;
  flex-direction: column;
}

.page-header {
  background: #FFFFFF;
  padding: 24rpx 32rpx;
  display: flex;
  align-items: center;
  gap: 24rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.04);
  position: sticky;
  top: 0;
  z-index: 10;

  .back-btn {
    width: 56rpx;
    height: 56rpx;
    display: flex;
    align-items: center;
    justify-content: center;

    &:active {
      opacity: 0.6;
    }
  }

  .page-title {
    font-size: 32rpx;
    font-weight: 600;
    color: #1D2129;
  }
}

.content-scroll {
  flex: 1;
  padding: 24rpx;
}

.content {
  background: #FFFFFF;
  border-radius: 16rpx;
  padding: 32rpx 28rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.04);
}

.agreement-section {
  margin-bottom: 32rpx;

  .section-title {
    display: block;
    font-size: 30rpx;
    font-weight: 600;
    color: #1D2129;
    margin-bottom: 16rpx;
  }

  .section-content {
    display: block;
    font-size: 26rpx;
    line-height: 1.8;
    color: #4E5969;
    margin-bottom: 12rpx;
  }
}

.agreement-footer {
  margin-top: 48rpx;
  padding-top: 32rpx;
  border-top: 2rpx solid #E5E6EB;
  text-align: center;

  text {
    display: block;
    font-size: 24rpx;
    color: #86909C;
    line-height: 1.8;
  }
}
</style>
