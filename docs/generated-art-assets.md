# 《我》生成美术资产记录

生成日期：2026-07-17  
生成方式：Codex 内置 `image_gen` / imagegen 技能（非 CLI fallback）  
用途：Godot 竖屏游戏内背景、视觉风格锚点与可交互物件图集

## 使用与编辑边界

- 所有图像均为本项目按母本和游戏脚本生成的原创视觉资源，没有使用外部图片或真实 IP 作为参考。
- `title_key_art.png` 是后续背景和物件的风格参考；各资源只继承其纸张质感、线稿、色彩与光线，不复刻构图。
- 图片不包含烘焙 UI、可读文字、商标或水印；交互提示与状态变化由 Godot 运行时叠加。
- 第三章明确排除知名漫画、动画与游戏角色的高相似造型。
- 七张背景为 941 × 1672 RGB PNG，四张物件图集为 1254 × 1254 RGB PNG；复制进工程后保留原始文件，没有覆盖或删除生成目录中的源文件。
- 根据实机视觉验收，标题图、第一章和第二章已二次生成：公交座椅统一朝车头、窗外车辆与公交同向并共享消失点，跑道改为标准连续椭圆。
- 物件图集的浅色底由运行时色键 Shader 去除；场景中已有的车窗、跑道、黑板等结构不重复覆盖图片，只设置透明命中区。

## 2026-08-07 Stage 3 方向评审稿

生成方式继续使用 Codex 内置 `image_gen` / imagegen 技能，不使用 CLI fallback。方向稿只用于 `c01_s02_commute_window` 的视觉语言评审，运行时不引用 `style-studies/`。

| 工程文件 | 状态 | 生成源文件 | 结论 |
| --- | --- | --- | --- |
| `game/assets/art/style-studies/c01_s02/direction_a_v001_rejected.png` | `rejected` | `exec-dc3d8525-4839-459d-8a31-0cea4187f042.png` | 成年主角被错误生成成女性 |
| `game/assets/art/style-studies/c01_s02/direction_b_v001_rejected.png` | `rejected` | `exec-30d4032b-7cbb-46d6-8591-6af7c74c9fc3.png` | 成年主角被错误生成成女性 |
| `game/assets/art/style-studies/c01_s02/direction_c_v001_composition_reference.png` | `reference_only` | `exec-2a4e52da-95d9-4621-874e-fd1c8098dd87.png` | 用户确认构图与车辆方向；女性身份不采纳 |
| `game/assets/art/style-studies/c01_s02/direction_a_v002.png` | `rejected` | `exec-cbe510af-320d-4825-a0b0-bf5019e2297d.png` | 道路或车辆方向未通过用户确认 |
| `game/assets/art/style-studies/c01_s02/direction_b_v002.png` | `rejected` | `exec-369a83f5-7a2d-49a9-b436-02ed6ad90c65.png` | 道路或车辆方向未通过用户确认 |
| `game/assets/art/style-studies/c01_s02/direction_c_v002.png` | `rejected` | `exec-af4e3473-1b93-405d-ac0c-776fcf1db316.png` | 道路或车辆方向未通过用户确认 |
| `game/assets/art/style-studies/c01_s02/direction_selected_v003.png` | `rejected` | `exec-12c60570-942a-4ec8-9db7-d608a3fe53b7.png` | 人物身份已纠正，但儿童朝向、眼线和动作未形成成年人的镜像 |
| `game/assets/art/style-studies/c01_s02/direction_selected_v004.png` | `rejected` | `exec-0f31d34d-baa1-457a-83f1-a0961edff756.png` | 头部已相向，但错误地把儿童整个身体转成左侧面 |
| `game/assets/art/style-studies/c01_s02/direction_selected_v005.png` | `rejected` | `exec-5d273d17-00bb-44c8-ad25-0a6541bb1a65.png` | 身体方向正确，但倒影越过玻璃，且儿童服装、手机和表情不符合要求 |
| `game/assets/art/style-studies/c01_s02/direction_selected_v006.png` | `rejected` | `exec-7dfde9dc-e260-4d25-950d-0595a338a835.png` | 边界、服装和空手正确，但表情读成尬笑，倒影过于清晰实体化 |
| `game/assets/art/style-studies/c01_s02/direction_selected_v007.png` | `rejected` | `exec-f3644651-dd8d-4c75-a5a7-289c3ffacaf8.png` | 表情仍显僵硬，倒影仍偏清晰 |
| `game/assets/art/style-studies/c01_s02/direction_selected_v009.png` | `approved` | `exec-f65a2305-a270-4bf0-b37d-97ff63fc1e06.png` | 用户接受为背景灰稿、人物与倒影资产的视觉和合成关系基准；不是运行时资产 |
| `game/assets/art/style-studies/c01_s02/bg_c01_s02_bus_night_layout_v001.png` | `rejected` | `exec-5cf76c7b-9935-4b6e-b42d-8b59b98e1f9a.png` | 移除成年人物时错误抹除了其固定座椅，人物叠加后将缺少可信承载面 |
| `game/assets/art/style-studies/c01_s02/bg_c01_s02_bus_night_layout_v002.png` | `rejected` | `exec-bdc29e4e-4661-477a-a64b-cb9ef00d87bf.png` | 恢复了座椅，但竖向黄扶手穿过靠背、坐垫并落地，明显阻塞乘坐空间 |
| `game/assets/art/style-studies/c01_s02/bg_c01_s02_bus_night_layout_v003.png` | `approved` | `exec-afe87548-a0b7-4988-9339-da3211c42fdd.png` | 用户确认扶手与座椅关系成立；锁定为正式背景生产的构图基准 |
| `game/assets/art/style-studies/c01_s02/bg_c01_s02_bus_night_base_v001_candidate.png` | `approved_reference` | `exec-8886f6c0-cb4f-4edb-9fa4-0fa3df1d04ce.png` | 用户确认该图为正式背景；保留为生成与评审来源，运行时改用 production 副本 |
| `game/assets/art/style-studies/c01_s02/foreground/fg_c01_s02_bus_rail_occluder_v001_candidate.png` | `reference_only` | `exec-8c92f483-91c5-422a-afa9-870ba2f93c33.png` | 保留为全画布对齐与提取母版；不作为可摆放运行时物件 |
| `game/assets/art/production/c01_s02_commute_window/foreground/fg_c01_s02_seat_armrest_occluder_v001.png` | `approved` | 上述母版无损裁切 | 左侧座位扶手紧边界运行时资产，可独立校正 |
| `game/assets/art/production/c01_s02_commute_window/foreground/fg_c01_s02_front_seat_occluder_v001.png` | `approved` | 上述母版无损裁切 | 底部弧形扶手与前排座椅上缘紧边界运行时资产，可独立校正 |
| `game/assets/art/style-studies/c01_s02/characters/char_adult_commuter_seated_down_v001_candidate.png` | `rejected` | `exec-26d4b9d0-f804-447c-80c8-86731062e0bf.png` | 用户指出人物显老，双手对称捧空不自然 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_adult_down_v001.png` | `rejected_review` | 本地确定性合成 | v001 合成反例，保留用于对照年龄与手势问题 |
| `game/assets/art/style-studies/c01_s02/characters/char_adult_commuter_seated_down_v002_candidate.png` | `rejected` | `exec-b7256d0c-c7c9-4551-87ef-77cce49e2174.png` | 手势改善，但用户认为人物仍显老，目标改为约 26 岁 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_adult_down_v002.png` | `rejected_review` | 本地确定性合成 | v002 年龄感反例，保留用于对照 |
| `game/assets/art/style-studies/c01_s02/characters/char_adult_commuter_seated_down_v003_candidate.png` | `approved_reference` | `exec-3e5d8d76-72cf-4467-a1b6-3df3e5c0a347.png` | 用户确认约 26 岁、低头与非对称持机动作；保留为生产来源 |
| `game/assets/art/production/c01_s02_commute_window/characters/char_adult_commuter_seated_down_v001.png` | `approved` | 上述候选逐字节复制 | 已接入运行时的低头状态人物，紧边界且可独立校正 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_adult_down_v003.png` | `approved_review` | 本地确定性合成 | 已确认的低头人物、临时手机占位、正式背景和结构层合成关系 |
| `game/assets/art/style-studies/c01_s02/characters/char_adult_commuter_seated_look_up_v001_candidate.png` | `approved_reference` | `exec-04e0017f-a15d-4657-936e-562fd8fe2d77.png` | 用户确认同锚点抬头状态；保留为生产来源 |
| `game/assets/art/production/c01_s02_commute_window/characters/char_adult_commuter_seated_look_up_v001.png` | `approved` | 上述候选逐字节复制 | 已登记为成人层的 `look_up` 状态资源 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_adult_look_up_v001.png` | `approved_review` | 本地确定性合成 | 已确认的抬头状态、手机校准占位、正式背景和结构层合成关系 |
| `game/assets/art/style-studies/c01_s02/props/prop_phone_commute_cold_v001_candidate.png` | `approved_reference` | `exec-2ce4e535-43fe-4927-9704-9ffbb3ec83d3.png` | 用户确认的无品牌低亮度冷蓝灰手机；保留为生产来源 |
| `game/assets/art/production/c01_s02_commute_window/props/prop_phone_commute_cold_v001.png` | `approved` | 上述候选逐字节复制 | 已接入运行时并保留人工校正能力的手机生产资产 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_phone_cold_adult_down_v001.png` | `approved_review` | 本地确定性合成 | 已确认手机与低头人物、正式背景和结构层的评审预览 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_phone_cold_adult_look_up_v001.png` | `approved_review` | 本地确定性合成 | 已确认手机与抬头人物的兼容性评审预览 |
| `game/assets/art/style-studies/c01_s02/props/prop_vehicle_focus_base_v001_candidate.png` | `rejected` | `exec-762cbc04-e661-4cca-b411-e6d299e752e7.png` | 角度与车道纵轴不符，车轮悬浮且覆盖雨纹，保留作反例 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_vehicle_focus_base_v001.png` | `rejected_review` | 本地确定性合成 | v001 背景落位反例 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_vehicle_focus_base_look_up_v001.png` | `rejected_review` | 本地确定性合成 | v001 完整关系反例 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_vehicle_focus_context_v002.png` | `rejected_review` | `exec-fed6b3dd-247d-4140-8d46-095ce07fb159.png` | 角度正确但车辆外宽超过该处可用车道宽 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_vehicle_focus_context_look_up_v002.png` | `rejected_review` | 本地确定性合成 | v002 车宽/车道宽完整关系反例 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_vehicle_focus_context_v003.png` | `rejected_review` | `exec-4d247436-7197-4397-b96b-a6fff7465c6b.png` + 本地徽标清理 | 车辆大小获认可，但近侧车道线拓扑错误；保留为车辆尺度基准 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_vehicle_focus_context_look_up_v003.png` | `rejected_review` | 本地确定性合成 | v003 完整关系道路反例 |
| `game/assets/art/style-studies/c01_s02/references/reference_c01_s02_vehicle_lane_markup_v001.png` | `approved_reference` | 用户标注附件 | 长红线只表示大致位置、方向和首尾通道，红圈内旧亮线必须移除；不复刻手绘抖动 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_vehicle_focus_context_v004.png` | `rejected_review` | v003 + 局部湿路 donor + 确定性车道线修正 | 旧亮线已清除，但错误复刻了手绘曲线 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_vehicle_focus_context_look_up_v004.png` | `rejected_review` | 本地确定性合成 | v004 完整关系曲线反例 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_vehicle_focus_context_v005.png` | `approved_reference` | v003 + 局部湿路 donor + 确定性透视直线 | 2026-08-12 用户确认；车辆完整场景与直线车道基准 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_vehicle_focus_context_look_up_v005.png` | `approved_review` | 本地确定性合成 | v005 与已确认人物、手机和结构层的完整关系预览 |
| `game/assets/art/production/c01_s02_commute_window/background/bg_c01_s02_bus_night_lane_v002.png` | `production` | v001 背景 + v005-v003 道路差分 | 无焦点车、保留直线车道的正式背景 |
| `game/assets/art/production/c01_s02_commute_window/props/prop_vehicle_focus_base_v001.png` | `production_adjustable` | v005 确定性紧边界提取 | 独立焦点车身，`locked = false` |
| `game/assets/art/production/c01_s02_commute_window/effects/fx_vehicle_grounding_v001.png` | `production_adjustable` | v005 确定性紧边界提取 | 独立接地阴影和破碎湿反射，`locked = false` |
| `game/assets/art/production/c01_s02_commute_window/effects/fx_vehicle_glass_rain_v001.png` | `production_adjustable` | v005 与无车 donor 的局部高频差分 | 独立玻璃雨纹，`locked = false` |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_vehicle_layers_v001.png` | `approved_technical_review` | 四张 production 资产本地确定性回组 | 初始分层合成检查图 |
| `game/assets/art/style-studies/c01_s02/props/prop_vehicle_headlights_neutral_v001.png` | `candidate_review` | v005 production 车身确定性裁切 | 两只中性灯罩，205 × 59 RGBA |
| `game/assets/art/style-studies/c01_s02/props/prop_vehicle_headlights_blink_v001.png` | `candidate_review` | 中性灯罩局部亮度/遮光处理 | 同裁切轻微收暗态，不画眼睛 |
| `game/assets/art/style-studies/c01_s02/props/prop_vehicle_plate_neutral_v001.png` | `candidate_review` | v005 production 车身确定性裁切 | 不可读前牌，93 × 35 RGBA |
| `game/assets/art/style-studies/c01_s02/props/prop_vehicle_plate_mouth_hint_v001.png` | `candidate_review` | 中性前牌局部阴影处理 | 同裁切下缘轻弧阴影，不画嘴巴 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_vehicle_state_candidates_v001.png` | `candidate_review` | 本地确定性合成 | 单项透明边界和放大状态对照 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_vehicle_states_neutral_v001.png` | `candidate_review` | 本地确定性合成 | 中性状态完整场景关系 |
| `game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_vehicle_states_hint_v001.png` | `candidate_review` | 本地确定性合成 | 收暗车灯与轻弧车牌完整场景关系 |

v002 共用提示词如下，三个方向只替换最后的 `Style/medium`：

```text
Use case: illustration-story
Asset type: portrait 9:16 visual-direction study for an original 2D narrative game
Primary request: a restrained rainy-night commute scene in which an emotionally tired adult briefly rediscovers his childhood way of seeing ordinary traffic lights as expressions
Scene/backdrop: inside a contemporary city bus or hired car, seen from the rear passenger area; a large rain-streaked side window dominates the upper and right side; a wet ordinary city road and street lamps outside; one nearby unbranded focus vehicle has two clearly visible headlights and an unreadable plate, with no literal cartoon face
Subject: exactly one ordinary East Asian adult man in his mid-thirties, clearly male, average build, short slightly untidy black hair, plain gray-blue collared work shirt and charcoal trousers; seated in the lower-left, body aligned with travel, phone held low near his lap, head turned up toward the window. In the glass is exactly one subtle reflection of the same person as an eight-year-old East Asian boy with matching hair direction and facial structure, looking curiously toward the vehicle lights
Composition/framing: fixed portrait 9:16 composition, adult lower-left, phone near hands, window as the main play field, focus vehicle and its headlights/plate readable on the right, child reflection inside the glass rather than standing outdoors; preserve clear regions for window, phone, headlights and plate interactions; no UI
Lighting/mood: realistic cool blue-gray rain and dim vehicle interior, with only a restrained warm amber near the child reflection and headlights; lived-in, quiet, observant, gently uncanny but not magical spectacle
Constraints: adult and child must both be male and the same identity at different ages; original character, vehicle and environment designs; no readable text or license number; no logos, trademarks, watermark or baked interface; do not imitate any named artist, animation studio, existing film, character, shot or signature design
Avoid: women or girls, photorealism, glossy 3D, cyberpunk neon, anime franchise look, giant eyes, chibi proportions, literal face on the car, fantasy portal, particles, horror, sentimental glow, crowded composition
```

方向差异：

- A：明亮手绘二维动画，柔和铅笔轮廓、透明水彩空间和克制哑光水粉重点，兼顾形体可读与生活细节。
- B：轻盈水彩绘本，细松铅笔、更多留白、局部消失边缘、浅层叠色与最少不透明重点。
- C：图形化赛璐珞与水粉，简化轮廓、明确手绘边、哑光色块、克制两级阴影与很少纹理。

### 用户选定构图的人物身份纠正

`direction_selected_v003.png` 使用内置 `image_gen` 编辑模式生成，输入图为用户确认的 `direction_c_v001_composition_reference.png`。最终提示词的核心不变量如下：

```text
Use case: precise-object-edit
Asset type: corrected portrait 9:16 visual-direction and composition reference for c01_s02_commute_window
Primary request: change only the two foreground human identities and neutralize vehicle branding. Replace the seated adult woman with an ordinary East Asian adult man in his mid-thirties, and replace the girl reflected in the window with the same person's eight-year-old boy version. Keep positions, poses, gaze, scale, hand placement and the phone unchanged.
Required invariants: preserve the exact crop, camera, bus interior, seats, yellow rails, window, rain, city, wet road, lane structure, every vehicle's position, orientation and travel direction, focal black car, right-side red car, headlights, reflections, lighting, palette and rendering style. The focal black car remains in the opposing lane facing the bus; the red car remains traveling away in the bus direction.
Small cleanup: replace recognizable manufacturer branding with a neutral grille detail and keep the plate blank and unreadable.
Constraints: exactly one foreground adult man and one boy reflection of the same identity; no new people, readable text, logo, trademark, watermark or UI.
Avoid: changing composition, road geometry, traffic directions, vehicle count or placement, bus structure, phone placement, lighting, crop, perspective or background.
```

### 儿童镜像关系纠正

`direction_selected_v004.png` 使用内置 `image_gen` 编辑模式生成。首次局部编辑建立相向朝向和对应持机动作，第二次局部编辑进一步约束眼线、头肩和动作高度；工程内保留的是第二次编辑结果。最终一次提示词如下：

```text
Make one precise local correction to this image. Do not alter, redraw, restyle, crop, move, or relight anything except the translucent child reflection in the window. Preserve the adult pixel composition, his face, pose, hands and phone; preserve the bus, rain, street, black oncoming car, red receding car, all traffic directions, perspective, palette, and lighting exactly.

