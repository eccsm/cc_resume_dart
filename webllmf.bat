@echo off
REM Fixed download_webllm_files.bat - Windows-compatible script for downloading WebLLM files
REM For Windows 11 compatibility

echo === WebLLM Local Files Downloader ===
echo This script will download the necessary WebLLM files for your Firebase app

REM Create directories
if not exist "web\assets\js" mkdir "web\assets\js"
if not exist "web\assets\wasm" mkdir "web\assets\wasm"
if not exist "web\assets\models" mkdir "web\assets\models"

REM Check for curl (Windows 11 should have it built-in)
where curl >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: curl is required but not installed.
    echo Please install curl or use Windows 11's built-in curl.
    exit /b 1
)

echo Downloading WebLLM JavaScript library...
REM Using ESM format URL - the correct current URL format
curl -L "https://cdn.jsdelivr.net/npm/@mlc-ai/web-llm@0.2.78/+esm" -o "web\assets\js\webllm.js"
if %ERRORLEVEL% NEQ 0 (
    echo Failed to download WebLLM library. Trying alternative URL...
    curl -L "https://esm.run/@mlc-ai/web-llm" -o "web\assets\js\webllm.js"
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to download WebLLM library from alternative URL.
        exit /b 1
    )
)

REM ---------- WASM runtime from public mirror ----------
echo Downloading WebLLM WASI runtime...
curl -Lf "https://huggingface.co/mrick/react-llm/resolve/main/tvmjs_runtime.wasi.js" ^
     -o "web\assets\wasm\tvmjs_runtime.wasi.js"   || (echo FATAL & exit /b 1)

curl -Lf "https://huggingface.co/mrick/react-llm/resolve/main/tvmjs_runtime.wasm" ^
     -o "web\assets\wasm\tvmjs_runtime.wasm"      || (echo FATAL & exit /b 1)




REM Create a simplified model directory structure
echo Creating model directory structure...
if not exist "web\assets\models\Llama-3-8B-Instruct-q4f32_1-MLC" mkdir "web\assets\models\Llama-3-8B-Instruct-q4f32_1-MLC"

REM Create a placeholder file that indicates models should be downloaded on demand
echo Writing model placeholder files...
(
    echo {
    echo   "model_id": "Llama-3-8B-Instruct-q4f32_1-MLC",
    echo   "model_path": "https://huggingface.co/mlc-ai/mlc-chat-Llama-3-8B-Instruct-q4f32_1-MLC/resolve/main/params/",
    echo   "fallback_path": "https://storage.googleapis.com/mlc-models/mlc-chat-Llama-3-8B-Instruct-q4f32_1-MLC/",
    echo   "local_path": false
    echo }
) > "web\assets\models\Llama-3-8B-Instruct-q4f32_1-MLC\model.json"

