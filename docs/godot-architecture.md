# 《我》Godot 制作架构

版本：v1.2

日期：2026-08-07

引擎锁定：Godot `4.7.1.stable.official.a13da4feb`

## 1. 产品边界

`game/` 是五章连续可玩的正式制作基线，不是单章 Demo 或机制沙盒。每章保留六幕结构：现实开场、渐进入界、两到三幕里世界交互、情绪收束和现实回声。

必须保持：

- `docs/me-story-manuscript.md` 是叙事基线；运行时短文案不能反向替代母本。
- 不解释里世界究竟是梦、记忆还是自我修复。
- 不加入战斗、死亡、怪物追逐、倒计时和惩罚性失败。
- 主角的现实没有被“治好”；变化落在重新看、慢下来、承认喜欢和继续往前等具体行动上。
- 9 件隐藏道具没有数值能力，最终展示只读取实际获得的 `collectedItems`。
- 第三章角色完全原创；第五章化石是“遇见旧愿望”，不是任务奖励。

## 2. 运行架构

```text
StoryContentCatalog（5 章 / 30 幕 / 9 收集物）
              ↓
MainApp（标题、章节、场景、图文卡片、收集册）
              ↓
InteractionBoard（17 类语义交互 + 场景内热点）
              ↓
GameState（六字段跨章状态） + SessionState（精确场景续玩）
              ↓
SaveCodec（版本、白名单、原子写入、备份恢复）

AudioDirector（Music / Ambience / SFX）贯穿场景阶段
```

- `GameState` 只保存跨章真相：当前章、章节阶段、感知阶段、收集物、章节解锁和回声。
- `SessionState` 保存精确续玩场景和静音设置；短谜题不持久化一半完成的手势状态。
- `StoryContentCatalog` 保留五章脚本中的场景链和交互参数，不直接写存档。
- `InteractionBoard` 把点击、重复、拖放、轨迹、描线、长按和多点触控转换为语义完成事件。
- `MainApp` 负责可视编排和反馈，不把章节规则复制进 UI。
- `AudioDirector` 在现实、入界、里世界和回声之间切换音乐、环境声和交互音效。

## 3. 画面、窗口与输入

- 逻辑画布：720 × 1280，9:16 竖屏。
- 桌面窗口：540 × 960，并在启动后最大化；窗口变化不修改逻辑画布。
- 渲染器：GL Compatibility，优先保证本地运行并为后续 Web 评估保留兼容基础。
- 字体：Noto Sans CJK SC Regular 随工程打包，避免导出后依赖系统中文字体。
- 可操作热区：最低高度 54 逻辑像素；多点触控提供鼠标/键盘替代输入。
- 失败反馈：轻退回、轻复位和场景线索，不扣分，不使用红色警报或失败音。

## 4. 场景内交互与反馈层

交互不采用 App 式表单或一排操作按钮。运行时遵循以下层级：

1. 背景和透明物件图集共同构成场景。
2. 已迁移场景由 `data/scene_layouts/<scene_id>.json` 分别记录交互 `targets` 与非交互视觉 `layers`。两者共用中心、视觉尺寸、层级、资产路径和锁定状态；命中尺寸与显示模式只属于交互目标，裁切视觉层另存 `source_rect`。未迁移目标回退到 `interaction_scene_layouts.gd`。
3. 普通观察弹出图文观察卡，展示物件局部图和一句克制反馈。
4. 一幕完成时弹出图文回忆卡，用画面和短文本完成情绪收束。
5. 提示优先通过物件轻动、光影、声音和环境文案给出，最后才使用轻量视觉强调。

交互层覆盖近乎完整画布，保持透明；底部叙事是鼠标穿透的渐变字幕层，不会切断校门、桌沿、手机或化石台的命中。全局导航按钮只存在于标题、章节选择、收集册、制作信息和必要的暂停/返回位置；它们不代替场景动作。

`interaction_scene_layout_store.gd` 是正式运行时与校准工具的共同数据边界。运行时交互目标先读取 JSON 并规范化为 Godot `Vector2`；文件缺失、目标尚未迁移或 JSON 目标无效时，再逐目标读取历史布局。非交互视觉层不回退到旧表，按紧边界资产和 `source_rect` 独立记录。`scene_layout_calibrator.tscn` 可直接拖动交互目标或视觉层，按对象类型调整字段并保存/重新载入同一份 JSON，不需要修改 GDScript 常量。

## 5. 内容与资源映射

| 章节 | 主背景 | 主要交互 |
| --- | --- | --- |
| 灰色早晨 | `chapter_01.png`（公交车窗已纠正） | 重复观察、车辆分类、路线、灯光节奏 |
| 绕完这一圈 | `chapter_02.png`（跑道空间已纠正） | 环线、第四圈慢拖、粉笔线索、桌面路径 |
| 纸片朋友 | `chapter_03.png` | 宽容描线、原创纸片朋友、情绪排序、书签补桥 |
| 柜子里的呼吸 | `chapter_04.png` | 柜门开合、声音摆放、空间比较、长按呼吸 |
| 密林之后 | `chapter_05.png` | 树影探索、旧意象、化石遇见、双指合作 |

现实回声复用 `reality_room.png`，标题使用 `title_key_art.png`，合计 7 张竖屏背景/主视觉。`assets/art/props/` 中 4 张旧图集为场景热点提供历史技术占位；这些资源不再视为逐幕精细化的产品验收结果。新资产按单幕拆为背景、人物、独立物件、状态图和光效，经过方向、构图、单项、合成与落位确认后才接入运行时。30 条 CC0 音频继续沿用，逐文件来源见 `audio-licenses.md`。

## 6. 存档与试玩指标

- 故事存档：`user://me_again/save_v1.json`，保留 `.bak`。
- 场景续玩：`user://me_again/session_v1.json`。
- 试玩指标：`user://me_again/playtest.ndjson`，记录场景耗时、错误次数、提示使用和交互指标，不记录个人信息。

## 7. 自动验证

```bash
HOME=/tmp/me-again-godot-home /Applications/Godot.app/Contents/MacOS/Godot \
  --headless --path game --script res://tests/run_all.gd
```

结果：状态与存档 138 条断言通过。

```bash
HOME=/tmp/me-again-godot-home /Applications/Godot.app/Contents/MacOS/Godot \
  --headless --path game --script res://scripts/content/catalog_self_check.gd
```

结果：5 章、30 幕、9 件收集物通过目录自检。

```bash
HOME=/tmp/me-again-godot-home /Applications/Godot.app/Contents/MacOS/Godot \
  --headless --path game --script res://scripts/interactions/interaction_self_check.gd
```

结果：197 条断言、17 类交互契约通过；覆盖 JSON 解析、样板交互布局、三张独立视觉层、人物状态与正式手机资源路径、裁切坐标、视觉/命中尺寸分离和旧布局回退检查。

## 8. 发布边界

当前目标是先完成 5–8 人本地外部试玩，再决定首个发布目标为 Web/itch.io 还是桌面包。微信/抖音小游戏不再是引擎默认导出路线；进入该方向前需单独评估 Godot 导出方案、包体、触控、多媒体播放、平台 SDK 和合规要求。

本机尚缺与 Godot 4.7.1 精确匹配的 export templates，因此当前没有发布包。安装匹配模板后再建立 export preset，并完成字体、音频、触控、存档、窗口和浏览器兼容验收。
