import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

test('Cocos project metadata is present for Creator 3.8', async () => {
  const tsconfig = await readFile(new URL('../tsconfig.json', import.meta.url), 'utf8');
  const defaultMeta = await readFile(new URL('../.creator/default-meta.json', import.meta.url), 'utf8');

  assert.match(tsconfig, /tsconfig\.cocos\.json/);
  assert.match(defaultMeta, /sprite-frame/);
});

test('Cocos bridge script defines the planned public interfaces', async () => {
  const bridge = await readFile(new URL('../assets/scripts/DemoStateBridge.ts', import.meta.url), 'utf8');

  assert.match(bridge, /interface SaveData/);
  assert.match(bridge, /interface SceneState/);
  assert.match(bridge, /interface Interactable/);
  assert.match(bridge, /interface PerceptionText/);
  assert.match(bridge, /interface PuzzleState/);
  assert.match(bridge, /interface Collectible/);
  assert.match(bridge, /@ccclass\('DemoStateBridge'\)/);
});
