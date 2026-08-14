# `c01_s02_commute_window` 分层资产清单

版本：v0.1

日期：2026-08-07

状态：Stage 3 样板已完成

## 1. 场景意图

成年主角在普通通勤中第一次从手机抬头。玩家连续观察同一扇车窗，先看见冷淡现实，再看见自己的倒影，最后把前车灯和车牌读成一张若有若无的脸。入界发生在玻璃反光里，不使用跳转门或宏大魔法效果。

玩家完成路径：

1. 可选观察手机，确认现实状态。
2. 第一次观察车窗，只得到客观反馈。
3. 第二次观察车窗，成年主角抬头，倒影开始出现。
4. 观察前车灯或车牌，发现“像表情”的线索。
5. 第三次观察车窗，儿童倒影变清楚，场景略微变暖并进入下一幕。

## 2. 固定构图

- 竖屏固定视角，逻辑画布 720 × 1280。
- 成年主角位于画面下方偏左，身体朝车行方向，头部可从低头切换到抬头。
- 车窗占画面主要区域，承担观察、倒影和车外焦点车辆。
- 手机位于主角手部附近但保持独立资产，不能烘焙进人物或背景。
- 一辆近处焦点车辆独立于背景，车灯和车牌拥有可切换状态。
- 远处车辆、道路、路灯和雨夜城市属于背景，不承担精确点击。
- 底部叙事字幕和顶部导航保留安全区，不遮住手机、车灯或车牌。

## 3. 分层顺序

从后到前：

1. 雨夜公交内外环境背景。
2. 近处焦点车辆与左侧水平座椅扶手；二者处于不同画面区域，扶手只负责人物后方的座椅结构。
3. 独立手机；只通过成年人物的透明手机槽显示，位于手指后方。
4. 成年主角基础坐姿；人物手指覆盖手机边缘，躯干遮住手机槽以外的区域。
5. 儿童倒影。
6. 车窗反光与暖化效果。
7. 最前排座椅与底部弧形扶手遮挡层。
8. 交互反馈、字幕和全局 UI。

## 4. 资产清单

### 视觉方向候选

| 方向 | 文件 | 状态 | 当前结论 |
| --- | --- | --- | --- |
| 用户选定构图 | `../game/assets/art/style-studies/c01_s02/direction_c_v001_composition_reference.png` | `reference_only` | 锁定公交镜头、双向车流、焦点黑车迎面与右侧红车同向远离；人物身份不采纳 |
| 选定方向人物初修版 | `../game/assets/art/style-studies/c01_s02/direction_selected_v003.png` | `rejected` | 人物身份已纠正，但儿童朝向、眼线和动作未形成成年人镜像 |
| 选定方向镜像初修版 | `../game/assets/art/style-studies/c01_s02/direction_selected_v004.png` | `rejected` | 头部已相向，但错误地把儿童整个身体转成左侧面 |
| 选定方向身体同向修正版 | `../game/assets/art/style-studies/c01_s02/direction_selected_v005.png` | `rejected` | 身体方向正确，但倒影越过玻璃，且儿童服装、手机和表情不符合要求 |
| 选定方向玻璃裁切修正版 | `../game/assets/art/style-studies/c01_s02/direction_selected_v006.png` | `rejected` | 边界、服装和空手正确，但表情读成尬笑，倒影过于清晰实体化 |
| 选定方向弱反射修正版 | `../game/assets/art/style-studies/c01_s02/direction_selected_v007.png` | `rejected` | 表情仍显僵硬，倒影仍偏清晰 |
| 五岁儿童弱反射修正版 | `../game/assets/art/style-studies/c01_s02/direction_selected_v009.png` | `approved` | 已锁定为背景灰稿、人物与倒影资产的视觉和合成关系基准；不是运行时资产 |
| A/B/C v002 | `../game/assets/art/style-studies/c01_s02/` | `rejected` | 用户确认其道路或车辆方向存在问题，不再进入后续方向选择 |

视觉参考的采纳范围和不变量见 [视觉参考摘要](./visual-reference-brief-c01-s02.md)。

### 场景背景

#### `bg_c01_s02_bus_night_layout_v001.png`

- 状态：`rejected`
- 用途：无人物、无手机、无近处焦点车辆的背景构图灰稿，仅用于确认空间和后续叠加预留区，不作为正式运行时背景。
- 拒绝原因：移除成年人物时把其固定座椅一并抹除，左下只剩平整侧板，人物重新叠加后缺少坐垫、靠背和可信接触面。

#### `bg_c01_s02_bus_night_layout_v002.png`

- 状态：`rejected`
- 拒绝原因：竖向黄扶手从座椅上方继续穿过靠背与坐垫并落到地板，阻塞乘客的背部、骨盆和腿部空间，结构不合理。

#### `bg_c01_s02_bus_night_layout_v003.png`