The child already faces the correct direction and holds a mirrored phone, but he is vertically too low. Move and redraw ONLY the child reflection so it reads as the adult at age eight occupying the same mirrored seated position. Align the child's TOP OF HEAD and EYE LINE horizontally with the adult's top of head and eye line across the window, within only a small natural difference. Align the child's chin, shoulder slope, elbow bend, forearm direction, hands, and smartphone gesture to the corresponding mirrored vertical landmarks of the adult, using shorter child limb lengths and child proportions without lowering the whole figure. The adult faces right; the child must remain a left-facing mirrored profile looking directly back at the adult. Mirror the adult's exact head turn, gaze direction, seated torso angle, shoulder line, arm arrangement, and phone orientation. Maintain recognizable shared facial structure, reflected hair direction, same quiet expression, and child-version of the same shirt. Keep the child translucent and fused into the wet glass, with street and rain visible through him. He must not look like a solid child sitting or standing outside.

This is a constrained retouch, not a new composition. No other object may drift. No logos, readable plates, text, UI, or watermark.
```

### 儿童身体朝向纠正

`direction_selected_v005.png` 使用内置 `image_gen` 编辑模式生成，输入图为 v004。最终提示词如下：

```text
Use case: precise-object-edit
Asset type: corrected portrait 9:16 visual-direction and composition reference for c01_s02_commute_window
Input image: edit target; change only the translucent child reflection in the bus window.
Primary request: Correct the child's BODY ORIENTATION. The adult and the child are both seated facing the front of the bus, which reads as facing the FRONT OF THE IMAGE / toward the viewer. The adult keeps his front-facing torso and turns only his head to the right toward the window. The child reflection must likewise have a front-facing seated torso, chest, pelvis, and shoulders, while turning only his head to the left to look back at the adult. Do not rotate the child's whole body left into profile.
Child pose details: show both shoulders and the front plane of the chest, with a near-horizontal shoulder line matching the adult's front-facing seated posture; hips and knees oriented toward the bus front / image front; elbows relaxed close to the body; hands holding the phone low over the lap in the child-scale equivalent of the adult's action. The child head remains a left-facing three-quarter/profile turn with eye contact toward the adult. Preserve recognizable shared facial structure, reflected hair direction, quiet expression, and child-version of the same shirt. Use believable eight-year-old proportions. Keep the child translucent and integrated into rain-streaked glass, never a solid person outside.
Required invariants: preserve every pixel-level composition outside the child reflection: portrait crop, camera, adult identity, adult front-facing torso, adult right-turned head, adult pose, hands and phone, bus structure, seats, yellow rails, wet window, rain, city, road geometry, lane markings, every vehicle position and direction, black focus car facing the bus in the opposing lane, red car traveling away in the bus direction, lighting, palette, and hand-painted rendering.
Avoid: child torso facing left or in side profile; child standing outside; changing the adult; moving or altering any vehicle; changing crop, perspective, road, bus, lighting, logos, readable plate, text, UI, or watermark.
```

### 儿童倒影边界与性格纠正

`direction_selected_v006.png` 使用内置 `image_gen` 编辑模式生成，输入图为 v005。最终提示词如下：

```text
Use case: precise-object-edit
Asset type: corrected portrait 9:16 visual-direction and composition reference for c01_s02_commute_window
Input image: edit target. Change ONLY the translucent eight-year-old child reflection in the bus window and erase any child pixels that currently spill outside the glass.

Primary request:
1. Treat the transparent window glass as a strict clipping mask. The child reflection may appear ONLY inside the large glass pane, bounded by the black rubber window frame and especially by the diagonal lower inner glass edge. Completely erase the child's arms, hands, phone, clothing, or reflection from the silver/blue metal window sill, black trim, lower interior panel, yellow rail, and every other solid bus surface. The original bus materials below and outside the glass must be restored cleanly with no ghost, haze, silhouette, or reflected child pixels. The child torso may end naturally at the diagonal glass edge as if physically occluded by the window frame.
2. Keep the child's already-correct orientation: pelvis, chest, torso, and both shoulders face the front of the bus / front of the image, while ONLY his head turns left to look at the adult. Do not rotate the whole child left.
3. Replace the adult-like collared shirt with age-appropriate, unbranded children's clothing: a simple muted moss-green crewneck sweatshirt with a soft knit texture and modest warm ochre collar detail, practical and playful rather than fashionable. Do not copy the adult's work shirt.
4. Remove the child's smartphone completely. His hands are empty and relaxed below the glass edge, therefore naturally hidden/occluded; do not invent another prop.
5. Make the child's expression more cheerful and alive: bright curious eyes, relaxed brows, and a small natural closed-mouth smile, warm and happy without exaggerated anime eyes, a broad grin, or cartoonish excitement. Keep him recognizably the same person as the adult at age eight, with related facial structure and reflected hair direction.

