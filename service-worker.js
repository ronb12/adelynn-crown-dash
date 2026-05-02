const CACHE_NAME = 'crown-dash-v20';
const ASSETS = [
  './',
  './index.html',
  './play.html',
  './privacy.html',
  './terms.html',
  './landing.css',
  './favicon.ico',
  './manifest.webmanifest',
  './assets/icon-192.png',
  './assets/icon-512.png',
  './assets/castle_track.png',
  './assets/menu_adelynn_portrait.png',
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
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key)))
    )
  );
});
self.addEventListener('fetch', event => {
  event.respondWith(caches.match(event.request).then(response => response || fetch(event.request)));
});