- 状态：`approved`
- 当前结果：保留车顶至座椅上沿区域的竖向扶手，移除穿过靠背、坐垫和腿部空间的下段及落地底座；恢复连续布面和地板，座椅现在可正常承载人物。
- 校准结论：Godot 实帧中靠背、坐垫和腿部空间没有竖杆穿入，`phone` 仍位于座椅右上方的未来手部区域，`window`、`headlight`、`plate` 未漂移，本轮保留既有坐标；正式人物层生成后再按骨盆、背部和手部锚点人工校正。
- 确认结论：用户确认本版座椅、扶手净空与构图关系，可以进入正式背景候选生产。

#### `bg_c01_s02_bus_night_base_v001_candidate.png`

- 状态：`approved_reference`
- 位置：`../game/assets/art/style-studies/c01_s02/`；保留为生成与评审来源，运行时不引用。
- 当前结果：在 v003 固定结构上补足深蓝灰布面、哑光金属、橡胶窗框、旧黄扶手、雨滴层次、湿路反光、树木、路灯和远车细节；右侧车辆为低饱和暗红车尾并同向远离。
- 分层边界：不包含成年人物、儿童倒影、手机、近处焦点黑车、车灯/车牌状态或 UI；玻璃、人物/手机与焦点车预留区保持可叠加。
- 校准结论：Godot 实帧中 `headlight`/`plate` 仍位于空置对向车道，`phone` 位于座椅右上方，`window` 覆盖主要玻璃；雨滴和反光未遮掉预留区，本轮保留既有坐标。校准工具统一将参考图压暗到 74%，暗部最终判断以原始候选图和后续合成为准。
- 确认结论：用户确认本图内容与车辆方向最合理，正式完成度、冷暖、暗部、材质和三个叠加预留区通过。

#### `bg_c01_s02_bus_night_base_v001.png`

- 状态：`approved`
- 位置：`../game/assets/art/production/c01_s02_commute_window/background/`；与已确认来源保持相同 SHA-256，运行时和校准器改用本路径。
- 内容：无人物、无手机、无近处焦点车辆的公交车内、车窗、道路和雨夜城市。
- 要求：车内与道路透视一致；保留双向车流，焦点黑车在对向车道迎面驶来，右侧红车与公交同向远离；保留焦点车辆的可信空间。
- 禁止：人物、儿童倒影、可读文字、UI、焦点车灯表情、过度黑暗和霓虹赛博感。
- 接入检查：Godot 4.7.1 正常导入，540 × 960 校准器实帧从 production 路径加载成功；四个既有热点未漂移。

### 前景遮挡

#### `fg_c01_s02_bus_rail_occluder_v001_candidate.png`

- 状态：`reference_only`
- 位置：`../game/assets/art/style-studies/c01_s02/foreground/`；只作为 941 × 1672 对齐与提取母版，不接入场景。
- 调整原因：左右两组内容相距较远，使用全画布会产生大面积无意义透明区，也不能分别人工校正；用户要求按内容实际尺寸拆分后摆放。

#### `fg_c01_s02_seat_armrest_occluder_v001.png`

- 状态：`approved` 资产；落位已确认并锁定。
- 位置：`../game/assets/art/production/c01_s02_commute_window/foreground/`。
- 内容：只保留空座前方水平旧黄扶手，裁切尺寸 334 × 101；母版 `source_rect` 为 `[0, 803, 334, 101]`。
- 确认落位：`anchor = (0.1775, 0.5105)`，`visual_size = 256 × 77`，`z_index = 2`；由母版坐标计算，经用户视觉确认后锁定。首次人物合成验证发现层级 7 会横穿人物面部，因此只调整层级到人物后方，不改变位置或尺寸。

#### `fg_c01_s02_front_seat_occluder_v001.png`

- 状态：`approved` 资产；落位已确认并锁定。
- 位置：`../game/assets/art/production/c01_s02_commute_window/foreground/`。
- 内容：保留底部弧形旧黄扶手和与其固定相连的最前排座椅上缘，裁切尺寸 693 × 326；母版 `source_rect` 为 `[248, 1346, 693, 326]`。
- 确认落位：`anchor = (0.6318, 0.9025)`，`visual_size = 530 × 250`，`z_index = 7`；由母版坐标计算，经用户视觉确认后锁定。

两张 production 资产合并回母版坐标后，Alpha 差异为 0，可见 RGBA 像素差异为 0；没有重绘、缩放或边缘损失。左侧水平扶手绘制在成年人物后方；底部弧形扶手与前排座椅上缘绘制在成年人物、手机和局部效果层之上。固定结构都不硬裁进人物 PNG。

### 成年主角

#### `char_adult_commuter_seated_down_v001_candidate.png`

- 状态：`rejected`；用户指出人物显老，双手对称捧空不自然。
- 内容：低头坐姿，手部为承接独立手机保留稳定空间。
- 锚点：座椅接触点和骨盆位置。
- 文件：766 × 1385 紧边界 RGBA，四周 16 px 透明安全边；不含座椅、扶手、手机、倒影或环境。

#### `char_adult_commuter_seated_down_v002_candidate.png`

