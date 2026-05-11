import assert from 'node:assert/strict';
import { access, readFile } from 'node:fs/promises';
import test from 'node:test';

const requiredFiles = [
  '.creator/default-meta.json',
  'assets/scripts/ChapterOneGreybox.ts',
  'assets/scripts/greyboxState.js',
  'assets/scenes/chapter-one-greybox.scene',
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
