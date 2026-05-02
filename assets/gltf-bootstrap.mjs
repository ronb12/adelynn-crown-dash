/**
 * Optional standalone bootstrap (desktop/file servers). The iOS app uses an **inline**
 * `<script type="module">` copy in index.html — WKWebView handles same-document imports better.
 */
import * as THREE from './vendor/three.module.js';
import { GLTFLoader } from './vendor/jsm/loaders/GLTFLoader.js';
window.__cdTHREE = THREE;
window.__cdGLTFLoader = GLTFLoader;
try {
  window.dispatchEvent(new Event('cdgltfready'));
} catch (e) {}
