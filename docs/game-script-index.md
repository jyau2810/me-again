# 《我》游戏脚本索引

版本：v1.0

日期：2026-07-17

用途：记录五章脚本的运行时映射、全局状态、收集物、交互反馈和资源复用决策。叙事内容仍以 [五章小说式母本](./me-story-manuscript.md) 为基线。

## 1. 脚本与运行时状态

| 章节 | 制作脚本 | 当前状态 |
| --- | --- | --- |
| 第一章：灰色早晨 | [game-script-chapter-01.md](./game-script-chapter-01.md) | 6 幕已接入 Godot |
| 第二章：绕完这一圈 | [game-script-chapter-02.md](./game-script-chapter-02.md) | 6 幕已接入 Godot |
| 第三章：纸片朋友 | [game-script-chapter-03.md](./game-script-chapter-03.md) | 6 幕已接入 Godot |
| 第四章：柜子里的呼吸 | [game-script-chapter-04.md](./game-script-chapter-04.md) | 6 幕已接入 Godot |
| 第五章：密林之后 | [game-script-chapter-05.md](./game-script-chapter-05.md) | 6 幕已接入 Godot |

运行时内容源为 `../game/scripts/content/story_content_catalog.gd`，保持 5 章 × 6 幕的场景 ID、章节链、交互参数和收集规则。运行时短文案服务场景节奏，不替代母本正文。

## 2. 全局状态

| 状态键 | 类型 | 说明 |
| --- | --- | --- |
| `currentChapter` | string | 当前章节 ID |
| `chapterProgress` | string | `opening`、`entry`、`inner_world`、`echo`、`complete` |
| `perceptionStage` | string | 控制现实物件文本和回声阶段 |
| `collectedItems` | string[] | 全局收集物，只记录实际获得的道具 |
| `chapterUnlocks` | object | 章节解锁与完成状态 |
| `visitedEchoes` | string[] | 已完成现实回声的连续链 |

精确场景续玩和静音设置由 `SessionState` 单独保存，不混入上述六字段故事存档。短谜题不保存一半完成的手势状态。

## 3. 章节状态落点

| 章节 | 完成场景 | 完成后 `perceptionStage` | 解锁/完成状态 | 回声记录 |
| --- | --- | --- | --- | --- |
| 第一章 | `c01_s06_commute_echo` | `chapter_01_echo` | 解锁 `02_looping_school` | `c01_commute_echo` |
| 第二章 | `c02_s06_room_corner_echo` | `chapter_02_echo` | 解锁 `03_paper_friends` | `c02_room_corner_echo` |
| 第三章 | `c03_s06_new_book_echo` | `chapter_03_echo` | 解锁 `04_cabinet_breath` | `c03_new_book_echo` |
| 第四章 | `c04_s06_quiet_room_echo` | `chapter_04_echo` | 解锁 `05_after_forest` | `c04_quiet_room_echo` |
| 第五章 | `c05_s06_morning_echo` | `ending_echo` | 标记第五章完成 | `c05_morning_echo` |

章节完成时必须原子同步 `chapterProgress`、`perceptionStage`、`chapterUnlocks` 和 `visitedEchoes`，不能由 UI 分步拼接状态。

## 4. 收集物

| 道具 ID | 名称 | 章节 | 情绪作用 |
| --- | --- | --- | --- |
| `candy_badge` | 糖纸徽章 | 1 | 把后座想象成堡垒 |
| `eraser_crumb` | 橡皮碎屑 | 2 | 旧学校落下的细小痕迹 |
| `half_chalk` | 半截粉笔 | 2 | 给童年的自己留位置 |
| `sticker_star` | 贴纸星星 | 2 | 让现实桌角亮一点 |
| `character_sticker` | 角色贴纸 | 3 | 喜欢纸片朋友的证据 |
| `old_bookmark` | 旧书签 | 3 | 连接旧漫画与新漫画 |
| `plastic_ruler` | 透明塑料尺 | 4 | 安静、透明、可以藏起来的边 |
| `glass_marble` | 玻璃弹珠 | 5 | 把灰色折出一点颜色 |
| `impossible_fossil` | 不可能的化石 | 5 | 没成功但很认真的愿望 |

收集物不提供数值能力。最终桌面只展示 `collectedItems` 中实际获得且有合法章节路径的道具。

## 5. 17 类交互契约

| 交互组 | 类型 | 章节用途 |
| --- | --- | --- |
| 场景观察 | `hotspot_sequence`、`repeat_observe`、`echo_revisit`、`collect_clues` | 现实物件、车窗、儿童痕迹、章节回声 |
| 拖放与空间 | `sort_targets`、`path_route`、`drag_place`、`slot_placement`、`compare_spaces` | 车辆阵营、后座路线、书签补桥、声音摆放、柜内比较 |
| 路径与描线 | `repeat_path`、`path_trace`、`trace_lines` | 跑圈、慢拖、桌面路径、临摹线 |
| 顺序与节奏 | `rhythm_sequence`、`reorder_sequence`、`repeat_toggle` | 信号灯、分镜排序、柜门开合 |
| 身体与多点 | `posture_sequence`、`multi_touch_sequence` | 躲柜姿态、树影与手指小人合作 |

