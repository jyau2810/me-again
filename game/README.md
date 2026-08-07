# Me Again — Godot 工程

`game/` 是《我》当前唯一开发中的游戏工程。引擎锁定 Godot `4.7.1.stable.official.a13da4feb`，使用 GL Compatibility；逻辑画布为 720 × 1280，桌面运行窗口为 540 × 960，并在启动后最大化。叙事与制作以 `../docs/me-story-manuscript.md` 和五章游戏脚本为准。

## 当前完成度

- 5 章 × 6 幕，共 30 幕；9 件收集物；17 类交互契约。
- 标题、新游戏/继续、章节选择、五章连续流程、收集册、制作信息、存档恢复和精确场景续玩均已接入。
- 可点击物直接布置在场景画面中，不显示“点击这里”“执行操作”式按钮。
- 观察行为使用带物件图的观察卡反馈；完成一幕时使用图文回忆卡收束，文本不依赖问答式面板。
- 交互层保持透明，让背景持续承担空间、氛围和线索；仅在需要阅读时叠加轻量卡片。
- 7 张竖屏背景/主视觉、4 张交互物件图集、30 条 CC0 音频已接入；公交车窗与操场跑道背景已经重新生成并替换。

## 启动

```bash
/Applications/Godot.app/Contents/MacOS/Godot --editor --path game
```

在编辑器中运行 `project.godot` 即可从标题页开始。键鼠与触屏均可使用；双指交互另有鼠标/键盘替代输入。

## 目录职责

- `scenes/app/main.tscn`：主场景入口。
- `scripts/ui/main_app.gd`：标题、章节、场景编排、观察卡、完成回忆卡、收集册与制作信息。
- `scripts/interactions/`：17 类语义交互、逐场景布局表、原位热区、拖放、描线、长按和多点触控。
- `scripts/content/story_content_catalog.gd`：5 章 30 幕运行时内容，不直接修改全局状态。
- `scripts/autoload/game_state.gd`：六字段跨章状态、事务式修改、自动存档和备份恢复。
- `scripts/autoload/session_state.gd`：精确场景续玩与静音设置。
- `scripts/autoload/audio_director.gd`：Music、Ambience、SFX 三类播放和切换。
- `scripts/domain/`：章节/收集物规则与版本化 JSON 存档编码。
- `assets/art/backgrounds/`：章节、现实回声背景；`assets/art/title_key_art.png` 为标题主视觉。
- `assets/art/props/`：4 张透明交互物件图集。
- `assets/audio/`：30 条 CC0 音乐、环境声和交互音效。
- `tests/`：不依赖可视窗口的状态与存档测试。

## 存档契约

故事存档位于 `user://me_again/save_v1.json`，同目录保留上一版 `.bak`。写入先落到 `.tmp` 再轮换主文件；主存档损坏时优先恢复备份，两者都不可用时回到安全默认状态。

跨章存档仅持久化六个白名单字段：

```text
currentChapter
chapterProgress
perceptionStage
collectedItems
chapterUnlocks
visitedEchoes
```

精确续玩场景和静音设置另存于 `user://me_again/session_v1.json`。短谜题不保存一半完成的手势状态，重新进入时从当前幕开头继续。

## 自动验证

状态与存档：

```bash
HOME=/tmp/me-again-godot-home \
  /Applications/Godot.app/Contents/MacOS/Godot \
  --headless --path game --script res://tests/run_all.gd
```

预期结果：`PASS: 138 assertions`。

内容目录：

```bash
HOME=/tmp/me-again-godot-home \
  /Applications/Godot.app/Contents/MacOS/Godot \
  --headless --path game --script res://scripts/content/catalog_self_check.gd
```

预期结果：`Story content catalog OK: 5 chapters, 30 scenes, 9 collectibles.`

交互契约：

```bash
HOME=/tmp/me-again-godot-home \
  /Applications/Godot.app/Contents/MacOS/Godot \
  --headless --path game --script res://scripts/interactions/interaction_self_check.gd
```

预期结果包含 `158 assertions` 和 `17 contracts`。

## 导出边界

本机尚未安装与 Godot 4.7.1 精确匹配的 export templates，所以当前完成的是可编辑、可运行、可自动验证的制作工程，尚未声称已产出 Web 或桌面发布包。安装匹配模板后再增加 export preset，并分别验证浏览器音频、触控、字体、存档与窗口适配。
