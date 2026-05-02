#!/usr/bin/env node
/**
 * Replace assets/vendor/jsm with only GLTFLoader + BufferGeometryUtils (Three r160).
 * Run from repo root: node scripts/trim-three-vendor.mjs
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const vendor = path.join(root, 'assets', 'vendor');
const jsm = path.join(vendor, 'jsm');

function resolveThreePackage() {
  const candidates = [
    path.join(root, 'node_modules', 'three'),
    path.join(root, 'scripts', 'node_modules', 'three'),
  ];
  for (const c of candidates) {
    const gltf = path.join(c, 'examples', 'jsm', 'loaders', 'GLTFLoader.js');
    if (fs.existsSync(gltf)) return c;
  }
  return null;
}

const threeRoot = resolveThreePackage();
if (!threeRoot) {
  console.error('Install three first: npm install three@0.160.0 --prefix "' + root + '"');
  process.exit(1);
}

const srcLoaders = path.join(threeRoot, 'examples', 'jsm', 'loaders', 'GLTFLoader.js');
const srcUtils = path.join(threeRoot, 'examples', 'jsm', 'utils', 'BufferGeometryUtils.js');
const srcCore = path.join(threeRoot, 'build', 'three.module.js');

for (const p of [srcLoaders, srcUtils, srcCore]) {
  if (!fs.existsSync(p)) {
    console.error('Missing:', p);
    process.exit(1);
  }
}

fs.rmSync(jsm, { recursive: true, force: true });
fs.mkdirSync(path.join(jsm, 'loaders'), { recursive: true });
fs.mkdirSync(path.join(jsm, 'utils'), { recursive: true });
fs.copyFileSync(srcLoaders, path.join(jsm, 'loaders', 'GLTFLoader.js'));
fs.copyFileSync(srcUtils, path.join(jsm, 'utils', 'BufferGeometryUtils.js'));
fs.copyFileSync(srcCore, path.join(vendor, 'three.module.js'));

/** WKWebView often fails bare `from 'three'` even with import maps — use relative core path. */
function patchBareThreeImport(absPath) {
  let s = fs.readFileSync(absPath, 'utf8');
  const next = s.replace(/\} from 'three';/g, "} from '../../three.module.js';");
  if (next !== s) fs.writeFileSync(absPath, next);
}
patchBareThreeImport(path.join(jsm, 'loaders', 'GLTFLoader.js'));
patchBareThreeImport(path.join(jsm, 'utils', 'BufferGeometryUtils.js'));

const kept = [
  path.join(jsm, 'loaders', 'GLTFLoader.js'),
  path.join(jsm, 'utils', 'BufferGeometryUtils.js'),
];
let bytes = 0;
for (const f of kept) bytes += fs.statSync(f).size;
console.log('Trimmed vendor/jsm to', kept.length, 'files (~' + Math.round(bytes / 1024) + ' KB) + three.module.js');
