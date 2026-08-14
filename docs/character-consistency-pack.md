# 《我》人物一致性包

版本：v0.1
日期：2026-08-14
状态：Stage 4 制作中；成年主角 v001 候选等待单项确认，儿童设定表尚未生成

本文把已确认的 `c01_s02_commute_window` 人物资产转成后续 29 幕可复查的身份约束。它只锁定“是谁”，不把公交坐姿、手机手势、服装遮挡或单幕光线误当成其他场景模板。

## 1. 参考输入与职责

| 参考 | 状态 | 只允许提取的内容 |
| --- | --- | --- |
| `../game/assets/art/production/c01_s02_commute_window/characters/char_adult_commuter_seated_down_v001.png` | `approved` | 成年主角正面脸型、发型、年龄、体型、基础服装和低头身份 |
| `../game/assets/art/production/c01_s02_commute_window/characters/char_adult_commuter_seated_look_up_v001.png` | `approved` | 同一成年人的右转头颈、侧脸轮廓、耳位、下颌与观察神情 |
| `../game/assets/art/production/c01_s02_commute_window/characters/char_child_reflection_curious_v001.png` | `approved` | 同一人物约五岁时的亲缘特征、儿童比例和概括程度；不反向幼化成年人 |
| `../game/assets/art/style-studies/c01_s02/direction_selected_v009.png` | `approved_reference` | 原创手绘二维语言、生活化光线与成年/儿童关系；不复用公交构图 |

被拒绝的成年 v001/v002、儿童方向 v003-v008 和旧图集手/手机均不得作为身份参考。

## 2. 成年主角身份锚点

| 维度 | 必须保持 | 允许按场景变化 | 禁止 |
| --- | --- | --- | --- |
| 年龄 | 视觉年龄约 26 岁；年轻成年人，不是学生 | 疲惫程度、光线造成的轻微眼下阴影 | 中年法令纹、明显眼袋、松弛颈部、过度少年化 |
| 脸型 | 紧凑椭圆脸、柔和但清楚的下颌、短而不尖的下巴 | 透视压缩和轻微表情肌变化 | 长脸、宽方颌、尖下巴、偶像化 V 脸 |
| 头发 | 短黑发，顶部略乱，前额短碎发，生长方向与 production 一致 | 雨湿、睡乱、逆光边缘 | 长刘海、染发、强造型、每幕改变发际线 |
| 眉眼 | 平直偏柔的深眉，眼型克制，目光不夸张 | 低头、侧看、注意、短暂放松 | 大眼动漫化、锐利英雄眼、标准笑眼、镜头式凝视 |
| 鼻口 | 鼻梁与鼻翼适中，嘴唇薄厚自然、通常接近中性 | 嘴唇微张、轻抿、呼吸状态 | 主动露齿笑、夸张撇嘴、戏剧性悲伤 |
| 耳位与侧脸 | 耳位、鼻尖、唇线和下颌转折以抬头 production 为基准 | 左右镜像透视 | 耳位随姿势漂移、鼻梁突然变高或变尖 |
| 身形 | 偏瘦的普通体型，肩宽适中，四肢自然 | 坐、站、走、缩肩和放松 | 英雄宽肩、模特长腿、驼背病态、Q 版比例 |
| 肤色与画法 | 自然暖中性肤色，简化水彩/水粉块面 | 现实冷光、里世界暖反射、雨夜环境色 | 橙色过饱和、写实毛孔、厚油画皮肤、塑料磨皮 |
| 服装身份 | 无品牌、当代基础款、低饱和，轮廓不抢交互物 | 衬衫、针织衫、简单外套按场景更换 | 职业制服、时装大片造型、显眼品牌、每幕固定同一套衣服 |

稳定面部识别点为：短碎发前缘、平直眉形、眼间距与眼尾角度、紧凑鼻口关系、短而柔和的下颌。新候选至少保持其中四项，且必须同时通过正面与侧面对照。

## 3. 五岁儿童身份锚点

儿童是同一人物的童年版本，不是另一个“可爱角色”。

- 保留成年人的黑发方向、眉眼间距、鼻口相对位置和耳部轮廓趋势。
- 年龄约五岁：额头相对更高、面颊更圆、下颌更短、鼻口更小、肩颈更窄，四肢长度符合幼儿比例。
- 面部和衣褶比成年人更概括，不做写实缩小成人脸，也不放大眼睛或头部。
- 日常儿童圆领卫衣、针织衫或基础外套；不复制成年工作衬衫，不拿手机。
- 轻快感来自松弛眉眼、自然关注和微张嘴唇；禁止主动笑容、标准嘴角上扬、抿嘴尬笑和面对镜头式表情。
- 生成儿童设定表前必须先确认成年 v001 身份候选；儿童候选必须与已确认成年设定表并排评审。

## 4. 姿势与手部规则

