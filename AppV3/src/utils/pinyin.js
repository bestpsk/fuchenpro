/**
 * 拼音工具 - 中文转拼音首字母（无需第三方库）
 */

// 常用汉字拼音首字母映射表（按Unicode区间）
const pinyinMap = {
  'A': '阿啊唉哎矮爱安暗按岸昂',
  'B': '八把吧白百般班板半办帮包薄宝保报杯北备被本比笔必边变便标表别宾冰兵病拨波伯驳补布步',
  'C': '才材财采彩菜参餐残惨草策层曾查差产长常厂场超朝车彻陈晨称成城程承吃充冲虫出初除楚处触穿传船创窗床吹春纯词此刺从村存错',
  'D': '达打大代带待单但淡弹蛋当党刀导岛到道得的灯等低底地第帝点电店掉调定丢东冬懂动都斗豆毒读独度渡端短段断堆队对顿多夺朵',
  'E': '鹅额恶恩儿而耳二',
  'F': '发法翻凡反犯范方房防仿放飞非肥废费分纷粉奋份风封丰锋冯逢凤佛否夫服福府付父负妇附复副富',
  'G': '该改盖干甘感刚钢高搞告哥歌格隔个各给根跟更工公功攻供宫弓共贡勾沟狗够估古谷股骨故固顾瓜挂怪关官观管馆惯冠贯光广规归轨柜贵国果过',
  'H': '哈海含寒汉行豪好号合何河核贺黑嘿恨哼亨横衡轰红洪宏虹猴后厚候乎呼胡湖壶虎互户花华化划画话怀坏欢环还换黄煌灰恢挥辉回悔会汇绘婚魂浑混活火或货获祸',
  'J': '击鸡积基机激及吉极即急疾集籍几己挤计划记纪技际季继寄加家佳夹甲价驾假嫁架尖坚间艰兼监减简检剪见件建剑健渐鉴键箭江姜将浆僵奖讲匠降酱交郊浇胶骄教角脚叫较接街节杰结截姐解介界届今金斤紧仅尽近进晋京经精惊晶井景警净径竞镜究九久酒旧救就居举巨具距拒据局聚卷决绝觉军均君',
  'K': '开凯刊看康扛抗考烤靠科棵颗壳可克刻客课肯坑空孔恐控口扣苦库裤酷夸跨快宽款狂况矿框亏困扩括',
  'L': '拉啦来赖蓝烂滥郎狼浪捞劳牢老乐勒雷蕾类累冷离梨理力立丽利例隶联连帘怜莲脸练炼恋链良凉粮梁量两亮辆量聊料列烈裂林临灵铃零领令另刘留流柳六龙隆楼露炉路录驴旅绿律虑率乱略轮论落骆',
  'M': '妈麻马码骂吗买麦卖满慢忙猫毛矛冒帽貌么没眉梅美门闷猛蒙盟梦迷米密蜜棉免面苗秒妙庙灭民敏名明命模摸膜魔摩磨末莫墨默谋某母木目牧幕',
  'N': '拿哪那纳奶南难囊脑闹呢内能尼你逆年念娘酿鸟尿捏您宁牛农浓弄奴努女暖诺',
  'O': '哦欧偶',
  'P': '拍排牌派盘盼判叛旁胖抛跑泡培赔配盆朋棚捧碰批皮疲脾片偏篇骗飘票拼品平评瓶凭坡泼破迫扑铺普',
  'Q': '七妻期欺齐奇骑棋旗乞企起气弃汽恰千牵铅谦签前钱潜浅欠枪强墙抢悄桥巧敲瞧切且亲琴勤青轻氢清情晴请庆秋求球区曲驱趋取去圈全权泉拳犬劝缺却确雀裙群',
  'R': '然燃染让饶扰绕惹人忍认任扔仍日荣容融熔溶柔肉如乳入软锐瑞润若弱',
  'S': '撒洒赛三伞散桑嗓扫色森杀沙纱傻晒山删闪善扇伤商赏上稍烧少绍哨蛇舍设社射涉申伸身深神审甚渗升生声胜圣失师诗施湿十石时识实拾食史使始驶士氏世市示式事势是适室释试视收手首守寿受兽书叔殊梳舒疏输蔬属鼠术束述树数刷耍摔甩双水税睡顺舜说丝司私思斯死四寺似饲松宋送颂搜苏俗诉肃素速宿塑酸蒜算虽随岁碎孙损缩所索锁',
  'T': '他它她塌塔踏台抬太态贪谈弹潭叹汤唐堂塘糖趟逃桃陶淘讨套特疼腾提题体天田甜填挑条跳贴铁厅听亭庭停挺通同铜统桶捅痛偷头投透突图途涂土吐兔团推退吞托拖脱驼',
  'W': '挖哇歪外碗万汪王网往忘望威微危围唯维伟伪尾委卫为未位味胃谓喂温文闻纹稳问翁窝我握乌污屋无吴五午伍武舞物务误雾',
  'X': '夕西吸希息习席喜洗系细戏下夏吓先仙鲜纤咸贤闲弦嫌显险县现线限宪献陷馅羡乡相香箱详享响想向象像消销小晓孝效笑些歇鞋写泄谢心辛欣新薪信星兴刑型形行醒幸性姓兄胸雄修秀绣虚需须许序续叙蓄宣悬旋选玄学雪血寻巡询',
  'Y': '压呀鸭牙芽哑亚咽烟淹延言严岩沿炎研盐颜眼掩演验厌宴燕央扬羊阳杨仰养样邀腰妖摇遥咬药要钥耀爷耶也野业叶页夜液一衣医依仪宜姨遗移疑乙已以椅蚁义亿忆艺议译异易役疫益意毅阴音银引饮隐印英应樱鹰迎营赢影映硬拥永勇涌用优悠忧尤由油游友有又右余鱼愉渔娱与予宇羽雨语玉育域欲遇御裕豫誉鸳渊元园原源圆援缘远院愿约月阅跃越云匀允运',
  'Z': '杂砸灾栽载再在咱赞暂攒脏葬遭糟早澡灶造噪则择泽贼怎增赠扎眨炸摘窄债寨沾粘展占战站张章掌丈仗帐障招找照罩遮折哲者这浙真针侦珍诊枕阵振镇争征挣睁蒸整正证支枝知织脂蜘执直值职植殖止只旨指纸至志制质治致智置中忠终钟种众重周洲粥轴肘皱骤珠诸猪竹烛主煮嘱住注驻助祝著柱铸筑住抓爪拽专砖转赚庄装壮撞追准捉桌着子紫字自宗综总纵走奏租足阻组祖钻嘴醉最罪尊遵昨左做作坐座'
}