- 状态：`rejected`；手势改善，但用户认为人物仍显老，目标年龄改为约 26 岁。
- 内容：约 32–35 岁的普通东亚男性低头坐姿；身体与双肩朝车前方，画面右手单手握持透明手机槽，画面左手自然搭在大腿上。
- 锚点：座椅接触点和骨盆位置。
- 文件：762 × 1376 紧边界 RGBA，四周 16 px 透明安全边；不含座椅、扶手、正式手机、倒影或环境。

#### `char_adult_commuter_seated_down_v003_candidate.png`

- 状态：`approved_reference`；用户于 2026-08-11 确认，保留在 `style-studies` 作为生产来源。
- 内容：约 26 岁的普通东亚男性低头坐姿；身体与双肩朝车前方，画面右手单手握持透明手机槽，画面左手自然搭在大腿上。
- 锚点：座椅接触点和骨盆位置。
- 文件：764 × 1381 紧边界 RGBA，四周 16 px 透明安全边；不含座椅、扶手、正式手机、倒影或环境。
- 生产文件：`../game/assets/art/production/c01_s02_commute_window/characters/char_adult_commuter_seated_down_v001.png`，状态 `approved`，与候选逐字节一致。
- 确认落位：正式背景原生画布 `rect = [-28, 612, 575, 1040]`；逻辑画布为 `anchor = (0.2758, 0.6770)`、`visual_size = 440 × 796`、`z_index = 4`，已写入场景布局并锁定。
- 手机分层：人物右手内部保留由色键移除的透明手机槽；正式手机必须绘制在人物手指后方、人物躯干前方。v003 预览中的灰蓝矩形只用于验证手势，不是手机资产。
- 合成检查：脸、颈部、体态和手部均读作二十多岁；背部与骨盆由固定座椅承接，底部前排座椅遮住腿部下缘。
- 技术检查：Godot 4.7.1 production 导入、主场景和校准器 smoke test 正常；状态与存档 138 条断言，内容目录 5 章、30 幕、9 件收集物，交互系统 193 条断言、17 类契约。

#### `char_adult_commuter_seated_look_up_v001_candidate.png`

- 状态：`approved_reference`；用户于 2026-08-11 确认，保留在 `style-studies` 作为生产来源。
- 内容：同一位约 26 岁的普通东亚男性；身体、胸口和双肩保持朝车前方，只抬起头颈并转向画面右侧车窗，视线略向上，表情平静且刚刚注意到外界。
- 文件：764 × 1381 紧边界 RGBA；严格复用低头状态的固定裁切窗口、锚点和比例，第 658 行以下与已确认 production 低头人物逐像素相等。
- 评审落位：正式背景原生画布 `rect = [-28, 612, 575, 1040]`，与低头状态完全一致；预览为 `../game/assets/art/style-studies/c01_s02/previews/preview_c01_s02_adult_look_up_v001.png`。
- 生产文件：`../game/assets/art/production/c01_s02_commute_window/characters/char_adult_commuter_seated_look_up_v001.png`，状态 `approved`，与候选逐字节一致。
- 状态登记：与低头状态共用 `adult_commuter_down` 的锚点、尺寸和层级，通过 `state_asset_paths.look_up` 解析，不创建第二个常驻人物层。
- 技术检查：Godot 4.7.1 候选与预览导入、主场景和校准器 smoke test 正常；状态与存档 138 条断言，内容目录 5 章、30 幕、9 件收集物，交互系统 193 条断言、17 类契约。
- 晋级检查：production 抬头人物导入正常；状态资源解析与默认回退加入自检后，交互系统为 196 条断言、17 类契约，其余回归保持通过。

### 儿童倒影

#### `char_child_reflection_curious_v001.png`

- 状态：`approved`；用户于 2026-08-13 确认。评审候选保留在 `style-studies`，生产文件位于 `../game/assets/art/production/c01_s02_commute_window/characters/`，两者逐字节一致。
- 内容：同一人物约五岁时的儿童版本，身体朝车前方，头部转向左侧看回成年人；穿儿童日常圆领上衣，空手，以嘴唇微张、松弛眉眼和自然关注表达轻快感。
- 文件：`762 × 1484` 紧边界 RGBA，四边保留透明安全区；正常不透明度底图不烘焙玻璃、雨纹、场景光或反射强度。SHA-256 为 `34881d7addb179e1c01c837c6c540ee006feaeca1a743a3197d92e481d8239f1`。
- 落位与状态：`anchor = (0.7662, 0.6944)`、`visual_size = 225 × 438`、`z_index = 4`、`locked = false`；`hidden` / `faint` / `visible` 分别为 0% / 11% / 22% Alpha，共用 38% 饱和度、68% 对比度和轻微柔化。
- 玻璃边界：逻辑多边形 `[(287, 7), (713, 7), (713, 1055), (282, 775)]` 比评审遮罩内收约 1 像素。正常渲染驱动导出的 720 × 1280 帧相对旧边界检查为 `outside = 0 pixels`，窗框、窗台及车厢实体表面没有儿童差异。
- 工具边界：校正器使用与运行时相同的着色器预览最高可见状态，仍可人工调整中心、尺寸和层级后写回 JSON；人物源图继续保持正常不透明度，避免把反射效果烘焙进资产。
- 回归检查：Godot 4.7.1 正常导入 production；状态与存档 138 条断言、内容目录 5 章 30 幕 9 件收集物、交互系统 251 条断言与 17 类契约通过，主场景与校正器 smoke test 正常。
- 禁止：任何倒影像素越过玻璃覆盖窗框或金属窗台；手机或其他手持物；成人化衬衫；任何主动笑容、抿嘴尬笑或面对镜头式表情；写实缩小成人脸、写实皮肤细节、七八岁以上成熟比例；大眼、Q 版、吉祥物化；倒影过于清晰实体化；固定光晕和电影角色相似造型。

