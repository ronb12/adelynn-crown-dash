const CACHE_NAME = 'crown-dash-v1';
const ASSETS = [
  './',
  './index.html',
  './manifest.webmanifest',
  './assets/icon-192.png',
  './assets/icon-512.png',
  './assets/run_0.png','./assets/run_1.png','./assets/run_2.png','./assets/run_3.png',
  './assets/dash_0.png','./assets/dash_1.png','./assets/dash_2.png',
  './assets/jump_0.png','./assets/jump_1.png',
  './assets/fall_0.png','./assets/fall_1.png',
  './assets/idle_0.png','./assets/idle_1.png','./assets/idle_2.png','./assets/idle_3.png',
  './assets/land_0.png','./assets/land_1.png','./assets/land_2.png'
];
self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(ASSETS)));
});
self.addEventListener('fetch', event => {
  event.respondWith(caches.match(event.request).then(response => response || fetch(event.request)));
});