Required invariants: preserve the adult exactly, including identity, front-facing seated body, right-turned head, hands, smartphone, clothes, position, scale and expression. Preserve the portrait crop, camera, bus structure, seats, yellow rails, metal sill, black window seals, wet glass, rain, city, road geometry, lane markings, every vehicle position and travel direction, black focus car facing the bus in the opposing lane, right red car traveling away in the bus direction, lighting, palette, and hand-painted rendering. Preserve the child's current position, scale, front-facing body direction and left-turned head except for the requested clothing, empty hands, expression and strict glass clipping.

Avoid: any child reflection outside the glass; any child pixels over metal or trim; phone or other object in child's hands; adult-style work shirt; sad, tired, blank, stern, exaggerated, or cartoon expression; changing adult, traffic, crop, perspective, road, bus, lighting; logos, readable plate, text, UI, or watermark.
```

### 儿童自然神情与弱反射纠正

`direction_selected_v007.png` 使用内置 `image_gen` 编辑模式生成，输入图为 v006。最终提示词如下：

```text
Use case: precise-object-edit
Asset type: corrected portrait 9:16 visual-direction and composition reference for c01_s02_commute_window
Input image: edit target. Change ONLY the translucent eight-year-old child reflection inside the bus window.

Primary request:
1. Replace the child's stiff posed smile with a natural, unselfconscious feeling of quiet happiness and curiosity. The emotion should come mostly from relaxed bright eyes, softened lower eyelids, gently lifted cheeks, relaxed brows, and an attentive look toward the adult, as if he has just noticed someone familiar and is quietly delighted. Keep the mouth relaxed and natural, slightly parted or almost neutral with only a faint asymmetric warmth. Do NOT create a symmetric upturned closed-mouth smile, pursed lips, a forced grin, a camera-facing smile, or an exaggerated cheerful expression. The face should feel candid and alive, not posed.
2. Make the entire child reflection noticeably fainter and less solid than in the input. Reduce its perceived opacity, saturation, edge sharpness, and local contrast so the rainy street, headlights, raindrops, and glass reflections remain clearly visible through the child's face, hair, and sweatshirt. Use soft partially disappearing edges and uneven reflected-light visibility. The child must still be recognizable, but should read immediately as a subtle wet-glass reflection, not a person behind the glass. Aim for roughly one-third to two-fifths of the visual strength of the real adult.

Preserve exactly: the child's correct front-facing torso toward the bus front/image front, left-turned head looking at the adult, same position and scale, age-appropriate muted moss-green crewneck sweatshirt, empty hands with no phone or prop, and strict clipping inside the transparent glass. No child pixel, haze, or silhouette may cross the black rubber seal or diagonal lower glass edge onto the metal sill, trim, interior panel, or yellow rail.

Required invariants: preserve the adult exactly, including identity, pose, expression, clothing, hands and smartphone. Preserve portrait crop, camera, bus structure, seats, yellow rails, metal sill, black seals, wet glass, rain, city, road geometry, lane markings, all vehicle positions and directions, black focus car facing the bus in the opposing lane, right red car traveling away in the bus direction, lighting, palette, and hand-painted rendering.

Avoid: stiff or awkward smile, pursed mouth, symmetric smile curve, broad grin, exaggerated anime joy, blank sadness, direct camera gaze; reflection too clear, opaque, sharp, saturated, high-contrast, or solid; child pixels outside glass; phone or prop; adult-style shirt; any changes to adult, traffic, bus, crop, perspective, road, lighting; logos, readable plate, text, UI, or watermark.
```

v008 使用 `exec-5c48cd36-039e-49f6-a302-b9098422a039.png` 生成，只作为本轮中间预览；因用户指出造型偏写实、年龄偏大，未复制进工程。

### 五岁儿童概括手绘造型纠正

`direction_selected_v009.png` 使用内置 `image_gen` 编辑模式生成，输入图为未入库的 v008 中间预览。最终提示词如下：

```text
Use case: precise-object-edit
Asset type: corrected portrait 9:16 visual-direction and composition reference for c01_s02_commute_window
Input image: edit target. Change ONLY the very faint child reflection inside the bus window.

Age and visual-language correction: redesign the child as approximately FIVE years old, not eight and not a realistic miniature adult. Use a softly simplified original hand-painted 2D animation character treatment that matches the painted scene: gently simplified contours, fewer anatomical micro-details, broader watercolor/gouache shapes, restrained two-step shading, soft rounded forms, and minimal realistic skin texture. Give him believable five-year-old proportions: rounder cheeks, shorter lower face and chin, smaller nose and mouth, slightly larger forehead, narrower shoulders, shorter neck, smaller torso, and child-sized crewneck sweatshirt. Keep the eyes naturally sized and human, not enlarged. Preserve recognizable family resemblance to the adult through hair direction, brow shape, face width, and attentive gaze, but do not make him look like a digitally aged-down adult portrait.

Expression: no deliberate smile. Use a candid five-year-old look of quiet delight and curious recognition: lips relaxed and slightly parted with neutral corners, eyes softly bright and focused left toward the adult, brows relaxed and subtly asymmetric, face caught mid-attention rather than posing. It should feel lively because of attention and openness, not because of a smile.

Reflection: preserve or slightly reduce the already faint reflection strength. Keep the child at only about one-fifth to one-quarter of the real adult's visual strength. Rain, streetlights, tree shapes, headlight glow, and wet-glass streaks must show clearly through face, hair, sweatshirt, and torso. Let most outer edges dissolve irregularly into the glass. He should be noticed after looking twice.

Preserve exactly: child torso faces the bus/image front; only head turns left toward the adult; current placement within the glass; muted moss-green unbranded crewneck sweatshirt; empty hands and no prop; strict glass clipping. No child pixels or haze may cross the black rubber frame or diagonal lower glass edge onto the metal sill, trim, interior panel, or yellow rail.

Required invariants: preserve the adult exactly, including identity, pose, expression, clothing, hands and smartphone. Preserve crop, camera, bus structure, seats, rails, sill, seals, wet glass, rain, city, road, lane markings, every vehicle position and direction, black oncoming focus car, right receding red car, lighting, palette, and the rest of the painting.

Avoid: photorealistic child, realistic aged-down adult face, skin pores, photographic rendering, mature seven-to-ten-year-old proportions, stiff expression, any smile or upward mouth corners, pursed lips, perfect symmetry, direct camera gaze; oversized anime eyes, chibi, mascot, doll, baby caricature; reflection too visible or solid; child outside glass; phone or prop; any changes to adult, traffic, bus, crop, perspective, road or lighting; logos, readable plate, text, UI, watermark. Do not imitate any named artist, studio, film, character, shot, or signature design.
```

### 无人物背景构图灰稿

`bg_c01_s02_bus_night_layout_v001.png` 使用内置 `image_gen` 编辑模式生成，输入图为已确认的 `direction_selected_v009.png`。用户复查后指出左下成年人物原坐处缺少固定座椅，因此 v001 标记为 `rejected`；工程文件为 941 × 1672 RGB PNG，SHA-256 为 `4128feebfb3ac24a18d0e3139b83342fd580cbad7cbb1c3bc18955a2c339c0db`。本轮使用的完整结构化提示词如下：

```text
Use case: precise-object-edit
Asset type: portrait 9:16 low-fidelity background composition layout for c01_s02_commute_window
Input image: edit target and locked visual-composition reference. Preserve its camera, crop, bus-window proportions, road perspective, traffic-direction logic, and hand-painted 2D visual language.

Primary request: create a background-only composition draft for later layered production. Remove the adult commuter, the child reflection, the smartphone, and the entire nearby black oncoming focus car. Reconstruct the bus seat, interior panels, wet window, rainy street, and road surface naturally behind the removed elements. The result must contain only the non-interactive environment and distant traffic.

Composition requirements: keep the empty seated-adult placement in the lower-left available for a later character overlay; keep a clean hand-and-phone overlay area near the lower-middle; keep a large unobstructed opposing-lane area in the middle-right for a later independent focus-car sprite, including readable future headlight and plate zones. Preserve the large glass pane and its hard frame boundaries for a later clipped child-reflection layer. Preserve the right-side car showing its rear and traveling away in the bus direction, plus distant traffic that supports a clearly readable two-way road.

Draft treatment: render this as a deliberate blue-gray value-and-layout study, not a polished production background. Use simplified matte gouache shapes, restrained graphite edges, broad value groups, and only small muted amber notes on rails, street lamps, and distant vehicle lights. Keep enough rain and wet-road reflection to judge depth, but avoid finished micro-detail.

Required invariants: portrait crop and fixed camera; bus frame, seats, yellow rails, window sill and road share credible perspective; right-side red car remains rear-facing and receding; distant opposing and same-direction traffic remain consistent; no readable text, plate number, logo, trademark, watermark, or UI.

