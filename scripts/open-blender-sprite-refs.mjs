#!/usr/bin/env node
/**
 * Opens Blender (GUI) and runs blender_sprite_reference_setup.py so 2D PNGs become reference planes.
 *
 * Usage:
 *   npm run blender:sprite-refs
 *   node scripts/open-blender-sprite-refs.mjs /path/to/assets
 */
import { spawn } from 'child_process';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { findBlender } from './find-blender.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const py = path.join(__dirname, 'blender_sprite_reference_setup.py');
const assetDir = process.argv[2] ? path.resolve(process.argv[2]) : path.join(root, 'assets');

if (!fs.existsSync(assetDir)) {
  console.error('[sprite-refs] Missing folder:', assetDir);
  process.exit(1);
}

const blender = findBlender();
if (!blender) {
  console.error('[sprite-refs] Blender not found. Set BLENDER or install Blender.');
  process.exit(1);
}

const proc = spawn(blender, ['--python', py, '--', assetDir], {
  cwd: root,
  detached: true,
  stdio: 'ignore',
});
proc.unref();

console.log('[sprite-refs] Starting Blender with reference planes from:', assetDir);
console.log('[sprite-refs] Look for collection "SpriteReferences". Model on top → Export → glTF (.glb).');
