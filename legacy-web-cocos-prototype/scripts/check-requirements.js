import { readFile } from 'node:fs/promises';

const files = {
  state: new URL('../src/gameState.js', import.meta.url),
  webHtml: new URL('../web/index.html', import.meta.url),
  webJs: new URL('../web/app.js', import.meta.url),
  webCss: new URL('../web/styles.css', import.meta.url),
  cocosBridge: new URL('../assets/scripts/DemoStateBridge.ts', import.meta.url),
  plan: new URL('../../docs/development-plan.md', import.meta.url),
};

const checks = [
  ['reality school opening', files.state, 'reality-school-gate'],
  ['playground loop scene', files.state, 'playground-loop'],
  ['chalk corridor scene', files.state, 'chalk-corridor'],
  ['old desk island scene', files.state, 'old-desk-island'],
  ['ending echo scene', files.state, 'ending-reality-echo'],
  ['half chalk collectible', files.state, 'half-chalk'],
  ['sticker star collectible', files.state, 'sticker-star'],
  ['true fourth loop puzzle', files.state, 'trueFourthLoopFound'],
  ['local save persistence', files.webJs, 'localStorage.setItem'],
  ['portrait responsive layout', files.webCss, 'aspect-ratio: 9 / 16'],
  ['Cocos Creator bridge', files.cocosBridge, "@ccclass('DemoStateBridge')"],
  ['development plan document', files.plan, '《我》竖切 Demo 开发计划'],
  ['no monetization in stage one', files.plan, '不做内购、广告、排行榜'],
];

const failures = [];

for (const [label, fileUrl, requiredText] of checks) {
  const content = await readFile(fileUrl, 'utf8');
  if (!content.includes(requiredText)) {
    failures.push(`${label}: missing "${requiredText}"`);
  }
}

if (failures.length > 0) {
  console.error(failures.join('\n'));
  process.exitCode = 1;
} else {
  console.log(`Requirement check passed (${checks.length} checks).`);
}