Avoid: any adult, child, face, human silhouette, child reflection, smartphone, hand-held prop, nearby black focus vehicle, baked headlight face, baked plate interaction, character shadow, empty glowing silhouette, photorealism, glossy 3D, cyberpunk neon, fantasy portal, dramatic magic, finished-production polish, or changes that collapse the two-way traffic logic.
```

### 背景灰稿座椅恢复

`bg_c01_s02_bus_night_layout_v002.png` 使用内置 `image_gen` 编辑模式生成，Image 1 为 v001 编辑目标，Image 2 为用户红框标注，Image 3 为 v009 人物坐姿与座椅占位参考。生成源为 `exec-bdc29e4e-4661-477a-a64b-cb9ef00d87bf.png`；源图 941 × 1671，入库前仅将高度归一化为统一画布 941 × 1672，最终 RGB PNG 的 SHA-256 为 `abbaba6e8ece7d14dc3ec02dd4eaf52f4e70428a434e3d5457b3fb125cc04aa0`。最终提示词如下：

```text
Use case: precise-object-edit
Asset type: corrected portrait 9:16 low-fidelity background composition layout for c01_s02_commute_window
Input images: Image 1 is the edit target; Image 2 marks the lower-left missing-seat area; Image 3 provides only the former adult seating footprint and occlusion reference.
Primary request: make one tightly localized correction. Restore a clearly readable empty city-bus passenger seat in the lower-left where the adult was seated. The seat faces the bus/image front and matches neighboring-seat perspective. Show a dark blue-gray upholstered backrest, seat cushion, restrained seams, and necessary lower support so the later seated-character layer has a credible contact surface. Keep the vertical yellow pole and foreground guard rail in front with correct occlusion.
Style/medium: match the v001 blue-gray value-and-layout study, simplified matte gouache shapes, restrained graphite edges, broad value groups, muted yellow rails, and no finished micro-detail.
Change only: the missing seat and the minimum adjacent panel/floor pixels needed to connect it naturally. Preserve the 941 × 1672 portrait crop and all other composition.
Required invariants: keep the window, frame, sill, rain, wet road, lane markings, distant traffic, right-side rear-facing receding car, trees, lamps, every existing rail/pole, background seats, lighting, palette, focus-car empty road area, and later overlay spaces unchanged. Keep the adult and phone overlay area usable above the restored seat.
Avoid: any person, face, body, silhouette, child reflection, smartphone, nearby black focus car, red annotation box, text, logo, watermark, UI, added vehicle, moved rail, changed window geometry, changed traffic direction, broad repainting, photorealism, glossy 3D, or polished production detail.
```

### 背景灰稿扶手遮挡纠正

`bg_c01_s02_bus_night_layout_v003.png` 使用内置 `image_gen` 编辑模式生成，输入图为 v002。生成源为 `exec-afe87548-a0b7-4988-9339-da3211c42fdd.png`；工程文件为 941 × 1672 RGB PNG，SHA-256 为 `6b08ae7abb1c073ecfa9abd5b0f714395e77ac7cc81166209d56af179b35c73a`。最终提示词如下：

```text
Use case: precise-object-edit
Asset type: corrected portrait 9:16 low-fidelity background composition layout for c01_s02_commute_window
Input image: the current seat-restored background-only bus layout v002.
Primary request: fix one physically impossible occlusion. The vertical yellow handrail continues across the restored backrest and cushion, blocking the passenger space. Preserve the pole from the ceiling to the upper guard-rail connection, then terminate it cleanly or hide its continuation fully behind the seat. No yellow pole may appear over the backrest, cushion, or leg space. Remove its visible floor foot and restore continuous upholstery, seat edge, and floor behind it.
Change only: the lower vertical pole segment from the seat's upper guard-rail connection downward, its floor foot, and the minimum hidden seat/floor pixels needed to close the gap.
Required invariants: keep the seat position, size, direction and perspective; preserve the upper pole, all other rails, adjacent seats, bus panels, window, sill, rain, road, traffic, right-side receding car, lighting, palette, focus-car empty area, and later overlay spaces. No broad repainting.
Style/medium: match the existing blue-gray value-and-layout study with simplified matte gouache, restrained graphite edges, broad value groups, and muted yellow metal.
Avoid: moving the seat; deleting the upper pole or horizontal rails; adding another pole; any rail crossing the backrest or cushion; any person, child reflection, phone, focus car, text, logo, UI, changed road or traffic direction, photorealism, glossy 3D, or production polish.
```

### 正式背景确认与晋级

`bg_c01_s02_bus_night_base_v001_candidate.png` 使用内置 `image_gen` 编辑模式分两步生成：先以已确认 v003 为编辑目标、v009 为完成度参考，将明度灰稿提升为正式手绘背景；再只把右侧同向车辆车身从灰蓝修正为低饱和暗红。首次完成度源 `exec-6b0a7aaf-a98e-48ce-81a1-bfe88d70583c.png` 未入库，最终源为 `exec-8886f6c0-cb4f-4edb-9fa4-0fa3df1d04ce.png`。源图 941 × 1671，入库前仅将高度归一化为 941 × 1672；最终 RGB PNG 的 SHA-256 为 `a144d543c382c31be06dd696ab17f0b52f742f0ad979d0ee628e12fa68666594`。用户于 2026-08-10 确认最终源图，候选状态晋级为 `approved_reference`；同哈希文件已复制为 `game/assets/art/production/c01_s02_commute_window/background/bg_c01_s02_bus_night_base_v001.png`，其状态为 `approved`，后续运行时和校准器只引用 production 路径。

完成度提示词核心约束：

```text
Use case: style-transfer
Asset type: production environment background for c01_s02_commute_window
Input images: Image 1 is the approved v003 composition layout; Image 2 provides only the deeper hand-painted finish, graphite/gouache language, cool rainy-night color depth, material separation, and restrained practical amber lights.
Primary request: turn v003 from a blue-gray layout study into a polished background-only painting while preserving the approved composition and layering contract.
Production finish: refine dark woven bus seats, matte metal, rubber seals, worn yellow rails, layered rain glass, ordinary wet road, trees, lamps, distant vehicles and puddle reflections. Keep the lower-left seat continuous and unobstructed. Keep the glass usable for a later clipped child reflection, the middle-right opposing lane clear for a separate focus car, and the lower areas clear for separate adult and phone layers.
Style/medium: original hand-painted 2D animation background, gentle graphite contours, matte gouache and transparent watercolor, simplified observed forms, restrained value modeling, tactile but not noisy; no imitation of any named artist, studio, film, shot, character, or signature design.
Lighting/mood: quiet ordinary rainy-night commute, cool navy and blue-gray with limited warm ochre rails and soft practical amber; readable shadow detail, no sentimental glow or magic.
Required invariants: preserve the 941 × 1672 crop, fixed camera, every bus structure, seat and rail clearance, window frame and sill, road geometry, lane directions, right receding car, distant traffic, trees, lamps and all future overlay spaces.
Must remain absent: adult, any person or silhouette, child reflection, smartphone, nearby focus car, baked interaction state, readable text, logo, watermark or UI.
Avoid: rail through seat, missing seat, changed geometry, moved traffic, photorealism, glossy 3D, cyberpunk neon, extreme darkness, excessive saturation, dense micro-detail, magic, or baked interactive objects.
```

右侧车辆颜色纠正提示词核心约束：

```text
Use case: precise-object-edit
Primary request: change only the rear-facing far-right car body to muted low-saturation deep red / weathered burgundy, plus its narrow corresponding wet-road reflection. Keep its tail lamps, shape, scale, position, perspective, road contact and receding direction unchanged.
Preserve: exact crop, bus, seat and rail clearances, window, rain, road, every other vehicle and light, open overlay areas, lighting and palette.
Avoid: bright red or orange, changing the car to a front view, moving it, adding vehicles, broad repainting, or changing any traffic direction.
```

### 前景扶手与座椅遮挡层候选

`fg_c01_s02_bus_rail_occluder_v001_candidate.png` 使用内置 `image_gen` 编辑模式生成，输入图为已确认正式背景；生成源为 `exec-8c92f483-91c5-422a-afa9-870ba2f93c33.png`。内置工具输出 941 × 1672 RGB 色键图，使用 imagegen 技能自带 `remove_chroma_key.py` 转为同画布 RGBA PNG；透明像素为 1,421,722 / 1,573,352，可见覆盖率约 9.64%，透明边缘像素 3,127，最终 SHA-256 为 `6285d5cea4ec3c913cfb9549acd4098d719ba7ae9b05af5f40df9bb047b70f30`。强不透明像素与正式背景同坐标区域的 RGB 平均绝对误差为 5.31 / 255，合成复查未见位置漂移。用户随后指出全画布尺寸不适合作为可摆放物件，因此该文件降为 `reference_only` 对齐母版。

最终提示词：

```text
Use case: background-extraction
Asset type: full-canvas foreground occlusion layer candidate for the Godot scene c01_s02_commute_window
Input images: Image 1 is the edit target and approved production background. Preserve its exact portrait crop and full-canvas coordinate system.
Primary request: isolate only the fixed bus structures that must render in front of the later seated adult character: (1) the lower-left horizontal worn-yellow safety rail that crosses directly in front of the empty character seat, including its rounded right bend; (2) the large worn-yellow curved rail across the lower foreground from lower center to the right edge; and (3) only the visible upper rim/backrest portion of the nearest dark blue-gray foreground seat beneath that lower rail. Remove every other image element.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for local background removal.
Style/medium: exact extraction from the existing original hand-painted 2D background; preserve existing graphite contours, matte gouache texture, lighting, wear, color and edge softness. Do not redesign or repaint.
Composition/framing: exact original full-frame 9:16 alignment. Every retained pixel group must remain at its original position, scale, perspective and silhouette so it can overlay Image 1 without manual registration.
Constraints: the chroma-key background must be one uniform #00ff00 with no shadows, gradients, texture, reflections or lighting variation. Retain no vertical poles, window frames, glass, road, scenery, vehicles, rear seats, the empty character seat itself, people, phones, reflections, text, logos, watermark or UI. Do not use #00ff00 within retained objects.
Avoid: moving, enlarging, completing or inventing rails; including the empty seat behind the future character; broad repainting; halos; transparent-looking green contamination; any change to geometry or crop.
```

2026-08-11 按用户要求将不相连内容拆成两张紧边界 production 资产。本次没有再次调用图像生成，也没有重绘或缩放，只对上方 RGBA 母版做确定性裁切：

| 文件 | 母版 `source_rect` | 输出尺寸 | SHA-256 |
| --- | --- | --- | --- |
| `fg_c01_s02_seat_armrest_occluder_v001.png` | `[0, 803, 334, 101]` | 334 × 101 | `20fa60b18adc6a0273530bc8fff39af35a1a7d52ab697ee121c5151e02dff6c9` |
| `fg_c01_s02_front_seat_occluder_v001.png` | `[248, 1346, 693, 326]` | 693 × 326 | `c5d6003c44e7c9d084ed56b4f12bf38066bd76d540bcc6632b297e9dd2e39e8e` |

两张裁切图按 `source_rect` 贴回 941 × 1672 母版后，Alpha 差异为空，可见 RGBA 像素差异为 0。初始锚点和显示尺寸由母版坐标换算写入场景布局 JSON，后续允许在 Godot 校准器中分别人工调整。

### 成年主角低头坐姿候选

`char_adult_commuter_seated_down_v001_candidate.png` 使用内置 `image_gen` 生成，输入参考为已确认的 `direction_selected_v009.png` 与正式背景 `bg_c01_s02_bus_night_base_v001.png`；生成源为 `exec-26d4b9d0-f804-447c-80c8-86731062e0bf.png`。源图为 1086 × 1448 RGB PNG，SHA-256 为 `015af744733720f1509db4459f068971ae2964942d4f4eedcef749c952e9ad6b`。

源图使用纯绿色背景生成，随后通过 imagegen 技能自带 `remove_chroma_key.py` 以 `--auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill` 去色键；自动采样键色为 `#04fa03`，全画布得到 898,376 个全透明像素和 5,723 个半透明边缘像素。人物 Alpha 包围盒为 `[180, 95, 914, 1448]`，以 16 px 透明安全边紧边界裁切为 766 × 1385 RGBA PNG；成品四边非透明像素为 0，SHA-256 为 `2a17e96084534f0bafc412d961f6ede69672d9c406f655197cd3934294ca53e2`。

评审预览 `preview_c01_s02_adult_down_v001.png` 使用正式背景原生 941 × 1672 画布，将人物候选缩放并放在 `rect = [-28, 612, 575, 1040]`。首次合成发现左侧水平扶手以 `z_index = 7` 绘制会横穿人物面部；保留其用户确认的坐标和尺寸，只将该层改为人物后方的 `z_index = 2`。底部弧形扶手与前排座椅继续以 `z_index = 7` 遮挡人物腿部。修正后预览 SHA-256 为 `0b50906b8c91fd82cd1fe0876766338cc77ad44ec80b6d57fd61aa761a08287d`。

用户随后指出 v001 的面部年龄明显偏大，且双手对称捧空的姿势不自然；v001 和对应预览均标记为 `rejected`，不进入 production。

提示词核心约束：

