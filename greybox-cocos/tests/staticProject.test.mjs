import assert from 'node:assert/strict';
import { access, readFile } from 'node:fs/promises';
import test from 'node:test';

const requiredFiles = [
  '.creator/default-meta.json',
  'assets/scripts/ChapterOneGreybox.ts',
  'assets/scripts/ChapterOneGreybox.ts.meta',
  'assets/scripts/greyboxState.js',
  'assets/scripts/greyboxState.js.meta',
  'assets/scenes/chapter-one-greybox.scene',
  'assets/scenes/chapter-one-greybox.scene.meta',
  'settings/v2/packages/project.json',
  'settings/v2/packages/scene.json',
  'README.md',
];

test('Cocos greybox project contains expected scaffold files', async () => {
  await Promise.all(requiredFiles.map((file) => access(new URL(`../${file}`, import.meta.url))));
});

test('Cocos component references shared state and chapter one script source', async () => {
  const component = await readFile(new URL('../assets/scripts/ChapterOneGreybox.ts', import.meta.url), 'utf8');
  const readme = await readFile(new URL('../README.md', import.meta.url), 'utf8');

  assert.match(component, /greyboxState\.js/);
  assert.match(component, /performInteraction/);
  assert.match(component, /Component\.EventHandler/);
  assert.match(component, /customEventData = interaction\.id/);
  assert.match(readme, /docs\/game-script-chapter-01\.md/);
  assert.match(readme, /Cocos Creator 3\.8/);
});

test('chapter one scene is a real Cocos scene with canvas and greybox controller', async () => {
  const scene = JSON.parse(await readFile(new URL('../assets/scenes/chapter-one-greybox.scene', import.meta.url), 'utf8'));

  assert.equal(scene[0].__type__, 'cc.SceneAsset');
  assert.equal(scene[0].scene.__id__, 1);
  assert.equal(scene[1].__type__, 'cc.Scene');
  assert.equal(scene[1]._name, 'chapter-one-greybox');
  assert.equal(scene[2].__type__, 'cc.Node');
  assert.equal(scene[2]._name, 'GreyboxCanvas');

  const componentTypes = scene.map((entry) => entry.__type__);
  assert.ok(componentTypes.includes('cc.Canvas'));
  assert.ok(componentTypes.includes('cc.Camera'));
  assert.ok(componentTypes.includes('42722wVBh5AHp4EIyXttji/'));
});

test('project settings point Creator preview at the chapter one scene', async () => {
  const sceneMeta = JSON.parse(await readFile(new URL('../assets/scenes/chapter-one-greybox.scene.meta', import.meta.url), 'utf8'));
  const sceneSettings = JSON.parse(await readFile(new URL('../settings/v2/packages/scene.json', import.meta.url), 'utf8'));
  const projectSettings = JSON.parse(await readFile(new URL('../settings/v2/packages/project.json', import.meta.url), 'utf8'));

  assert.equal(sceneSettings['current-scene'], sceneMeta.uuid);
  assert.equal(projectSettings.general.designResolution.width, 960);
  assert.equal(projectSettings.general.designResolution.height, 640);
});