### 交互物件

#### `prop_phone_commute_cold_v001.png`

- 状态：`approved`；用户于 2026-08-11 确认。生产文件位于 `../game/assets/art/production/c01_s02_commute_window/props/`，与 `style-studies` 候选逐字节一致。
- 内容：无品牌当代手机，屏幕只显示不可读的冷色块。
- 状态需求：基础、轻微暗下两个状态可通过运行时调色完成，无需重复生成。
- 分层：放在成年人物层下方，通过人物资产的透明手机槽显示；不得覆盖握持手指。
- 文件：746 × 1261 紧边界 RGBA，四周透明；运行时按 `62 × 105` 显示，中心 `(0.3448, 0.7790)`，层级 3，命中尺寸仍为 `180 × 180`。
- 双状态预览：`preview_c01_s02_phone_cold_adult_down_v001.png` 与 `preview_c01_s02_phone_cold_adult_look_up_v001.png` 使用同一手机落位；两张图中手指均正确覆盖手机边缘。
- 布局登记：`phone.asset_path` 已写入 production 路径；中心、视觉尺寸、命中尺寸与层级保持已确认值，`locked = false`，手机视觉和命中区域都继续允许人工校正。
- 技术检查：Godot 4.7.1 production 手机导入、主场景和校准器 smoke test 正常；状态与存档 138 条断言，内容目录 5 章、30 幕、9 件收集物，交互系统 197 条断言、17 类契约。

#### `prop_vehicle_focus_base_v001_candidate.png`

- 状态：`rejected`；位于 `../game/assets/art/style-studies/c01_s02/props/`，只保留作反例，不进入 production 或布局 JSON。
- 拒绝原因：画面右侧车身和右侧车轮露出过多，车身纵轴没有沿对向车道从远处左上指向近处右下；车轮悬浮，缺少接地阴影与湿路反射，车辆完整轮廓覆盖在雨纹上方，读作贴图。
- 文件：946 × 696 紧边界 RGBA，四边 16 px 透明安全边；不包含道路、投影、雨滴、车灯光束或车牌文字。
- 反例预览：`preview_c01_s02_vehicle_focus_base_v001.png` 与 `preview_c01_s02_vehicle_focus_base_look_up_v001.png`。
- 技术检查：Godot 4.7.1 候选与两张预览导入、主场景和校准器 smoke test 正常；状态与存档 138 条断言，内容目录 5 章、30 幕、9 件收集物，交互系统 197 条断言、17 类契约。

#### `preview_c01_s02_vehicle_focus_context_v002.png`

- 状态：`rejected_review`；场景内透视与接地反例，不是运行时背景或独立车身资产。
- 角度：道路与对向车道由远处左上延伸到近处右下；车鼻随车道略指向画面右下，主要露出画面左侧前翼子板、左侧车身与左后视镜，画面右侧车身和右侧车轮后缩。
- 拒绝原因：车辆角度虽已修正，但外宽几乎占满甚至超过该深度的可用对向车道宽，轮胎到两侧车道边界没有可信湿路余量。
- 玻璃：车辆位于车外，现有雨滴、玻璃纹理与反射绘制在车辆上方并穿过车身区域，不能出现完整锐利贴纸边。
- 几何：两只灯罩与空白前牌保持可读；格栅无徽标、文字或品牌特征，不把灯和牌组合成卡通脸。
- 完整关系反例：`preview_c01_s02_vehicle_focus_context_look_up_v002.png`。
- 技术检查：Godot 4.7.1 两张 v002 预览导入、主场景和校准器 smoke test 正常；状态与存档 138 条断言，内容目录 5 章、30 幕、9 件收集物，交互系统 197 条断言、17 类契约。

#### `preview_c01_s02_vehicle_focus_context_v003.png`