```text
Use case: isolated-character-asset generation for a layered Godot scene.
Generate exactly one ordinary East Asian man around age 35, average build, seated upright with a mild after-work slouch. His pelvis, torso, chest and shoulders face straight toward the front of the bus, read as facing the picture/viewer. His head is naturally bowed toward the future phone position near his lap; this is low-head State 0, not a window-looking pose.
Include the complete hair, torso, forearms, hands, lap and enough upper legs for a believable seated pose. Leave a clean rectangular negative space between relaxed hands for a separate phone asset; do not draw the phone, seat, rail, bus, window, reflection, prop or UI.
Style: original hand-painted 2D animation character, gentle graphite contour, matte gouache and restrained simplified cel shading, observed everyday anatomy, cool blue-gray ambient light and limited warm ochre edge light; stylized rather than photorealistic, not chibi, mascot-like, glossy 3D or franchise anime.
Backdrop: uniform solid #00ff00 chroma key with clean margin around the figure. No shadow, gradient, texture, halo, text, logo or watermark.
```

`char_adult_commuter_seated_down_v002_candidate.png` 继续使用内置 `image_gen` 编辑模式迭代。第一步源 `exec-58a139f1-d074-4cd7-a3c5-9fb61624d897.png` 建立纯绿色手机占位片与真实手指接触；第二步源 `exec-95229a27-c7e6-4650-8bdd-5d7740781445.png` 只减轻面部年龄感；最终源 `exec-b7256d0c-c7c9-4551-87ef-77cce49e2174.png` 将双手改为非对称动作：画面右手单手握持手机槽，画面左手自然搭在大腿上。最终源为 1086 × 1448 RGB PNG，SHA-256 为 `e888df4c1955e3efb9011e3891b7fc5992caf86ec95723a7b1181e42dca8050b`。

最终源继续通过技能自带 `remove_chroma_key.py` 以 `--auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill` 去色键；自动采样键色为 `#0bd608`，全画布得到 913,382 个全透明像素和 6,007 个半透明边缘像素。人物 Alpha 包围盒为 `[182, 104, 912, 1448]`，以 16 px 透明安全边裁切为 762 × 1376 RGBA PNG；成品四边非透明像素为 0，SHA-256 为 `d61710c6867fc37fd8f0532c3476b06b938bcd0a24eee113663c639641cc04b8`。纯绿色手机占位片同时被移除，形成供独立手机层置于手指后方的透明槽。

评审预览 `preview_c01_s02_adult_down_v002.png` 保持人物 `rect = [-28, 612, 576, 1040]`，左侧扶手在人物后方，底部前排座椅在人物前方。为使持机手势可读，预览仅在透明手机槽下方绘制无文字、无细节的灰蓝校准占位：外框 `(284, 1234, 365, 1371)`，内区 `(291, 1243, 358, 1360)`；它不是正式手机资产。预览 SHA-256 为 `b1c03b31cbaa1725e86f8d444d984785c153ab02ed8d65903864cb1eb0eabe61`。

v002 最终手势提示词核心约束：

```text
Preserve the youthful 32-to-34-year-old face, bowed head, frontal seated torso and green-screen workflow. Replace only both forearms, wrists, hands and the green phone placeholder with a relaxed asymmetrical commuter pose.
On the image-right side, one hand naturally holds a portrait phone-shaped #00ff00 chroma-key placeholder slightly right of center; four fingers curl behind it and the thumb rests along the lower front-side edge. On the image-left side, the other hand rests palm-down on the upper thigh with loose, gently separated fingers.
Avoid mirrored bowl-shaped hands, touching fingertips, an invisible sphere, crossed wrists, fused or extra fingers, a finished phone, environment, text, logo, watermark or UI.
```

用户随后指出 v002 仍然显老，并将目标年龄明确为约 26 岁；v002 与对应预览均标记为 `rejected`。

`char_adult_commuter_seated_down_v003_candidate.png` 使用内置 `image_gen` 对 v002 最终绿幕源进行年龄修正，生成源为 `exec-3e5d8d76-72cf-4467-a1b6-3df3e5c0a347.png`。本轮保留既有低头坐姿、画面右手持机、画面左手搭腿和纯绿色手机槽，同时统一年轻化面部、颈部、肩臂与手部。源图为 1086 × 1448 RGB PNG，SHA-256 为 `98222e98ae4672efd80cf1aaf94eb1570d81c72ef93c4599d77f8b677552c8b8`。

源图通过技能自带 `remove_chroma_key.py` 以 `--auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill` 去色键；自动采样键色为 `#07d804`，全画布得到 912,005 个全透明像素和 5,610 个半透明边缘像素。人物 Alpha 包围盒为 `[181, 99, 913, 1448]`，以 16 px 透明安全边裁切为 764 × 1381 RGBA PNG；成品四边非透明像素为 0，SHA-256 为 `ba929bce75f7096ed67bd0974d85aec6efec76311a5d6697fd8d729695403886`。纯绿色手机占位片同步形成透明手机槽。

评审预览 `preview_c01_s02_adult_down_v003.png` 使用人物 `rect = [-28, 612, 575, 1040]`，继续在人物下方使用与 v002 相同的无文字灰蓝手机校准占位，左侧扶手位于人物后方，底部前排座椅位于人物前方。预览 SHA-256 为 `7e1dee3267e695182096cabd1f7521f56532a5f78f7149b143cccfc62457733d`。

用户于 2026-08-11 确认 v003。候选逐字节晋级为 `game/assets/art/production/c01_s02_commute_window/characters/char_adult_commuter_seated_down_v001.png`，SHA-256 仍为 `ba929bce75f7096ed67bd0974d85aec6efec76311a5d6697fd8d729695403886`。运行时人物层使用 `anchor = (0.2758, 0.6770)`、`visual_size = 440 × 796`、`z_index = 4`；对应源图裁切坐标为 `[181, 99, 732, 1349]`。临时手机位按透明槽重标为 `anchor = (0.3448, 0.7790)`、`visual_size = 62 × 105`、`hit_size = 180 × 180`、`z_index = 3`，正式手机仍待单独生成和确认。

v003 年龄修正提示词核心约束：

```text
Redraw the person so he reads immediately as an ordinary East Asian man aged about 26, not 30+, middle-aged, or a teenager. Remove mature age cues across the face, neck, build, and hands: smooth forehead and under-eye planes, softly tapered youthful jaw, slightly fuller cheeks, slimmer neck and forearms, smoother youthful hands with lighter joint definition.
Preserve the exact frontal seated pose, bowed head, downward gaze, image-right single-hand phone grip, image-left hand resting on the thigh, and the uniform #00ff00 phone placeholder for a separate phone layer.
Keep an original hand-painted 2D animation language with gentle graphite, matte gouache and simplified soft-edged cel shading; avoid idol styling, giant eyes, chibi, glossy 3D, photorealism, text, logo, watermark or UI.
```

### 成年主角抬头坐姿候选

`char_adult_commuter_seated_look_up_v001_candidate.png` 使用内置 `image_gen` 编辑已确认低头状态的完整绿幕源 `exec-3e5d8d76-72cf-4467-a1b6-3df3e5c0a347.png`，生成源为 `exec-04e0017f-a15d-4657-936e-562fd8fe2d77.png`。生成源为 1085 × 1450 RGB PNG，SHA-256 为 `652fa7eb684e6efe7f63b75a0ceb737450008e7dab63f7ad16e0536e4c5fbeda`；为保持两个状态同坐标，先以 Lanczos 确定性归一化到 1086 × 1448，再只使用其第 0–740 行。第 620–740 行与已确认低头源渐变融合，第 741 行以下逐像素复用低头源，因此腰腿、双臂、双手和手机槽不会随状态切换漂移。归一化源 SHA-256 为 `7f05136cda853b84e7d5973b5e6c3ced2bde94e2e762ea925cb8f3be9df1b3a5`，融合绿幕源 SHA-256 为 `dda2b5ca4b70eaa14955f7d03111ba513996b85582e91f6e07e7de7cc8159964`。

融合源通过技能自带 `remove_chroma_key.py` 以 `--auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill` 去色键；自动采样键色为 `#06ce08`，全画布得到 903,714 个全透明像素和 6,026 个半透明边缘像素。随后严格复用低头状态的固定裁切窗口，不按新 Alpha 包围盒重新定位：从归一化源坐标 `(165, 83)` 起裁切，并在底部补足透明安全边，得到 764 × 1381 RGBA。为消除两次去色键采样差异，最终再将候选第 658 行以下替换为已确认 production 低头人物的对应 RGBA 像素；逐像素相等检查通过。成品 Alpha 包围盒为 `[16, 4, 748, 1365]`，四边非透明像素为 0，含 386,026 个全透明像素和 6,270 个半透明边缘像素，SHA-256 为 `3b0a7307a465c9a77b5584b371f1a9deb9505c7fc1eb4160753c54985ab1962c`。

评审预览 `preview_c01_s02_adult_look_up_v001.png` 与低头状态使用相同人物 `rect = [-28, 612, 575, 1040]`、手机校准占位和结构层顺序。预览 SHA-256 为 `cec14922f2c100291ce7031f4bb0333c3d5d65f05c1972d492169ce4576a4600`。候选只改变头颈与必要的上肩过渡：身体仍朝车前方，头转向画面右侧车窗，视线略向上，表情平静且刚刚注意到外界；确认前不进入 production。

用户于 2026-08-11 确认抬头 v001。候选逐字节晋级为 `game/assets/art/production/c01_s02_commute_window/characters/char_adult_commuter_seated_look_up_v001.png`，SHA-256 仍为 `3b0a7307a465c9a77b5584b371f1a9deb9505c7fc1eb4160753c54985ab1962c`。布局中的成人层保留低头图为默认 `asset_path`，并以 `state_asset_paths.down` / `state_asset_paths.look_up` 登记两个 production 路径；两种状态共享同一锚点、尺寸和层级，不创建会与默认人物重叠的第二个常驻视觉层。

抬头状态提示词核心约束：

```text
Preserve the exact canvas, identity, age about 26, frontal seated body, clothing, arms, hands and green phone slot from the confirmed low-head source. Change only the head and neck with minimal necessary shoulder response: lift the head, turn naturally toward the image-right bus window, and look upward-right in a modest three-quarter view.
Keep a calm, newly attentive expression with relaxed brows and neutral lips. No smile, fear, surprise, direct camera gaze, environment, phone, child, reflection, text, logo, watermark or UI.
```

### 通勤手机

`prop_phone_commute_cold_v001_candidate.png` 使用内置 `image_gen` 生成。首次源 `exec-6d7ab856-428a-431c-8c11-1ee46ec5bbaf.png` 的机身比例偏窄，未入库；最终源 `exec-2ce4e535-43fe-4927-9704-9ffbb3ec83d3.png` 只加宽机身，保留正面竖持角度、暗色磨砂边框、低亮度冷蓝灰屏幕和不可读抽象块面。最终源为 964 × 1632 RGB PNG，SHA-256 为 `f392019af3f507db7013073c63683e4b09457b73447eaf650a61fc20cc570d53`。

最终源通过技能自带 `remove_chroma_key.py` 以 `--auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --edge-contract 1 --despill` 去色键；自动采样键色为 `#06f405`，全画布得到 778,775 个全透明像素和 3,956 个半透明边缘像素，Alpha 包围盒为 `[151, 185, 811, 1414]`。裁切后将 660 × 1229 主体轻微横向归一化为 714 × 1229，再增加四周 16 px 透明边，得到 746 × 1261 RGBA；纹理宽高比为 `0.591594`，与运行时 `62 × 105` 容器基本一致。最后清除 Alpha 小于 32 的边缘噪点并中和残余色键污染；可见像素中不再存在绿色主导边缘。成品四边非透明像素为 0，SHA-256 为 `13ad4a4fb751f649975e0e60fadf6fd281900643a078c1616c66ae8b8c075338`。

