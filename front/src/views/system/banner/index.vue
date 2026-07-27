<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="标题" prop="title">
        <el-input v-model="queryParams.title" placeholder="请输入标题" clearable style="width: 200px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="轮播图状态" clearable style="width: 200px">
          <el-option v-for="dict in sys_normal_disable" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['system:banner:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="Edit" :disabled="single" @click="handleUpdate" v-hasPermi="['system:banner:edit']">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete" v-hasPermi="['system:banner:remove']">删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="bannerList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="bannerId" min-width="80" />
      <el-table-column label="图片" align="center" prop="image" min-width="120">
        <template #default="scope">
          <image-preview :src="scope.row.image" :width="80" :height="34" />
        </template>
      </el-table-column>
      <el-table-column label="标题" align="center" prop="title" :show-overflow-tooltip="true" />
      <el-table-column label="跳转链接" align="center" prop="linkUrl" :show-overflow-tooltip="true" />
      <el-table-column label="排序" align="center" prop="sortOrder" min-width="80" />
      <el-table-column label="状态" align="center" prop="status" min-width="100">
        <template #default="scope">
          <el-switch v-model="scope.row.status" :active-value="'0'" :inactive-value="'1'" @change="handleStatusChange(scope.row)" />
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" min-width="100">
        <template #default="scope">
          <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['system:banner:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['system:banner:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="600px" append-to-body>
      <el-form ref="bannerRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入标题" />
        </el-form-item>
        <el-form-item label="图片" prop="image">
          <div class="banner-upload">
            <div class="banner-preview" v-if="form.image" @click="openCropDialog">
              <img :src="getImageUrl(form.image)" class="banner-thumb" />
              <div class="banner-preview-overlay">点击重新裁剪</div>
            </div>
            <el-button v-else @click="openCropDialog" type="primary" plain icon="Plus">选择图片</el-button>
          </div>
        </el-form-item>
        <el-form-item label="跳转链接" prop="linkUrl">
          <el-input v-model="form.linkUrl" placeholder="请输入跳转链接（可选）" />
        </el-form-item>
        <el-form-item label="排序号" prop="sortOrder">
          <el-input-number v-model="form.sortOrder" :min="0" :max="999" controls-position="right" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio v-for="dict in sys_normal_disable" :key="dict.value" :value="dict.value">{{ dict.label }}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <el-dialog title="裁剪轮播图" v-model="cropOpen" width="700px" append-to-body @opened="onCropOpened" @close="onCropClose">
      <div style="height: 400px">
        <vue-cropper
          ref="cropperRef"
          :img="cropOptions.img"
          :info="true"
          :autoCrop="true"
          :autoCropWidth="630"
          :autoCropHeight="270"
          :fixed="true"
          :fixedNumber="[21, 9]"
          :fixedBox="false"
          :outputType="'jpeg'"
          :full="false"
          v-if="cropVisible && cropOptions.img"
        />
        <div v-else-if="cropVisible && !cropOptions.img" class="crop-placeholder">
          <el-icon :size="48" color="#c0c4cc"><Plus /></el-icon>
          <p>请点击下方"选择图片"按钮选取本地图片</p>
        </div>
      </div>
      <br />
      <el-row :gutter="10">
        <el-col :span="4">
          <el-upload action="#" :http-request="() => {}" :show-file-list="false" :before-upload="beforeCropUpload">
            <el-button>选择图片</el-button>
          </el-upload>
        </el-col>
        <el-col :span="2"><el-button icon="Plus" @click="changeCropScale(1)" /></el-col>
        <el-col :span="2"><el-button icon="Minus" @click="changeCropScale(-1)" /></el-col>
        <el-col :span="2"><el-button icon="RefreshLeft" @click="rotateCropLeft" /></el-col>
        <el-col :span="2"><el-button icon="RefreshRight" @click="rotateCropRight" /></el-col>
        <el-col :span="4" :offset="4">
          <el-button type="primary" @click="confirmCrop" :loading="cropUploading">确认上传</el-button>
        </el-col>
      </el-row>
    </el-dialog>
  </div>
</template>

<script setup>
import { listBanner, getBanner, addBanner, updateBanner, delBanner } from "@/api/system/banner"
import "vue-cropper/dist/index.css"
import { VueCropper } from "vue-cropper"
import request from '@/utils/request'

const { proxy } = getCurrentInstance()
const { sys_normal_disable } = useDict("sys_normal_disable")

const bannerList = ref([])
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const title = ref("")

const data = reactive({
  form: {},
  queryParams: { pageNum: 1, pageSize: 10, title: undefined, status: undefined },
  rules: {
    image: [{ required: true, message: "图片不能为空", trigger: "change" }]
  }
})
const { queryParams, form, rules } = toRefs(data)

const cropperRef = ref(null)
const cropOpen = ref(false)
const cropVisible = ref(false)
const cropUploading = ref(false)
const cropOptions = reactive({
  img: '',
  previews: {},
  filename: ''
})

function getImageUrl(url) {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return import.meta.env.VITE_APP_BASE_API + url
}

function openCropDialog() {
  cropOpen.value = true
}

function onCropOpened() {
  cropVisible.value = true
}

function onCropClose() {
  cropVisible.value = false
  cropOptions.img = ''
  cropOptions.previews = {}
}

function beforeCropUpload(file) {
  if (file.type.indexOf('image/') === -1) {
    proxy.$modal.msgError('请上传图片文件')
    return false
  }
  const reader = new FileReader()
  reader.readAsDataURL(file)
  reader.onload = () => {
    cropOptions.img = reader.result
    cropOptions.filename = file.name
  }
  return false
}

function changeCropScale(num) {
  cropperRef.value?.changeScale(num)
}

function rotateCropLeft() {
  cropperRef.value?.rotateLeft()
}

function rotateCropRight() {
  cropperRef.value?.rotateRight()
}

function confirmCrop() {
  if (!cropOptions.img) {
    proxy.$modal.msgError('请先选择图片')
    return
  }
  cropUploading.value = true
  cropperRef.value.getCropBlob(async (blob) => {
    const formData = new FormData()
    formData.append('file', blob, cropOptions.filename || 'banner.jpg')
    try {
      const res = await request({ url: '/common/upload', method: 'post', data: formData, headers: { 'Content-Type': 'multipart/form-data', 'repeatSubmit': false } })
      if (res.code === 200) {
        form.value.image = res.url
        cropOpen.value = false
        cropVisible.value = false
        proxy.$modal.msgSuccess('图片上传成功')
      } else {
        proxy.$modal.msgError(res.msg || '上传失败')
      }
    } catch (e) {
      proxy.$modal.msgError('上传失败')
    } finally {
      cropUploading.value = false
    }
  })
}

function getList() {
  loading.value = true
  listBanner(queryParams.value).then(response => {
    bannerList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

function cancel() {
  open.value = false
  reset()
}

function reset() {
  form.value = { bannerId: undefined, title: undefined, image: undefined, linkUrl: undefined, sortOrder: 0, status: "0", remark: undefined }
  proxy.resetForm("bannerRef")
}

function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

function resetQuery() {
  proxy.resetForm("queryRef")
  handleQuery()
}

function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.bannerId)
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function handleStatusChange(row) {
  let text = row.status === "0" ? "启用" : "停用"
  proxy.$modal.confirm('确认"' + text + '"该轮播图？').then(() => {
    return updateBanner({ bannerId: row.bannerId, status: row.status })
  }).then(() => {
    proxy.$modal.msgSuccess(text + "成功")
  }).catch(() => {
    row.status = row.status === "0" ? "1" : "0"
  })
}

function handleAdd() {
  reset()
  open.value = true
  title.value = "新增轮播图"
}

function handleUpdate(row) {
  reset()
  const bannerId = row.bannerId || ids.value
  getBanner(bannerId).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改轮播图"
  })
}

function submitForm() {
  proxy.$refs["bannerRef"].validate(valid => {
    if (valid) {
      if (form.value.bannerId != undefined) {
        updateBanner(form.value).then(() => {
          proxy.$modal.msgSuccess("修改成功")
          open.value = false
          getList()
        })
      } else {
        addBanner(form.value).then(() => {
          proxy.$modal.msgSuccess("新增成功")
          open.value = false
          getList()
        })
      }
    }
  })
}

function handleDelete(row) {
  const bannerIds = row.bannerId || ids.value
  proxy.$modal.confirm('是否确认删除轮播图编号为"' + bannerIds + '"的数据项？').then(() => {
    return delBanner(bannerIds)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

getList()
</script>

<style scoped lang="scss">
.banner-upload {
  display: flex;
  align-items: center;
}

.banner-preview {
  position: relative;
  width: 315px;
  height: 135px;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  border: 1px solid #e5e6eb;

  &:hover .banner-preview-overlay {
    opacity: 1;
  }
}

.banner-thumb {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.banner-preview-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 14px;
  opacity: 0;
  transition: opacity 0.2s;
}

.crop-placeholder {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: var(--el-fill-color-lighter);
  border-radius: 8px;
  border: 1px dashed #dcdfe6;
  color: #909399;
  font-size: 14px;
}
</style>
