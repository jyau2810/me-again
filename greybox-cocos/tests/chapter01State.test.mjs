import assert from 'node:assert/strict';
import test from 'node:test';

import {
  CHAPTERS,
  CHAPTER_ONE,
  SCENES,
  createInitialGreyboxState,
  getAvailableInteractions,
  performInteraction,
} from '../assets/scripts/greyboxState.js';

test('initial state enters chapter one with later greybox chapters locked as placeholders', () => {
  const state = createInitialGreyboxState();

  assert.equal(state.currentChapter, CHAPTER_ONE.id);
  assert.equal(state.chapterProgress, 'opening');
  assert.equal(state.perceptionStage, 'opening');
  assert.equal(state.chapterUnlocks[CHAPTER_ONE.id], true);
  assert.deepEqual(
    CHAPTERS.map((chapter) => chapter.id),
    ['01_grey_morning', '02_looping_school', '04_cabinet_breath', '03_paper_friends', '05_after_forest'],
  );
  assert.equal(CHAPTERS[1].status, '待验证');
});

test('three window observations move from reality into the inner world', () => {
  let state = createInitialGreyboxState();

  state = performInteraction(state, 'tap_alarm');
  state = performInteraction(state, 'tap_cup');
  state = performInteraction(state, 'tap_shirt');
  state = performInteraction(state, 'tap_door_lock');
  state = performInteraction(state, 'tap_window_1');
  state = performInteraction(state, 'tap_window_2');
  state = performInteraction(state, 'tap_window_3');

  assert.equal(state.chapterProgress, 'inner_world');
  assert.equal(state.currentScene, 'c01_s03_night_car_array');
  assert.equal(state.chapterOne.windowObservationCount, 3);
});

test('vehicle marking tracks correct and incorrect factions without unlocking early', () => {
  let state = createInitialGreyboxState();

  for (const id of ['tap_alarm', 'tap_cup', 'tap_shirt', 'tap_door_lock', 'tap_window_1', 'tap_window_2', 'tap_window_3']) {
    state = performInteraction(state, id);
  }
  state = performInteraction(state, 'mark_round_light_enemy');

  assert.equal(state.chapterOne.vehicleMarks.round_light, 'wrong');
  assert.equal(state.chapterOne.safeRouteReady, false);

  for (const id of ['mark_round_light_friend', 'mark_soft_light_friend', 'mark_blinking_light_friend', 'mark_narrow_light_enemy', 'mark_late_corner_enemy']) {
    state = performInteraction(state, id);
  }

  assert.equal(state.chapterOne.safeRouteReady, true);
  assert.equal(state.currentScene, 'c01_s04_backseat_fort');
});

test('signal rhythm resets on wrong light and completes on green green red green', () => {
  let state = createInitialGreyboxState();

  for (const id of [
    'tap_alarm',
    'tap_cup',
    'tap_shirt',
    'tap_door_lock',
    'tap_window_1',
    'tap_window_2',
    'tap_window_3',
    'mark_round_light_friend',
    'mark_soft_light_friend',
    'mark_blinking_light_friend',
    'mark_narrow_light_enemy',
    'mark_late_corner_enemy',
    'drag_safe_route',
    'tap_green_1',
    'tap_red_wrong',
  ]) {
    state = performInteraction(state, id);
  }

  assert.deepEqual(state.chapterOne.signalRhythm, []);
  assert.equal(state.chapterOne.signalRhythmSolved, false);

  for (const id of ['tap_green_1', 'tap_green_2', 'tap_red_3', 'tap_green_4']) {
    state = performInteraction(state, id);
  }

  assert.equal(state.chapterOne.signalRhythmSolved, true);
  assert.equal(state.currentScene, 'c01_s06_commute_echo');
});

test('echo object visits are unique and completion writes global chapter state', () => {
  let state = createInitialGreyboxState();

  for (const id of [
    'tap_alarm',
    'tap_cup',
    'tap_shirt',
    'tap_door_lock',
    'tap_window_1',
    'tap_window_2',
    'tap_window_3',
    'mark_round_light_friend',
    'mark_soft_light_friend',
    'mark_blinking_light_friend',
    'mark_narrow_light_enemy',
    'mark_late_corner_enemy',
    'drag_safe_route',
    'tap_green_1',
    'tap_green_2',
    'tap_red_3',
    'tap_green_4',
    'tap_window_echo',
    'tap_window_echo',
    'tap_red_light_echo',
    'tap_tree_echo',
  ]) {
    state = performInteraction(state, id);
  }

  assert.deepEqual(state.echoObjectsVisited, ['window', 'red_light', 'tree']);
  assert.equal(state.chapterProgress, 'complete');
  assert.equal(state.perceptionStage, 'chapter_01_echo');
  assert.equal(state.chapterUnlocks['02_looping_school'], true);
  assert.deepEqual(state.visitedEchoes, ['c01_commute_echo']);
});

test('available interactions follow the active scene', () => {
  const state = createInitialGreyboxState();
  const interactions = getAvailableInteractions(state);

  assert.deepEqual(
    interactions.map((interaction) => interaction.id),
    ['tap_alarm', 'tap_cup', 'tap_shirt', 'tap_keys', 'tap_door_lock'],
  );
});

test('chapter one scenes expose visible greybox stage and hotspot data', () => {
  assert.equal(SCENES.length, 6);

  for (const scene of SCENES) {
    assert.match(scene.goal, /\S/);
    assert.ok(scene.stage.elements.length >= 3, `${scene.id} should render at least three stage elements`);

    for (const interaction of scene.interactions) {
      assert.equal(typeof interaction.hotspot.x, 'number', `${interaction.id} needs hotspot x`);
      assert.equal(typeof interaction.hotspot.y, 'number', `${interaction.id} needs hotspot y`);
      assert.equal(typeof interaction.hotspot.width, 'number', `${interaction.id} needs hotspot width`);
      assert.equal(typeof interaction.hotspot.height, 'number', `${interaction.id} needs hotspot height`);
      assert.match(interaction.hotspot.action, /点击|拖动|标记|节奏|观察|复访/);
    }
  }
});
