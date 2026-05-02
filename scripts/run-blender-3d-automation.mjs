#!/usr/bin/env node
/**
 * Launches: blender -b -P scripts/blender_3d_automation.py -- <args>
 *
 *   npm run blender:automation -- help
 *   npm run blender:automation -- proc-runner
 */
import { spawnSync } from 'child_process';
import path from 'path';
import { fileURLToPath } from 'url';
import { findBlender } from './find-blender.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const py = path.join(__dirname, 'blender_3d_automation.py');

const blender = findBlender();
if (!blender) {
  console.error('[blender:automation] Blender not found. Set BLENDER or install Blender.');
  process.exit(1);
}

const pass = process.argv.slice(2);
const r = spawnSync(blender, ['-b', '-P', py, '--', ...pass], {
  stdio: 'inherit',
  cwd: root,
});
process.exit(r.status === 0 ? 0 : 1);