两张评审预览都将手机绘制在正式背景原生画布 `(284, 1234, 81, 137)`，对应逻辑布局 `anchor = (0.3448, 0.7790)`、`visual_size = 62 × 105`、`z_index = 3`；人物继续使用 `rect = [-28, 612, 575, 1040]`、`z_index = 4`，因此手指覆盖手机边缘。低头预览 `preview_c01_s02_phone_cold_adult_down_v001.png` 的 SHA-256 为 `46274fd7098e256e520c410b527a53795aeeecfaa60330f284f3d4052b39cbd2`；抬头预览 `preview_c01_s02_phone_cold_adult_look_up_v001.png` 的 SHA-256 为 `c2930f7abb15e5cd070a5e0a84f1c688951b0f068cf9e8c949ab01c5de1224c4`。

用户于 2026-08-11 确认手机 v001。候选逐字节晋级为 `game/assets/art/production/c01_s02_commute_window/props/prop_phone_commute_cold_v001.png`，SHA-256 仍为 `13ad4a4fb751f649975e0e60fadf6fd281900643a078c1616c66ae8b8c075338`。JSON `phone.asset_path` 已写入 production 路径；锚点、视觉尺寸、命中尺寸和层级保持不变，`locked = false` 以便继续人工校正。

手机提示词核心约束：

```text
Generate exactly one ordinary contemporary unbranded smartphone, front-facing and upright, with a tall narrow 0.59 width-to-height silhouette, thin dark charcoal blue-gray matte case, and dim cool blue-gray screen containing only unreadable abstract value blocks.
Match the original hand-painted 2D graphite-and-gouache prop language. Use a uniform #00ff00 chroma-key background. No hand, person, scene, readable UI, text, icons, clock, logo, watermark, glow halo, shadow or any other object.
```

### 对向焦点车辆候选

`prop_vehicle_focus_base_v001_candidate.png` 使用内置 `image_gen` 生成。首轮源 `exec-3db3f71e-3f51-4b93-a6c5-151bf94961a8.png` 的侧面占比过高、接近产品展示角度，未入库；第二轮源 `exec-811fb3ef-d2a7-4801-a10c-7526edd95229.png` 将同一普通车型转为近正面迎向公交，但质感仍偏产品图，未入库；最终源 `exec-762cbc04-e661-4cca-b411-e6d299e752e7.png` 只收敛为石墨线、哑光水粉与克制赛璐珞明暗，保留第二轮的角度、轮廓、灯罩和空白前牌几何。三张源图 SHA-256 依次为 `2e4db52e5892dd3fbb35a72beaf6d290a338b5d4cae27b92b2b348497e3bfbe9`、`c94159e38c3e4c13993c8d84de0596df979652a9c0b388248668ac9a8ee18ba2`、`f2a3c2f5043d60544c033ce3191df09e9d5118e733c7abcf71e007db9ad85142`。

最终源通过技能自带 `remove_chroma_key.py` 以 `--auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --edge-contract 1 --despill` 去色键；自动采样键色为 `#0eea1a`。清除 Alpha 小于 32 的边缘噪点与残余低 Alpha 色键像素后，按可见包围盒四周增加 16 px 安全边，得到 946 × 696 RGBA 候选。成品 Alpha 包围盒为 `[16, 16, 930, 680]`，四角与四边均为全透明，可见像素中无绿色主导残留，SHA-256 为 `5b90265a45efb6b90b48b0cf2c3fbf9412c4e71fdd5652d96c9c0f1df1167ac4`。

背景评审预览将车辆绘制在正式背景原生画布 `(469, 588, 400, 294)`，对应逻辑建议值 `anchor = (0.7110, 0.4396)`、`visual_size = 306 × 225`、`z_index = 1`。背景预览 `preview_c01_s02_vehicle_focus_base_v001.png` SHA-256 为 `d5101d256ab2f62dd909d735f4d7dc3e4cfc064f71f1b6fb9bfbc0d7dfc6acc0`；完整关系预览 `preview_c01_s02_vehicle_focus_base_look_up_v001.png` SHA-256 为 `18e4854d944716cc3da570eb500d113ab01282c97f434af49a764cf802692a3b`。用户随后指出车辆纵轴和可见车身侧面均与道路不符，且存在悬浮、缺少湿路反射和覆盖雨纹的贴图感；候选与两张预览均改为 `rejected`，不进入 production 或布局 JSON。

车辆提示词核心约束：

```text
Generate exactly one ordinary contemporary unbranded dark graphite family car approaching the bus in the opposing lane, nearly head-on with only a restrained front three-quarter cue. Preserve two readable dim-neutral headlamp housings and one centered blank matte-gray plate recess for later independent overlays.
Match the original hand-painted 2D graphite, matte-gouache and restrained cel-shaded game language on a uniform #00ff00 chroma-key background. No road, shadow, rain, occupants, readable text, logo, badge, watermark, glow, beam, cartoon face, recognizable real model, photorealism or glossy 3D.
```

v002 改为先生成完整场景关系，再拆分运行时资产。第一次场景源 `exec-a08ce3a1-5590-4cbd-b395-0787e2fb8399.png` 建立正确车道角度、接地和玻璃层级，SHA-256 为 `938b0dfe6df89b45f168d073d47fd22e6cd10d90091acf6dfafe91e771453d10`，但格栅中央出现疑似真实厂牌标志，未入库。第二次只清除该标志，其他像素关系保持不变；最终源 `exec-fed6b3dd-247d-4140-8d46-095ce07fb159.png` 保存为 `preview_c01_s02_vehicle_focus_context_v002.png`，SHA-256 为 `f492b2adb281b7438e197459f71269f0f994feef427c80f1431358e370174634`。本地确定性叠加已确认人物、手机和结构层后得到 `preview_c01_s02_vehicle_focus_context_look_up_v002.png`，SHA-256 为 `7299b3ec42f120a5362f7ebff0d398f28acb39286317d1d103e8f1f773c97d1f`。

v002 核心提示词约束：

```text
Use case: illustration-story
Asset type: full-scene perspective and grounding review for a portrait 2D narrative game
Primary request: replace the empty opposing-lane focus area with one ordinary unbranded dark graphite family car whose perspective is fully integrated into this exact rainy bus-window scene.
Composition/framing: the opposing lane runs from distant upper-left to near lower-right; the car nose follows that axis and points slightly toward canvas lower-right. Show predominantly the image-left front fender, image-left flank and image-left mirror; the image-right flank and wheel must recede. Keep both wheels inside the opposing lane.
Lighting/mood: match the existing cool blue-gray rainy night, restrained warm lamps and matte hand-painted 2D treatment.
Constraints: believable tire contact, subtle undercar shadow, broken wet-road reflection along the road axis, and existing rain/glass texture visibly above and through the vehicle. Keep two lamp housings and one blank unreadable plate recess. Preserve the bus interior, seat, rails, distant traffic and image-right dark-red receding car.
Avoid: symmetric head-on or product-shot view, dominant image-right body side, floating wheels, pasted sharp silhouette, dry road beneath the car, logo, badge, readable plate, real model, photorealism, glossy 3D or cartoon face.
```

v002 当时只保存两张评审预览，没有生成 `prop_vehicle_focus_base_v002_candidate.png`，也没有写入 production 或布局 JSON；计划在场景关系确认后才派生独立车身、路面阴影/湿反射和玻璃雨纹三层。

用户于 2026-08-12 撤回继续指令并拒绝 v002：车辆外宽几乎占满甚至超过该深度的可用车道宽，轮胎两侧缺少连续湿路余量。v002 两张预览改为 `rejected_review`，未开始的拆分、production 晋级和布局接入继续取消。

v003 尺度修正使用内置 `image_gen` 的 `compositing` / `precise-object-edit` 流程，以正式空道路背景为编辑底图、v002 为角度参考，并用临时像素标注约束车道边界与最大车身范围。过小远景版本 `exec-36b841eb-c69e-4e92-afff-353d3a9a3c05.png`、错误回到近似 v002 大小的 `exec-13149008-466d-4fff-b4c8-d4ce618d8067.png`、再次过小的 `exec-1402c090-77f3-4160-af29-2d2d5ab16299.png` 和仍含徽标的 `exec-e670ad83-8d59-4138-be28-8c48ba47fbaa.png` 均未入库。最终采用的生成源为 `exec-4d247436-7197-4397-b96b-a6fff7465c6b.png`，SHA-256 为 `a475ad4e66ded92f754f2fe5cbbb05252be76b355d6c441076e1a8b615c8aed5`；车辆外轮廓约 300 px，该深度可用车道宽约 400 px，两侧均留出连续湿路。源图格栅中央出现约 42 × 41 px 的疑似徽标，本地使用逐行水平纹理插值并以羽化椭圆只覆盖徽标区域，未改变车辆尺度、角度、灯、车牌、阴影、反射或其余场景。最终 `preview_c01_s02_vehicle_focus_context_v003.png` SHA-256 为 `bc893ffc8b30619d51cceb470711a1db4ffc9784356fdc9cc7e0999536ed43c9`；完整关系版 SHA-256 为 `64b5ed1c4c82611d675eb90d8d1c825e8a4e9fa196cabf7115b37d06cba573a7`。

v003 使用的核心尺度约束：

```text
The opposing lane runs from distant upper-left to near lower-right. Preserve the corrected three-quarter angle with the image-left front fender/flank/mirror dominant and the image-right side receding. Keep normal vehicle proportions; never horizontally squeeze. At the vehicle depth, tire-to-tire width must occupy about 75 percent of the usable lane width, with a continuous visible strip of wet pavement between both outer tire edges and the adjacent lane boundaries. Preserve contact shadow, broken wet reflection, and rain/glass texture above and through the vehicle. No logo, badge, readable plate or recognizable real model.
```

用户随后确认 v003 的车辆大小符合，但通过 `reference_c01_s02_vehicle_lane_markup_v001.png` 指出道路拓扑错误：右下圈出的旧亮线必须删除，近侧边界必须沿长红线从车身左后方延伸到画面右下。v003 两张图因此改为 `rejected_review`，但继续作为车辆大小、位置、角度、阴影和湿反射的锁定基准。

v004 为确定性局部修正。先将用户 738 × 596 标注按 `941 / 738` 比例映射回原始画布并补偿约 320 px 的标注截图纵向裁切；使用未含焦点车的内置 `image_gen` 失败稿 `exec-f666a5f8-800f-4184-8280-e2542b85ae52.png` 仅作为右下旧亮线区域的湿路像素 donor，不采用其余区域。新边界中心线按标注轨迹约从 `(422, 785)` 延伸到 `(905, 1057)`，由远及近从约 6 px 渐宽到 12 px，并加入低对比、羽化和确定性磨损。最终车辆区域取自 v003，大小、位置、角度、车灯、前牌、阴影、反射与玻璃雨层均未重生成。

本轮精确局部编辑约束如下：

