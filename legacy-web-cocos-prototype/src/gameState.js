export const SCENES = {
  REALITY_SCHOOL_GATE: 'reality-school-gate',
  PLAYGROUND_LOOP: 'playground-loop',
  CHALK_CORRIDOR: 'chalk-corridor',
  OLD_DESK_ISLAND: 'old-desk-island',
  ENDING_REALITY_ECHO: 'ending-reality-echo',
};

export const COLLECTIBLES = {
  HALF_CHALK: 'half-chalk',
  STICKER_STAR: 'sticker-star',
};

const perceptionTexts = {
  tree: {
    opening: '树。',
    afterChapter: '一棵很高的树。',
    endingEcho: '树把影子伸过来，好像在跟你打招呼。',
  },
  flower: {
    opening: '小花。',
    afterChapter: '花开在砖缝里。',
    endingEcho: '小花站得很直，好像今天也有自己的事要做。',
  },
  schoolGate: {
    opening: '校门。',
    afterChapter: '校门旁边有几道粉笔灰。',
    endingEcho: '校门像一张没有关紧的作业本。',
  },
  streetLight: {
    opening: '路灯。',
    afterChapter: '路灯下面有一圈亮。',
    endingEcho: '路灯把晚上举起来一点，让路没那么怕黑。',
  },
  desk: {
    opening: '课桌。',
    afterChapter: '桌角有几道旧划痕。',
    endingEcho: '课桌偷偷留着以前的小路，只是你很久没问它了。',
  },
  window: {
    opening: '窗户。',
    afterChapter: '窗户里有一点你的影子。',
    endingEcho: '窗户把灯光揉成一条河，你站在河边。',
  },
};

const sceneInteractions = {
  [SCENES.REALITY_SCHOOL_GATE]: [
    { id: 'tree', label: '树', type: 'perception' },
    { id: 'flower', label: '小花', type: 'perception' },
    { id: 'schoolGate', label: '校门', type: 'perception' },
    { id: 'streetLight', label: '路灯', type: 'perception' },
  ],
  [SCENES.PLAYGROUND_LOOP]: [
    { id: 'track-line', label: '跑道线', type: 'hint', text: '线弯了一下，好像在等你慢下来。' },
    { id: 'chalk-rule-note', label: '粉笔纸条', type: 'puzzleHint', text: '第四圈要慢慢跑，不然门会装作没看见。' },
  ],
  [SCENES.CHALK_CORRIDOR]: [
    { id: 'chalk-rule-note', label: '粉笔纸条', type: 'puzzleHint', text: '第四圈要慢慢跑，不然门会装作没看见。' },
    { id: 'wall-arrow', label: '墙上箭头', type: 'hint', text: '箭头没有指向前面，而是指向你刚跑过的地方。' },
  ],
  [SCENES.OLD_DESK_ISLAND]: [
    { id: 'desk-map', label: '课桌地图', type: 'puzzleHint', text: '桌角画着小地图：三圈以后，从影子短的那边开始第四圈。' },
    { id: COLLECTIBLES.HALF_CHALK, label: '半截粉笔', type: 'collectible' },
    { id: COLLECTIBLES.STICKER_STAR, label: '贴纸星星', type: 'collectible' },
  ],
  [SCENES.ENDING_REALITY_ECHO]: [
    { id: 'tree', label: '树', type: 'perception' },
    { id: 'flower', label: '小花', type: 'perception' },
    { id: 'schoolGate', label: '校门', type: 'perception' },
    { id: 'streetLight', label: '路灯', type: 'perception' },
    { id: 'desk', label: '课桌', type: 'perception' },
    { id: 'window', label: '窗户', type: 'perception' },
  ],
};

const knownSaveKeys = [
  'version',
  'currentScene',
  'chapterProgress',
  'loopCount',
  'perceptionStage',
  'sceneEffects',
  'puzzleState',
  'collectedItems',
  'inspectedInteractions',
];

export function createInitialSaveData() {
  return {
    version: 1,
    currentScene: SCENES.REALITY_SCHOOL_GATE,
    chapterProgress: 'opening',
    loopCount: 0,
    perceptionStage: 'opening',
    sceneEffects: {
      windowLights: false,
      chalkArrowsVisible: false,
      warmPalette: false,
    },
    puzzleState: {
      chalkRuleRead: false,
      deskMapRead: false,
      trueFourthLoopFound: false,
    },
    collectedItems: [],
    inspectedInteractions: [],
  };
}

export function getPerceptionText(objectId, stage) {
  const entry = perceptionTexts[objectId];
  if (!entry) {
    throw new Error(`Unknown perception object: ${objectId}`);
  }
  return entry[stage] ?? entry.opening;
}

export function getAvailableInteractions(sceneId) {
  return [...(sceneInteractions[sceneId] ?? [])];
}

