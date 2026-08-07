# 《我》Cocos 灰盒原型

阶段：Stage 3 灰盒交互验证  
目标版本：Cocos Creator 3.8.x  
当前范围：第一章《灰色早晨》低保真完整流程

## 当前验证目标

- 脚本基准：`docs/game-script-chapter-01.md`
- 全局顺序：`docs/game-script-index.md`
- 进度基准：`docs/development-plan.md`

第一轮只验证交互节奏和状态推进，不制作正式美术、音乐或发布包。

## 可玩流程

1. 早晨房间点击现实物件。
2. 三次观察车窗进入里世界。
3. 标记 3 辆友军与 2 辆敌军。
4. 拖动安全路线，进入信号灯塔。
5. 输入 `绿、绿、红、绿`。
6. 复访 3 个现实回声物件，完成第一章。

## 交互表现

- 每个场景由脚本数据生成低保真灰盒舞台，不依赖正式美术资源。
- 舞台上的亮色描边框就是当前可交互热点，点击后会推进状态或给出错误反馈。
- 车窗观察和信号灯节奏只显示当前有效热点，避免玩家面对一整组文本按钮。
- 下方提示条会同步显示房间调查、车窗观察、车阵标记、信号节奏和回声复访进度。

## 验证

```bash
npm test
npm run verify
```

Node 测试覆盖核心状态机；Cocos Creator 手动运行用于检查 UI 绑定与低保真交互表现。

## Cocos Creator 运行

用 Cocos Dashboard 打开本目录，Creator 3.8.x 会默认载入 `assets/scenes/chapter-one-greybox.scene`。如果看到空白 Untitled 场景，请在 Assets 面板双击 `scenes/chapter-one-greybox` 后再运行预览。