- 状态：`rejected_review`；车辆尺度获认可、近侧车道线错误的场景反例，不是运行时背景或独立车身资产。
- 角度：保持 v002 已修正的纵深轴，车鼻略指向画面右下，主要露出画面左侧前翼子板、左侧车身与左后视镜，画面右侧后缩。
- 尺度：车辆外轮廓约 300 px，该深度可用车道宽约 400 px；两侧轮胎外缘到车道边界均保留连续湿路，不再出现车比车道宽或压满车道的问题。
- 空间与玻璃：车轮接触路面，阴影和破碎湿反射沿道路纵深延伸；车辆位于车外，雨滴、玻璃纹理和反射继续绘制在车身上方并穿过车辆区域。
- 几何：两只灯罩与空白前牌保持可读；格栅中央疑似徽标通过约 42 × 41 px 的确定性水平纹理插值清除，不含文字、标志或可识别品牌特征。
- 拒绝原因：车辆大小符合，但右下道路存在错误的亮色斜线；近侧边界没有沿用户长红线从车身左后方收束到画面右下。车辆大小、位置、角度、接地和反射仍作为后续锁定基准。
- 完整关系反例：`preview_c01_s02_vehicle_focus_context_look_up_v003.png`。
- 技术检查：Godot 4.7.1 两张 v003 预览导入、主场景和校准器 smoke test 正常；状态与存档 138 条断言，内容目录 5 章、30 幕、9 件收集物，交互系统 197 条断言、17 类契约。

#### `preview_c01_s02_vehicle_focus_context_v004.png`

- 状态：`rejected_review`；过度复刻用户手绘弯折的车道线反例，不是运行时背景或独立车身资产。
- 道路：用户标注圈出的右下旧亮线已用连续湿路替换；近侧边界沿长红线约从 `(422, 785)` 到 `(905, 1057)`，由远及近渐宽，保持低对比、磨损和雨夜软化。
- 车辆：逐像素锁定 v003 的大小、位置、比例、角度、车灯、前牌、接地阴影、破碎湿反射和车窗雨层；没有通过移动或缩放车辆迁就道路。
- 拒绝原因：长红线是手绘位置示意，v004 错误逐点跟踪了其中的弯折；真实车道线中心轴应为透视直线。
- 完整关系反例：`preview_c01_s02_vehicle_focus_context_look_up_v004.png`。
- 技术检查：像素差异仅位于原图 `(418, 781)–(940, 1064)` 道路区域，车辆区域最大像素差为 0；Godot 4.7.1 两张 v004 预览和标注参考导入、主场景与校准器 smoke test 正常；状态与存档 138 条断言，内容目录 5 章、30 幕、9 件收集物，交互系统 197 条断言、17 类契约。

#### `preview_c01_s02_vehicle_focus_context_v005.png`

- 状态：`approved_reference`；2026-08-12 用户确认的直线车道、车辆尺度、透视与接地基准。
- 道路：继续移除右下旧亮线；只取用户红线的大致首尾 `(422, 785)` 与 `(905, 1057)` 建立严格直线中心轴，远端约 6 px、近端约 12 px 线性渐宽。雨夜磨损只改变透明度和边缘，不改变中心方向。
- 车辆：逐像素锁定 v003 的大小、位置、比例、角度、车灯、前牌、接地阴影、破碎湿反射和车窗雨层；没有通过移动或缩放车辆迁就道路。
- 完整关系预览：`preview_c01_s02_vehicle_focus_context_look_up_v005.png` 只叠加已确认的人物、手机和结构层，用于检查人物视线、遮挡和焦点关系。
- 分层结果：已从同一基准派生 `bg_c01_s02_bus_night_lane_v002.png`、`prop_vehicle_focus_base_v001.png`、`fx_vehicle_grounding_v001.png` 和 `fx_vehicle_glass_rain_v001.png`；三张可移动层分别落位且保持 `locked = false`。
- 最新边界：车辆完整场景、初始分层、车灯/车牌状态、儿童倒影、固定窗外三态和第三态局部暖意 Gate 均已关闭；下一道 Gate 为三次观察完整运行时合成与单幕内部验收。
- 技术检查：中心轴相对端点直线的最大叉积误差约 `7.28e-11`，只存在浮点误差；像素差异仅位于原图 `(418, 781)–(940, 1063)` 道路区域，车辆区域最大像素差为 0。Godot 4.7.1 两张 v005 预览导入、主场景与校准器 smoke test 正常；状态与存档 138 条断言，内容目录 5 章、30 幕、9 件收集物，交互系统 197 条断言、17 类契约。

#### v005 production 分层

| 层 | 文件 | 母版 `source_rect` | `anchor` | `visual_size` | `z_index` | `locked` |
| --- | --- | --- | --- | --- | --- | --- |
| 直线车道背景 | `background/bg_c01_s02_bus_night_lane_v002.png` | `[0, 0, 941, 1672]` | 全画布 | `720 × 1280` | 背景 | 不适用 |
| 接地阴影/湿反射 | `effects/fx_vehicle_grounding_v001.png` | `[435, 729, 408, 328]` | `(0.6791, 0.5341)` | `312 × 251` | 0 | `false` |
| 焦点车身 | `props/prop_vehicle_focus_base_v001.png` | `[456, 596, 367, 226]` | `(0.6796, 0.4240)` | `281 × 173` | 1 | `false` |
| 玻璃雨纹 | `effects/fx_vehicle_glass_rain_v001.png` | `[464, 597, 350, 220]` | `(0.6791, 0.4228)` | `268 × 168` | 3 | `false` |

