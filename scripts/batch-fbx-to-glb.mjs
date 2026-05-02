#!/usr/bin/env node
/**
 * Convert every *.fbx in a folder → assets/animations/<name>.glb and rewrite manifest.json.
 *
 * Uses Blender CLI when available (preferred), otherwise FBX2glTF from npm `fbx2gltf`.
 *
 * Usage:
 *   node scripts/batch-fbx-to-glb.mjs "/path/to/folder/with/fbx"
 *
 * Env: BLENDER=/path/to/Blender
 * Or create scripts/blender-binary.path with one line: full path to the Blender binary.
 * If Blender.app sits next to the project folder (same parent), it is auto-detected.
 *
 * Output GLBs: assets/animations/*.glb
 * Manifest:   assets/animations/manifest.json
 */
import { spawnSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import os from 'os';
import { findBlender } from './find-blender.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const outDir = path.join(root, 'assets', 'animations');
const manifestPath = path.join(outDir, 'manifest.json');
const blenderPy = path.join(root, 'scripts', 'blender_fbx_to_glb.py');

function findFbx2GltfExe() {
  const plat = os.platform();
  const pkgRoot = path.join(root, 'node_modules', 'fbx2gltf');
  if (!fs.existsSync(pkgRoot)) return null;
  const sub = plat === 'darwin' ? 'Darwin' : plat === 'win32' ? 'Windows' : 'Linux';
  const name = plat === 'win32' ? 'FBX2glTF.exe' : 'FBX2glTF';
  const p = path.join(pkgRoot, 'bin', sub, name);
  if (fs.existsSync(p)) return p;
  return null;
}

function convertOne(fbxPath, glbAbs, blenderBin, fbx2gltfExe) {
  if (blenderBin) {
    const r = spawnSync(
      blenderBin,
      ['-b', '-P', blenderPy, '--', fbxPath, glbAbs],
      { stdio: 'inherit', cwd: root }
    );
    if (r.status === 0) return true;
    console.warn('[batch-fbx-to-glb] Blender failed, trying FBX2glTF…');
  }
  if (!fbx2gltfExe) return false;
  const r2 = spawnSync(fbx2gltfExe, ['-i', fbxPath, '-o', glbAbs, '--binary'], {
    stdio: 'inherit',
    cwd: root,
  });
  return r2.status === 0;
}

function clipNameFromBasename(base) {
  const noExt = base.replace(/\.fbx$/i, '');
  const words = noExt.split(/[_\s-]+/).filter(Boolean);
  return words.map((w) => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase()).join(' ');
}

const inputDir = process.argv[2];
if (!inputDir) {
  console.error('Usage: node scripts/batch-fbx-to-glb.mjs "/path/to/folder/with/fbx/files"');
  process.exit(1);
}

const absIn = path.isAbsolute(inputDir) ? inputDir : path.join(root, inputDir);
if (!fs.existsSync(absIn) || !fs.statSync(absIn).isDirectory()) {
  console.error('Not a directory:', absIn);
  process.exit(1);
}

const blenderBin = findBlender();
const fbx2gltfExe = findFbx2GltfExe();
if (!blenderBin && !fbx2gltfExe) {
  console.error('Need Blender (install app or set BLENDER=…) or npm package fbx2gltf (`npm install`).');
  process.exit(1);
}
if (blenderBin) console.info('[batch-fbx-to-glb] Using Blender:', blenderBin);
else console.info('[batch-fbx-to-glb] Using FBX2glTF (Blender not found)');

fs.mkdirSync(outDir, { recursive: true });

const files = fs.readdirSync(absIn).filter((f) => /\.fbx$/i.test(f));
if (!files.length) {
  console.error('No .fbx files in', absIn);
  process.exit(1);
}

const extra = [];
for (const f of files.sort()) {
  const fbxPath = path.join(absIn, f);
  const base = f.replace(/\.fbx$/i, '');
  const glbRel = path.join('assets', 'animations', base + '.glb');
  const glbAbs = path.join(root, glbRel);
  const ok = convertOne(fbxPath, glbAbs, blenderBin, fbx2gltfExe);
  if (!ok) {
    console.error('Failed:', fbxPath);
    process.exit(1);
  }
  extra.push({
    url: glbRel.split(path.sep).join('/'),
    name: clipNameFromBasename(f),
  });
  console.log('OK', f, '→', glbRel);
}

const manifest = { extra };
fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + '\n', 'utf8');
console.log('Wrote', manifestPath, '(' + extra.length + ' clips)');
