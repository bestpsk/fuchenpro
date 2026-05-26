/**
 * @description 图标加载器 - 扫描SVG图标目录并导出图标名列表
 * @description 使用import.meta.glob动态扫描assets/icons/svg目录下所有SVG文件，
 * 提取文件名作为图标名称列表，供图标选择器使用
 */
let icons = []
const modules = import.meta.glob('./../../assets/icons/svg/*.svg')
for (const path in modules) {
  const p = path.split('assets/icons/svg/')[1].split('.svg')[0]
  icons.push(p)
}

export default icons
