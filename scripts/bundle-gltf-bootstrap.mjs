#!/usr/bin/env node
/**
 * Build one non-module file for iOS WKWebView: Three + GLTFLoader on globalThis.
 * Run: npm run vendor:gltf-bundle  (after npm install)
 */
import esbuild from 'esbuild';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const outFile = path.join(root, 'assets', 'vendor', 'cdgltf-bootstrap.bundle.js');
const entry = path.join(root, 'scripts', 'gltf-iife-entry.mjs');

await esbuild.build({
  entryPoints: [entry],
  bundle: true,
  format: 'iife',
  platform: 'browser',
  outfile: outFile,
  minify: true,
  legalComments: 'none',
  logLevel: 'info',
});

const mb = (fs.statSync(outFile).size / (1024 * 1024)).toFixed(2);
console.log('Wrote', outFile, '(' + mb + ' MB)');
