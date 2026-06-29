<template>
  <view class="map-picker-page">
    <view class="search-box">
      <input
        class="search-input"
        type="text"
        v-model="searchKeyword"
        placeholder="搜索地址"
        confirm-type="search"
        @confirm="handleSearch"
      />
      <view class="search-btn" @click="handleSearch">
        <text>搜索</text>
      </view>
    </view>
    <view class="map-wrapper">
      <!-- #ifdef H5 -->
      <div class="map-container" ref="mapContainer"></div>
      <!-- #endif -->
      <!-- #ifndef H5 -->
      <view class="map-container" ref="mapContainer"></view>
      <!-- #endif -->

      <!-- 搜索结果列表 - 叠加在地图上方，不遮挡搜索框和底部按钮 -->
      <view class="search-results" v-if="showSearchResults && searchResults.length > 0">
        <scroll-view scroll-y class="results-scroll">
          <view
            v-for="(item, index) in searchResults"
            :key="index"
            class="result-item"
            @click="selectSearchResult(item)"
          >
            <view class="result-name">{{ item.name }}</view>
            <view class="result-address">{{ item.address || item.district }}</view>
          </view>
        </scroll-view>
      </view>
    </view>
    <view class="info-bar" v-if="selectedAddress">
      <view class="info-icon">
        <u-icon name="map" size="16" color="#3D6DF7"></u-icon>
      </view>
      <text class="info-text">{{ selectedAddress }}</text>
    </view>
    <view class="bottom-bar">
      <view class="btn-cancel" @click="handleCancel">
        <text>取消</text>
      </view>
      <view class="btn-confirm" @click="handleConfirm">
        <text>确定</text>
      </view>
    </view>
  </view>
</template>

<script setup>
/**
 * @description 地图选点页面 - 高德地图位置选择器
 * @description 通过 uni.navigateTo 跳转到此页面，使用 eventChannel 返回选点结果
 * @description 地图渲染使用 JS API，搜索和逆地理编码使用 REST API（webServiceKey 无需域名白名单）
 */
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { getConfigKey } from '@/api/system/config'
import config from '@/config'

const searchKeyword = ref('')
const selectedAddress = ref('')
const selectedLatitude = ref(null)
const selectedLongitude = ref(null)
const showSearchResults = ref(false)
const searchResults = ref([])
const mapContainer = ref(null)

let map = null
let marker = null
let AMap = null

// JS API 配置（用于地图渲染）
const AMAP_KEY = ref('fa588d6bc9fbc9dce1f0c379e40f9faa')
const AMAP_SECURITY_CODE = ref('19ef226bdd6e4a6276d45ed1e5cb9a475')
// REST API 配置（用于搜索和逆地理编码，无需域名白名单）
const AMAP_WEB_SERVICE_KEY = ref(config.amap.webServiceKey)

/** 从后端加载高德地图配置 */
async function loadAmapConfig() {
  try {
    const [jsKeyRes, securityRes, webKeyRes] = await Promise.all([
      getConfigKey('sys.amap.jsKey'),
      getConfigKey('sys.amap.securityJsCode'),
      getConfigKey('sys.amap.webServiceKey')
    ])
    if (jsKeyRes.data) AMAP_KEY.value = jsKeyRes.data
    if (securityRes.data) AMAP_SECURITY_CODE.value = securityRes.data
    if (webKeyRes.data) AMAP_WEB_SERVICE_KEY.value = webKeyRes.data
  } catch (e) {
    console.warn('获取高德地图配置失败，使用默认配置', e)
  }
}

/** 动态加载高德地图JS（仅用于地图渲染，不再加载服务插件） */
function loadAMapScript() {
  return new Promise((resolve, reject) => {
    if (window.AMap) {
      resolve(window.AMap)
      return
    }
    window._AMapSecurityConfig = {
      securityJsCode: AMAP_SECURITY_CODE.value
    }
    const script = document.createElement('script')
    script.src = `https://webapi.amap.com/maps?v=2.0&key=${AMAP_KEY.value}`
    script.onload = () => {
      AMap = window.AMap
      resolve(AMap)
    }
    script.onerror = (e) => reject(e)
    document.head.appendChild(script)
  })
}