```text
Change only the road lane markings. Preserve the exact current car size, position, proportions, three-quarter angle, lighting, contact shadow, wet reflections, rain and glass texture. Remove the circled lower-right bright stripe. Place one worn, dim lane boundary along the user's long red trajectory, converging from upper-left to lower-right and widening subtly toward the foreground. Do not move, resize or redraw the vehicle.
```

最终 `preview_c01_s02_vehicle_focus_context_v004.png` SHA-256 为 `1d5e49479961f61af5d9203962671c3079f1ae4e7121244b8fc0f74f30ad8ab8`；完整关系版 SHA-256 为 `e96a4e3b03ef98d695a5a1b03a4fd7f6b20ab7046976c0c0b66b55f2423551f1`。v004 当时只用于场景评审，没有生成独立车辆或效果层，也没有改 production 与布局 JSON。

Godot 4.7.1 已正常导入两张 v004 预览和用户标注参考；像素差异仅位于原图 `(418, 781)–(940, 1064)` 道路区域，车辆区域最大像素差为 0；状态与存档 138 条断言、内容目录 5 章 30 幕 9 件收集物、交互系统 197 条断言与 17 类契约均通过，主场景和校准器 smoke test 正常。

用户随后澄清：红线是手工位置示意，不应完全按其弯折绘制；正确车道线必须是直线。v004 因过度复刻手绘路径降为 `rejected_review`。v005 继续使用同一湿路 donor 清除旧线，但不再对红色连通域逐点跟踪，而是只取大致端点 `(422, 785)` 与 `(905, 1057)` 建立严格直线中心轴；线宽从远端约 6 px 线性渐增到近端约 12 px，磨损只调制透明度和边缘，不改变几何方向。车辆区域继续逐像素取自 v003。

v005 的精确局部编辑约束如下：

```text
Treat the user's red stroke only as a positional corridor, not exact geometry. The lane boundary centerline must be a straight perspective line between the approximate marked endpoints. It may widen linearly toward the foreground and vary only in opacity or edge wear; it must not bend, wobble or follow the hand-drawn stroke point by point. Preserve every vehicle pixel and remove the circled old stripe.
```

最终 `preview_c01_s02_vehicle_focus_context_v005.png` SHA-256 为 `dbf7ac8c7ac7fc0b5a482bae3d63dfdb1b33541d72f525771d578d57ac5eeac6`；完整关系版 SHA-256 为 `56821c1ff82eebcab880a931ec568532d25d3fc4dfb6f87e2353dc08223a47b6`。用户于 2026-08-12 确认 v005，状态改为 `approved_reference`。

v005 的中心轴相对端点直线最大叉积误差约 `7.28e-11`，只存在浮点误差；像素差异仅位于原图 `(418, 781)–(940, 1063)` 道路区域，车辆区域最大像素差为 0。Godot 4.7.1 已正常导入两张 v005 预览；状态与存档 138 条断言、内容目录 5 章 30 幕 9 件收集物、交互系统 197 条断言与 17 类契约均通过，主场景和校准器 smoke test 正常。

确认后不再生成车辆，而是从同一 v005 确定性派生四层。正式背景把 `v005 - v003` 的道路差分施加到已确认无车背景，保证直线车道只属于环境；车身、接地效果和玻璃雨纹按可见内容紧边界裁切，初始坐标从 941 × 1672 母版换算到 720 × 1280 逻辑画布。结果如下：

| production 文件 | `source_rect` | 逻辑 `anchor` | `visual_size` | `z_index` | SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `background/bg_c01_s02_bus_night_lane_v002.png` | `[0, 0, 941, 1672]` | 全画布 | `720 × 1280` | 背景 | `af5524ced48deb58552aec3f62d294c7e099099fc378aeffd033ad5f9983801d` |
| `props/prop_vehicle_focus_base_v001.png` | `[456, 596, 367, 226]` | `(0.6796, 0.4240)` | `281 × 173` | 1 | `91cd20dd0a39f5bea71b7c0b7961ecfe31fd23e29c323157987a5ff266d69b3b` |
| `effects/fx_vehicle_grounding_v001.png` | `[435, 729, 408, 328]` | `(0.6791, 0.5341)` | `312 × 251` | 0 | `54d2f2159777723835c6c85a820b25f5639cb71ea3e85bb97ff94d1a2f20cad7` |
| `effects/fx_vehicle_glass_rain_v001.png` | `[464, 597, 350, 220]` | `(0.6791, 0.4228)` | `268 × 168` | 3 | `3c97454b76b5ed1105ff5d479004c4f2853e101c4668c44bfbca499519985d51` |

三张可移动层均为 RGBA、`locked = false`；接地层在车身下方，玻璃雨纹当前位于车身及后续车灯/车牌覆盖层上方，车道线不在任一可移动层。首次分层检查时交互自检为 217 条断言、17 类契约；车灯/车牌接入后的当前结果见下文。此处未调用新一轮图片生成：分层完全来自已确认图和同场景无车 donor 的确定性局部处理，避免改变车辆设计。

2026-08-12 继续从 production 车身确定性派生车灯和车牌状态，没有调用新一轮图片生成，也没有重绘整车。车灯使用车身局部 `source_rect = [562, 695, 205, 59]`，两只灯罩之间的格栅保持透明；车牌使用 `source_rect = [635, 742, 93, 35]`。中性态保留确认图像素，车灯变化态只在灯罩蒙版内降低亮度并增加轻微上缘遮光，车牌变化态只在不可读牌面下缘增加约 2 px 的浅弧形阴影。四张状态共用各自裁切、锚点和透明边界，雨纹在合成预览与运行时均重新置于其上方。

| 候选文件 | SHA-256 |
| --- | --- |
| `props/prop_vehicle_headlights_neutral_v001.png` | `b66b8977f401ab9c37593a8da67b59f34cfab6406ce2c773c9a4fa4e7741abda` |
| `props/prop_vehicle_headlights_blink_v001.png` | `49e9228cbe470736c26ff7c8949ac6b230b3c68e5eec7b02332ec8afc9baf81b` |
| `props/prop_vehicle_plate_neutral_v001.png` | `0ac2be5ebd5fd06df255e39f4e3d287fbd568092b762d4706fb10977548482d1` |
| `props/prop_vehicle_plate_mouth_hint_v001.png` | `e5b5ed9eef44a17dd3f6a2e999786d63e0676cd841f8687c5725be4de170fe64` |

`preview_c01_s02_vehicle_state_candidates_v001.png` 提供放大状态与 Alpha 边界对照；`preview_c01_s02_vehicle_states_neutral_v001.png` 和 `preview_c01_s02_vehicle_states_hint_v001.png` 提供完整场景关系。初始校正值为：车灯 `(0.7062, 0.4333)`、视觉 `157 × 45`、命中 `176 × 72`；车牌 `(0.7242, 0.4542)`、视觉 `71 × 27`、命中 `96 × 56`。二者保持 `locked = false` 并以 `style-studies` 路径接入评审状态，用户确认前不进入 production。Godot 4.7.1 已正常导入 7 张候选与预览；状态与存档 138 条断言、内容目录 5 章 30 幕 9 件收集物、交互系统 235 条断言与 17 类契约通过，主场景和校准器 smoke test 正常。

## 资产清单

| 工程文件 | 用途 | 生成源文件 |
| --- | --- | --- |
| `game/assets/art/title_key_art.png` | 标题画面、角色与风格锚点；已修正公交座椅方向 | `exec-c467e077-edd3-4e1e-be96-c01121e2f471.png` |
| `game/assets/art/backgrounds/chapter_01.png` | 第一章夜路车阵；已修正座椅、车辆方向与透视 | `exec-dcde6cfd-e951-442a-b00b-bb73c6d0e108.png` |
| `game/assets/art/backgrounds/chapter_02.png` | 第二章学校环线；已修正为标准连续椭圆跑道 | `exec-c902813a-3f90-46dc-9bd5-36ce1f19e0d3.png` |
| `game/assets/art/backgrounds/chapter_03.png` | 第三章书脊城市与纸片剧场 | `exec-863e2d98-1772-4e9a-b3d8-343cbc940d1f.png` |
| `game/assets/art/backgrounds/chapter_04.png` | 第四章雨夜教室与柜群 | `exec-3b22988f-7a00-452f-b068-e0c486ec5d43.png` |
| `game/assets/art/backgrounds/chapter_05.png` | 第五章密林与地下教室 | `exec-0603ee2a-3ef4-497f-9e6a-2da7ab50b505.png` |
| `game/assets/art/backgrounds/reality_room.png` | 现实段与最终桌面复用 | `exec-0d12eba2-42c1-4861-bb7f-d8bf9f15d53e.png` |
| `game/assets/art/props/everyday_props_atlas.png` | 现实房间、通勤和学校日常物件 4×4 图集 | `exec-365d8979-b147-4a89-b684-ccd67dbef33a.png` |
| `game/assets/art/props/paper_props_atlas.png` | 漫画、纸片角色和柜中物件 4×4 图集 | `exec-7de8b4eb-64e8-499e-a0fc-de5607eb135f.png` |
| `game/assets/art/props/shelter_forest_props_atlas.png` | 藏身、森林和地下教室物件 4×4 图集 | `exec-7dac602c-cb33-445f-8a44-69af139a6e86.png` |
| `game/assets/art/props/action_props_atlas.png` | 车辆、信号灯与手势反馈物件 4×4 图集 | `exec-2acc710e-da9f-48f6-a535-c921f8a0895b.png` |

## 最终提示词

### 标题与风格锚点

```text
Use case: illustration-story
Asset type: vertical 2D narrative game key art and visual style anchor
Primary request: original key art for a gentle point-and-click game about an emotionally numb adult rediscovering childhood imagination
Scene/backdrop: a quiet city bus at night; through the large window, ordinary traffic lights subtly become expressive eyes, while faint layered motifs of a school track, paper pages, an old cabinet, and a forest path emerge like memories
Subject: one ordinary East Asian adult man in simple contemporary clothes, seated in a forward-facing city-bus seat with torso and knees aligned to the bus travel direction, turning only his head toward the side window; his reflection is the same person as a small child leaning closer to the glass with curiosity
Style/medium: hand-painted 2D game illustration, graphite linework, soft gouache washes, tactile recycled-paper grain, restrained indie narrative game finish
Composition/framing: portrait 9:16 full-bleed composition for a mobile game title screen; clear silhouettes; keep calm open space near the upper third and lower edge for interface overlays; no border
Lighting/mood: muted blue-gray reality gradually warming into amber, dusty teal, faded coral and chalk white around the child reflection; intimate, observant, hopeful but not sentimental
Constraints: exactly one adult and one child reflection of the same person; all seat rows and the aisle run toward the front of the bus; outside cars travel parallel to the bus and recede toward the same road vanishing point, never approaching the bus broadside; original design; no readable text; no logos; no trademarks; no watermark; no famous characters; no UI baked into the artwork
Avoid: anime franchise look, photorealism, glossy 3D, horror, dramatic portal, combat, magical explosion, excessive saturation, motivational-poster sentiment
```

### 第一章