所有类型通过统一的 `InteractionBoard` 输出完成事件、错误次数、提示使用和交互指标。多点触控必须提供鼠标/键盘替代。

## 6. 共用交互与反馈规则

- 可操作物直接嵌在场景中，热点跟随物件位置；不显示“观察”“前往”“执行操作”式按钮。
- 每幕使用独立布置数据；背景里已有的车窗、跑道、校门、纸页、柜门和黑板使用透明命中区，不再叠加一份悬空图标。
- 背景保持可见，交互层透明；不得用大面积纯色面板盖住空间和线索。
- 玩家点击物件后，先出现物件自身的轻动、声音或局部变化，再出现带局部图的观察卡和一句短反馈。
- 一幕完成后使用图文回忆卡收束；完成卡不写成问卷，也不替玩家宣布标准答案。
- 重复动作必须产生轻微可见或可听变化，例如车窗变暖、学校偏移、雨声变近。
- 卡住时先使用场景内光影、轻动、声音和环境短句，最后才使用轻量视觉强调。
- 场景动作不依赖导航 UI；全局按钮只服务标题、章节选择、收集册、制作信息和必要返回。
- 失败只轻退回或复位，不扣分，不使用红色警报和惩罚音。
- 每章现实回声至少重新触碰两个现实物件。

## 7. 共用文本规则

- 成年现实文本短、硬、克制。
- 入界文本允许一点“不确定”和“好像”。
- 儿童痕迹短、直白、具体，不总结人生。
- `objective` 与 `hint` 写成物件、光影、声音和空间关系，不使用产品说明、表单问题或直白操作命令。
- 反馈只写眼前发生的变化，不评价玩家该看多久、该如何感受；禁用“再看一会”“慢慢试”“没关系，可以重来”等系统安慰腔。
- 观察卡一次只保留一个画面重点和一句反馈。
- 结尾回声允许轻微拟人，但不写成鸡汤。

## 8. 美术与音频决策

| 资源 | 数量与路径 | 当前用途 |
| --- | --- | --- |
| 竖屏背景/主视觉 | 7 张：`../game/assets/art/title_key_art.png`、`../game/assets/art/backgrounds/` | 标题、五章主背景、现实回声；公交车窗与操场跑道已纠正 |
| 透明交互物件图集 | 4 张：`../game/assets/art/props/` | 日常、动作、纸片、柜子/森林物件；用于场景原位热点 |
| 音频 | 30 条 CC0：`../game/assets/audio/` | 音乐、环境声、观察与交互反馈 |
| 字体 | `../game/assets/fonts/` | Noto Sans CJK SC，随工程打包 |

生成提示词、文件映射和约束见 [生成美术记录](./generated-art-assets.md)；音频逐条来源见 [音频许可证清单](./audio-licenses.md)。背景不烘焙 UI 或可读文字，交互图集不得呈现通用 App 按钮风格。

## 9. 资源复用

| 资源类型 | 复用范围 |
| --- | --- |
| 图文观察卡 | 五章共用，图片随热点物件切换 |
| 完成回忆卡 | 五章共用版式，章节色彩和图文不同 |
| 儿童纸条/粉笔痕 | 第二、三、四、五章 |
| 现实房间 | 第二、四、五章现实回声 |
| 车窗与灯光意象 | 第一、五章 |
| 纸片与旧书质感 | 第三章主用，其他章节少量回声 |
| 最终桌面 | 按实际收集状态动态展示 |
| Music / Ambience / SFX 总线 | 五章共用，按阶段切换 |

## 10. 当前验证与外测重点

本地自动验证结果：

- 状态与存档：138 条断言通过。
- 内容目录：5 章、30 幕、9 件收集物自检通过。
- 交互系统：158 条断言、17 类契约自检通过。

下一轮由 5–8 名外部玩家重点验证：

1. 第一章车窗观察、车辆阵营和场景热点是否容易理解。
2. 第二章跑圈与第四圈慢行是否通过跑道画面自然成立。
3. 第三章描线、分镜线索和纸片剧场是否宽容且不显得像排序表单。
4. 第四章声音摆放、柜内空间和长按呼吸是否有身体感。
5. 第五章化石是否像“遇见旧愿望”，双指合作与替代输入是否顺畅。
6. 观察卡和完成回忆卡是否增强反馈，同时没有遮住背景或打断情绪。

测试若改变脚本、文案、交互、资源或音频决策，必须同步回写对应制作脚本和本索引。