/** 初始化地图 */
async function initMap() {
  await loadAmapConfig()
  try {
    AMap = await loadAMapScript()

    await nextTick()

    // 从页面参数获取初始坐标
    const pages = getCurrentPages()
    const currentPage = pages[pages.length - 1]
    const opts = currentPage.options || {}
    const lat = opts.lat ? parseFloat(opts.lat) : null
    const lng = opts.lng ? parseFloat(opts.lng) : null

    const center = (lat && lng) ? [lng, lat] : [116.397428, 39.90923]

    map = new AMap.Map(mapContainer.value, {
      zoom: 15,
      center: center
    })

    if (lat && lng) {
      addMarker(lng, lat)
      selectedLatitude.value = lat
      selectedLongitude.value = lng
      reverseGeocode(lat, lng)
    }

    map.on('click', (e) => {
      const lngVal = e.lnglat.getLng()
      const latVal = e.lnglat.getLat()
      addMarker(lngVal, latVal)
      reverseGeocode(latVal, lngVal)
    })
  } catch (e) {
    console.error('地图加载失败', e)
    uni.showToast({ title: '地图加载失败', icon: 'none' })
  }
}

function addMarker(lng, lat) {
  if (marker) {
    marker.setPosition([lng, lat])
  } else if (map) {
    marker = new AMap.Marker({
      position: [lng, lat],
      draggable: true
    })
    marker.on('dragend', () => {
      const pos = marker.getPosition()
      const latVal = pos.lat
      const lngVal = pos.lng
      reverseGeocode(latVal, lngVal)
    })
    map.add(marker)
  }
  selectedLatitude.value = lat
  selectedLongitude.value = lng
  map && map.setCenter([lng, lat])
}

/**
 * 逆地理编码（REST API）
 * 调用 restapi.amap.com/v3/geocode/regeo，使用 webServiceKey 无需域名白名单
 */
async function reverseGeocode(lat, lng) {
  try {
    const key = AMAP_WEB_SERVICE_KEY.value
    const url = `https://restapi.amap.com/v3/geocode/regeo?location=${lng},${lat}&key=${key}&extensions=all&output=JSON`
    const res = await new Promise((resolve, reject) => {
      uni.request({ url, method: 'GET', timeout: 8000, success: resolve, fail: reject })
    })
    if (res.data?.regeocode) {
      selectedAddress.value = res.data.regeocode.formatted_address || ''
      selectedLatitude.value = lat
      selectedLongitude.value = lng
    }
  } catch (e) {
    console.warn('逆地理编码失败', e)
  }
}

/**
 * 搜索地点（REST API）
 * 调用 restapi.amap.com/v3/place/text，使用 webServiceKey 无需域名白名单
 */
async function handleSearch() {
  if (!searchKeyword.value.trim()) return
  try {
    const key = AMAP_WEB_SERVICE_KEY.value
    const url = `https://restapi.amap.com/v3/place/text?keywords=${encodeURIComponent(searchKeyword.value)}&key=${key}&offset=10&page=1&extensions=base`
    const res = await new Promise((resolve, reject) => {
      uni.request({ url, method: 'GET', timeout: 8000, success: resolve, fail: reject })
    })
    if (res.data?.pois && res.data.pois.length > 0) {
      searchResults.value = res.data.pois.map(poi => ({
        name: poi.name,
        address: poi.address || (poi.pname || '') + (poi.cityname || '') + (poi.adname || ''),
        latitude: poi.location ? parseFloat(poi.location.split(',')[1]) : null,
        longitude: poi.location ? parseFloat(poi.location.split(',')[0]) : null
      }))
      showSearchResults.value = true
    } else {
      uni.showToast({ title: '无搜索结果', icon: 'none' })
    }
  } catch (e) {
    console.warn('搜索失败', e)
    uni.showToast({ title: '搜索失败', icon: 'none' })
  }
}

