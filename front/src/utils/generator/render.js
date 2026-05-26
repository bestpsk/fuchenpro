/**
 * @description 渲染器 - 表单设计器运行时组件渲染
 * @description 使用Vue3的render函数动态渲染表单设计器中的组件，
 * 根据组件配置自动生成对应的Element Plus组件VNode，处理属性映射、子组件和插槽
 */
import { defineComponent, h } from 'vue'
import { makeMap } from '@/utils/index'

/** HTML合法属性名集合，用于区分组件props和DOM属性 */
const isAttr = makeMap(
  'accept,accept-charset,accesskey,action,align,alt,async,autocomplete,' +
  'autofocus,autoplay,autosave,bgcolor,border,buffered,challenge,charset,' +
  'checked,cite,class,code,codebase,color,cols,colspan,content,http-equiv,' +
  'name,contenteditable,contextmenu,controls,coords,data,datetime,default,' +
  'defer,dir,dirname,disabled,download,draggable,dropzone,enctype,method,for,' +
  'form,formaction,headers,height,hidden,high,href,hreflang,http-equiv,' +
  'icon,id,ismap,itemprop,keytype,kind,label,lang,language,list,loop,low,' +
  'manifest,max,maxlength,media,method,GET,POST,min,multiple,email,file,' +
  'muted,name,novalidate,open,optimum,pattern,ping,placeholder,poster,' +
  'preload,radiogroup,readonly,rel,required,reversed,rows,rowspan,sandbox,' +
  'scope,scoped,seamless,selected,shape,size,type,text,password,sizes,span,' +
  'spellcheck,src,srcdoc,srclang,srcset,start,step,style,summary,tabindex,' +
  'target,title,type,usemap,value,width,wrap' + 'prefix-icon'
)
/** 不应作为props传递的配置字段 */
const isNotProps = makeMap(
  'layout,prepend,regList,tag,document,changeTag,defaultValue'
)

/** 构建组件的v-model双向绑定 */
function useVModel(props, emit) {
  return {
    modelValue: props.defaultValue,
    'onUpdate:modelValue': (val) => emit('update:modelValue', val),
  }
}

/** 各组件的子内容生成器（如选项、按钮文字等） */
const componentChild = {
  'el-button': {
    default(h, conf, key) {
      return conf[key]
    },
  },
  'el-select': {
    options(h, conf, key) {
      return conf.options.map(item => h(resolveComponent('el-option'), {
        label: item.label,
        value: item.value,
      }))
    }
  },
  'el-radio-group': {
    options(h, conf, key) {
      return conf.optionType === 'button' ? conf.options.map(item => h(resolveComponent('el-checkbox-button'), {
        label: item.value,
      }, () => item.label)) : conf.options.map(item => h(resolveComponent('el-radio'), {
        label: item.value,
        border: conf.border,
      }, () => item.label))
    }
  },
  'el-checkbox-group': {
    options(h, conf, key) {
      return conf.optionType === 'button' ? conf.options.map(item => h(resolveComponent('el-checkbox-button'), {
        label: item.value,
      }, () => item.label)) : conf.options.map(item => h(resolveComponent('el-checkbox'), {
        label: item.value,
        border: conf.border,
      }, () => item.label))
    }
  },
  'el-upload': {
    'list-type': (h, conf, key) => {
      const option = {}
      if (conf['list-type'] === 'picture-card') {
        return h(resolveComponent('el-icon'), option, () => h(resolveComponent('Plus')))
      } else {
        option.type = "primary"
        option.icon = "Upload"
        return h(resolveComponent('el-button'), option, () => conf.buttonText)
      }
    },

  }
}

/** 各组件的插槽内容生成器 */
const componentSlot = {
  'el-upload': {
    'tip': (h, conf, key) => {
      if (conf.showTip) {
        return () => h('div', {
          class: "el-upload__tip"
        }, '只能上传不超过' + conf.fileSize + conf.sizeUnit + '的' + conf.accept + '文件')
      }
    },
  }
}
export default defineComponent({

  /** 使用render函数动态渲染组件，根据conf配置生成对应的Element Plus组件 */
  render() {
    const dataObject = {
      attrs: {},
      props: {},
      on: {},
      style: {}
    }
    const confClone = JSON.parse(JSON.stringify(this.conf))
    const children = []
    const slot = {}
    const childObjs = componentChild[confClone.tag]
    if (childObjs) {
      Object.keys(childObjs).forEach(key => {
        const childFunc = childObjs[key]
        if (confClone[key]) {
          children.push(childFunc(h, confClone, key))
        }
      })
    }
    const slotObjs = componentSlot[confClone.tag]
    if (slotObjs) {
      Object.keys(slotObjs).forEach(key => {
        const childFunc = slotObjs[key]
        if (confClone[key]) {
          slot[key] = childFunc(h, confClone, key)
        }
      })
    }
    /** 将组件配置中的属性分类到attrs/props中 */
    Object.keys(confClone).forEach(key => {
      const val = confClone[key]
      if (dataObject[key]) {
        dataObject[key] = val
      } else if (isAttr(key)) {
        dataObject.attrs[key] = val
      } else if (!isNotProps(key)) {
        dataObject.props[key] = val
      }
    })
    if(children.length > 0){
      slot.default = () => children
    }
    
    return h(resolveComponent(this.conf.tag),
      {
        modelValue: this.$attrs.modelValue,
        ...dataObject.props,
        ...dataObject.attrs,
        style: {
          ...dataObject.style
        },
      }
      , slot ?? null)
  },
  props: {
    /** 组件配置对象，包含标签类型、属性、选项等 */
    conf: {
      type: Object,
      required: true,
    },
  }
})
