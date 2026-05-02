#!/usr/bin/env node
/**
 * FBX → GLB: prefers Blender CLI, falls back to FBX2glTF (npm `fbx2gltf`).
 *
 * External drive / same folder as the repo:
 *   Put your FBX here:  assets/character.fbx  (under Adelynn Crown Dash on the volume, e.g. Passport)
 *   Then from repo root:  npm run convert:character
 *   Output:                assets/character.glb  → Xcode "Bundle Web Game" ships it in the app.
 *
 * Usage:
 *   npm run convert:character
 *   npm run convert:character:blender   — same, but **Blender only** (no FBX2glTF fallback)
 *   node scripts/convert-fbx-to-glb.mjs --blender-only [source.fbx] [out.glb]
 *   node scripts/convert-fbx-to-glb.mjs --prep  — import + material prep, then GLB (see blender_prep_runner_from_fbx.py)
 *   node scripts/convert-fbx-to-glb.mjs "/path/to/source.fbx" "/path/to/out.glb"
 *
 * Blender CLI (same as manual):  blender -b -P scripts/blender_fbx_to_glb.py -- <input.fbx> <output.glb>
 *
 * Env: BLENDER=/path/to/Blender  — optional; or scripts/blender-binary.path (one line)
 *      CHARACTER_SOURCE_FBX=/path/to/file.fbx — used when no CLI args (override default assets/character.fbx)
 */
import { spawnSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import os from 'os';
import { findBlender } from './find-blender.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');

function printMissingFbxHints(requestedFbx) {
  console.error('Missing:', requestedFbx);
  const found = [];
  function scanDir(dir, prefix) {
    if (!fs.existsSync(dir)) return;
    let ents;
    try {
      ents = fs.readdirSync(dir, { withFileTypes: true });
    } catch {
      return;
    }
    const depth = prefix ? prefix.split('/').length : 0;
    for (const e of ents) {
      const rel = prefix ? prefix + '/' + e.name : e.name;
      if (e.isDirectory() && !e.name.startsWith('.') && depth < 3) {
        scanDir(path.join(dir, e.name), rel);
      } else if (e.isFile() && e.name.toLowerCase().endsWith('.fbx')) {
        found.push(rel.replace(/\\/g, '/'));
      }
    }
  }
  scanDir(path.join(root, 'assets'), '');
  console.error('');
  if (found.length) {
    console.error('.fbx files under assets/:');
    found.forEach((f) => console.error('  assets/' + f));
    console.error('');
    console.error('Use one of them, for example:');
    console.error('  node scripts/convert-fbx-to-glb.mjs "assets/' + found[0] + '"');
  } else {
    console.error('No .fbx found under assets/. Copy your FBX into assets/, then either:');
    console.error('  • Rename it to character.fbx and run: npm run convert:character');
    console.error('  • Or run (quotes matter if the name has spaces):');
    console.error('    node scripts/convert-fbx-to-glb.mjs \"/Volumes/My Passport for Mac/Adelynn Crown Dash/assets/your file.fbx\"');
  }
  console.error('');
}

const rawArgv = process.argv.slice(2);
const blenderOnly = rawArgv.includes('--blender-only');
const usePrep = rawArgv.includes('--prep');
const argv = rawArgv.filter((a) => a !== '--blender-only' && a !== '--prep');
const blenderPy = usePrep
  ? path.join(root, 'scripts', 'blender_prep_runner_from_fbx.py')
  : path.join(root, 'scripts', 'blender_fbx_to_glb.py');
let fbx;
let glb;
const defaultGlb = path.join(root, 'assets', 'character.glb');
if (argv.length >= 2) {
  fbx = path.isAbsolute(argv[0]) ? argv[0] : path.join(root, argv[0]);
  glb = path.isAbsolute(argv[1]) ? argv[1] : path.join(root, argv[1]);
} else if (argv.length === 1) {
  fbx = path.isAbsolute(argv[0]) ? argv[0] : path.join(root, argv[0]);
  glb = defaultGlb;
} else {
  const envSrc = process.env.CHARACTER_SOURCE_FBX;
  if (envSrc && fs.existsSync(envSrc)) {
    fbx = path.isAbsolute(envSrc) ? envSrc : path.join(root, envSrc);
  } else {
    fbx = path.join(root, 'assets', 'character.fbx');
  }
  glb = defaultGlb;
}

if (!fs.existsSync(fbx)) {
  printMissingFbxHints(fbx);
  process.exit(1);
}

function findFbx2GltfExe() {
  const plat = os.platform();
  const pkgRoot = path.join(root, 'node_modules', 'fbx2gltf');
  if (!fs.existsSync(pkgRoot)) return null;
  const sub =
    plat === 'darwin' ? 'Darwin' :
    plat === 'win32' ? 'Windows' :
    'Linux';
  const name = plat === 'win32' ? 'FBX2glTF.exe' : 'FBX2glTF';
  const p = path.join(pkgRoot, 'bin', sub, name);
  if (fs.existsSync(p)) return p;
  const legacyBin = path.join(root, 'node_modules', '.bin', plat === 'win32' ? 'fbx2gltf.cmd' : 'fbx2gltf');
  if (fs.existsSync(legacyBin)) return legacyBin;
  return null;
}

fs.mkdirSync(path.dirname(glb), { recursive: true });

const blenderBin = findBlender();
const fbx2gltfExe = findFbx2GltfExe();

if (blenderOnly && !blenderBin) {
  console.error('[convert-fbx-to-glb] --blender-only requires Blender on PATH.');
  console.error('Install Blender or: export BLENDER=/Applications/Blender.app/Contents/MacOS/Blender');
  console.error('Check: npm run blender:which');
  process.exit(1);
}
if (usePrep && !blenderBin) {
  console.error('[convert-fbx-to-glb] --prep requires Blender (material prep is not available in FBX2glTF).');
  console.error('Install Blender or: export BLENDER=/Applications/Blender.app/Contents/MacOS/Blender');
  process.exit(1);
}

let ok = false;
if (blenderBin) {
  console.info('[convert-fbx-to-glb] Blender CLI:', blenderBin);
  if (usePrep) console.info('[convert-fbx-to-glb] Using prep pipeline (materials + runner cleanup)');
  console.info('[convert-fbx-to-glb] Args:', ['-b', '-P', blenderPy, '--', fbx, glb].join(' '));
  const r = spawnSync(blenderBin, ['-b', '-P', blenderPy, '--', fbx, glb], {
    stdio: 'inherit',
    cwd: root,
  });
  ok = r.status === 0 && fs.existsSync(glb);
  if (!ok && !blenderOnly) console.warn('[convert-fbx-to-glb] Blender failed or missing output; trying FBX2glTF…');
}

if (!ok && !blenderOnly && fbx2gltfExe) {
  console.info('[convert-fbx-to-glb] Using FBX2glTF');
  const r2 = spawnSync(fbx2gltfExe, ['-i', fbx, '-o', glb, '--binary'], {
    stdio: 'inherit',
    cwd: root,
  });
  ok = r2.status === 0;
}

if (!ok || !fs.existsSync(glb)) {
  if (blenderOnly) {
    console.error('[convert-fbx-to-glb] Blender-only conversion failed (see errors above).');
  } else {
    console.error(
      'Conversion failed. Point to Blender: export BLENDER=…, or add scripts/blender-binary.path, or put Blender.app next to the project folder. Or: npm install (fbx2gltf fallback).'
    );
  }
  process.exit(1);
}

const mb = (fs.statSync(glb).size / (1024 * 1024)).toFixed(2);
console.log('Wrote', glb, '(' + mb + ' MB)');