- 背景只继承 `v005 - v003` 的道路差分，保留已确认无车场景并把直线车道固定在环境层；车道线不随车辆移动。
- `preview_c01_s02_vehicle_layers_v001.png` 是四层初始坐标回组检查图；正式主场景实帧确认车辆尺度、角度、两侧湿路余量和人物关系没有漂移。
- `scene_visual_composer.gd` 已让正式游戏读取同一 JSON 的背景、七张视觉层与带资产的交互目标视觉，按 `z_index` 渲染并忽略鼠标；手机因此真正位于人物手指下方，车灯/车牌状态位于雨纹下方，儿童倒影受玻璃遮罩约束，Board 只保留透明命中区。校正器与正式场景共用完整 `720 × 1280` 坐标和图层处理着色器。
- 分层检查点：交互自检 217 条断言、17 类契约通过；状态与存档、内容目录及两处 smoke test 继续通过。

#### `prop_vehicle_headlights_neutral_v001.png`

- 状态：`approved`；用户于 2026-08-13 确认，候选保留为评审来源，逐字节晋级 production。
- 位置：`../game/assets/art/production/c01_s02_commute_window/props/`；`205 × 59` RGBA，母版 `source_rect = [562, 695, 205, 59]`。
- 内容：从已确认 v005 production 车身原像素确定性裁出的两只中性灯罩；不重绘车辆，不改变灯罩几何、车身透视或光色。

#### `prop_vehicle_headlights_blink_v001.png`

- 状态：`approved`；与中性态共同晋级 production。
- 内容：与中性态同一裁切、锚点和透明边界，只降低灯罩内亮度并增加极轻上缘遮光；不出现眼皮、瞳孔或字面卡通眼睛。

#### `prop_vehicle_plate_neutral_v001.png`

- 状态：`approved`；用户于 2026-08-13 确认，候选保留为评审来源，逐字节晋级 production。
- 位置：`../game/assets/art/production/c01_s02_commute_window/props/`；`93 × 35` RGBA，母版 `source_rect = [635, 742, 93, 35]`。
- 内容：从已确认车身原像素确定性裁出的不可读、无真实号码前牌中性态。

#### `prop_vehicle_plate_mouth_hint_v001.png`

- 状态：`approved`；与中性态共同晋级 production。
- 内容：与中性态同一裁切和锚点，只在牌面下缘增加极浅弧形阴影产生“像抿嘴”的错觉；不画真实嘴巴，不增加任何字符。

评审图：`previews/preview_c01_s02_vehicle_state_candidates_v001.png` 提供放大单项对照；`preview_c01_s02_vehicle_states_neutral_v001.png` 与 `preview_c01_s02_vehicle_states_hint_v001.png` 提供完整场景关系。四张状态已晋级 production，布局路径完成切换；原候选继续保留为评审来源。

### 场景效果

#### `fx_c01_s02_window_reflection_cool_v001.png`

- 状态：`rejected`；工程候选保留在 `style-studies/c01_s02/effects/fx_c01_s02_window_reflection_cool_v001_candidate.png` 作为所属 v001 评审轮次记录，不进入 production。
- 内容：冷色车窗反光和细雨纹理，不包含人物、车辆、道路或车厢结构；`620 × 1424` 紧边界 RGBA，四角透明、无可见洋红残留。
- 拒绝原因：其 v001 整场预览没有使用已确认的 v005 整场母版，无法作为可靠视觉 Gate；本轮停止独立冷色效果。

#### `fx_c01_s02_window_reflection_warm_v001.png`

- 状态：`rejected`；工程候选保留在 `style-studies/c01_s02/effects/fx_c01_s02_window_reflection_warm_v001_candidate.png` 作为所属 v001 评审轮次记录，不进入 production。
- 内容：与冷色状态独立的局部暖化效果，范围集中在儿童倒影与焦点车辆之间；`702 × 1422` 紧边界 RGBA，不包含人物、车辆或整场色层。
- 拒绝原因：随同 v001 整场预览退回；局部暖意需在 v005 固定母版的三态关系重新确认后单独设计。

v001 四张评审图状态为 `rejected_review`：它们使用 720 × 1280 运行时分层重组帧，导致窗外场景不再保持用户确认的 v005 整场像素。修正版 `preview_c01_s02_observation_state_01_locked_v002.png`、`preview_c01_s02_observation_state_02_faint_v002.png`、`preview_c01_s02_observation_state_03_visible_v002.png` 和横向 `preview_c01_s02_observation_states_v002.png` 均以 941 × 1672 v005 整场母版构建，不使用冷暖候选。`game/scripts/tools/build_c01_s02_observation_previews.gd` 断言成人状态、儿童倒影和车辆状态的授权遮罩之外差异为 0 像素；用户于 2026-08-13 确认该组固定窗外三态，下一道 Gate 为只作用于第三态的独立局部暖意候选。

