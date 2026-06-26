<template>
  <view class="form-container">
    <view class="form-section">
      <view class="form-field">
        <view class="field-label"><text class="required">*</text> 品名</view>
        <view class="field-input-box">
          <input class="field-input" type="text" v-model="form.productName" placeholder="请输入品名" placeholder-class="field-placeholder" @input="onProductNameInput" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-label">货品编码</view>
        <view class="field-input-box">
          <input class="field-input" type="text" v-model="form.productCode" placeholder="自动生成拼音首字母" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-label">供货商</view>
        <view class="field-input-box picker-field" @click="showSupplierPicker = true">
          <input class="field-input" :value="form.supplierName" placeholder="请选择供货商" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
          <u-icon name="arrow-right" size="14" color="#C9CDD4"></u-icon>
        </view>
      </view>

      <view class="form-field">
        <view class="field-label">类别</view>
        <view class="field-input-box">
          <input class="field-input" type="text" v-model="form.category" placeholder="请输入类别" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-row">
        <view class="form-field half">
          <view class="field-label"><text class="required">*</text> 单位(整)</view>
          <view class="field-input-box">
            <input class="field-input" type="text" v-model="form.unit" placeholder="请输入单位" placeholder-class="field-placeholder" />
          </view>
        </view>
        <view class="form-field half">
          <view class="field-label">规格(拆)</view>
          <view class="field-input-box">
            <input class="field-input" type="text" v-model="form.spec" placeholder="请输入规格" placeholder-class="field-placeholder" />
          </view>
        </view>
      </view>

      <view class="form-field">
        <view class="field-label">包装数量</view>
        <view class="field-input-box">
          <input class="field-input" type="digit" v-model="form.packQty" placeholder="用于换算" placeholder-class="field-placeholder" @input="calcSplitPrice" />
        </view>
      </view>

      <view class="form-row">
        <view class="form-field half">
          <view class="field-label">进货价</view>
          <view class="field-input-box">
            <input class="field-input" type="digit" v-model="form.purchasePrice" placeholder="请输入进货价" placeholder-class="field-placeholder" @input="onPurchasePriceInput" />
          </view>
        </view>
        <view class="form-field half">
          <view class="field-label">出货价(整)</view>
          <view class="field-input-box">
            <input class="field-input" type="digit" v-model="form.sellingPrice" placeholder="请输入出货价" placeholder-class="field-placeholder" @input="calcSplitPrice" />
          </view>
        </view>
      </view>

      <view class="form-field">
        <view class="field-label">出货价(拆)</view>
        <view class="field-input-box">
          <input class="field-input" type="digit" :value="form.splitPrice" placeholder="自动计算" placeholder-class="field-placeholder" disabled :disabledColor="'transparent'" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-label">预警数量</view>
        <view class="field-input-box">
          <input class="field-input" type="digit" v-model="form.warnQty" placeholder="请输入预警数量" placeholder-class="field-placeholder" />
        </view>
      </view>

      <view class="form-field">
        <view class="field-label">状态</view>
        <view class="field-input-box radio-field">
          <view class="radio-group">
            <view class="radio-item" :class="{ active: form.status === '0' }" @click="form.status = '0'">
              <view class="radio-dot"></view>
              <text>正常</text>
            </view>
            <view class="radio-item" :class="{ active: form.status === '1' }" @click="form.status = '1'">
              <view class="radio-dot"></view>
              <text>停用</text>
            </view>
          </view>
        </view>
      </view>

      <view class="form-field">
        <view class="field-label">备注</view>
        <view class="field-textarea-box">
          <textarea class="field-textarea" v-model="form.remark" placeholder="请输入备注信息" placeholder-class="field-placeholder" :maxlength="500" auto-height></textarea>
        </view>
      </view>
    </view>

    <u-popup :show="showSupplierPicker" mode="bottom" round="16" @close="showSupplierPicker = false">
      <view class="picker-content">
        <view class="picker-header">
          <text class="picker-title">选择供货商</text>
          <view class="picker-close" @click="showSupplierPicker = false">
            <u-icon name="close" size="18" color="#86909C"></u-icon>
          </view>
        </view>
        <view class="picker-search">
          <view class="picker-search-box">
            <u-icon name="search" size="14" color="#86909C"></u-icon>
            <input class="picker-search-input" type="text" v-model="supplierKeyword" placeholder="搜索供货商" placeholder-class="search-placeholder" @input="onSupplierSearch" />
          </view>
        </view>
        <scroll-view scroll-y class="picker-list">
          <view v-for="item in supplierList" :key="item.supplierId" class="picker-item" :class="{ active: form.supplierId === item.supplierId }" @click="selectSupplier(item)">
            <text class="picker-item-name">{{ item.supplierName }}</text>
            <u-icon v-if="form.supplierId === item.supplierId" name="checkmark" size="16" color="#3D6DF7"></u-icon>
          </view>
          <u-empty v-if="supplierList.length === 0 && !supplierLoading" mode="search" text="未找到供货商" :marginTop="40"></u-empty>
        </scroll-view>
      </view>
    </u-popup>

    <view class="form-actions">
      <u-button type="info" plain text="取消" @click="goBack"></u-button>
      <u-button type="primary" text="保存" :loading="submitting" @click="submitForm"></u-button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getProduct, addProduct, updateProduct } from '@/api/wms/product'
