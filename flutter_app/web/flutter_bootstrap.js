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
      return ensureApp().then(function (app) {
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
