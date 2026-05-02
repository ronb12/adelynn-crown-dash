#!/usr/bin/env node
/**
 * Blender CLI → assets/game_props.glb (hazards, coin, pickups for Three.js)
 *
 *   npm run build:game-props
 */
import { spawnSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { findBlender } from './find-blender.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const pyPath = path.join(root, 'scripts', 'blender_build_game_props.py');
const out = path.join(root, 'assets', 'game_props.glb');

const blender = findBlender();
if (!blender) {
  console.error('Blender not found. Set BLENDER=… or: npm run blender:which');
  process.exit(1);
}

const r = spawnSync(blender, ['-b', '-P', pyPath, '--', out], {
  stdio: 'inherit',
  cwd: root,
});
if (r.status !== 0 || !fs.existsSync(out)) {
  console.error('build-game-props failed');
  process.exit(1);
}
const mb = (fs.statSync(out).size / (1024 * 1024)).toFixed(2);
console.log('Wrote', out, '(' + mb + ' MB)');