import { searchSupplier } from '@/api/wms/supplier'

const submitting = ref(false)
const mode = ref('add')
const productId = ref(null)
const showSupplierPicker = ref(false)
const supplierKeyword = ref('')
const supplierList = ref([])
const supplierLoading = ref(false)

let supplierSearchTimer = null

const form = reactive({
  productId: undefined,
  productName: '',
  productCode: '',
  supplierId: null,
  supplierName: '',
  category: '',
  unit: '',
  spec: '',
  packQty: '',
  purchasePrice: '',
  sellingPrice: '',
  splitPrice: '',
  warnQty: '',
  status: '0',
  remark: ''
})

function getPinyinInitials(str) {
  if (!str) return ''
  const pinyinMap = {
    '阿':'A','哎':'A','安':'A','暗':'A','奥':'A',
    '八':'B','巴':'B','百':'B','白':'B','办':'B','包':'B','北':'B','本':'B','比':'B','边':'B','表':'B','别':'B','冰':'B','波':'B','不':'B','布':'B',
    '才':'C','采':'C','参':'C','餐':'C','草':'C','策':'C','层':'C','茶':'C','差':'C','产':'C','长':'C','常':'C','厂':'C','超':'C','车':'C','陈':'C','成':'C','城':'C','程':'C','吃':'C','持':'C','充':'C','出':'C','初':'C','除':'C','楚':'C','处':'C','穿':'C','传':'C','创':'C','窗':'C','床':'C','春':'C','词':'C','次':'C','从':'C','村':'C','存':'C','错':'C',
    '达':'D','大':'D','代':'D','带':'D','单':'D','当':'D','党':'D','到':'D','道':'D','得':'D','的':'D','灯':'D','等':'D','低':'D','地':'D','点':'D','电':'D','店':'D','掉':'D','调':'D','定':'D','东':'D','冬':'D','动':'D','都':'D','斗':'D','读':'D','度':'D','短':'D','段':'D','断':'D','队':'D','对':'D','多':'D',
    '额':'E','恩':'E','儿':'E','而':'E','耳':'E','二':'E',
    '发':'F','法':'F','翻':'F','凡':'F','反':'F','范':'F','方':'F','房':'F','防':'F','放':'F','飞':'F','非':'F','分':'F','丰':'F','风':'F','封':'F','峰':'F','服':'F','福':'F','府':'F','复':'F','副':'F','富':'F',
    '该':'G','改':'G','干':'G','感':'G','刚':'G','钢':'G','高':'G','搞':'G','告':'G','歌':'G','革':'G','格':'G','个':'G','各':'G','给':'G','根':'G','更':'G','工':'G','公':'G','功':'G','攻':'G','供':'G','共':'G','够':'G','构':'G','估':'G','古':'G','谷':'G','股':'G','固':'G','故':'G','顾':'G','瓜':'G','挂':'G','关':'G','观':'G','馆':'G','管':'G','光':'G','广':'G','归':'G','规':'G','国':'G','果':'G','过':'G',
    '哈':'H','海':'H','含':'H','寒':'H','汉':'H','行':'H','航':'H','好':'H','号':'H','合':'H','何':'H','和':'H','河':'H','核':'H','贺':'H','黑':'H','很':'H','红':'H','后':'H','厚':'H','候':'H','湖':'H','互':'H','户':'H','花':'H','华':'H','化':'H','画':'H','话':'H','怀':'H','坏':'H','欢':'H','还':'H','环':'H','换':'H','黄':'H','回':'H','会':'H','婚':'H','活':'H','火':'H','货':'H','获':'H',
    '机':'J','击':'J','鸡':'J','积':'J','基':'J','及':'J','吉':'J','极':'J','集':'J','急':'J','几':'J','己':'J','计':'J','记':'J','技':'J','际':'J','季':'J','继':'J','寄':'J','加':'J','家':'J','嘉':'J','假':'J','价':'J','架':'J','嫁':'J','坚':'J','间':'J','肩':'J','艰':'J','兼':'J','监':'J','检':'J','减':'J','简':'J','见':'J','件':'J','建':'J','剑':'J','健':'J','渐':'J','江':'J','姜':'J','将':'J','奖':'J','讲':'J','降':'J','交':'J','郊':'J','浇':'J','胶':'J','教':'J','角':'J','脚':'J','叫':'J','较':'J','接':'J','街':'J','节':'J','杰':'J','结':'J','截':'J','姐':'J','解':'J','介':'J','界':'J','届':'J','今':'J','金':'J','津':'J','紧':'J','仅':'J','尽':'J','近':'J','进':'J','京':'J','经':'J','精':'J','井':'J','景':'J','警':'J','净':'J','竞':'J','敬':'J','境':'J','静':'J','纠':'J','究':'J','九':'J','久':'J','酒':'J','旧':'J','救':'J','就':'J','居':'J','局':'J','举':'J','巨':'J','具':'J','距':'J','拒':'J','据':'J','聚':'J','卷':'J','决':'J','绝':'J','觉':'J','军':'J','均':'J','君':'J',
    '开':'K','凯':'K','看':'K','康':'K','扛':'K','考':'K','科':'K','棵':'K','颗':'K','壳':'K','可':'K','克':'K','客':'K','课':'K','肯':'K','空':'K','孔':'K','控':'K','口':'K','扣':'K','苦':'K','库':'K','裤':'K','酷':'K','快':'K','块':'K','宽':'K','款':'K','狂':'K','况':'K','矿':'K','亏':'K','困':'K','扩':'K','括':'K',
    '拉':'L','来':'L','蓝':'L','拦':'L','栏':'L','劳':'L','老':'L','乐':'L','了':'L','雷':'L','类':'L','累':'L','冷':'L','离':'L','梨':'L','理':'L','力':'L','历':'L','立':'L','丽':'L','利':'L','例':'L','粒':'L','连':'L','联':'L','廉':'L','脸':'L','练':'L','炼':'L','恋':'L','链':'L','良':'L','凉':'L','粮':'L','两':'L','亮':'L','量':'L','聊':'L','疗':'L','料':'L','列':'L','裂':'L','林':'L','临':'L','灵':'L','铃':'L','零':'L','领':'L','令':'L','另':'L','溜':'L','流':'L','留':'L','六':'L','龙':'L','楼':'L','漏':'L','露':'L','炉':'L','路':'L','录':'L','旅':'L','铝':'L','绿':'L','律':'L','率':'L','乱':'L','略':'L','轮':'L','论':'L','落':'L',
    '妈':'M','麻':'M','马':'M','码':'M','骂':'M','吗':'M','买':'M','卖':'M','麦':'M','满':'M','慢':'M','忙':'M','猫':'M','毛':'M','矛':'M','茅':'M','冒':'M','帽':'M','貌':'M','没':'M','梅':'M','媒':'M','煤':'M','每':'M','美':'M','门':'M','们':'M','蒙':'M','猛':'M','梦':'M','米':'M','密':'M','棉':'M','免':'M','面':'M','苗':'M','描':'M','秒':'M','庙':'M','民':'M','名':'M','明':'M','命':'M','摸':'M','模':'M','膜':'M','磨':'M','魔':'M','末':'M','莫':'M','墨':'M','默':'M','谋':'M','某':'M','母':'M','木':'M','目':'M','牧':'M','幕':'M','墓':'M','慕':'M','暮':'M',
    '拿':'N','哪':'N','那':'N','纳':'N','乃':'N','奶':'N','耐':'N','男':'N','南':'N','难':'N','内':'N','能':'N','尼':'N','泥':'N','你':'N','逆':'N','年':'N','念':'N','娘':'N','酿':'N','鸟':'N','尿':'N','捏':'N','您':'N','宁':'N','凝':'N','牛':'N','农':'N','浓':'N','弄':'N','奴':'N','努':'N','女':'N','暖':'N','诺':'N',
    '哦':'O','欧':'O','偶':'O',
    '啪':'P','爬':'P','怕':'P','拍':'P','排':'P','牌':'P','派':'P','攀':'P','盘':'P','判':'P','盼':'P','叛':'P','胖':'P','旁':'P','抛':'P','跑':'P','泡':'P','炮':'P','袍':'P','陪':'P','配':'P','佩':'P','盆':'P','喷':'P','朋':'P','棚':'P','碰':'P','批':'P','皮':'P','疲':'P','脾':'P','片':'P','偏':'P','篇':'P','骗':'P','漂':'P','飘':'P','票':'P','拼':'P','贫':'P','品':'P','平':'P','评':'P','凭':'P','瓶':'P','坡':'P','泼':'P','破':'P','迫':'P','扑':'P','铺':'P','朴':'P','普':'P','谱':'P',
    '七':'Q','妻':'Q','期':'Q','欺':'Q','齐':'Q','奇':'Q','骑':'Q','棋':'Q','旗':'Q','企':'Q','起':'Q','启':'Q','气':'Q','弃':'Q','汽':'Q','器':'Q','恰':'Q','千':'Q','迁':'Q','牵':'Q','铅':'Q','前':'Q','钱':'Q','潜':'Q','浅':'Q','欠':'Q','枪':'Q','强':'Q','墙':'Q','抢':'Q','悄':'Q','桥':'Q','巧':'Q','切':'Q','茄':'Q','且':'Q','亲':'Q','青':'Q','轻':'Q','氢':'Q','清':'Q','情':'Q','晴':'Q','请':'Q','庆':'Q','穷':'Q','秋':'Q','球':'Q','求':'Q','区':'Q','曲':'Q','驱':'Q','趋':'Q','取':'Q','去':'Q','趣':'Q','圈':'Q','全':'Q','权':'Q','泉':'Q','拳':'Q','犬':'Q','劝':'Q','缺':'Q','却':'Q','确':'Q','雀':'Q','裙':'Q','群':'Q',
    '然':'R','燃':'R','染':'R','嚷':'R','让':'R','绕':'R','惹':'R','人':'R','仁':'R','忍':'R','认':'R','任':'R','扔':'R','仍':'R','日':'R','荣':'R','容':'R','融':'R','熔':'R','柔':'R','肉':'R','如':'R','入':'R','软':'R','瑞':'R','润':'R','弱':'R',
    '撒':'S','洒':'S','赛':'S','三':'S','伞':'S','散':'S','桑':'S','嗓':'S','丧':'S','扫':'S','色':'S','森':'S','杀':'S','沙':'S','纱':'S','傻':'S','晒':'S','山':'S','删':'S','闪':'S','善':'S','伤':'S','商':'S','上':'S','尚':'S','烧':'S','稍':'S','少':'S','哨':'S','舌':'S','蛇':'S','舍':'S','社':'S','设':'S','射':'S','涉':'S','摄':'S','申':'S','伸':'S','身':'S','深':'S','神':'S','审':'S','甚':'S','渗':'S','慎':'S','升':'S','生':'S','声':'S','牲':'S','绳':'S','省':'S','圣':'S','胜':'S','盛':'S','剩':'S','尸':'S','失':'S','师':'S','诗':'S','施':'S','湿':'S','十':'S','石':'S','时':'S','识':'S','实':'S','拾':'S','食':'S','史':'S','使':'S','始':'S','驶':'S','士':'S','氏':'S','世':'S','市':'S','示':'S','式':'S','事':'S','势':'S','是':'S','适':'S','室':'S','释':'S','试':'S','视':'S','收':'S','手':'S','守':'S','首':'S','寿':'S','受':'S','瘦':'S','书':'S','叔':'S','殊':'S','梳':'S','舒':'S','疏':'S','输':'S','蔬':'S','熟':'S','暑':'S','鼠':'S','属':'S','术':'S','树':'S','数':'S','刷':'S','摔':'S','甩':'S','帅':'S','双':'S','水':'S','税':'S','睡':'S','顺':'S','说':'S','丝':'S','司':'S','私':'S','思':'S','死':'S','四':'S','寺':'S','似':'S','饲':'S','松':'S','宋':'S','送':'S','颂':'S','诵':'S','搜':'S','苏':'S','俗':'S','素':'S','速':'S','宿':'S','诉':'S','肃':'S','酸':'S','蒜':'S','算':'S','虽':'S','随':'S','岁':'S','碎':'S','穗':'S','孙':'S','损':'S','缩':'S','所':'S','索':'S','锁':'S',
    '他':'T','它':'T','她':'T','塔':'T','踏':'T','台':'T','抬':'T','太':'T','态':'T','泰':'T','贪':'T','摊':'T','滩':'T','谈':'T','坦':'T','叹':'T','炭':'T','探':'T','弹':'T','汤':'T','唐':'T','塘':'T','糖':'T','堂':'T','逃':'T','桃':'T','陶':'T','淘':'T','讨':'T','套':'T','特':'T','疼':'T','腾':'T','踢':'T','提':'T','题':'T','体':'T','替':'T','天':'T','田':'T','甜':'T','填':'T','条':'T','挑':'T','跳':'T','铁':'T','厅':'T','听':'T','亭':'T','庭':'T','停':'T','挺':'T','通':'T','同':'T','铜':'T','童':'T','统':'T','痛':'T','偷':'T','头':'T','投':'T','透':'T','突':'T','图':'T','途':'T','土':'T','吐':'T','团':'T','推':'T','退':'T','吞':'T','托':'T','拖':'T','脱':'T','驼':'T','妥':'T',
    '挖':'W','蛙':'W','娃':'W','瓦':'W','袜':'W','歪':'W','外':'W','弯':'W','湾':'W','丸':'W','完':'W','玩':'W','顽':'W','挽':'W','晚':'W','碗':'W','万':'W','汪':'W','王':'W','网':'W','往':'W','忘':'W','望':'W','危':'W','威':'W','微':'W','为':'W','围':'W','违':'W','唯':'W','维':'W','伟':'W','尾':'W','委':'W','卫':'W','未':'W','位':'W','味':'W','胃':'W','谓':'W','喂':'W','慰':'W','温':'W','文':'W','纹':'W','闻':'W','稳':'W','问':'W','翁':'W','窝':'W','我':'W','握':'W','乌':'W','污':'W','屋':'W','无':'W','吴':'W','五':'W','午':'W','伍':'W','武':'W','舞':'W','务':'W','物':'W','误':'W','悟':'W',
    '夕':'X','西':'X','吸':'X','希':'X','息':'X','悉':'X','牺':'X','惜':'X','溪':'X','膝':'X','习':'X','席':'X','袭':'X','喜':'X','洗':'X','系':'X','细':'X','戏':'X','瞎':'X','峡':'X','狭':'X','下':'X','夏':'X','吓':'X','先':'X','仙':'X','鲜':'X','纤':'X','咸':'X','贤':'X','闲':'X','弦':'X','嫌':'X','显':'X','险':'X','县':'X','现':'X','线':'X','限':'X','宪':'X','献':'X','陷':'X','羡':'X','乡':'X','相':'X','香':'X','箱':'X','详':'X','享':'X','响':'X','想':'X','向':'X','象':'X','像':'X','项':'X','消':'X','销':'X','小':'X','晓':'X','孝':'X','效':'X','笑':'X','些':'X','歇':'X','鞋':'X','协':'X','斜':'X','携':'X','写':'X','泄':'X','卸':'X','谢':'X','心':'X','辛':'X','欣':'X','新':'X','薪':'X','信':'X','星':'X','兴':'X','刑':'X','型':'X','形':'X','行':'X','醒':'X','幸':'X','性':'X','姓':'X','凶':'X','胸':'X','雄':'X','兄':'X','休':'X','修':'X','秀':'X','绣':'X','锈':'X','袖':'X','虚':'X','需':'X','许':'X','序':'X','叙':'X','续':'X','蓄':'X','畜':'X','悬':'X','旋':'X','选':'X','玄':'X','学':'X','雪':'X','血':'X','寻':'X','巡':'X','询':'X','循':'X','训':'X','讯':'X','迅':'X',
    '压':'Y','呀':'Y','鸭':'Y','牙':'Y','芽':'Y','雅':'Y','哑':'Y','亚':'Y','咽':'Y','烟':'Y','淹':'Y','盐':'Y','严':'Y','言':'Y','岩':'Y','沿':'Y','炎':'Y','研':'Y','眼':'Y','演':'Y','验':'Y','雁':'Y','燕':'Y','央':'Y','扬':'Y','羊':'Y','阳':'Y','杨':'Y','仰':'Y','养':'Y','样':'Y','邀':'Y','摇':'Y','遥':'Y','咬':'Y','药':'Y','要':'Y','钥':'Y','耀':'Y','爷':'Y','也':'Y','野':'Y','业':'Y','叶':'Y','页':'Y','夜':'Y','液':'Y','一':'Y','衣':'Y','医':'Y','依':'Y','仪':'Y','宜':'Y','姨':'Y','遗':'Y','疑':'Y','乙':'Y','已':'Y','以':'Y','椅':'Y','蚁':'Y','亿':'Y','义':'Y','艺':'Y','忆':'Y','议':'Y','译':'Y','异':'Y','易':'Y','役':'Y','疫':'Y','益':'Y','意':'Y','毅':'Y','因':'Y','音':'Y','阴':'Y','银':'Y','引':'Y','饮':'Y','隐':'Y','印':'Y','英':'Y','应':'Y','樱':'Y','鹰':'Y','迎':'Y','盈':'Y','营':'Y','赢':'Y','影':'Y','映':'Y','硬':'Y','拥':'Y','永':'Y','勇':'Y','涌':'Y','用':'Y','优':'Y','悠':'Y','忧':'Y','尤':'Y','由':'Y','油':'Y','游':'Y','友':'Y','有':'Y','又':'Y','右':'Y','幼':'Y','于':'Y','余':'Y','鱼':'Y','娱':'Y','渔':'Y','逾':'Y','愉':'Y','宇':'Y','羽':'Y','雨':'Y','语':'Y','玉':'Y','育':'Y','域':'Y','欲':'Y','遇':'Y','御':'Y','豫':'Y','誉':'Y','元':'Y','园':'Y','原':'Y','源':'Y','圆':'Y','援':'Y','缘':'Y','远':'Y','院':'Y','愿':'Y','约':'Y','月':'Y','阅':'Y','悦':'Y','跃':'Y','越':'Y','云':'Y','匀':'Y','允':'Y','运':'Y',
    '杂':'Z','砸':'Z','灾':'Z','栽':'Z','载':'Z','再':'Z','在':'Z','咱':'Z','赞':'Z','暂':'Z','脏':'Z','葬':'Z','遭':'Z','糟':'Z','早':'Z','澡':'Z','灶':'Z','造':'Z','噪':'Z','燥':'Z','则':'Z','择':'Z','责':'Z','贼':'Z','增':'Z','赠':'Z','扎':'Z','眨':'Z','炸':'Z','摘':'Z','窄':'Z','债':'Z','寨':'Z','沾':'Z','粘':'Z','展':'Z','占':'Z','战':'Z','站':'Z','张':'Z','章':'Z','掌':'Z','丈':'Z','仗':'Z','帐':'Z','账':'Z','障':'Z','招':'Z','朝':'Z','找':'Z','照':'Z','罩':'Z','折':'Z','哲':'Z','者':'Z','这':'Z','浙':'Z','针':'Z','珍':'Z','真':'Z','诊':'Z','枕':'Z','阵':'Z','振':'Z','镇':'Z','震':'Z','争':'Z','征':'Z','挣':'Z','睁':'Z','蒸':'Z','整':'Z','正':'Z','证':'Z','政':'Z','症':'Z','支':'Z','汁':'Z','知':'Z','织':'Z','脂':'Z','蜘':'Z','执':'Z','直':'Z','值':'Z','职':'Z','植':'Z','殖':'Z','止':'Z','只':'Z','旨':'Z','指':'Z','纸':'Z','至':'Z','志':'Z','制':'Z','质':'Z','治':'Z','致':'Z','智':'Z','置':'Z','中':'Z','忠':'Z','钟':'Z','终':'Z','种':'Z','众':'Z','重':'Z','周':'Z','洲':'Z','粥':'Z','轴':'Z','肘':'Z','皱':'Z','骤':'Z','珠':'Z','猪':'Z','竹':'Z','烛':'Z','主':'Z','煮':'Z','嘱':'Z','住':'Z','注':'Z','驻':'Z','助':'Z','筑':'Z','祝':'Z','著':'Z','柱':'Z','铸':'Z','住':'Z','抓':'Z','爪':'Z','拽':'Z','专':'Z','砖':'Z','转':'Z','赚':'Z','庄':'Z','装':'Z','壮':'Z','撞':'Z','状':'Z','追':'Z','准':'Z','捉':'Z','桌':'Z','着':'Z','资':'Z','姿':'Z','滋':'Z','子':'Z','紫':'Z','字':'Z','自':'Z','宗':'Z','综':'Z','总':'Z','纵':'Z','走':'Z','租':'Z','足':'Z','族':'Z','阻':'Z','组':'Z','祖':'Z','嘴':'Z','醉':'Z','最':'Z','罪':'Z','尊':'Z','遵':'Z','昨':'Z','左':'Z','作':'Z','坐':'Z','座':'Z','做':'Z'
  }
  let result = ''
  for (let i = 0; i < str.length; i++) {
    const ch = str.charAt(i)
    if (pinyinMap[ch]) {
      result += pinyinMap[ch]
    } else if (/[a-zA-Z]/.test(ch)) {
      result += ch.toUpperCase()
    } else if (/[0-9]/.test(ch)) {
      result += ch
    }
  }
  return result
}

