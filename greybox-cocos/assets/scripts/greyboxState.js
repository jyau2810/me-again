export const CHAPTER_ONE = {
  id: '01_grey_morning',
  title: '第一章：灰色早晨',
  status: '可玩',
};

export const CHAPTERS = [
  CHAPTER_ONE,
  { id: '02_looping_school', title: '第二章：绕完这一圈', status: '待验证' },
  { id: '04_cabinet_breath', title: '第四章：柜子里的呼吸', status: '待验证' },
  { id: '03_paper_friends', title: '第三章：纸片朋友', status: '待验证' },
  { id: '05_after_forest', title: '第五章：密林之后', status: '待验证' },
];

export const CHAPTER_PROGRESS = ['opening', 'entry', 'inner_world', 'echo', 'complete'];

const FRIEND_VEHICLES = ['round_light', 'soft_light', 'blinking_light'];
const ENEMY_VEHICLES = ['narrow_light', 'late_corner'];
const SIGNAL_PATTERN = ['green', 'green', 'red', 'green'];

export const SCENES = [
  {
    id: 'c01_s01_room_morning',
    title: '早晨房间',
    copy: '早晨没有坏到哪里去。只是每一样东西都像已经安排好了。',
    goal: '点击房间里的现实物件。调查三个以上物件后，门锁会带你出门。',
    stage: {
      caption: '灰盒房间：所有亮框都是可点物件。',
      elements: [
        { label: '床', x: -250, y: -55, width: 210, height: 110, color: [70, 78, 76, 220] },
        { label: '窗', x: -250, y: 95, width: 170, height: 92, color: [78, 93, 99, 220] },
        { label: '桌', x: 30, y: -70, width: 180, height: 88, color: [72, 66, 58, 220] },
        { label: '门', x: 300, y: 15, width: 110, height: 210, color: [66, 61, 55, 230] },
        { label: '主角', x: -110, y: -10, width: 62, height: 120, color: [118, 126, 121, 230] },
      ],
    },
    interactions: [
      { id: 'tap_alarm', label: '闹钟', feedback: '闹钟停下。房间还是很安静。', hotspot: { x: -330, y: 18, width: 118, height: 52, action: '点击', tone: 'reality' } },
      { id: 'tap_cup', label: '杯子', feedback: '杯子。', hotspot: { x: -12, y: -18, width: 100, height: 52, action: '点击', tone: 'reality' } },
      { id: 'tap_shirt', label: '衬衫', feedback: '衬衫。', hotspot: { x: 114, y: -96, width: 112, height: 52, action: '点击', tone: 'reality' } },
      { id: 'tap_keys', label: '钥匙', feedback: '钥匙。', hotspot: { x: 83, y: -16, width: 96, height: 52, action: '点击', tone: 'reality' } },
      { id: 'tap_door_lock', label: '门锁', feedback: '门锁。可以出门了。', hotspot: { x: 308, y: 31, width: 112, height: 58, action: '点击', tone: 'exit' } },
    ],
  },
  {
    id: 'c01_s02_commute_window',
    title: '通勤车窗',
    copy: '车窗外的灯一格一格往后退。',
    goal: '连续观察车窗三次，让普通车灯慢慢变成“有表情”的入口。',
    stage: {
      caption: '通勤后座：大车窗是当前唯一关键热点。',
      elements: [
        { label: '车窗', x: 0, y: 50, width: 600, height: 165, color: [52, 69, 78, 225] },
        { label: '路灯线', x: -120, y: 88, width: 270, height: 16, color: [180, 166, 112, 210] },
        { label: '前车灯', x: 176, y: 51, width: 150, height: 46, color: [204, 190, 132, 220] },
        { label: '手机冷光', x: -235, y: -112, width: 95, height: 62, color: [75, 92, 132, 220] },
        { label: '后座', x: 0, y: -105, width: 620, height: 70, color: [54, 51, 48, 235] },
      ],
    },
    interactions: [
      { id: 'tap_window_1', label: '看车窗', feedback: '车窗。', hotspot: { x: 0, y: 55, width: 250, height: 76, action: '观察', tone: 'entry' } },
      { id: 'tap_window_2', label: '再看一会儿', feedback: '车窗上有一点你的影子。', hotspot: { x: 0, y: 55, width: 278, height: 76, action: '观察', tone: 'entry' } },
      { id: 'tap_window_3', label: '继续看', feedback: '前面的车灯，好像在看这边。', hotspot: { x: 176, y: 52, width: 230, height: 76, action: '观察', tone: 'entry' } },
    ],
  },
  {
    id: 'c01_s03_night_car_array',
    title: '夜路车阵',
    copy: '车灯开始像眼睛，车牌像嘴。',
    goal: '把 3 辆友军和 2 辆敌军分清楚。标错会留下提示，但不会卡死。',
    stage: {
      caption: '夜路棋盘：暖色偏友军，冷硬细灯偏敌军。',
      elements: [
        { label: '友军路线', x: -230, y: -90, width: 210, height: 52, color: [75, 96, 70, 210] },
        { label: '敌军岔路', x: 235, y: -90, width: 210, height: 52, color: [90, 58, 61, 210] },
        { label: '圆灯车', x: -275, y: 72, width: 112, height: 58, color: [148, 132, 80, 225] },
        { label: '软灯车', x: -95, y: 38, width: 112, height: 58, color: [130, 125, 93, 225] },
        { label: '眨灯车', x: 80, y: 86, width: 112, height: 58, color: [122, 132, 82, 225] },
        { label: '细灯车', x: 260, y: 33, width: 112, height: 58, color: [80, 92, 118, 225] },
        { label: '拐角车', x: 15, y: -52, width: 112, height: 58, color: [95, 70, 78, 225] },
      ],
    },
    interactions: [
      { id: 'mark_round_light_friend', label: '圆灯：友军', feedback: '圆圆的灯光站到你这边。', hotspot: { x: -275, y: 115, width: 128, height: 46, action: '标记友军', tone: 'friend' } },
      { id: 'mark_round_light_enemy', label: '圆灯：敌军', feedback: '不太对。它不像坏家伙。', hotspot: { x: -275, y: 62, width: 128, height: 46, action: '标记敌军', tone: 'enemy' } },
      { id: 'mark_soft_light_friend', label: '软灯：友军', feedback: '它亮得不吓人。', hotspot: { x: -95, y: 82, width: 128, height: 46, action: '标记友军', tone: 'friend' } },
      { id: 'mark_blinking_light_friend', label: '眨灯：友军', feedback: '它像是在打暗号。', hotspot: { x: 80, y: 130, width: 128, height: 46, action: '标记友军', tone: 'friend' } },
      { id: 'mark_narrow_light_enemy', label: '细灯：敌军', feedback: '细细的灯眯起来了。', hotspot: { x: 260, y: 78, width: 128, height: 46, action: '标记敌军', tone: 'enemy' } },
      { id: 'mark_late_corner_enemy', label: '拐角车：敌军', feedback: '它停太久了，像埋伏。', hotspot: { x: 15, y: -8, width: 140, height: 46, action: '标记敌军', tone: 'enemy' } },
    ],
  },
  {
    id: 'c01_s04_backseat_fort',
    title: '后座堡垒',
    copy: '后座像一座很小的堡垒。',
    goal: '拖出安全路线，让友军通过；也可以找座椅缝里的糖纸。',
    stage: {
      caption: '后座指挥室：安全带和座椅缝组成临时地图。',
      elements: [
        { label: '后座堡垒', x: 0, y: -20, width: 610, height: 165, color: [61, 56, 52, 230] },
        { label: '路线图', x: 0, y: 65, width: 330, height: 116, color: [86, 83, 70, 225] },
        { label: '安全带线', x: -175, y: 0, width: 250, height: 20, color: [130, 118, 82, 225] },
        { label: '敌军节点', x: 160, y: 45, width: 74, height: 50, color: [96, 56, 61, 225] },
        { label: '糖纸闪光', x: -280, y: -122, width: 76, height: 38, color: [168, 146, 94, 230] },
      ],
    },
    interactions: [
      { id: 'drag_safe_route', label: '拖出安全路线', feedback: '友军沿着安全线绕过去。', hotspot: { x: 0, y: 69, width: 260, height: 70, action: '拖动', tone: 'route' } },
      { id: 'collect_candy_badge', label: '糖纸', feedback: '获得隐藏道具：糖纸徽章。', hotspot: { x: -280, y: -122, width: 118, height: 46, action: '点击', tone: 'collect' } },
    ],
  },
  {
    id: 'c01_s05_signal_tower',
    title: '信号灯塔',
    copy: '灯塔只听得懂小孩口令。',
    goal: '按小孩口令输入节奏：绿、绿、红、绿。错了会重置当前节奏。',
    stage: {
      caption: '信号灯塔：当前正确灯和一个错误灯都会显示。',
      elements: [
        { label: '灯塔', x: 0, y: 38, width: 125, height: 210, color: [56, 57, 59, 235] },
        { label: '绿灯位', x: 0, y: 96, width: 70, height: 52, color: [72, 132, 88, 235] },
        { label: '红灯位', x: 0, y: 18, width: 70, height: 52, color: [142, 63, 63, 235] },
        { label: '友军等待', x: -242, y: -115, width: 230, height: 56, color: [74, 98, 72, 225] },
        { label: '敌军旁路', x: 245, y: -115, width: 230, height: 56, color: [94, 62, 66, 225] },
      ],
    },
    interactions: [
      { id: 'tap_green_1', label: '绿', feedback: '第一盏绿灯亮起。', hotspot: { x: -76, y: 100, width: 120, height: 56, action: '节奏', tone: 'green' } },
      { id: 'tap_green_2', label: '绿', feedback: '第二辆友军向前。', hotspot: { x: -76, y: 100, width: 120, height: 56, action: '节奏', tone: 'green' } },
      { id: 'tap_red_3', label: '红', feedback: '敌军停住。', hotspot: { x: 76, y: 20, width: 120, height: 56, action: '节奏', tone: 'red' } },
      { id: 'tap_green_4', label: '绿', feedback: '友军全部通过。', hotspot: { x: -76, y: 100, width: 120, height: 56, action: '节奏', tone: 'green' } },
      { id: 'tap_red_wrong', label: '红', feedback: '不对，它听不懂。', hotspot: { x: 76, y: 20, width: 120, height: 56, action: '节奏', tone: 'red' } },
    ],
  },
  {
    id: 'c01_s06_commute_echo',
    title: '第二天通勤',
    copy: '现实还是现实，但没有那么冷。',
    goal: '复访三个现实回声物件。重复点击不会重复计数。',
    stage: {
      caption: '现实回声：同一辆车，但窗外开始有温度。',
      elements: [
        { label: '车窗河流', x: 0, y: 65, width: 600, height: 150, color: [55, 78, 86, 225] },
        { label: '红灯小旗', x: 235, y: 74, width: 86, height: 66, color: [140, 62, 63, 225] },
        { label: '树影', x: -246, y: 48, width: 94, height: 126, color: [58, 88, 70, 225] },
        { label: '手机', x: -220, y: -118, width: 92, height: 58, color: [65, 79, 105, 225] },
        { label: '座椅', x: 0, y: -110, width: 620, height: 70, color: [56, 52, 48, 235] },
      ],
    },
    interactions: [
      { id: 'tap_window_echo', label: '车窗', feedback: '车窗把灯光揉成一条河，你坐在河边。', hotspot: { x: -40, y: 68, width: 170, height: 58, action: '复访', tone: 'echo' } },
      { id: 'tap_red_light_echo', label: '红灯', feedback: '红灯亮着，像有人在远处举起小旗。', hotspot: { x: 235, y: 74, width: 118, height: 52, action: '复访', tone: 'echo' } },
      { id: 'tap_tree_echo', label: '树影', feedback: '树影跟着车走了一小段。', hotspot: { x: -246, y: 48, width: 118, height: 52, action: '复访', tone: 'echo' } },
      { id: 'tap_phone_echo', label: '手机', feedback: '手机还在手里，但你没有马上低头。', hotspot: { x: -220, y: -118, width: 118, height: 52, action: '复访', tone: 'echo' } },
    ],
  },
];

