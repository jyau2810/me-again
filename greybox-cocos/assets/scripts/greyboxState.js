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
    interactions: [
      { id: 'tap_alarm', label: '闹钟', feedback: '闹钟停下。房间还是很安静。' },
      { id: 'tap_cup', label: '杯子', feedback: '杯子。' },
      { id: 'tap_shirt', label: '衬衫', feedback: '衬衫。' },
      { id: 'tap_keys', label: '钥匙', feedback: '钥匙。' },
      { id: 'tap_door_lock', label: '门锁', feedback: '门锁。可以出门了。' },
    ],
  },
  {
    id: 'c01_s02_commute_window',
    title: '通勤车窗',
    copy: '车窗外的灯一格一格往后退。',
    interactions: [
      { id: 'tap_window_1', label: '看车窗', feedback: '车窗。' },
      { id: 'tap_window_2', label: '再看一会儿', feedback: '车窗上有一点你的影子。' },
      { id: 'tap_window_3', label: '继续看', feedback: '前面的车灯，好像在看这边。' },
    ],
  },
  {
    id: 'c01_s03_night_car_array',
    title: '夜路车阵',
    copy: '车灯开始像眼睛，车牌像嘴。',
    interactions: [
      { id: 'mark_round_light_friend', label: '圆灯：友军', feedback: '圆圆的灯光站到你这边。' },
      { id: 'mark_round_light_enemy', label: '圆灯：敌军', feedback: '不太对。它不像坏家伙。' },
      { id: 'mark_soft_light_friend', label: '软灯：友军', feedback: '它亮得不吓人。' },
      { id: 'mark_blinking_light_friend', label: '眨灯：友军', feedback: '它像是在打暗号。' },
      { id: 'mark_narrow_light_enemy', label: '细灯：敌军', feedback: '细细的灯眯起来了。' },
      { id: 'mark_late_corner_enemy', label: '拐角车：敌军', feedback: '它停太久了，像埋伏。' },
    ],
  },
  {
    id: 'c01_s04_backseat_fort',
    title: '后座堡垒',
    copy: '后座像一座很小的堡垒。',
    interactions: [
      { id: 'drag_safe_route', label: '拖出安全路线', feedback: '友军沿着安全线绕过去。' },
      { id: 'collect_candy_badge', label: '糖纸', feedback: '获得隐藏道具：糖纸徽章。' },
    ],
  },
  {
    id: 'c01_s05_signal_tower',
    title: '信号灯塔',
    copy: '灯塔只听得懂小孩口令。',
    interactions: [
      { id: 'tap_green_1', label: '绿', feedback: '第一盏绿灯亮起。' },
      { id: 'tap_green_2', label: '绿', feedback: '第二辆友军向前。' },
      { id: 'tap_red_3', label: '红', feedback: '敌军停住。' },
      { id: 'tap_green_4', label: '绿', feedback: '友军全部通过。' },
      { id: 'tap_red_wrong', label: '误按红灯', feedback: '不对，它听不懂。' },
    ],
  },
  {
    id: 'c01_s06_commute_echo',
    title: '第二天通勤',
    copy: '现实还是现实，但没有那么冷。',
    interactions: [
      { id: 'tap_window_echo', label: '车窗', feedback: '车窗把灯光揉成一条河，你坐在河边。' },
      { id: 'tap_red_light_echo', label: '红灯', feedback: '红灯亮着，像有人在远处举起小旗。' },
      { id: 'tap_tree_echo', label: '树影', feedback: '树影跟着车走了一小段。' },
      { id: 'tap_phone_echo', label: '手机', feedback: '手机还在手里，但你没有马上低头。' },
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
  return [...(sceneById.get(state.currentScene)?.interactions ?? [])];
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
    if (interactionId === 'tap_door_lock' && next.chapterOne.roomObjectsRead.length >= 3) {
      next.currentScene = 'c01_s02_commute_window';
      next.chapterProgress = 'entry';
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