function onProductNameInput() {
  if (mode.value === 'add') {
    form.productCode = getPinyinInitials(form.productName)
  }
}

function onPurchasePriceInput() {
  form.sellingPrice = form.purchasePrice
  calcSplitPrice()
}

function calcSplitPrice() {
  const price = parseFloat(form.sellingPrice)
  const qty = parseFloat(form.packQty)
  if (!isNaN(price) && !isNaN(qty) && qty > 0) {
    form.splitPrice = (price / qty).toFixed(2)
  } else {
    form.splitPrice = ''
  }
}

async function loadDetail() {
  if (!productId.value) return
  try {
    uni.showLoading({ title: '加载中...' })
    const response = await getProduct(productId.value)
    const data = response.data || response
    Object.assign(form, {
      productId: data.productId,
      productName: data.productName || '',
      productCode: data.productCode || '',
      supplierId: data.supplierId || null,
      supplierName: data.supplierName || '',
      category: data.category || '',
      unit: data.unit || '',
      spec: data.spec || '',
      packQty: data.packQty ?? '',
      purchasePrice: data.purchasePrice ?? '',
      sellingPrice: data.sellingPrice ?? '',
      splitPrice: data.splitPrice ?? '',
      warnQty: data.warnQty ?? '',
      status: data.status || '0',
      remark: data.remark || ''
    })
  } catch (e) {
    console.error('加载详情失败:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally { uni.hideLoading() }
}

async function searchSupplierList(keyword) {
  supplierLoading.value = true
  try {
    const response = await searchSupplier(keyword || '')
    const data = response.data || response
    supplierList.value = data.rows || data.items || (Array.isArray(data) ? data : [])
  } catch (e) {
    console.error('搜索供货商失败:', e)
    supplierList.value = []
  } finally { supplierLoading.value = false }
}

function onSupplierSearch() {
  if (supplierSearchTimer) clearTimeout(supplierSearchTimer)
  supplierSearchTimer = setTimeout(() => searchSupplierList(supplierKeyword.value), 500)
}

function selectSupplier(item) {
  form.supplierId = item.supplierId
  form.supplierName = item.supplierName
  showSupplierPicker.value = false
}

async function submitForm() {
  if (!form.productName.trim()) { uni.showToast({ title: '请输入品名', icon: 'none' }); return }
  if (!form.unit.trim()) { uni.showToast({ title: '请输入单位(整)', icon: 'none' }); return }

  submitting.value = true
  try {
    const formData = {
      productName: form.productName.trim(),
      productCode: form.productCode.trim() || null,
      supplierId: form.supplierId || null,
      category: form.category.trim() || null,
      unit: form.unit.trim(),
      spec: form.spec.trim() || null,
      packQty: form.packQty ? Number(form.packQty) : null,
      purchasePrice: form.purchasePrice ? Number(form.purchasePrice) : null,
      sellingPrice: form.sellingPrice ? Number(form.sellingPrice) : null,
      splitPrice: form.splitPrice ? Number(form.splitPrice) : null,
      warnQty: form.warnQty ? Number(form.warnQty) : null,
      status: form.status,
      remark: form.remark.trim() || null
    }

    if (form.productId) {
      formData.productId = form.productId
      await updateProduct(formData)
      uni.showToast({ title: '修改成功', icon: 'success' })
    } else {
      await addProduct(formData)
      uni.showToast({ title: '新增成功', icon: 'success' })
    }
    setTimeout(() => goBack(), 1500)
  } catch (e) {
    console.error('提交失败:', e)
    const msg = e?.msg || e?.message || '操作失败，请重试'
    uni.showToast({ title: msg, icon: 'none', duration: 2000 })
  } finally { submitting.value = false }
}

function goBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) uni.navigateBack()
  else uni.redirectTo({ url: '/pages/wms/product/index' })
}

