/**
 * WebLLM Helper - A simplified helper for direct ESM import of WebLLM in Flutter web app
 */
(function() {
  // Create global namespace
  window.webLLMHelper = {
    isAvailable: false,
    engine: null,
    
    /**
     * Initialize the WebLLM helper
     */
    init: async function() {
      console.log('[WebLLMHelper] Initializing');
      
      if (this.isAvailable) {
        console.log('[WebLLMHelper] Already initialized');
        return true;
      }
      
      // Check browser requirements
      if (!this._checkRequirements()) {
        console.error('[WebLLMHelper] Browser requirements not met');
        return false;
      }
      
      // In this updated version, we'll try to dynamically import WebLLM
      // instead of waiting for it to be globally available
      try {
        // First check if it's already globally available
        if (typeof window.webllm !== 'undefined') {
          console.log('[WebLLMHelper] WebLLM is already available globally');
          this.isAvailable = true;
          return true;
        }
        
        // Try to import WebLLM directly using ESM
        console.log('[WebLLMHelper] Trying to import WebLLM via ESM');
        const webllmModule = await this._importWebLLM();
        
        if (webllmModule) {
          console.log('[WebLLMHelper] Successfully imported WebLLM module');
          // Make it globally available to match the expected behavior
          window.webllm = webllmModule;
          this.isAvailable = true;
          return true;
        } else {
          console.error('[WebLLMHelper] Failed to import WebLLM module');
          return false;
        }
      } catch (e) {
        console.error('[WebLLMHelper] Error initializing WebLLM:', e);
        return false;
      }
    },
    
    /**
     * Import WebLLM module using ESM dynamic import
     */
    _importWebLLM: async function() {
      try {
        // Try local file first. The base is overridable so the app works both
        // standalone (assets at /assets/js/) and embedded as an island, where
        // flutter_bootstrap.js sets window.__webllmBase to the hashed
        // /assets/flutter/<hash>/assets/js/ directory.
        try {
          const localBase = window.__webllmBase || '/assets/js/';
          const module = await import(localBase + 'webllm.js');
          return module;
        } catch (localError) {
          console.warn('[WebLLMHelper] Could not load local WebLLM module:', localError);
        }
        
        // CDN fallback, pinned to the same version as the local bundle so a
        // remote release can never silently change what runs on the site.
        const cdnSources = [
          'https://cdn.jsdelivr.net/npm/@mlc-ai/web-llm@0.2.78/+esm'
        ];
        
        for (const source of cdnSources) {
          try {
            console.log(`[WebLLMHelper] Trying to import from ${source}`);
            const module = await import(source);
            console.log(`[WebLLMHelper] Successfully imported from ${source}`);
            return module;
          } catch (e) {
            console.warn(`[WebLLMHelper] Failed to import from ${source}:`, e);
          }
        }
        
        // All attempts failed
        return null;
      } catch (e) {
        console.error('[WebLLMHelper] Error in importWebLLM:', e);
        return null;
      }
    },
    
    /**
     * Check if browser meets WebLLM requirements
     */
    _checkRequirements: function() {
      const isSecureContext = window.isSecureContext === true;
      const hasSharedArrayBuffer = typeof SharedArrayBuffer !== "undefined";
      const isCrossOriginIsolated = window.crossOriginIsolated === true;
      
      console.log('[WebLLMHelper] Browser requirements:', {
        isSecureContext,
        hasSharedArrayBuffer,
        isCrossOriginIsolated
      });
      
      return isSecureContext && hasSharedArrayBuffer && isCrossOriginIsolated;
    },
    
    /**
     * Load a specific model.
     * @param {string} modelId - MLC model id
     * @param {function=} onProgress - optional callback receiving a human-readable status string
     */
    loadModel: async function(modelId, onProgress) {
      if (!this.isAvailable) {
        if (!await this.init()) {
          throw new Error('WebLLM is not available');
        }
      }

      console.log(`[WebLLMHelper] Loading model: ${modelId}`);

      try {
        // Get the correct webllm object (either global or imported)
        const webllm = window.webllm;

        const options = {
          initProgressCallback: (report) => {
            if (typeof onProgress === 'function' && report && report.text) {
              onProgress(report.text);
            }
          }
        };

        // Create the engine instance
        this.engine = await webllm.CreateMLCEngine(modelId, options);
        console.log('[WebLLMHelper] Model loaded successfully');

        return true;
      } catch (e) {
        console.error('[WebLLMHelper] Error loading model:', e);
        throw e;
      }
    },

    /**
     * Get available model IDs
     */
    getAvailableModels: function() {
      // Small models that download in a reasonable time for site visitors
      const defaultModels = [
        'Llama-3.2-1B-Instruct-q4f32_1-MLC',
        'Qwen2.5-1.5B-Instruct-q4f16_1-MLC'
      ];
      
      // If WebLLM is available, try to get the models from it
      if (this.isAvailable && typeof window.webllm !== 'undefined') {
        try {
          if (window.webllm.prebuiltAppConfig && window.webllm.prebuiltAppConfig.model_list) {
            return window.webllm.prebuiltAppConfig.model_list.map(m => m.model_id);
          }
        } catch (e) {
          console.warn('[WebLLMHelper] Error getting models from WebLLM:', e);
        }
      }
      
      return defaultModels;
    },
    
    /**
     * Generate a chat completion
     */
    generateCompletion: async function(message, history, onChunk, onDone, onError) {
      if (!this.isAvailable || !this.engine) {
        onError("WebLLM engine is not initialized");
        return;
      }
      
      try {
        // Format messages for the API
        const messages = [];
        
        // Add system message if available
        const systemMessage = history.find(m => m.role === 'system');
        if (systemMessage) {
          messages.push(systemMessage);
        } else {
          messages.push({
            role: 'system',
            content: 'You are a helpful assistant.'
          });
        }
        
        // Add conversation history (excluding system messages)
        const conversationHistory = history.filter(m => m.role !== 'system');
        messages.push(...conversationHistory);
        
        // Add the current user message
        messages.push({
          role: 'user',
          content: message
        });
        
        console.log('[WebLLMHelper] Generating completion with messages:', messages);
        
        // Set up options
        const options = {
          messages: messages,
          max_tokens: 1024,
          temperature: 0.7,
          stream: true
        };
        
        // Generate the response
        const stream = await this.engine.chat.completions.create(options);
        
        // Process the stream
        for await (const chunk of stream) {
          if (chunk.choices && chunk.choices[0] && chunk.choices[0].delta) {
            const content = chunk.choices[0].delta.content;
            if (content) {
              onChunk(content);
            }
          }
        }
        
        onDone();
      } catch (e) {
        console.error('[WebLLMHelper] Generation error:', e);
        onError(e.toString());
      }
    }
  };
})();