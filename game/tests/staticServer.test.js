import assert from 'node:assert/strict';
import test from 'node:test';

import { createStaticServer } from '../scripts/serve.js';

test('static server serves the web prototype and shared module', async () => {
  const server = createStaticServer();
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));

  try {
    const { port } = server.address();
    const html = await fetch(`http://127.0.0.1:${port}/`);
    const stateModule = await fetch(`http://127.0.0.1:${port}/src/gameState.js`);

    assert.equal(html.status, 200);
    assert.match(await html.text(), /<script type="module" src="\.\/app\.js"><\/script>/);
    assert.equal(stateModule.status, 200);
    assert.match(await stateModule.text(), /createInitialSaveData/);
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
});