onMounted(() => {
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}
  mode.value = options.mode || 'add'
  productId.value = options.id ? parseInt(options.id) : null

  if (mode.value === 'add') {
    uni.setNavigationBarTitle({ title: '新增货品' })
  } else if (mode.value === 'edit') {
    uni.setNavigationBarTitle({ title: '编辑货品' })
    loadDetail()
  }

  searchSupplierList('')
})
</script>

<style lang="scss" scoped>
page { background-color: #F5F7FA; }
.form-container { min-height: 100vh; padding-bottom: 140rpx; }

.form-section { margin: 24rpx; background: #fff; border-radius: 20rpx; padding: 32rpx; }

.form-field { margin-bottom: 28rpx; &:last-child { margin-bottom: 0; } }
.field-label { font-size: 26rpx; color: #4E5969; font-weight: 500; margin-bottom: 12rpx;
  .required { color: #F53F3F; margin-right: 4rpx; }
}
.field-input-box { display: flex; align-items: center; background: #F7F8FA; border-radius: 12rpx; padding: 0 24rpx; height: 84rpx; gap: 12rpx; transition: background 0.2s;
  &:focus-within { background: #EFF0F1; }
  &.picker-field { cursor: pointer; }
  &.radio-field { background: transparent; padding: 0; height: auto; }
}
.field-input { flex: 1; font-size: 28rpx; color: #1D2129; height: 84rpx; line-height: 84rpx; background: transparent; }
.field-placeholder { color: #C9CDD4; font-size: 28rpx; }

.field-textarea-box { background: #F7F8FA; border-radius: 12rpx; padding: 20rpx 24rpx; }
.field-textarea { width: 100%; min-height: 120rpx; font-size: 28rpx; color: #1D2129; line-height: 1.6; background: transparent; }

.form-row { display: flex; gap: 24rpx; }
.half { flex: 1; min-width: 0; }

.radio-group { display: flex; gap: 40rpx; padding: 8rpx 0; }
.radio-item { display: flex; align-items: center; gap: 10rpx; font-size: 28rpx; color: #86909C; transition: color 0.2s;
  &.active { color: #1D2129; }
}
.radio-dot { width: 32rpx; height: 32rpx; border-radius: 50%; border: 4rpx solid #C9CDD4; position: relative; transition: border-color 0.2s;
  .radio-item.active & { border-color: #3D6DF7;
    &::after { content: ''; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 16rpx; height: 16rpx; border-radius: 50%; background: #3D6DF7; }
  }
}

.picker-content { background: #fff; max-height: 70vh; display: flex; flex-direction: column; }
.picker-header { display: flex; justify-content: space-between; align-items: center; padding: 30rpx; border-bottom: 1rpx solid #F2F3F5; }
.picker-title { font-size: 32rpx; font-weight: 600; color: #1D2129; }
.picker-close { padding: 8rpx; }
.picker-search { padding: 20rpx 30rpx; }
.picker-search-box { display: flex; align-items: center; background: #F7F8FA; border-radius: 36rpx; padding: 0 24rpx; height: 64rpx; gap: 10rpx; }
.picker-search-input { flex: 1; font-size: 26rpx; color: #1D2129; height: 64rpx; }
.picker-list { flex: 1; padding: 0 30rpx; max-height: 50vh; }
.picker-item { display: flex; justify-content: space-between; align-items: center; padding: 24rpx 0; border-bottom: 1rpx solid #F2F3F5;
  &.active { .picker-item-name { color: #3D6DF7; font-weight: 500; } }
}
.picker-item-name { font-size: 28rpx; color: #1D2129; }

.form-actions { position: fixed; left: 24rpx; right: 24rpx; bottom: 40rpx; display: flex; gap: 20rpx; z-index: 100;
  .u-button { flex: 1; height: 88rpx; border-radius: 44rpx; font-size: 30rpx; font-weight: 600; }
}
</style>
