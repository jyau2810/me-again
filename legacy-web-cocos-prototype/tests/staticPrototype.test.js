import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const files = {
  html: new URL('../web/index.html', import.meta.url),
  css: new URL('../web/styles.css', import.meta.url),
  js: new URL('../web/app.js', import.meta.url),
};

test('web prototype exposes the expected mobile-first shell', async () => {
  const html = await readFile(files.html, 'utf8');

  assert.match(html, /id="scene-title"/);
  assert.match(html, /id="interactions"/);
  assert.match(html, /id="loop-button"/);
  assert.match(html, /id="true-fourth-loop-button"/);
  assert.match(html, /id="collection-book"/);
});

test('web prototype script connects to the shared game state module', async () => {
  const js = await readFile(files.js, 'utf8');

  assert.match(js, /from '..\/src\/gameState.js'/);
  assert.match(js, /localStorage\.setItem/);
  assert.match(js, /performTrueFourthLoop/);
});

test('web prototype stylesheet keeps a portrait phone canvas', async () => {
  const css = await readFile(files.css, 'utf8');

  assert.match(css, /aspect-ratio:\s*9\s*\/\s*16/);
  assert.match(css, /max-width:\s*430px/);
  assert.match(css, /min-height:\s*100svh/);
});