export function collectItem(saveData, itemId) {
  if (!Object.values(COLLECTIBLES).includes(itemId)) {
    throw new Error(`Unknown collectible: ${itemId}`);
  }
  if (saveData.collectedItems.includes(itemId)) {
    return cloneSave(saveData);
  }
  return {
    ...cloneSave(saveData),
    collectedItems: [...saveData.collectedItems, itemId],
  };
}

export function moveToScene(saveData, sceneId) {
  if (!Object.values(SCENES).includes(sceneId)) {
    throw new Error(`Unknown scene: ${sceneId}`);
  }
  if (sceneId !== SCENES.REALITY_SCHOOL_GATE && saveData.chapterProgress === 'opening') {
    throw new Error('需要先完成入界动作。');
  }
  return {
    ...cloneSave(saveData),
    currentScene: sceneId,
  };
}

export function serializeSaveData(saveData) {
  return JSON.stringify(pickKnownSaveFields(saveData));
}

export function restoreSaveData(serialized) {
  const parsed = typeof serialized === 'string' ? JSON.parse(serialized) : serialized;
  return {
    ...createInitialSaveData(),
    ...pickKnownSaveFields(parsed),
    sceneEffects: {
      ...createInitialSaveData().sceneEffects,
      ...parsed.sceneEffects,
    },
    puzzleState: {
      ...createInitialSaveData().puzzleState,
      ...parsed.puzzleState,
    },
    collectedItems: Array.isArray(parsed.collectedItems) ? [...parsed.collectedItems] : [],
    inspectedInteractions: Array.isArray(parsed.inspectedInteractions) ? [...parsed.inspectedInteractions] : [],
  };
}

export function makeGameEngine(initialSaveData = createInitialSaveData()) {
  let state = restoreSaveData(initialSaveData);

  return {
    getState() {
      return cloneSave(state);
    },
    performLoop() {
      state = advanceLoop(state);
      return cloneSave(state);
    },
    inspect(interactionId) {
      state = inspectInteraction(state, interactionId);
      return cloneSave(state);
    },
    collect(itemId) {
      state = collectItem(state, itemId);
      return cloneSave(state);
    },
    moveTo(sceneId) {
      state = moveToScene(state, sceneId);
      return cloneSave(state);
    },
    performTrueFourthLoop() {
      state = completeTrueFourthLoop(state);
      return cloneSave(state);
    },
  };
}

function advanceLoop(saveData) {
  const loopCount = Math.min(saveData.loopCount + 1, 4);
  const sceneEffects = {
    windowLights: loopCount >= 2,
    chalkArrowsVisible: loopCount >= 3,
    warmPalette: loopCount >= 3,
  };

  return {
    ...cloneSave(saveData),
    loopCount,
    sceneEffects,
    currentScene: loopCount >= 3 ? SCENES.PLAYGROUND_LOOP : SCENES.REALITY_SCHOOL_GATE,
    chapterProgress: loopCount >= 3 ? 'innerWorld' : 'opening',
    perceptionStage: loopCount >= 3 ? 'afterChapter' : 'opening',
  };
}

function inspectInteraction(saveData, interactionId) {
  const puzzleState = { ...saveData.puzzleState };
  if (interactionId === 'chalk-rule-note') {
    puzzleState.chalkRuleRead = true;
  }
  if (interactionId === 'desk-map') {
    puzzleState.deskMapRead = true;
  }

  return {
    ...cloneSave(saveData),
    puzzleState,
    inspectedInteractions: saveData.inspectedInteractions.includes(interactionId)
      ? [...saveData.inspectedInteractions]
      : [...saveData.inspectedInteractions, interactionId],
  };
}

function completeTrueFourthLoop(saveData) {
  if (!saveData.puzzleState.chalkRuleRead) {
    throw new Error('还没有读懂粉笔纸条。');
  }
  if (!saveData.puzzleState.deskMapRead) {
    throw new Error('还没有看过课桌地图。');
  }

  return {
    ...cloneSave(saveData),
    loopCount: 4,
    currentScene: SCENES.ENDING_REALITY_ECHO,
    chapterProgress: 'ending',
    perceptionStage: 'endingEcho',
    puzzleState: {
      ...saveData.puzzleState,
      trueFourthLoopFound: true,
    },
  };
}

function pickKnownSaveFields(value) {
  return Object.fromEntries(
    Object.entries(value ?? {}).filter(([key]) => knownSaveKeys.includes(key)),
  );
}

function cloneSave(saveData) {
  return {
    ...saveData,
    sceneEffects: { ...saveData.sceneEffects },
    puzzleState: { ...saveData.puzzleState },
    collectedItems: [...saveData.collectedItems],
    inspectedInteractions: [...saveData.inspectedInteractions],
  };
}
