import {
  createInitialSaveData,
  getAvailableInteractions,
  getPerceptionText,
  makeGameEngine,
  restoreSaveData,
  serializeSaveData,
} from '../src/gameState.js';

const storageKey = 'me-demo-save-v1';

const sceneCopy = {
  'reality-school-gate': '下班路过学校。树、花、校门和路灯都很普通，像被快速看了一眼。',
  'playground-loop': '第三圈以后，跑道线弯成奇怪的路。窗户里有一点暖光。',
  'chalk-corridor': '墙上的粉笔箭头像小孩写下的规则，短短的，但很认真。',
  'old-desk-island': '课桌排成小岛，抽屉和桌角藏着以前留下来的东西。',
  'ending-reality-echo': '回到现实以后，学校没有变大，也没有变小。只是你看它的方式变了一点。',
};

const sceneTitles = {
  'reality-school-gate': '学校门口',
  'playground-loop': '操场环线',
  'chalk-corridor': '粉笔走廊',
  'old-desk-island': '旧课桌岛',
  'ending-reality-echo': '结尾回声',
};

const sceneTabs = [
  ['playground-loop', '操场'],
  ['chalk-corridor', '走廊'],
  ['old-desk-island', '课桌'],
];

const collectibleNames = {
  'half-chalk': '半截粉笔',
  'sticker-star': '贴纸星星',
};

const saved = localStorage.getItem(storageKey);
const engine = makeGameEngine(saved ? restoreSaveData(saved) : createInitialSaveData());

const elements = {
  stage: document.querySelector('#stage'),
  sceneTitle: document.querySelector('#scene-title'),
  sceneCopy: document.querySelector('#scene-copy'),
  character: document.querySelector('#character'),
  loopButton: document.querySelector('#loop-button'),
  trueFourthLoopButton: document.querySelector('#true-fourth-loop-button'),
  sceneTabs: document.querySelector('#scene-tabs'),
  interactions: document.querySelector('#interactions'),
  interactionOutput: document.querySelector('#interaction-output'),
  collectionBook: document.querySelector('#collection-book'),
  resetButton: document.querySelector('#reset-button'),
};

elements.loopButton.addEventListener('click', () => {
  const state = engine.performLoop();
  const line = state.loopCount < 3
    ? `第 ${state.loopCount} 圈。学校还是学校，只是窗户亮了一点。`
    : '第三圈。粉笔箭头出现了，跑道线像一条会拐弯的路。';
  saveAndRender(line);
});

elements.trueFourthLoopButton.addEventListener('click', () => {
  try {
    engine.performTrueFourthLoop();
    saveAndRender('第四圈慢慢跑完。门没有打开，世界自己退回了现实。');
  } catch (error) {
    render(error.message);
  }
});

elements.resetButton.addEventListener('click', () => {
  localStorage.removeItem(storageKey);
  window.location.reload();
});

function saveAndRender(message) {
  localStorage.setItem(storageKey, serializeSaveData(engine.getState()));
  render(message);
}

function render(message = '树影贴在校门边，像一条没写完的线。') {
  const state = engine.getState();
  elements.sceneTitle.textContent = sceneTitles[state.currentScene];
  elements.sceneCopy.textContent = sceneCopy[state.currentScene];
  elements.interactionOutput.textContent = message;

  elements.stage.className = [
    'stage',
    state.chapterProgress === 'innerWorld' ? 'inner' : '',
    state.currentScene === 'old-desk-island' ? 'desks' : '',
    state.currentScene === 'ending-reality-echo' ? 'ending' : '',
  ].filter(Boolean).join(' ');

  elements.loopButton.disabled = state.currentScene === 'ending-reality-echo' || state.loopCount >= 3;
  elements.trueFourthLoopButton.disabled = state.currentScene === 'ending-reality-echo';

  renderSceneTabs(state);
  renderInteractions(state);
  renderCollection(state);
}

function renderSceneTabs(state) {
  elements.sceneTabs.replaceChildren();
  for (const [sceneId, label] of sceneTabs) {
    const button = document.createElement('button');
    button.type = 'button';
    button.textContent = label;
    button.disabled = state.chapterProgress === 'opening' || state.currentScene === 'ending-reality-echo';
    button.className = state.currentScene === sceneId ? 'active' : '';
    button.addEventListener('click', () => {
      engine.moveTo(sceneId);
      saveAndRender(sceneCopy[sceneId]);
    });
    elements.sceneTabs.append(button);
  }
}

function renderInteractions(state) {
  elements.interactions.replaceChildren();
  for (const interaction of getAvailableInteractions(state.currentScene)) {
    const button = document.createElement('button');
    button.type = 'button';
    button.textContent = interaction.label;
    button.addEventListener('click', () => handleInteraction(interaction));
    elements.interactions.append(button);
  }
}

function handleInteraction(interaction) {
  const state = engine.getState();
  if (interaction.type === 'perception') {
    render(getPerceptionText(interaction.id, state.perceptionStage));
    return;
  }

  if (interaction.type === 'collectible') {
    engine.collect(interaction.id);
    saveAndRender(`${collectibleNames[interaction.id]}被放进铁皮盒。`);
    return;
  }

  engine.inspect(interaction.id);
  saveAndRender(interaction.text);
}

function renderCollection(state) {
  elements.collectionBook.replaceChildren();
  if (state.collectedItems.length === 0) {
    const empty = document.createElement('span');
    empty.className = 'collectible-chip';
    empty.textContent = '空的';
    elements.collectionBook.append(empty);
    return;
  }

  for (const itemId of state.collectedItems) {
    const item = document.createElement('span');
    item.className = 'collectible-chip';
    item.textContent = collectibleNames[itemId];
    elements.collectionBook.append(item);
  }
}

render();
