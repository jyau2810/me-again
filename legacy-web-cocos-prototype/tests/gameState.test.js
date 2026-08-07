import assert from 'node:assert/strict';
import test from 'node:test';

import {
  collectItem,
  createInitialSaveData,
  getAvailableInteractions,
  getPerceptionText,
  makeGameEngine,
  moveToScene,
  restoreSaveData,
  serializeSaveData,
} from '../src/gameState.js';

test('initial save data matches the Demo scope', () => {
  const save = createInitialSaveData();

  assert.equal(save.version, 1);
  assert.equal(save.currentScene, 'reality-school-gate');
  assert.equal(save.chapterProgress, 'opening');
  assert.equal(save.loopCount, 0);
  assert.equal(save.perceptionStage, 'opening');
  assert.deepEqual(save.collectedItems, []);
  assert.equal(save.puzzleState.trueFourthLoopFound, false);
});

test('repeated loops move reality toward the inner world', () => {
  const engine = makeGameEngine(createInitialSaveData());

  engine.performLoop();
  assert.equal(engine.getState().loopCount, 1);
  assert.equal(engine.getState().currentScene, 'reality-school-gate');

  engine.performLoop();
  assert.equal(engine.getState().sceneEffects.windowLights, true);

  engine.performLoop();
  assert.equal(engine.getState().sceneEffects.chalkArrowsVisible, true);
  assert.equal(engine.getState().currentScene, 'playground-loop');
  assert.equal(engine.getState().chapterProgress, 'innerWorld');
});

test('the true fourth loop requires reading the childish rule before returning', () => {
  const engine = makeGameEngine(createInitialSaveData());

  engine.performLoop();
  engine.performLoop();
  engine.performLoop();
  engine.inspect('chalk-rule-note');
  engine.inspect('desk-map');
  engine.performTrueFourthLoop();

  assert.equal(engine.getState().puzzleState.chalkRuleRead, true);
  assert.equal(engine.getState().puzzleState.deskMapRead, true);
  assert.equal(engine.getState().puzzleState.trueFourthLoopFound, true);
  assert.equal(engine.getState().currentScene, 'ending-reality-echo');
  assert.equal(engine.getState().perceptionStage, 'endingEcho');
});

test('the true fourth loop is blocked until both environmental hints are read', () => {
  const engine = makeGameEngine(createInitialSaveData());

  engine.performLoop();
  engine.performLoop();
  engine.performLoop();
  engine.inspect('chalk-rule-note');

  assert.throws(() => engine.performTrueFourthLoop(), /课桌地图/);
});

test('perception text changes across opening, after chapter, and ending echo', () => {
  assert.equal(getPerceptionText('tree', 'opening'), '树。');
  assert.equal(getPerceptionText('tree', 'afterChapter'), '一棵很高的树。');
  assert.equal(getPerceptionText('tree', 'endingEcho'), '树把影子伸过来，好像在跟你打招呼。');
});

test('collectibles enter the collection book once', () => {
  const save = createInitialSaveData();
  const withChalk = collectItem(save, 'half-chalk');
  const duplicate = collectItem(withChalk, 'half-chalk');
  const withStar = collectItem(duplicate, 'sticker-star');

  assert.deepEqual(withStar.collectedItems, ['half-chalk', 'sticker-star']);
});

test('available interactions expose the required vertical slice content', () => {
  const interactions = getAvailableInteractions('old-desk-island');
  const ids = interactions.map((item) => item.id);

  assert.deepEqual(ids, ['desk-map', 'half-chalk', 'sticker-star']);
});

test('scene changes are constrained to the demo route', () => {
  const save = createInitialSaveData();
  const innerWorld = {
    ...save,
    chapterProgress: 'innerWorld',
    currentScene: 'playground-loop',
  };

  assert.equal(moveToScene(innerWorld, 'chalk-corridor').currentScene, 'chalk-corridor');
  assert.equal(moveToScene(innerWorld, 'old-desk-island').currentScene, 'old-desk-island');
  assert.throws(() => moveToScene(innerWorld, 'paper-friends'), /Unknown scene/);
});

test('save data serializes and restores progress without unknown fields', () => {
  const engine = makeGameEngine(createInitialSaveData());
  engine.performLoop();
  engine.performLoop();
  engine.performLoop();
  engine.inspect('chalk-rule-note');
  engine.inspect('desk-map');
  engine.collect('half-chalk');

  const restored = restoreSaveData(serializeSaveData(engine.getState()));

  assert.deepEqual(restored.collectedItems, ['half-chalk']);
  assert.equal(restored.loopCount, 3);
  assert.equal(restored.puzzleState.chalkRuleRead, true);
  assert.equal(restored.puzzleState.deskMapRead, true);
});