#### `fx_c01_s02_window_reflection_warm_v002.png`

- 状态：`production_adjustable`；工程候选 `style-studies/c01_s02/effects/fx_c01_s02_window_reflection_warm_v002_candidate.png` 已获确认，并以相同 SHA-256 晋级 `production/c01_s02_commute_window/effects/fx_c01_s02_window_reflection_warm_v002.png`。
- 内容：490 × 860 RGBA 独立笔触；保留稀疏暖灰、暗琥珀雨痕，不包含人物、车辆、道路、窗框或任何完整场景像素；四角透明、无可见紫粉色键污染。
- 正式落位：母版 `rect = [555, 710, 180, 333]`，逻辑画布 `anchor = (0.6856, 0.5244)`、`visual_size = 138 × 255`、`z_index = 5`、`locked = false`；14% 屏幕混合，仅用于第三态并受玻璃硬遮罩限制。
- 像素约束：评审对照的授权遮罩外差异为 0 像素，三张已确认 v002 状态哈希不变；production 实帧有无对照改变 4,738 像素，逻辑玻璃外差异为 0。

## 5. 场景对象与布局

| 目标 ID | 显示模式 | 独立资产 | 初始中心 | 初始命中尺寸 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `window` | `region` | 无 | `(0.620, 0.390)` | `470 × 680` | 覆盖主要车窗，人工校正后保存 |
| `phone` | `sprite` | `prop_phone_commute_cold_v001.png` | `(0.3448, 0.7790)` | `180 × 180` | 视觉尺寸 `62 × 105`、层级 3；按透明手机槽校准且保持可调整 |
| `headlight` | `sprite` | 两张 production 车灯状态 | `(0.7062, 0.4333)` | `176 × 72` | 视觉 `157 × 45`；覆盖实际两只灯罩，保持可人工校正 |
| `plate` | `sprite` | 两张 production 车牌状态 | `(0.7242, 0.4542)` | `96 × 56` | 视觉 `71 × 27`；覆盖实际前牌，保持可人工校正 |

2026-08-12 已按 v005 实际灯罩与前牌重新校正；命中框刻意大于视觉框以保留触控容错。2026-08-13 状态视觉确认后保留同一坐标；两项目标均保持 `locked = false`，可在校正工具中继续人工调整。

| 视觉层 ID | 独立资产 | 初始中心 | 初始显示尺寸 | 层级 | 状态 |
| --- | --- | --- | --- | --- | --- |
| `seat_armrest_occluder` | `fg_c01_s02_seat_armrest_occluder_v001.png` | `(0.1775, 0.5105)` | `256 × 77` | 2 | 用户确认位置；人物合成后改到人物后方，已锁定 |
| `vehicle_grounding` | `fx_vehicle_grounding_v001.png` | `(0.6791, 0.5341)` | `312 × 251` | 0 | 接地和湿反射，保持可人工校正 |
| `vehicle_focus_base` | `prop_vehicle_focus_base_v001.png` | `(0.6796, 0.4240)` | `281 × 173` | 1 | 已确认车辆像素的紧边界层，保持可人工校正 |
| `vehicle_glass_rain` | `fx_vehicle_glass_rain_v001.png` | `(0.6791, 0.4228)` | `268 × 168` | 3 | 车辆上方玻璃雨纹，覆盖车身和车灯/车牌状态层，保持可人工校正 |
| `adult_commuter_down` | 默认低头图；状态映射含抬头图 | `(0.2758, 0.6770)` | `440 × 796` | 4 | 两种人物状态共用落位，已锁定 |
| `child_reflection` | `char_child_reflection_curious_v001.png` | `(0.7662, 0.6944)` | `225 × 438` | 4 | 0% / 11% / 22% 三档；玻璃硬遮罩；保持可人工校正 |
| `window_reflection_warm` | `fx_c01_s02_window_reflection_warm_v002.png` | `(0.6856, 0.5244)` | `138 × 255` | 5 | 0% / 14% 两档；第三态屏幕混合；玻璃硬遮罩；保持可人工校正 |
| `front_seat_occluder` | `fg_c01_s02_front_seat_occluder_v001.png` | `(0.6318, 0.9025)` | `530 × 250` | 7 | 用户确认，已锁定 |

视觉层不设置命中尺寸，不参与点击判定；校准器只编辑其中心、显示尺寸、层级、资产路径和锁定状态。

## 6. 关键状态合成

### State 0：低头

- 成年主角低头。
- 手机冷光可见。
- 儿童倒影不可见。
- 焦点车辆保持中性。

### State 1：第一次观察

- 车窗局部对焦，环境不变暖。
- 只强化雨滴、反射和车外层次。

### State 2：第二次观察

