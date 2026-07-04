// WebLLM bootstrap: model-cache patch + legacy service-worker cleanup.
// Lives in an external file (not inline in index.html) so the site can run
// under a strict Content-Security-Policy.

// WebLLM model cache
window.webLLMModelCache = { initialized: false, cachedModels: {} };

// Patch WebLLMHelper for background model loading
function patchWebLLMHelper() {
  if (!window.webLLMHelper) return;
  const originalLoadModel = window.webLLMHelper.loadModel;

  window.webLLMHelper.loadModel = async function(modelId, onProgress) {
    if (window.webLLMModelCache.cachedModels[modelId]?.failCount > 2) return false;

    if (!window.webLLMModelCache.cachedModels[modelId]) {
      window.webLLMModelCache.cachedModels[modelId] = {
        loaded: false, loading: false, engine: null, failCount: 0
      };
    }

    const cache = window.webLLMModelCache.cachedModels[modelId];
    if (cache.loaded) { this.engine = cache.engine; return true; }
    if (cache.loading) return false;

    cache.loading = true;
    try {
      // Pass every argument through so download progress reaches Flutter.
      const result = await originalLoadModel.call(this, modelId, onProgress);
      if (result) { cache.loaded = true; cache.engine = this.engine; }
      else { cache.failCount++; }
      cache.loading = false;
      return result;
    } catch (e) {
      cache.failCount++;
      cache.loading = false;
      return false;
    }
  };

  window.webLLMHelper.recoverFromError = function() {
    this.engine = null;
    this.isAvailable = false;
    Object.values(window.webLLMModelCache.cachedModels).forEach(m => {
      m.loaded = false; m.engine = null; m.loading = false;
    });
    return this.init();
  };
}

// Keep WebLLM bootstrap lightweight. Flutter already manages its own
// service worker, so we avoid registering a second app-wide worker here.
patchWebLLMHelper();

// Clean up the legacy custom service worker and cache if a previous build
// registered them. This prevents service-worker handoff loops on refresh.
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then(function(registrations) {
    registrations.forEach(function(registration) {
      const scriptUrl = registration.active?.scriptURL ||
          registration.waiting?.scriptURL ||
          registration.installing?.scriptURL ||
          '';

      if (scriptUrl.endsWith('/service-worker.js')) {
        registration.unregister().catch(function(e) {
          console.warn('Legacy service worker cleanup failed:', e);
        });
      }
    });
  }).catch(function(e) {
    console.warn('Could not inspect service workers:', e);
  });
}

if ('caches' in window) {
  caches.keys().then(function(cacheNames) {
    cacheNames.forEach(function(cacheName) {
      if (cacheName === 'webllm-flutter-cache-v1') {
        caches.delete(cacheName).catch(function(e) {
          console.warn('Legacy WebLLM cache cleanup failed:', e);
        });
      }
    });
  }).catch(function(e) {
    console.warn('Could not inspect caches:', e);
  });
}