```text
Use case: stylized-concept
Asset type: production game environment background for Chapter 1, portrait mobile 9:16
Input images: Image 1 is the locked visual style and character-palette reference; use its graphite linework, soft gouache, recycled-paper grain, muted blue-gray to amber transition, but create a new playable composition
Primary request: the inside of a city bus at night seen from the back seat, with every passenger seat facing forward along the aisle; a large rain-streaked side window reveals a clear five-car traffic formation and one red/green signal tower; the visible cars travel in the same direction as the bus, shown from rear or rear three-quarter angles, and their lights and license plates subtly read like different friendly or wary faces
Subject: the bus window and five vehicles are the focal play area; a small quiet child reflection is visible in the glass, while only a partial adult shoulder silhouette appears at the lower edge
Composition/framing: full-bleed portrait 9:16; bus aisle, seat rows, road lanes and outside vehicles share coherent forward depth and compatible vanishing points; uncluttered center play field; distinct car silhouettes and generous gaps for touch hotspots; fixed 2D point-and-click camera
Lighting/mood: ordinary urban night slowly reinterpreted through imagination; cool navy, charcoal and desaturated steel with restrained warm headlight amber and signal red/green
Constraints: match Image 1 style; original imagery; no readable text; no logos; no trademarks; no watermark; no UI baked in; no famous characters
Avoid: photorealism, cyberpunk neon, racing action, crashes, weapons, horror, dramatic magic portal, excessive saturation
```

### 第二章

```text
Use case: stylized-concept
Asset type: production game environment background for Chapter 2, portrait mobile 9:16
Input images: Image 1 is the locked visual style and palette reference; preserve its hand-painted graphite-and-gouache paper texture
Primary request: an ordinary Chinese city school at dusk with a physically correct athletics track: exactly two parallel straightaways connected by two smooth semicircular bends, continuous evenly spaced lane markings and an open field fully enclosed inside the oval; warm classroom windows, a faint trail of chalk dust, childlike arrows and circles on the wall, and a distant island of old wooden desks
Subject: school gate, standard oval track and wall path create a clear circular interaction route; no crossed, broken, branching or tangled lanes; no character in the foreground
Composition/framing: full-bleed portrait 9:16, slightly elevated fixed point-and-click view; central school and oval path clearly readable; distinct inner lane; open lower edge for translucent controls
Lighting/mood: first three quarters restrained gray-green evening, with gentle amber windows and chalk-white accents suggesting that the world is loosening rather than transforming abruptly
Constraints: match Image 1 style; original environment; no readable words; simple childlike chalk symbols only; no logos; no trademarks; no watermark; no UI baked in
Avoid: fantasy castle school, dramatic portal, crowded students, horror, perfect glossy digital painting, excessive saturation
```

### 第三章

```text
Use case: stylized-concept
Asset type: production game environment background for Chapter 3, portrait mobile 9:16
Input images: Image 1 is the locked visual style and palette reference; preserve its tactile graphite lines, soft gouache and old-paper grain
Primary request: an imaginative city made from tall book spines and floating comic panels, leading to a tiny handmade paper theater built from cardboard and sticky notes; three completely original childlike paper-drawing friends appear warm, wobbly and imperfect
Subject: book-spine streets, four clearly separate blank picture panels, a small bridge gap and old bookmark are distinct interaction landmarks
Composition/framing: full-bleed portrait 9:16; layered upward path from books at bottom to panels in center to paper theater near top; ample touch spacing; calm lower edge for translucent UI
Lighting/mood: dusty teal, faded coral, parchment cream, graphite gray and a restrained amber glow; affectionate and handmade, not sugary
Constraints: match Image 1 style; all paper friends must be original abstract silhouettes with no resemblance to known manga/anime/cartoon IP; no readable text; no logos; no trademarks; no watermark; no UI baked in
Avoid: recognizable blue robot cats, famous character clothing or props, polished superhero art, photorealism, glossy 3D, excessive cuteness, crowded collage
```

### 第四章

```text
Use case: stylized-concept
Asset type: production game environment background for Chapter 4, portrait mobile 9:16
Input images: Image 1 is the locked visual style and palette reference; preserve its graphite linework, soft gouache and tactile recycled-paper grain
Primary request: a rain-darkened old classroom flowing into a corridor of many school storage cabinets; one cabinet is half open with a narrow warm seam of light, a school bag rests near the window, and tree shadows move gently beyond the glass
Subject: three clear spatial interaction targets—the rainy window, corridor door, and school bag—plus three distinct cabinets and one close half-open hiding cabinet
Composition/framing: full-bleed portrait 9:16, fixed 2D point-and-click camera, readable foreground cabinet at lower center, clear touch spacing, subtle open lower edge for translucent controls
Lighting/mood: intimate tension and safety at the same time; cool rain blue-gray, dark wood and aged green metal, with a small amber seam; never frightening
Constraints: match Image 1 style; original environment; no people; no readable text; no logos; no trademarks; no watermark; no UI baked in
Avoid: horror game, monster, blood, jump-scare lighting, prison cell, dramatic spotlight, glossy 3D, excessive darkness
```

### 第五章

```text
Use case: stylized-concept
Asset type: production game environment background for Chapter 5, portrait mobile 9:16
Input images: Image 1 is the locked visual style and palette reference; preserve its graphite, gouache and old-paper visual language
Primary request: a quiet forest path behind an old school descending naturally into an impossible underground classroom where a blackboard, bus window, comic page and cabinet coexist; on a modest clay table sits a small worn transparent box containing an ambiguous beetle-shaped fossil
Subject: the path invites the eye forward; the four memory objects are distinct but integrated; the fossil box feels discovered rather than rewarded; two subtle hand-shaped shadows overlap near a plain morning-light exit
Composition/framing: full-bleed portrait 9:16, layered depth from forest foreground through classroom middle to ordinary morning light near the top; clear touch landmarks and open lower edge for translucent controls
Lighting/mood: curious, hushed and open-ended; moss green, charcoal, dusty teal, parchment and gentle dawn amber; no grand revelation
Constraints: match Image 1 style; original environment; no readable text; no logos; no trademarks; no watermark; no UI baked in
Avoid: treasure chest, reward glow, archaeological dig, fantasy cave crystals, horror, monster, magical portal, victory spectacle, glossy 3D
```

### 现实房间

```text
Use case: stylized-concept
Asset type: reusable production game background for reality interludes and final echo, portrait mobile 9:16
Input images: Image 1 is the locked visual style and palette reference; preserve its quiet graphite-and-gouache paper texture
Primary request: a modest contemporary apartment room in soft ordinary morning light, with an uncluttered wooden desk, chair, shaded window and a turned-over phone; the desktop is intentionally mostly empty so collected keepsakes can be layered by the game at runtime
Subject: empty tabletop is the main interaction area; window, lamp, chair, shelf and phone are clear landmarks
Composition/framing: full-bleed portrait 9:16 fixed point-and-click camera; generous clean tabletop in the lower-middle; warm negative space for dynamic item sprites and translucent UI
Lighting/mood: credible everyday calm, slightly warmer than the title scene but not idealized; charcoal, warm gray, dusty cream and a small amber morning glow
Constraints: match Image 1 style; no person; keep the tabletop empty except for the turned-over phone; no readable text; no logos; no trademarks; no watermark; no UI baked in
Avoid: luxury interior, perfectly staged showroom, sentimental glow, magical elements, clutter, visible collectible objects, glossy 3D
```

## 可交互物件图集提示词

四张图集均使用同一生产约束：严格 4×4 等分网格、每格一个完整物件、物件居中且四周留白、正交或轻微三分之四视角、石墨线稿与克制水粉、旧纸纹理、统一光向和比例感；不生成文字、数字、UI、按钮、边框、人物全身、商标或水印。浅中性底色供 Godot 运行时色键处理。

### 日常物件图集

```text
Use case: asset-atlas
Asset type: 4 by 4 production prop atlas for a portrait point-and-click narrative game
Style: graphite linework, restrained gouache, recycled-paper grain, muted charcoal, dusty teal, faded coral and amber; match the supplied game key-art mood
Grid, row-major, exactly one isolated prop per cell:
row 1: alarm clock; ceramic cup; folded everyday shirt; small key ring
row 2: apartment door lock and handle; rain-streaked bus window fragment; smartphone visibly resting in a human hand from first-person view; red traffic light
row 3: roadside tree silhouette; school gate fragment; oval-running-track shadow; worn wall corner
row 4: piece of white chalk; small paper star; wooden desk corner; school bag
Constraints: consistent camera and scale, no cast environment, no labels, no readable clock digits, no logos, no watermark, no UI, pale neutral removable background
```

### 纸页与柜中物件图集

```text
Use case: asset-atlas
Asset type: 4 by 4 production prop atlas for a handmade paper-world chapter
Style: tactile graphite, soft gouache and aged paper; original abstract paper characters with no resemblance to known manga, anime or game IP
Grid, row-major, exactly one isolated prop per cell:
row 1: worn old manga book; short wooden pencil; folded old paper; round original paper friend
row 2: friend with expressive brow; friend carrying a small bag; clean new book; frayed bookmark
row 3: faded receipt; stack of phone message cards without text; wooden desk drawer; dim overhead classroom light
row 4: cabinet containing books; cabinet with a dry leaf; empty cabinet; translucent plastic ruler
Constraints: blank pages and screens, no readable marks, no logos, no watermark, no UI, pale neutral removable background
```

### 藏身与森林物件图集

```text
Use case: asset-atlas
Asset type: 4 by 4 production prop atlas for rain shelter, forest and underground-school scenes
Style: graphite-and-gouache paper texture, moss green, charcoal, dusty teal, parchment and restrained amber
Grid, row-major, exactly one isolated prop per cell:
row 1: shaded desk lamp; worn school chair; distant old school building; soft forest shadow
row 2: patch of wet mud; long fallen branch suitable for dragging; old classroom blackboard; loose manga page
row 3: aged school cabinet; small transparent fossil box; blank childhood question book; dried old mud trace
row 4: new fountain pen; ambiguous beetle-shaped fossil; glass marble; close-up of two fingers gently holding
Constraints: no horror, no reward glow, no readable text, no logo, no watermark, no UI, pale neutral removable background
```

### 动作与信号物件图集

```text
Use case: asset-atlas
Asset type: 4 by 4 production prop and feedback atlas for traffic, signal and gesture interactions
Style: hand-painted graphite outlines, restrained gouache, recycled-paper grain; subtle face-like vehicle lights without literal cartoon faces
Grid, row-major, exactly one isolated prop per cell:
row 1: car with round friendly lights; car with sleepy lights; car with narrow wary lights; car rear with red tail lamps
row 2: tiny van; seatbelt latch pin; green signal lamp; red signal lamp
row 3: worn bookmark; gap in a paper stage; rain streak cluster; short sequence of walking footprints
row 4: small breath cloud; half-open cabinet door; draggable fallen branch; close-up of two fingers gently holding
Constraints: coherent road orientation, no racing, no crashes, no readable plates, no logos, no watermark, no UI, pale neutral removable background
```

## 运行时落位原则

- 物件不使用跨场景通用坐标；每幕按背景结构单独记录中心点、显示尺寸、命中尺寸和层级。
- 背景已有物件优先使用透明命中区，避免图集物件与原画出现“双影”。
- 独立物件必须落在可信承载面：杯子和钥匙在桌面，衣服和书在架子，门锁贴门，灯与柜子贴建筑结构。
- 手机采用第一人称手持图，只出现在画面下方偏右，并为底部故事纸保留安全区。
- 命中范围可大于视觉物件，但不得跨入无关物体；悬停、点击、长按和拖放反馈控制在 150–300 毫秒。