function selectSearchResult(item) {
  showSearchResults.value = false
  if (item.longitude && item.latitude) {
    addMarker(item.longitude, item.latitude)
    reverseGeocode(item.latitude, item.longitude)
  }
  searchKeyword.value = item.name
}

function handleConfirm() {
  if (!selectedLatitude.value || !selectedLongitude.value) {
    uni.showToast({ title: '请先选择地点', icon: 'none' })
    return
  }
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const eventChannel = currentPage.getOpenerEventChannel?.()
  if (eventChannel && eventChannel.emit) {
    eventChannel.emit('mapPickerConfirm', {
      latitude: selectedLatitude.value,
      longitude: selectedLongitude.value,
      address: selectedAddress.value
    })
  }
  uni.navigateBack()
}

function handleCancel() {
  uni.navigateBack()
}

onMounted(() => {
  initMap()
})

onUnmounted(() => {
  if (map) {
    map.destroy()
    map = null
    marker = null
  }
})
</script>

<style lang="scss" scoped>
page {
  height: 100%;
  padding: 0;
  margin: 0;
}

.map-picker-page {
  display: flex;
  flex-direction: column;
  /* 让 uni-app H5 的 uni-page-wrapper 自动处理导航栏偏移，避免我们手动算导航栏高度不准确 */
  position: relative;
  width: 100%;
  height: 100%;
  background: #fff;
  overflow: hidden;
}

.search-box {
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 16rpx 24rpx;
  background: #fff;
  border-bottom: 1rpx solid #F0F0F0;
  flex-shrink: 0;
}

.search-input {
  flex: 1;
  height: 72rpx;
  background: #F7F8FA;
  border-radius: 36rpx;
  padding: 0 28rpx;
  font-size: 28rpx;
  color: #1D2129;
}

.search-btn {
  flex-shrink: 0;
  padding: 0 28rpx;
  height: 72rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #3D6DF7;
  border-radius: 36rpx;
  color: #fff;
  font-size: 28rpx;
}

.map-wrapper {
  flex: 1;
  position: relative;
  width: 100%;
  min-height: 300rpx;
  overflow: hidden;
}

.map-container {
  width: 100%;
  height: 100%;
  min-height: 300rpx;
}

.info-bar {
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 20rpx 24rpx;
  background: #fff;
  border-top: 1rpx solid #F0F0F0;
  flex-shrink: 0;
}

.info-text {
  flex: 1;
  font-size: 26rpx;
  color: #4E5969;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.bottom-bar {
  display: flex;
  gap: 20rpx;
  padding: 20rpx 24rpx;
  /* 适配 iPhone 底部安全区，避免被 Home Indicator 遮挡 */
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  padding-bottom: calc(20rpx + constant(safe-area-inset-bottom));
  background: #fff;
  border-top: 1rpx solid #F0F0F0;
  flex-shrink: 0;
}

.btn-cancel, .btn-confirm {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 22rpx 0;
  border-radius: 12rpx;
  font-size: 28rpx;
  font-weight: 500;
}

.btn-cancel {
  background: #F7F8FA;
  color: #4E5969;
  border: 1rpx solid #E5E6EB;
}

.btn-confirm {
  background: linear-gradient(180deg, #5B8FF9 0%, #3D6DF7 100%);
  color: #fff;
}

.search-results {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  max-height: 600rpx;
  background: #fff;
  border-radius: 0 0 16rpx 16rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.15);
  z-index: 10;
  overflow: hidden;
}

.results-scroll {
  max-height: 600rpx;
}

.result-item {
  padding: 24rpx;
  border-bottom: 1rpx solid #F2F3F5;
}

.result-name {
  font-size: 28rpx;
  color: #1D2129;
  font-weight: 500;
}

.result-address {
  font-size: 24rpx;
  color: #86909C;
  margin-top: 6rpx;
}
</style>
