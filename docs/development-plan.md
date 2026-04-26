# 《我》竖切 Demo 开发计划

## 当前实现目标

本仓库的第一阶段实现聚焦第二章“绕完这一圈”：现实学校开场、绕圈入界、操场环线、粉笔走廊、旧课桌岛、真正的第四圈、半截粉笔、贴纸星星和结尾现实回声。

由于 Cocos Creator 工程需要编辑器生成场景资源，本次先在 `game/` 内建立两层可运行基础：

- Cocos Creator 3.8 项目骨架：`game/tsconfig.json`、`game/.creator/default-meta.json`、`game/assets/scripts/DemoStateBridge.ts`。
- 零依赖 Web 原型：`game/web/index.html`，用于快速体验核心流程和验证触控节奏。

## 范围边界

第一阶段只验证 10-20 分钟竖切 Demo，不做内购、广告、排行榜、多人玩法、复杂账号、云存档、正式商业化和完整五章内容。

平台顺序保持为：Cocos 编辑器完整跑通、微信开发者工具预览、小范围测试。抖音小游戏、itch.io 和商业化路径留到 Demo 验证后再规划。

## 核心接口

`game/src/gameState.js` 已实现可测试的核心状态模型：

- `SaveData`：版本、当前场景、章节进度、绕圈次数、感知文本阶段、谜题状态、收集状态。
- `SceneState`：现实学校、操场环线、粉笔走廊、旧课桌岛、结尾现实回声。
- `Interactable`：可点击调查、谜题提示、隐藏道具。
- `PerceptionText`：`opening / afterChapter / endingEcho` 三档文本。
- `PuzzleState`：粉笔纸条、课桌地图、真正的第四圈。
- `Collectible`：半截粉笔、贴纸星星。

`game/assets/scripts/DemoStateBridge.ts` 保留 Cocos 组件入口，后续在 Creator 里绑定 `Label`、按钮和场景节点即可把同一套流程落到正式场景。

## 本地运行

测试：

```bash
/Users/jyau/.local/bin/npm --prefix game test
```

完整验收：

```bash
/Users/jyau/.local/bin/npm --prefix game run verify
```

Web 原型可以用任意静态服务器打开 `game/web/index.html`。后续若要在 Cocos 中继续制作，使用 Cocos Dashboard 导入 `game/`，再在 Creator 3.8.8 里创建竖屏 2D 场景并绑定 `DemoStateBridge`。

## 下一步

1. 在 Cocos Creator 中创建正式竖屏场景，绑定 `DemoStateBridge` 到根节点。
2. 用灰盒节点还原学校门口、操场、走廊、旧课桌岛和结尾复访。
3. 将 Web 原型中验证过的按钮、文本气泡、收集册和场景切换迁入 Cocos UI。
4. 用微信开发者工具预览小游戏构建，检查包体、加载、适配和本地存档。