// 构建汉字到首字母的反向索引
const charToInitial = {}
for (const [initial, chars] of Object.entries(pinyinMap)) {
  for (const ch of chars) {
    charToInitial[ch] = initial
  }
}

/**
 * 获取中文字符的拼音首字母
 * @param {string} chinese - 中文字符串
 * @returns {string} 拼音首字母大写
 */
export function getPinyinInitial(chinese) {
  if (!chinese) return ''

  let result = ''
  for (const char of chinese) {
    // 优先查表
    if (charToInitial[char]) {
      result += charToInitial[char]
    } else if (/[a-zA-Z]/.test(char)) {
      // 英文字母直接取大写
      result += char.toUpperCase()
    } else if (/[\u4e00-\u9fa5]/.test(char)) {
      // 未在映射表中的汉字，按Unicode区间粗略推断
      const code = char.charCodeAt(0)
      if (code >= 0x4E00 && code <= 0x4EFF) result += 'Y'
      else if (code >= 0x4F00 && code <= 0x52FF) result += 'Z'
      else if (code >= 0x5300 && code <= 0x56FF) result += 'S'
      else if (code >= 0x5700 && code <= 0x59FF) result += 'Q'
      else if (code >= 0x5A00 && code <= 0x5CFF) result += 'G'
      else if (code >= 0x5D00 && code <= 0x5FFF) result += 'D'
      else if (code >= 0x6000 && code <= 0x62FF) result += 'C'
      else if (code >= 0x6300 && code <= 0x65FF) result += 'L'
      else if (code >= 0x6600 && code <= 0x68FF) result += 'J'
      else if (code >= 0x6900 && code <= 0x6BFF) result += 'H'
      else if (code >= 0x6C00 && code <= 0x6EFF) result += 'Z'
      else if (code >= 0x6F00 && code <= 0x71FF) result += 'W'
      else if (code >= 0x7200 && code <= 0x74FF) result += 'Z'
      else if (code >= 0x7500 && code <= 0x77FF) result += 'T'
      else if (code >= 0x7800 && code <= 0x7AFF) result += 'S'
      else if (code >= 0x7B00 && code <= 0x7DFF) result += 'M'
      else if (code >= 0x7E00 && code <= 0x7FFF) result += 'G'
      else if (code >= 0x8000 && code <= 0x82FF) result += 'N'
      else if (code >= 0x8300 && code <= 0x85FF) result += 'X'
      else if (code >= 0x8600 && code <= 0x87FF) result += 'C'
      else if (code >= 0x8800 && code <= 0x89FF) result += 'Z'
      else if (code >= 0x8A00 && code <= 0x8BFF) result += 'Y'
      else if (code >= 0x8C00 && code <= 0x8DFF) result += 'Z'
      else if (code >= 0x8E00 && code <= 0x8FFF) result += 'Y'
      else if (code >= 0x9000 && code <= 0x92FF) result += 'G'
      else if (code >= 0x9300 && code <= 0x95FF) result += 'K'
      else if (code >= 0x9600 && code <= 0x97FF) result += 'G'
      else if (code >= 0x9800 && code <= 0x99FF) result += 'X'
      else if (code >= 0x9A00 && code <= 0x9BFF) result += 'F'
      else result += 'Z'
    }
    // 非中文非英文的字符（数字、符号等）跳过
  }

  return result.toUpperCase()
}

/**
 * 生成货品编码
 * 格式：拼音首字母-YYYYMMDD
 * @param {string} productName - 货品名称
 * @returns {string} 货品编码
 */
export function generateProductCode(productName) {
  if (!productName) return ''

  const initials = getPinyinInitial(productName)
  const now = new Date()
  const date = `${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}`

  return `${initials}-${date}`
}