const sceneById = new Map(SCENES.map((scene) => [scene.id, scene]));
const interactionById = new Map(SCENES.flatMap((scene) => scene.interactions.map((interaction) => [interaction.id, interaction])));

export function createInitialGreyboxState() {
  return {
    currentChapter: CHAPTER_ONE.id,
    currentScene: 'c01_s01_room_morning',
    chapterProgress: 'opening',
    perceptionStage: 'opening',
    collectedItems: [],
    chapterUnlocks: {
      [CHAPTER_ONE.id]: true,
    },
    visitedEchoes: [],
    echoObjectsVisited: [],
    sceneVisited: [],
    chapterOne: {
      roomObjectsRead: [],
      windowObservationCount: 0,
      vehicleMarks: {},
      safeRouteReady: false,
      signalRhythm: [],
      signalRhythmSolved: false,
    },
    lastFeedback: '',
  };
}

export function getAvailableInteractions(state) {
  const scene = sceneById.get(state.currentScene);
  const interactions = scene?.interactions ?? [];

  if (state.currentScene === 'c01_s02_commute_window') {
    const nextObservationId = `tap_window_${Math.min(state.chapterOne.windowObservationCount + 1, 3)}`;
    return interactions.filter((interaction) => interaction.id === nextObservationId);
  }

  if (state.currentScene === 'c01_s05_signal_tower') {
    const correctId = ['tap_green_1', 'tap_green_2', 'tap_red_3', 'tap_green_4'][state.chapterOne.signalRhythm.length] ?? 'tap_green_4';
    const wrongId = correctId === 'tap_red_3' ? 'tap_green_1' : 'tap_red_wrong';
    return interactions.filter((interaction) => interaction.id === correctId || interaction.id === wrongId);
  }

  return [...interactions];
}