REM Create WebLLM helper script
echo Creating WebLLM helper script...
(
    echo /**
    echo  * WebLLM Helper - A simplified helper for WebLLM in Flutter web app
    echo  */
    echo (function() {
    echo   // Create global namespace
    echo   window.webLLMHelper = {
    echo     isAvailable: false,
    echo     engine: null,
    echo     
    echo     /**
    echo      * Initialize the WebLLM helper
    echo      */
    echo     init: async function() {
    echo       console.log('[WebLLMHelper] Initializing');
    echo       
    echo       if (this.isAvailable) {
    echo         console.log('[WebLLMHelper] Already initialized');
    echo         return true;
    echo       }
    echo       
    echo       // Check browser requirements
    echo       if (!this._checkRequirements()) {
    echo         console.error('[WebLLMHelper] Browser requirements not met');
    echo         return false;
    echo       }
    echo       
    echo       // Check if WebLLM module is available
    echo       if (typeof webllm !== 'undefined') {
    echo         console.log('[WebLLMHelper] WebLLM is available');
    echo         this.isAvailable = true;
    echo         return true;
    echo       }
    echo       
    echo       // Wait for WebLLM to load
    echo       try {
    echo         await this._waitForWebLLM();
    echo         return true;
    echo       } catch (e) {
    echo         console.error('[WebLLMHelper] Failed to initialize WebLLM:', e);
    echo         return false;
    echo       }
    echo     },
    echo     
    echo     /**
    echo      * Check if browser meets WebLLM requirements
    echo      */
    echo     _checkRequirements: function() {
    echo       const isSecureContext = window.isSecureContext === true;
    echo       const hasSharedArrayBuffer = typeof SharedArrayBuffer !== "undefined";
    echo       const isCrossOriginIsolated = window.crossOriginIsolated === true;
    echo       
    echo       console.log('[WebLLMHelper] Browser requirements:', {
    echo         isSecureContext,
    echo         hasSharedArrayBuffer,
    echo         isCrossOriginIsolated
    echo       });
    echo       
    echo       return isSecureContext && hasSharedArrayBuffer && isCrossOriginIsolated;
    echo     },
    echo     
    echo     /**
    echo      * Wait for WebLLM to be available
    echo      */
    echo     _waitForWebLLM: function() {
    echo       return new Promise((resolve, reject) => {
    echo         // Set a timeout for the check
    echo         const timeout = setTimeout(() => {
    echo           reject(new Error('Timeout waiting for WebLLM'));
    echo         }, 5000);
    echo         
    echo         // Create check interval
    echo         const checkInterval = setInterval(() => {
    echo           if (typeof webllm !== 'undefined') {
    echo             clearInterval(checkInterval);
    echo             clearTimeout(timeout);
    echo             this.isAvailable = true;
    echo             console.log('[WebLLMHelper] WebLLM is now available');
    echo             resolve(true);
    echo           }
    echo         }, 200);
    echo       });
    echo     },
    echo     
    echo     /**
    echo      * Load a specific model
    echo      */
    echo     loadModel: async function(modelId) {
    echo       if (!this.isAvailable) {
    echo         if (!await this.init()) {
    echo           throw new Error('WebLLM is not available');
    echo         }
    echo       }
    echo       
    echo       console.log(`[WebLLMHelper] Loading model: ${modelId}`);
    echo       
    echo       try {
    echo         // Configure the engine with the selected model
    echo         const options = {
    echo           // Use local paths first, then CDN as fallback
    echo           wasmPath: 'assets/wasm/',
    echo           modelPath: `assets/models/${modelId}/`,
    echo           fallbackWasmPath: 'https://cdn.jsdelivr.net/npm/@mlc-ai/web-runtime/dist/',
    echo           fallbackModelPath: `https://huggingface.co/mlc-ai/mlc-chat-${modelId}/resolve/main/`
    echo         };
    echo         
    echo         // Create the engine instance
    echo         this.engine = await webllm.CreateMLCEngine(modelId, options);
    echo         console.log('[WebLLMHelper] Model loaded successfully');
    echo         
    echo         return true;
    echo       } catch (e) {
    echo         console.error('[WebLLMHelper] Error loading model:', e);
    echo         throw e;
    echo       }
    echo     },
    echo     
    echo     /**
    echo      * Get available model IDs
    echo      */
    echo     getAvailableModels: function() {
    echo       // Default models that should work with the local setup
    echo       const defaultModels = [
    echo         'Llama-3-8B-Instruct-q4f32_1-MLC',
    echo         'gemma-2b-it-q4f32_1'
    echo       ];
    echo       
    echo       // If WebLLM is available, try to get the models from it
    echo       if (this.isAvailable && typeof webllm !== 'undefined' && webllm.prebuiltAppConfig) {
    echo         try {
    echo           if (webllm.prebuiltAppConfig.model_list) {
    echo             return webllm.prebuiltAppConfig.model_list.map(m => m.model_id);
    echo           }
    echo         } catch (e) {
    echo           console.warn('[WebLLMHelper] Error getting models from WebLLM:', e);
    echo         }
    echo       }
    echo       
    echo       return defaultModels;
    echo     },
    echo     
    echo     /**
    echo      * Generate a chat completion
    echo      */
    echo     generateCompletion: async function(message, history, onChunk, onDone, onError) {
    echo       if (!this.isAvailable || !this.engine) {
    echo         onError("WebLLM engine is not initialized");
    echo         return;
    echo       }
    echo       
    echo       try {
    echo         // Format messages for the API
    echo         const messages = [];
    echo         
    echo         // Add system message if available
    echo         const systemMessage = history.find(m => m.role === 'system');
    echo         if (systemMessage) {
    echo           messages.push(systemMessage);
    echo         } else {
    echo           messages.push({
    echo             role: 'system',
    echo             content: 'You are a helpful assistant.'
    echo           });
    echo         }
    echo         
    echo         // Add conversation history (excluding system messages)
    echo         const conversationHistory = history.filter(m => m.role !== 'system');
    echo         messages.push(...conversationHistory);
    echo         
    echo         // Add the current user message
    echo         messages.push({
    echo           role: 'user',
    echo           content: message
    echo         });
    echo         
    echo         console.log('[WebLLMHelper] Generating completion with messages:', messages);
    echo         
    echo         // Set up options
    echo         const options = {
    echo           messages: messages,
    echo           max_tokens: 1024,
    echo           temperature: 0.7,
    echo           stream: true
    echo         };
    echo         
    echo         // Generate the response
    echo         const stream = await this.engine.chat.completions.create(options);
    echo         
    echo         // Process the stream
    echo         for await (const chunk of stream) {
    echo           if (chunk.choices && chunk.choices[0] && chunk.choices[0].delta) {
    echo             const content = chunk.choices[0].delta.content;
    echo             if (content) {
    echo               onChunk(content);
    echo             }
    echo           }
    echo         }
    echo         
    echo         onDone();
    echo       } catch (e) {
    echo         console.error('[WebLLMHelper] Generation error:', e);
    echo         onError(e.toString());
    echo       }
    echo     }
    echo   };
    echo })();
) > "web\assets\js\webllm_helper.js"

