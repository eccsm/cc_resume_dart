{{flutter_js}}
{{flutter_build_config}}

// Custom bootstrap for embedding the app as a lazy multi-view island inside
// the Astro shell (see site/src/components/FlutterIsland.astro). The engine
// boots once; views are added/removed per overlay open/close. No service
// worker is registered — the shell owns caching.
(function () {
  // Assets live wherever this script was served from (the hashed
  // /assets/flutter/<hash>/ directory in production).
  var BASE = new URL('.', document.currentScript && document.currentScript.src
    ? document.currentScript.src
    : document.baseURI).toString();

  var appPromise = null;

  // WebLLM helper scripts (normally loaded by the standalone index.html).
  // Loaded here so the in-app AI chat works in embedded mode too. Order
  // matters: the bootstrap patches the helper. Requires the host page to be
  // cross-origin isolated (COOP/COEP headers) — without isolation the chat
  // degrades gracefully to keyword answers.
  window.__webllmBase = BASE + 'assets/js/';
  var webllmScripts = null;

  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var s = document.createElement('script');
      s.src = src;
      s.onload = resolve;
      s.onerror = reject;
      document.head.appendChild(s);
    });
  }

  function ensureWebllmScripts() {
    if (!webllmScripts) {
      webllmScripts = loadScript(BASE + 'assets/js/webllm_helper.js')
        .then(function () {
          return loadScript(BASE + 'assets/js/webllm_bootstrap.js');
        })
        .catch(function (err) {
          console.warn('[flutter-island] WebLLM helper failed to load:', err);
        });
    }
    return webllmScripts;
  }

  function ensureApp() {
    if (!appPromise) {
      appPromise = new Promise(function (resolve, reject) {
        _flutter.loader.load({
          config: {
            multiViewEnabled: true,
            assetBase: BASE,
            entrypointBaseUrl: BASE,
          },
          onEntrypointLoaded: function (engineInitializer) {
            engineInitializer
              .initializeEngine({ multiViewEnabled: true, assetBase: BASE })
              .then(function (appRunner) { return appRunner.runApp(); })
              .then(resolve, reject);
          },
        });
      });
    }
    return appPromise;
  }

  window._flutterIsland = {
    addView: function (hostElement) {
      // Helper first: WebLLMService probes window.webLLMHelper during app
      // bootstrap, so it must exist before the first view is added.
      return ensureWebllmScripts()
        .then(ensureApp)
        .then(function (app) {
          return app.addView({ hostElement: hostElement });
        });
    },
    removeView: function (viewId) {
      return ensureApp().then(function (app) {
        return app.removeView(viewId);
      });
    },
  };
})();
