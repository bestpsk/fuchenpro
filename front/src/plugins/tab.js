/**
 * @description 标签页操作插件 - 页签刷新/关闭/打开管理
 * @description 提供标签页的刷新、关闭（当前/指定/全部/左侧/右侧/其他）、
 * 打开新页签、更新页签等操作，与TagsView Store联动
 */
import useTagsViewStore from '@/store/modules/tagsView'
import router from '@/router'

export default {
  /** 刷新当前tab页签，通过重定向路由实现组件重新加载 */
  refreshPage(obj) {
    const { path, query, matched } = router.currentRoute.value
    if (path.startsWith('/redirect/')) {
      return Promise.resolve()
    }
    if (obj === undefined) {
      matched.forEach((m) => {
        if (m.components && m.components.default && m.components.default.name) {
          if (!['Layout', 'ParentView'].includes(m.components.default.name)) {
            obj = { name: m.components.default.name, path: path, query: query }
          }
        }
      })
    }
    return useTagsViewStore().delCachedView(obj).then(() => {
      const { path, query } = obj
      router.replace({
        path: '/redirect' + path,
        query: query
      })
    })
  },
  /** 关闭当前tab页签并跳转到新页面 */
  closeOpenPage(obj) {
    useTagsViewStore().delView(router.currentRoute.value)
    if (obj !== undefined) {
      return router.push(obj)
    }
  },
  /** 关闭指定tab页签，无指定时关闭当前页签并跳转到最近访问的页签 */
  closePage(obj) {
    if (obj === undefined) {
      return useTagsViewStore().delView(router.currentRoute.value).then(({ visitedViews }) => {
        const latestView = visitedViews.slice(-1)[0]
        if (latestView) {
          return router.push(latestView.fullPath)
        }
        return router.push('/')
      })
    }
    return useTagsViewStore().delView(obj)
  },
  /** 关闭所有tab页签 */
  closeAllPage() {
    return useTagsViewStore().delAllViews()
  },
  /** 关闭当前页签左侧的所有页签 */
  closeLeftPage(obj) {
    return useTagsViewStore().delLeftTags(obj || router.currentRoute.value)
  },
  /** 关闭当前页签右侧的所有页签 */
  closeRightPage(obj) {
    return useTagsViewStore().delRightTags(obj || router.currentRoute.value)
  },
  /** 关闭除当前页签外的其他所有页签 */
  closeOtherPage(obj) {
    return useTagsViewStore().delOthersViews(obj || router.currentRoute.value)
  },
  /** 打开新tab页签并跳转，可指定标题、路径和查询参数 */
  openPage(title, url, params) {
    const obj = { path: url, meta: { title: title } }
    useTagsViewStore().addView(obj)
    return router.push({ path: url, query: params })
  },
  /** 更新指定tab页签的信息（如标题等） */
  updatePage(obj) {
    return useTagsViewStore().updateVisitedView(obj)
  }
}
