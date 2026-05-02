#!/usr/bin/env node
/**
 * Print resolved Blender executable and `blender -b --version` (headless check).
 * Usage: npm run blender:which
 */
import { spawnSync } from 'child_process';
import { findBlender } from './find-blender.mjs';

const bin = findBlender();
if (!bin) {
  console.error('Blender CLI not found.');
  console.error('Set BLENDER=/path/to/Blender, or create scripts/blender-binary.path (one line),');
  console.error('or install Blender.app under /Applications or next to the repo folder.');
  process.exit(1);
}
console.log(bin);
const r = spawnSync(bin, ['-b', '--version'], { encoding: 'utf8', timeout: 20_000 });
if (r.error && r.error.code === 'ETIMEDOUT') {
  console.error('(version check timed out; path above is still valid for npm run convert:character:blender)');
  process.exit(0);
}
if (r.stdout) process.stdout.write(r.stdout);
if (r.stderr) process.stderr.write(r.stderr);
process.exit(typeof r.status === 'number' ? r.status : 0);
