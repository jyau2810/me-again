# 《我》/ Me Again

五章制竖屏点触叙事游戏。成年主角在普通现实与童年里世界之间往返，重新学会认真看、慢下来、承认喜欢，也允许自己暂时躲进安静的角落。

## 当前工程

- `game/`：当前唯一开发中的 Godot `4.7.1` 工程，使用 GL Compatibility；逻辑画布 720 × 1280，桌面窗口 540 × 960 并最大化显示。
- 当前内容：5 章、30 幕、9 件收集物、17 类交互，五章可从标题页连续游玩。
- 交互原则：可操作物直接嵌在场景中；不使用显式“操作按钮”；观察后出现图文观察卡，场景完成后出现回忆卡。
- 当前资源：7 张竖屏背景/主视觉、4 张交互物件图集、30 条 CC0 音频和随工程打包的中文字体。公交车窗与操场跑道背景已经过针对性交正。
- `docs/me-story-manuscript.md`：叙事母本；游戏脚本、运行时文案、交互和资源决策均以它为基线。
- `docs/development-plan.md`：项目进度的唯一跟踪表。
- `legacy-web-cocos-prototype/`：旧 Web/Cocos 技术实验，仅供历史参考，不参与当前产品实现或验收。

工程结构、运行方式与测试命令见 [game/README.md](./game/README.md)。资源来源和许可证见 [docs/audio-licenses.md](./docs/audio-licenses.md)、[docs/generated-art-assets.md](./docs/generated-art-assets.md) 与 [docs/third-party-notices.md](./docs/third-party-notices.md)。

## 打开工程

```bash
/Applications/Godot.app/Contents/MacOS/Godot --editor --path game
```

本机目前缺少与 Godot `4.7.1.stable.official.a13da4feb` 精确匹配的 export templates，因此工程可编辑、运行和测试，但尚未生成 Web 或桌面发布包。下一阶段先进行 5–8 人本地外部试玩，再安装匹配模板并补导出验收。
