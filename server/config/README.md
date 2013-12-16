# Application Config
This file sets the global app configuration for the given environment.
The file must be valid JSON and named `#{env}.json`.

The config is accessible thusly:

### Require it
```javascript
  AppConfig = require('initialisers/config')
  AppConfig.get('features').dpsir_filtering
```
### Controllers/Middleware
```javascript
  req.APP_CONFIG.features.dpsir_filtering
```
### Handlebars views
```javascript
  {{APP_CONFIG.features.dpsir_filtering}}
```

## Example

```json
{
  "features": { # Toggle features
    "dpsir_filtering": true # Enable visibility and filtering of DPSIR attributes
  }
}
```
