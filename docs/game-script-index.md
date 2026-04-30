# 《我》游戏脚本索引

版本：v0.2  
日期：2026-04-30  
用途：记录五章脚本之间的全局状态、共用规则、收集物、资源复用和灰盒验证顺序。

## 1. 脚本文档

| 章节 | 文档 | 当前状态 |
| --- | --- | --- |
| 第一章：灰色早晨 | [game-script-chapter-01.md](./game-script-chapter-01.md) | 已完成样章 |
| 第二章：绕完这一圈 | [game-script-chapter-02.md](./game-script-chapter-02.md) | 已完成样章 |
| 第三章：纸片朋友 | [game-script-chapter-03.md](./game-script-chapter-03.md) | 已完成样章 |
| 第四章：柜子里的呼吸 | [game-script-chapter-04.md](./game-script-chapter-04.md) | 已完成样章 |
| 第五章：密林之后 | [game-script-chapter-05.md](./game-script-chapter-05.md) | 已完成样章 |

## 2. 全局状态

| 状态键 | 类型 | 说明 |
| --- | --- | --- |
| `currentChapter` | string | 当前章节 ID |
| `chapterProgress` | string | `opening`、`entry`、`inner_world`、`echo`、`complete` |
| `perceptionStage` | string | 控制现实物件文本变化 |
| `collectedItems` | string[] | 全局收集物 |
| `chapterUnlocks` | object | 章节解锁状态，例如 `chapterUnlocks.03_paper_friends = true` |
| `visitedEchoes` | string[] | 已完成现实回声，例如 `c02_room_corner_echo` |

## 3. 章节状态命名

| 章节 | `chapter` 值 | 完成后 `perceptionStage` |
| --- | --- | --- |
| 第一章 | `01_grey_morning` | `chapter_01_echo` |
| 第二章 | `02_looping_school` | `chapter_02_echo` |
| 第三章 | `03_paper_friends` | `chapter_03_echo` |
| 第四章 | `04_cabinet_breath` | `chapter_04_echo` |
| 第五章 | `05_after_forest` | `ending_echo` |

## 4. 收集物

| 道具 ID | 名称 | 章节 | 情绪作用 |
| --- | --- | --- | --- |
| `candy_badge` | 糖纸徽章 | 1 | 把后座想象成堡垒 |
| `eraser_crumb` | 橡皮碎屑 | 2 | 旧学校的细小痕迹 |
| `half_chalk` | 半截粉笔 | 2 | 给童年的自己留位置 |
| `sticker_star` | 贴纸星星 | 2 | 让现实桌角亮一点 |
| `character_sticker` | 角色贴纸 | 3 | 喜欢纸片朋友的证据 |
| `old_bookmark` | 旧书签 | 3 | 连接旧漫画和新漫画 |
| `plastic_ruler` | 透明塑料尺 | 4 | 安静、透明、可藏起来的边界 |
| `glass_marble` | 玻璃弹珠 | 5 | 把灰色现实折出一点颜色 |
| `impossible_fossil` | 不可能的化石 | 5 | 没成功但很认真的愿望 |

## 5. 章节完成状态落点

| 章节 | 完成场景 | `perceptionStage` 变化 | 解锁/完成状态 | 回声记录 |
| --- | --- | --- | --- | --- |
| 第一章 | `c01_s06_commute_echo` | `chapter_01_echo` | `chapterUnlocks.02_looping_school = true` | `visitedEchoes += c01_commute_echo` |
| 第二章 | `c02_s06_room_corner_echo` | `chapter_02_echo` | `chapterUnlocks.03_paper_friends = true` | `visitedEchoes += c02_room_corner_echo` |
| 第三章 | `c03_s06_new_book_echo` | `chapter_03_echo` | `chapterUnlocks.04_cabinet_breath = true` | `visitedEchoes += c03_new_book_echo` |
| 第四章 | `c04_s06_quiet_room_echo` | `chapter_04_echo` | `chapterUnlocks.05_after_forest = true` | `visitedEchoes += c04_quiet_room_echo` |
| 第五章 | `c05_s06_morning_echo` | `ending_echo` | `chapterUnlocks.05_after_forest = complete` | `visitedEchoes += c05_morning_echo` |

## 6. 共用交互规则

- 点击物件只给短反馈，不写大段解释。
- 重复动作必须产生轻微可见变化，例如车窗变暖、学校偏移、雨声变厚。
- 卡住时先用场景元素提示，再使用 UI 光圈。
- 隐藏道具不提供数值能力，主要负责情绪回收。
- 每章现实回声至少复访 2 个现实物件。
- 第二到第五章完成时必须同时写入 `chapterProgress`、`perceptionStage`、`chapterUnlocks` 和 `visitedEchoes`。
- 最终桌面展示只显示已在章节中有获取路径的道具。

## 7. 共用文本规则

- 成年现实文本短、硬、克制。
- 入界文本允许一点“不确定”和“好像”。
- 儿童痕迹短、直白、具体，不总结人生。
- 结尾回声允许轻微拟人，但不能写成鸡汤。

## 8. 资源复用

| 资源类型 | 可复用范围 |
| --- | --- |
| 文本气泡 UI | 五章共用 |
| 儿童纸条 UI | 第二章、第三章、第四章、第五章 |
| 收集提示 UI | 五章共用 |
| 成年主角基础动作 | 五章共用，逐章增加更松弛的待机 |
| 小孩主角基础动作 | 第二至第五章共用，按章节增加特殊动作 |
| 现实房间 | 第二章、第四章、第五章回声复用 |
| 车窗/灯光意象 | 第一章、第五章复用 |
| 最终桌面收集展示 | 第二章、第三章、第四章、第五章回声递进复用 |

## 9. 灰盒验证顺序

建议灰盒阶段按以下顺序推进：

1. 第一章：验证观察车窗和车灯阵营判断。
2. 第二章：验证重复跑圈和场景渐变。
3. 第四章：验证声音摆放、柜内身体感和长按呼吸。
4. 第三章：验证描线、分镜线索推导和纸片剧场。
5. 第五章：验证探索、化石“遇见感”和双指手影合作。

这个顺序先验证基础观察与重复动作，再验证声音和手势等更特殊交互。
