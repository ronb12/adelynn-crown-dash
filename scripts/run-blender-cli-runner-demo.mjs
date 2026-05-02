#!/usr/bin/env node
/**
 * Headless: procedural mesh + armature + Idle/Run/Jump NLA → assets/runner_cli_demo.glb
 *
 *   npm run blender:cli-runner-demo
 *   node scripts/run-blender-cli-runner-demo.mjs [optional-output.glb]
 */
import { spawnSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { findBlender } from './find-blender.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const py = path.join(__dirname, 'blender_cli_runner_demo.py');
const outArg = process.argv[2];
const args = outArg
  ? [path.isAbsolute(outArg) ? outArg : path.join(root, outArg)]
  : [];

const blender = findBlender();
if (!blender) {
  console.error('[cli-runner-demo] Blender not found. Set BLENDER=… or install Blender.');
  process.exit(1);
}

const r = spawnSync(
  blender,
  ['-b', '--python', py, '--', ...args],
  { stdio: 'inherit', cwd: root }
);
process.exit(r.status === 0 ? 0 : 1);