- 成年主角切换为抬头状态。
- 儿童倒影以很低透明度出现。
- 车灯和车牌允许单独观察。

### State 3：第三次观察

- 儿童倒影变清楚但仍属于玻璃反光。
- 焦点车灯播放一次轻微眨动。
- 局部暖化效果出现，背景整体不发生突变。

## 7. 当前验收顺序

1. 已确认 `direction_selected_v009.png` 同时保留选定构图、车辆方向、人物身份、“身体同向、头部反向”的关系、严格玻璃裁切、五岁手绘造型、无笑容自然神情和弱反射质感。
2. 已确认 `bg_c01_s02_bus_night_layout_v003.png` 的扶手终止位置、固定座椅乘坐空间、人物承载关系、公交结构、双向道路和三个叠加预留区。
3. 已确认 `bg_c01_s02_bus_night_base_v001_candidate.png` 并晋级正式背景 `production/c01_s02_commute_window/background/bg_c01_s02_bus_night_base_v001.png`。
4. 已将全画布遮挡母版改为 `reference_only`，拆出 `seat_armrest` 与 `front_seat` 两张紧边界 production 资产，并确认各自落位和人物可移动范围后锁定。
5. v001 因显老和手势不自然被拒绝，v002 因年龄仍高于目标被拒绝；v003 已确认并晋级 production，人物与手机槽的运行时落位已写入 JSON。
6. 成年主角抬头状态已确认并晋级 production；两张人物图同画布、同锚点，并登记为同一人物层的状态资源。
7. 手机与 v005 焦点车完整场景均已确认；车辆已拆为背景、车身、接地效果和玻璃雨纹并接入正式运行时，三张车辆相关层保持可人工校正。
8. 车灯和车牌状态层已确认并晋级 production，热点继续保留人工校正能力。
9. 约五岁儿童倒影 v001 已确认并晋级 production；0% / 11% / 22% 三档、玻璃硬遮罩和人工校正已接入，旧玻璃边界外真实帧差异为 0 像素。
10. 冷暖效果 v001 与错误基底三状态预览已拒绝；固定窗外 v002 三态已确认，不能再使用运行时重组帧替代整场母版。
11. 第三态局部暖意 v002 已确认并晋级 production；14% 屏幕混合、玻璃硬裁切和人工校正均已接入，production 实帧玻璃外差异为 0。
12. 三态横向实帧已获确认。正式主窗口曾因 Board 错误回退旧图集而叠出方向错误的额外手/手机，现已改为 `SceneVisualComposer` 独占正式视觉、Board 只保留透明命中；第三句观察卡完整停留后才进入完成卡。
13. 2026-08-14 用户要求继续，修正后的主场景最终视觉 Gate 关闭；本清单、production 资产、布局 JSON、真实运行时三态和 290 条交互断言共同构成 Stage 3 完成基线。

## 8. 真实运行时三态输出

2026-08-14 新增 `../game/scripts/tools/capture_c01_s02_runtime_observations.gd`。工具在 Godot 正常 macOS / GL Compatibility 渲染器中实例化正式 `InteractionBoard` 与 `SceneVisualComposer`，真实提交三次 `window` 交互，不使用评审母版做静态拼接。主场景与工具共用 `SceneVisualComposer.apply_interaction_state()`，并统一使用入界遮色 `#0d17204a`。

| 状态 | 输出 | SHA-256 |
| --- | --- | --- |
| 第一次观察 | `previews/preview_c01_s02_runtime_observation_state_01_v001.png` | `fbd76ed819ad024809c9dca3bdfacdee523a99d562bb9ad12bb9869db9bffb7d` |
| 第二次观察 | `previews/preview_c01_s02_runtime_observation_state_02_v001.png` | `7ff1e3edde1f4e088f8825bc92e5c7b69c798839ce9ea3a5ee3894cdec2e0e8f` |
| 第三次观察 | `previews/preview_c01_s02_runtime_observation_state_03_v001.png` | `51de87ac1d3db039c688dbd6c18e9abe64eee5116a79ef67a59306ae213bd1cc` |
| 横向对照 | `previews/preview_c01_s02_runtime_observation_states_v001.png` | `0151e00ee9e6c4e0ddbd98150b5fb440df912c919d4457e23442e5221edb69b0` |

状态 1→2 改变 121,159 像素，状态 2→3 改变 45,280 像素。单层开关检查中，儿童倒影改变 38,342 像素，局部暖意改变 4,737 像素；按 GPU 边界栅格与四点玻璃多边形求交后，两层玻璃外差异均为 0。

2026-08-14 正式窗口补充验收发现截帧未覆盖的 Board 可见层问题：`phone` 命中节点回退显示旧图集中的整只手与手机，方向和人物正式手势冲突。运行时已把所有带 production `asset_path` 的迁移目标切换为纯 `region` 命中；手机、车灯和车牌均不再重复绘制。第三次观察先显示第三句并播放玻璃声，2.06 秒后完成卡与成功音同步出现。对应交互自检为 290 条断言、17 类契约。
