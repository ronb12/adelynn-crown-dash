/**
 * Bundled by scripts/bundle-gltf-bootstrap.mjs → assets/vendor/cdgltf-bootstrap.bundle.js
 * Classic scriptload for WKWebView file:// (no ES module graph / CORS issues).
 */
import * as THREE from 'three';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';

globalThis.__cdTHREE = THREE;
globalThis.__cdGLTFLoader = GLTFLoader;
try {
  globalThis.dispatchEvent(new Event('cdgltfready'));
} catch (e) {}
