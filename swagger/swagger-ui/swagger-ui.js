
var SwaggerUIBundle = require('swagger-ui-dist/swagger-ui-bundle');
var SwaggerUIStandalonePreset = require('swagger-ui-dist/swagger-ui-standalone-preset');

window.onload = function() {

  // Build a system
  const ui = SwaggerUIBundle({
    url: "swagger.json",
    dom_id: '#swagger-ui',
    deepLinking: true,
    validatorUrl: null,
    defaultModelExpandDepth: 2,
    defaultModelsExpandDepth: 0,
    filter: true,
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ],
    layout: "StandaloneLayout"
  })

  window.ui = ui
}

