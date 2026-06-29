<template>
  <el-dialog title="选择考勤地点" v-model="visible" width="700px" append-to-body @open="initMap" @close="destroyMap">
    <div class="map-picker">
      <div class="map-search">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索地址"
          clearable
          @keyup.enter="handleSearch"
        >
          <template #append>
            <el-button icon="Search" @click="handleSearch" />
          </template>
        </el-input>
      </div>
      <div class="map-container" ref="mapContainer"></div>
      <div class="map-info" v-if="selectedPoint.address">
        <el-icon><Location /></el-icon>
        <span>{{ selectedPoint.address }}</span>
      </div>
    </div>
    <template #footer>
      <div class="dialog-footer">
        <el-button @click="visible = false">取 消</el-button>
        <el-button type="primary" @click="handleConfirm">确 定</el-button>
      </div>
    </template>
  </el-dialog>
</template>

<script setup>
/**
 * @description 地图选点组件 - 高德地图位置选择器
 * @description 基于高德地图实现位置选择，支持搜索地址、点击地图获取经纬度和地址
 */
import { ref, reactive } from 'vue'
import AMapLoader from '@amap/amap-jsapi-loader'
import { getConfigKey } from '@/api/system/config'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  latitude: { type: [Number, String], default: null },
  longitude: { type: [Number, String], default: null }
})

const emit = defineEmits(['update:modelValue', 'confirm'])

const visible = ref(false)
const searchKeyword = ref('')
const mapContainer = ref(null)
const selectedPoint = reactive({ latitude: null, longitude: null, address: '' })

let map = null
let marker = null

// 高德地图配置：默认使用 .env，运行时从后端覆盖
const AMAP_KEY = ref(import.meta.env.VITE_AMAP_KEY)
const AMAP_SECURITY_CODE = ref(import.meta.env.VITE_AMAP_SECURITY_CODE)
// REST API 配置（用于搜索和逆地理编码，无需域名白名单）
const AMAP_WEB_SERVICE_KEY = ref('')

/** 从后端加载高德地图配置，覆盖 .env 默认值 */
async function loadAmapConfig() {
  try {
    const [keyRes, securityRes, webKeyRes] = await Promise.all([
      getConfigKey('sys.amap.jsKey'),
      getConfigKey('sys.amap.securityJsCode'),
      getConfigKey('sys.amap.webServiceKey')
    ])
    if (keyRes.data) AMAP_KEY.value = keyRes.data
    if (securityRes.data) AMAP_SECURITY_CODE.value = securityRes.data
    if (webKeyRes.data) AMAP_WEB_SERVICE_KEY.value = webKeyRes.data
  } catch (e) {
    console.warn('获取高德地图配置失败，使用默认配置', e)
  }
}

async function initMap() {
  await loadAmapConfig()
  window._AMapSecurityConfig = {
    securityJsCode: AMAP_SECURITY_CODE.value
  }
  AMapLoader.load({
    key: AMAP_KEY.value,
    version: '2.0',
    securityJsCode: AMAP_SECURITY_CODE.value
  }).then((AMap) => {
    const center = (props.latitude && props.longitude)
      ? [parseFloat(props.longitude), parseFloat(props.latitude)]
      : [116.397428, 39.90923]

    map = new AMap.Map(mapContainer.value, {
      zoom: 15,
      center: center
    })

    if (props.latitude && props.longitude) {
      addMarker(center[0], center[1])
    }

    map.on('click', (e) => {
      const lng = e.lnglat.getLng()
      const lat = e.lnglat.getLat()
      addMarker(lng, lat)
      reverseGeocode(lat, lng)
    })
  }).catch((e) => {
    console.error('地图加载失败', e)
  })
}

function addMarker(lng, lat) {
  if (marker) {
    marker.setPosition([lng, lat])
  } else if (map) {
    marker = new AMap.Marker({
      position: [lng, lat],
      draggable: true
    })
    marker.on('dragend', (e) => {
      const pos = marker.getPosition()
      reverseGeocode(pos.lat, pos.lng)
    })
    map.add(marker)
  }
  selectedPoint.latitude = lat
  selectedPoint.longitude = lng
  map?.setCenter([lng, lat])
}

/**
 * 逆地理编码（REST API）
 * 调用 restapi.amap.com/v3/geocode/regeo，使用 webServiceKey 无需域名白名单
 */
async function reverseGeocode(lat, lng) {
  try {
    const key = AMAP_WEB_SERVICE_KEY.value
    const url = `https://restapi.amap.com/v3/geocode/regeo?location=${lng},${lat}&key=${key}&extensions=all&output=JSON`
    const resp = await fetch(url)
    const data = await resp.json()
    if (data?.regeocode) {
      selectedPoint.address = data.regeocode.formatted_address || ''
      selectedPoint.latitude = lat
      selectedPoint.longitude = lng
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
  if (!searchKeyword.value.trim()) {
    return
  }
  try {
    const key = AMAP_WEB_SERVICE_KEY.value
    const url = `https://restapi.amap.com/v3/place/text?keywords=${encodeURIComponent(searchKeyword.value)}&key=${key}&offset=10&page=1&extensions=base`
    const resp = await fetch(url)
    const data = await resp.json()
    if (data?.pois && data.pois.length > 0) {
      const poi = data.pois[0]
      const [lngStr, latStr] = poi.location.split(',')
      const lng = parseFloat(lngStr)
      const lat = parseFloat(latStr)
      addMarker(lng, lat)
      reverseGeocode(lat, lng)
    } else {
      console.warn('搜索无结果')
    }
  } catch (e) {
    console.warn('搜索失败', e)
  }
}

function handleConfirm() {
  emit('confirm', {
    latitude: selectedPoint.latitude,
    longitude: selectedPoint.longitude,
    address: selectedPoint.address
  })
  visible.value = false
}

function destroyMap() {
  if (map) {
    map.destroy()
    map = null
    marker = null
  }
}

function open() {
  visible.value = true
}

defineExpose({ open })
</script>

<style scoped>
.map-picker {
  width: 100%;
}

.map-search {
  margin-bottom: 12px;
}

.map-container {
  width: 100%;
  height: 400px;
  border-radius: 8px;
  overflow: hidden;
}

.map-info {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-top: 12px;
  padding: 8px 12px;
  background: var(--el-fill-color-lighter);
  border-radius: 6px;
  font-size: 13px;
  color: #606266;
}
</style>