export function getCurrentScene(state) {
  return sceneById.get(state.currentScene);
}

export function performInteraction(state, interactionId) {
  if (!interactionById.has(interactionId)) {
    throw new Error(`Unknown interaction: ${interactionId}`);
  }

  const next = cloneState(state);
  const interaction = interactionById.get(interactionId);
  next.lastFeedback = interaction.feedback;

  if (interactionId.endsWith('_echo')) {
    visitEcho(next, echoKeyFor(interactionId));
    return next;
  }

  if (interactionId.startsWith('tap_window_')) {
    observeWindow(next);
    return next;
  }

  if (interactionId.startsWith('mark_')) {
    markVehicle(next, interactionId);
    return next;
  }

  if (interactionId === 'drag_safe_route') {
    if (!next.chapterOne.safeRouteReady) {
      next.lastFeedback = '路线还看不清，先分清车灯阵营。';
      return next;
    }
    next.currentScene = 'c01_s05_signal_tower';
    return next;
  }

  if (interactionId.startsWith('tap_green') || interactionId === 'tap_red_3' || interactionId === 'tap_red_wrong') {
    pressSignal(next, interactionId);
    return next;
  }

  if (interactionId === 'collect_candy_badge') {
    addUnique(next.collectedItems, 'candy_badge');
    return next;
  }

  if (['tap_alarm', 'tap_cup', 'tap_shirt', 'tap_keys', 'tap_door_lock'].includes(interactionId)) {
    addUnique(next.chapterOne.roomObjectsRead, interactionId);
    if (interactionId === 'tap_door_lock') {
      if (next.chapterOne.roomObjectsRead.length >= 3) {
        next.currentScene = 'c01_s02_commute_window';
        next.chapterProgress = 'entry';
      } else {
        next.lastFeedback = '门锁还很冷。先确认房间里几样东西。';
      }
    }
  }

  return next;
}

