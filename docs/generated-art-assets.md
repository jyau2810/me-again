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