REM Create service worker that handles WebLLM requests
echo Creating WebLLM-aware service worker...
(
    echo // Service worker for WebLLM-enabled Flutter web app
    echo 
    echo const CACHE_NAME = 'webllm-flutter-cache-v1';
    echo 
    echo // Add WebLLM files to precache
    echo const PRECACHE_URLS = [
    echo   '/',
    echo   '/index.html',
    echo   '/main.dart.js',
    echo   '/flutter.js',
    echo   '/assets/js/webllm_helper.js',
    echo   '/assets/js/webllm.js',
    echo   '/assets/wasm/tvmjs_runtime.wasi.js',
    echo   '/assets/wasm/tvmjs_runtime.wasm',
    echo   '/assets/NOTICES',
    echo   '/favicon.png',
    echo   '/manifest.json'
    echo ];
    echo 
    echo // Logger function
    echo function log(...messages) {
    echo   console.log('[Service Worker]', ...messages);
    echo }
    echo 
    echo // Install handler
    echo self.addEventListener('install', event => {
    echo   log('Installing service worker');
    echo   event.waitUntil(
    echo     caches.open(CACHE_NAME)
    echo       .then(cache => {
    echo         log('Pre-caching app shell resources');
    echo         return cache.addAll(PRECACHE_URLS.map(url => new Request(url, {credentials: 'same-origin'})));
    echo       })
    echo       .catch(error => {
    echo         console.error('[Service Worker] Pre-cache error:', error);
    echo       })
    echo   );
    echo   self.skipWaiting();
    echo });
    echo 
    echo // Activate handler
    echo self.addEventListener('activate', event => {
    echo   log('Activating service worker');
    echo   event.waitUntil(
    echo     caches.keys().then(cacheNames => {
    echo       return Promise.all(
    echo         cacheNames.filter(cacheName => {
    echo           return cacheName !== CACHE_NAME;
    echo         }).map(cacheName => {
    echo           log('Deleting old cache:', cacheName);
    echo           return caches.delete(cacheName);
    echo         })
    echo       );
    echo     })
    echo   );
    echo   self.clients.claim();
    echo });
    echo 
    echo // Helper to check if a URL is for WebLLM
    echo function isWebLLMResource(url) {
    echo   const webLLMPatterns = [
    echo     '/web-llm/',
    echo     '/webllm',
    echo     'mlc-chat-',
    echo     'mlc-ai/',
    echo     '.wasm',
    echo     'tvmjs'
    echo   ];
    echo   
    echo   return webLLMPatterns.some(pattern => url.includes(pattern));
    echo }
    echo 
    echo // Helper to check if a URL is from an allowed origin
    echo function isAllowedOrigin(url) {
    echo   const allowedDomains = [
    echo     'cdn.jsdelivr.net',
    echo     'unpkg.com',
    echo     'huggingface.co',
    echo     'storage.googleapis.com',
    echo     'esm.run',
    echo     self.location.hostname // Allow same origin
    echo   ];
    echo   
    echo   return allowedDomains.some(domain => url.includes(domain));
    echo }
    echo 
    echo // Skip problematic URLs
    echo function shouldSkipUrl(url) {
    echo   return url.protocol === 'chrome-extension:';
    echo }
    echo 
    echo // Fetch handler with special WebLLM handling
    echo self.addEventListener('fetch', event => {
    echo   const url = new URL(event.request.url);
    echo   
    echo   // Skip non-GET requests
    echo   if (event.request.method !== 'GET') {
    echo     return;
    echo   }
    echo   
    echo   // Skip problematic URLs
    echo   if (shouldSkipUrl(url)) {
    echo     return;
    echo   }
    echo   
    echo   // Handle WebLLM resources
    echo   if (isWebLLMResource(url.toString())) {
    echo     log('Handling WebLLM resource:', url.toString());
    echo     
    echo     // Security check - only allow specific domains
    echo     if (!isAllowedOrigin(url.toString())) {
    echo       log('Blocked request to non-allowed domain:', url.hostname);
    echo       return;
    echo     }
    echo     
    echo     // For WebLLM resources, use a network-first strategy with cache fallback
    echo     event.respondWith(
    echo       fetch(event.request, { mode: 'cors', credentials: 'omit' })
    echo         .then(response => {
    echo           log('Successfully fetched WebLLM resource:', url.toString());
    echo           
    echo           // Don't cache non-successful responses
    echo           if (!response || response.status !== 200) {
    echo             return response;
    echo           }
    echo           
    echo           // Cache a clone of the response
    echo           const clonedResponse = response.clone();
    echo           caches.open(CACHE_NAME).then(cache => {
    echo             try {
    echo               cache.put(event.request, clonedResponse);
    echo               log('Cached WebLLM resource:', url.toString());
    echo             } catch (e) {
    echo               console.error('[Service Worker] Error caching WebLLM resource:', e);
    echo             }
    echo           });
    echo           
    echo           return response;
    echo         })
    echo         .catch(error => {
    echo           log('Failed to fetch WebLLM resource, trying cache:', url.toString(), error);
    echo           
    echo           return caches.match(event.request)
    echo             .then(cachedResponse => {
    echo               if (cachedResponse) {
    echo                 log('Serving cached WebLLM resource:', url.toString());
    echo                 return cachedResponse;
    echo               }
    echo               
    echo               log('No cached version available for:', url.toString());
    echo               throw error;
    echo             });
    echo         })
    echo     );
    echo     
    echo     return;
    echo   }
    echo   
    echo   // For all other resources, use a cache-first strategy
    echo   event.respondWith(
    echo     caches.match(event.request)
    echo       .then(cachedResponse => {
    echo         if (cachedResponse) {
    echo           log('Serving from cache:', url.pathname);
    echo           return cachedResponse;
    echo         }
    echo         
    echo         log('Cache miss, fetching from network:', url.pathname);
    echo         return fetch(event.request)
    echo           .then(response => {
    echo             // Don't cache non-successful or non-basic responses
    echo             if (!response || response.status !== 200 || response.type !== 'basic') {
    echo               return response;
    echo             }
    echo             
    echo             // Cache a clone of the response
    echo             const clonedResponse = response.clone();
    echo             caches.open(CACHE_NAME).then(cache => {
    echo               cache.put(event.request, clonedResponse);
    echo               log('Cached resource:', url.pathname);
    echo             });
    echo             
    echo             return response;
    echo           })
    echo           .catch(error => {
    echo             log('Fetch failed:', url.pathname, error);
    echo             throw error;
    echo           });
    echo       })
    echo   );
    echo });
    echo 
    echo // Handle errors more gracefully
    echo self.addEventListener('error', event => {
    echo   console.error('[Service Worker] Uncaught error:', event.message, event.filename, event.lineno);
    echo });
    echo 
    echo log('Service worker initialized');
) > "web\service-worker.js"

echo.
echo === WebLLM files prepared successfully ===
echo The necessary files have been downloaded and prepared for your Firebase app.
echo.
echo Next steps:
echo 1. Make sure your index.html uses local paths for WebLLM files
echo 2. Update firebase.json to include the correct COOP/COEP headers
echo 3. Build and deploy your app with 'flutter build web && firebase deploy'
echo.
echo Note: Model weights will be downloaded on first use.

pause