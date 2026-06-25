<template>
  <view class="agreement-page">
    <view class="page-header">
      <view class="back-btn" @click="goBack">
        <u-icon name="arrow-left" size="20" color="#1D2129" />
      </view>
      <text class="page-title">用户服务协议</text>
    </view>

    <scroll-view scroll-y class="content-scroll">
      <view class="content">
        <view class="agreement-section">
          <text class="section-title">一、协议接受</text>
          <text class="section-content">欢迎使用"赛诺美生"管理系统（以下简称"本系统"）。在使用本系统前，请您仔细阅读本协议。您下载、安装、注册或使用本系统的行为即视为您已阅读并同意本协议的全部条款。</text>
        </view>

        <view class="agreement-section">
          <text class="section-title">二、服务内容</text>
          <text class="section-content">本系统为美容、医美行业提供一体化管理服务，包括但不限于：客户管理、订单管理、库存管理、财务管理、考勤管理、数据统计等业务功能。</text>
        </view>

        <view class="agreement-section">
          <text class="section-title">三、用户权利与义务</text>
          <text class="section-content">3.1 您应妥善保管账号和密码，对使用您账号进行的一切活动承担责任。</text>
          <text class="section-content">3.2 您应保证上传的数据真实、合法，不侵犯第三方权益。</text>
          <text class="section-content">3.3 您不得利用本系统从事违法违规活动。</text>
          <text class="section-content">3.4 您应遵守国家法律法规和本协议约定。</text>
        </view>

        <view class="agreement-section">
          <text class="section-title">四、服务变更与终止</text>
          <text class="section-content">4.1 我们保留随时修改或中断本系统服务的权利。</text>
          <text class="section-content">4.2 如您违反本协议，我们有权终止您的使用权限。</text>
        </view>

        <view class="agreement-section">
          <text class="section-title">五、知识产权</text>
          <text class="section-content">本系统的所有内容（包括但不限于文字、图片、代码、设计等）的知识产权归本公司所有，受法律保护。</text>
        </view>

        <view class="agreement-section">
          <text class="section-title">六、免责条款</text>
          <text class="section-content">6.1 因不可抗力导致的服务中断，我们不承担责任。</text>
          <text class="section-content">6.2 因您个人原因造成的数据丢失，我们不承担责任。</text>
        </view>

        <view class="agreement-section">
          <text class="section-title">七、协议修改</text>
          <text class="section-content">我们有权根据需要修改本协议，修改后的协议一经公布即生效。</text>
        </view>

        <view class="agreement-section">
          <text class="section-title">八、联系我们</text>
          <text class="section-content">如您对本协议有任何疑问，请通过以下方式联系我们：</text>
          <text class="section-content">联系电话：19512187797</text>
          <text class="section-content">微信号：best-pengpeng</text>
        </view>

        <view class="agreement-footer">
          <text>本协议最终解释权归本公司所有</text>
          <text>更新日期：2026年6月</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
/**
 * @description 用户服务协议页面
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