1. 每个姿势先画重心线、骨盆方向、胸口方向、肩线、视线和承载面，再生成服装细节。
2. 手部不能作为脱离身体的补丁。凡握手机、翻书、捧盒、压纸、拖门或整理桌面，必须同时检查手指、手腕、前臂、肩膀和物件重心。
3. 常态动作使用非对称自然分工；避免双手镜像捧空、两臂同角度下垂或手掌僵直贴腿。
4. 坐姿必须标明臀部、背部、脚底和膝盖的接触关系；站姿必须标明承重脚；缩进柜子的姿势必须标明骨盆、背部和膝盖净空。
5. 同一动作状态组使用相同画布、锚点、身体比例和下半身不变量。仅改变头颈时，下方授权区域必须逐像素保持或由同一骨架确定性重绘。
6. 每只可见手必须有可信腕部、正确拇指侧和五指结构；候选评审至少查看原尺寸与运行时显示尺寸。

## 5. 场景覆盖与服装策略

| 场景组 | 成年状态 | 五岁状态 | 身份复用边界 |
| --- | --- | --- | --- |
| 第一章现实与通勤 | 床边、通勤坐姿、看窗外 | 车窗倒影、后座坐姿 | `c01_s02` 两个 production 状态保持不变；其他姿势重新生产 |
| 第二章学校 | 校门站立、沿墙走 | 跑道站立、慢走、桌角停步 | 可延续下班基础款；跑动不使用成人骨架缩放 |
| 第三章纸片 | 翻书、坐下、翻页 | 临摹过渡手部/小孩形态 | 手与纸页关系逐状态确认，禁止悬空手 |
| 第四章柜子 | 工位紧张坐姿、安静坐下 | 柜内蜷缩、进入、探头 | 成年服装可更居家；儿童每个柜内姿势按空间重做 |
| 第五章森林与结尾 | 林边站立、最终放松、整理、发消息 | 探索、观察化石、捧盒 | 最终放松只改变重心和神情，不重新设计身份 |

## 6. 成年 v001 设定表候选

文件：`../game/assets/art/style-studies/character-consistency/char_adult_identity_sheet_v001_candidate.png`

- 状态：`candidate`，等待用户单项确认；不得进入 production 或作为运行时人物。
- 规格：1536 × 1024 RGB PNG；SHA-256 `dd6cbfc5b33c5774444f6e4356a14fac659917443df3b4e7eca998dd99dd09e8`。
- 内容：等比例正面站姿、右转四分之三站姿、右侧面站姿和自然坐姿；无文字、手机或其他道具。
- 当前自检：四视图的短发方向、紧凑脸型、眉眼、体型与服装关系连续；视觉年龄约 26 岁；可见手部没有重复肢体或对称捧空。
- 待确认点：是否仍像 `c01_s02` 已确认成年人；正面与坐姿年龄是否合适；站姿比例、侧脸和手部是否可作为后续生成锚点。
- 后续门槛：只有该图确认后，才生成独立的五岁儿童身份设定表；不在一次评审中混入儿童新候选。

### 最终生成提示词

生成方式：内置 `image_gen`，四张本地图片分别作为成年低头身份、成年抬头身份、五岁亲缘和整体视觉语言参考。

```text
Use case: stylized-concept
Asset type: game character identity model-sheet candidate for review, not a runtime sprite
Primary request: Create one clean model sheet for the approved adult protagonist, preserving his identity across four views.
Subject: The same ordinary East Asian man, approximately 26 years old, short slightly uneven black hair with the same growth direction, straight soft eyebrows, compact oval face, youthful smooth jaw and neck, modest nose and mouth, lean average build. He wears the same unbranded charcoal-blue basic shirt, dark trousers and simple black belt.
Style/medium: Original hand-drawn 2D animation character design, clear pencil-weight contours, restrained transparent watercolor and matte gouache shapes, simplified skin rendering, non-photorealistic, everyday and understated.
Composition/framing: Landscape model sheet on one perfectly plain warm light-gray background. Four clearly separated full-body views at equal scale: neutral front standing, neutral three-quarter standing turned right, clean right-side profile standing, and natural seated pose on a simple untextured rectangular block. Keep the whole figure visible in every view with generous margins. No labels, no text, no borders.
Expression and pose: Calm neutral attentive expression, no smile, no sadness, no fashion pose. Relaxed shoulders. Standing hands rest naturally at the sides; seated hands rest asymmetrically and naturally on the thighs. Every view has exactly two arms, two hands and five fingers per visible hand, with believable wrists and no object held.
Constraints: Preserve the approved face, haircut, age, build and clothing identity. All four views must unmistakably be the same person. He must read as about 26, not middle-aged and not teenage. Hands must be anatomically natural. No phone, no props, no environment, no cast shadow, no logos, no watermark, no text.
Avoid: photorealism, skin pores, heavy oil-paint texture, older facial lines, long chin, broad heroic shoulders, idealized idol styling, anime exaggeration, oversized eyes, symmetrical stiff hands, duplicate limbs, fused fingers, front-facing glamour pose, smile or grimace.
```

## 7. 单项验收

成年或儿童设定表只有同时满足以下条件才可标记为 `approved_reference`：

- 正面、四分之三侧、正侧面和坐姿能被识别为同一人物。
- 年龄、体型、头身比和亲缘关系符合本文件，不靠服装维持身份。
- 五个稳定面部识别点至少保持四项。
- 手、腕、肩与身体结构自然，没有重复、融合或悬空肢体。
- 线条、肤色和材质符合原创视觉方向，不偏写实或偶像化。
- 用户明确确认后才复制为长期身份参考；候选本身不进入运行时。
