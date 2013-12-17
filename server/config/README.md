# Application Config
This file sets the global app configuration for the given environment.
The file must be valid JSON and named `#{env}.json`.

The config is accessible thusly:

### Require it
```javascript
  AppConfig = require('initializers/config')
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
  "instance_name": "Abu Dhabi", # The name of the instance
  "db": {
    "name: "nrt_production" # The name of your database
  }
  "features": { # Toggle features
    "dpsir_filtering": true, # Enable visibility and filtering of DPSIR attributes
    "ldap": true # Enable LDAP authentication
  }
}
```
