#!/usr/bin/env node
/**
 * Atomically replace assets/vendor/jsm with only GLTFLoader + BufferGeometryUtils.
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const jsm = path.join(__dirname, '..', 'assets', 'vendor', 'jsm');
const gltf = path.join(jsm, 'loaders', 'GLTFLoader.js');
const buff = path.join(jsm, 'utils', 'BufferGeometryUtils.js');

if (!fs.existsSync(gltf) || !fs.existsSync(buff)) {
  console.error('Missing GLTFLoader.js or BufferGeometryUtils.js under', jsm);
  process.exit(1);
}
const gltfSrc = fs.readFileSync(gltf);
const buffSrc = fs.readFileSync(buff);
fs.rmSync(jsm, { recursive: true, force: true });
fs.mkdirSync(path.join(jsm, 'loaders'), { recursive: true });
fs.mkdirSync(path.join(jsm, 'utils'), { recursive: true });
fs.writeFileSync(path.join(jsm, 'loaders', 'GLTFLoader.js'), gltfSrc);
fs.writeFileSync(path.join(jsm, 'utils', 'BufferGeometryUtils.js'), buffSrc);
console.log('vendor/jsm trimmed to loaders/GLTFLoader.js + utils/BufferGeometryUtils.js');