function observeWindow(state) {
  state.chapterOne.windowObservationCount = Math.min(state.chapterOne.windowObservationCount + 1, 3);
  if (state.chapterOne.windowObservationCount >= 3) {
    state.currentScene = 'c01_s03_night_car_array';
    state.chapterProgress = 'inner_world';
  }
}

function markVehicle(state, interactionId) {
  const [, vehicle, faction] = interactionId.match(/^mark_(.+)_(friend|enemy)$/) ?? [];
  if (!vehicle || !faction) {
    return;
  }

  const expectedFaction = FRIEND_VEHICLES.includes(vehicle) ? 'friend' : ENEMY_VEHICLES.includes(vehicle) ? 'enemy' : undefined;
  state.chapterOne.vehicleMarks[vehicle] = expectedFaction === faction ? faction : 'wrong';

  const allCorrect = [
    ...FRIEND_VEHICLES.map((id) => state.chapterOne.vehicleMarks[id] === 'friend'),
    ...ENEMY_VEHICLES.map((id) => state.chapterOne.vehicleMarks[id] === 'enemy'),
  ].every(Boolean);

  if (allCorrect) {
    state.chapterOne.safeRouteReady = true;
    state.currentScene = 'c01_s04_backseat_fort';
  }
}

function pressSignal(state, interactionId) {
  const signal = interactionId === 'tap_red_3' || interactionId === 'tap_red_wrong' ? 'red' : 'green';
  const expectedSignal = SIGNAL_PATTERN[state.chapterOne.signalRhythm.length];

  if (signal !== expectedSignal || interactionId === 'tap_red_wrong') {
    state.chapterOne.signalRhythm = [];
    state.lastFeedback = '不对，它听不懂。';
    return;
  }

  state.chapterOne.signalRhythm.push(signal);
  if (state.chapterOne.signalRhythm.length === SIGNAL_PATTERN.length) {
    state.chapterOne.signalRhythmSolved = true;
    state.currentScene = 'c01_s06_commute_echo';
    state.chapterProgress = 'echo';
  }
}

function visitEcho(state, echoKey) {
  addUnique(state.echoObjectsVisited, echoKey);
  if (state.echoObjectsVisited.length >= 3) {
    state.chapterProgress = 'complete';
    state.perceptionStage = 'chapter_01_echo';
    state.chapterUnlocks['02_looping_school'] = true;
    addUnique(state.visitedEchoes, 'c01_commute_echo');
  }
}

function echoKeyFor(interactionId) {
  return {
    tap_window_echo: 'window',
    tap_red_light_echo: 'red_light',
    tap_tree_echo: 'tree',
    tap_phone_echo: 'phone',
  }[interactionId];
}

function addUnique(list, value) {
  if (value && !list.includes(value)) {
    list.push(value);
  }
}

function cloneState(state) {
  return structuredClone(state);
}
