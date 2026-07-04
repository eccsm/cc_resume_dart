// Self-destructing service worker.
//
// The previous Flutter PWA deployment of casim.net registered a service
// worker at this exact URL and scope. Returning visitors would otherwise be
// served the stale Flutter shell from its cache forever. This replacement
// takes over on their next visit, wipes every cache, unregisters itself,
// and reloads the open tabs onto the live Astro site.
self.addEventListener('install', () => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();
      await Promise.all(keys.map((key) => caches.delete(key)));
      await self.registration.unregister();
      const clients = await self.clients.matchAll({ type: 'window' });
      for (const client of clients) {
        client.navigate(client.url);
      }
    })()
  );
});
