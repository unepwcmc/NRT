# NRT Config
NRT is powered by a number of configuration files

## config/`env`.json
This file sets the global app configuration for the given environment.
Currently, the possible environments are 'development', 'test' and 'production'.

If you are configuring a specific instance of NRT, you can store and
commit the config files in `config/instances` and then use symlinks to
include these configurations in the correct location as above.

### Using it in the app
The config is accessible thusly:
#### Require it
```javascript
  AppConfig = require('initializers/config')
  AppConfig.get('features').dpsir_filtering
```
#### Controllers/Middleware
```javascript
  req.APP_CONFIG.features.dpsir_filtering
```
#### Handlebars views
```javascript
  {{APP_CONFIG.features.dpsir_filtering}}
```

### Example

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

## ldap.json
Configuration for ldap, if that feature is enabled for the instance (see
above). See config/ldap.json.example.

## seeds/
This directory contains the seed data for NRT, which is loaded into the DB if
the DB is empty.

# Instance configurations
`config/instances/` contains the configuration for the many instances of NRT.
When developing or deploying an instance of NRT, copy the relevant
configuration from this folder to `config/`, to setup the app correctly.
Long-term, this will probably be moved elsewhere.
