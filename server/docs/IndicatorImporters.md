# Importing indicators
After the initial indicator definitions have been populated from the
seeds folder on the first startup of the application, additional indicators
can be imported through specific importers.

As of now, the available importers are:

## Google Drive (aka Google Docs)
An indicator can be imported from a Google Spreadsheet via the admin interface,
by providing the spreadsheet key. This can be found in the URL that points to
the spreadsheet itself. For instance:

    https://docs.google.com/spreadsheets/d/12-n-xlzFlT3T1dScfaI7a7ZnhEILbtSCjXSNKbfLJEI/pubhtml
                                           <------------- spreadsheet key ------------>

### Spreadsheet structure
The given spreadsheet must at least contain three worksheets,
in no particular order:

#### 'Definition' worksheet
This worksheet defines the main properties of the wanted indicator.
Specifically, three values must be provided on the second row of
the worksheet. The first row may comprise indicative headers.
As an example:

What's the name of this indicator? | What theme does this indicator relate to? | What unit does the indicator value use?
---------------------------------- | ----------------------------------------- | ---------------------------------------
Indicator Name                     | Theme name                                | mg/m3

#### 'Ranges' worksheet
This worksheet defines the ranges to be applied to the indicator.
These have to be provided as a list of (Threshold,Text) tuples on
the first two columns of the worksheet. The first row is skipped,
and can be used for informative headers. As an example:

Threshold | Text
--------- | ----
100       | Catastrophic
5         | Dangerous
2.5       | Bad
0.5       | Good

#### 'Data' worksheet
This worksheet is not used during the import process, but has to
be present for the indicatoration to succesfully import and
indicatorate the environmental data. Further information on this
process can be found in the
[indicatoration documentation](server/components/indicatorator/README.md)

#### Registering for automatic changes in Google Drive
NRT can watch google spreadsheets for changes and pull in data updates
automatically. This is done using the [Google Web-hooks
API](https://developers.google.com/drive/web/push#creating).

##### Setting up the application for webhooks
To use the web-hooks API, you have to register your application with Google.
Because callback routes are required to be https, but NRT instances don't use
this, we have an https proxy at https://secure.nrt.io. This URL is the site
that registered with the [Google Webmaster
Tools](https://www.google.com/webmasters/tools/).
Next, you have to register the application in the [developer
console](https://console.developers.google.com/). In the API setup section you
must enable the Drive API. Then, go to credentials and create client for web
applications, which will generate a client ID must use in the OAuth2 setup
process.

##### Getting an OAuth2 bearer token
NRT doesn't \(yet\) support full OAuth2 authentication, so for now you must
grab a token manually. To do this, you will need an OAuth2 capable request
library (I used [Postman](http://www.getpostman.com). Send your authentication
request with the following parameters:

  Auth URL: https://accounts.google.com/o/oauth2/auth
  Access Token URL: https://accounts.google.com/o/oauth2/token
  Client ID: <some-long-key>.apps.googleusercontent.com # Comes from developer console
  Client secret: <some-other-key> # Also from developer console
  Scope: https://www.googleapis.com/auth/drive # List of permissions, here we're requesting everything Drive-related

This will open the google log-in page, where you must then log-in with the same
google account which will host the documents.

This process will yield a 'bearer' token, which is long hex token. Once you
have this, add it to your application config like so:

```json
  ... // server/config/<env>.json
  "google_oauth_key": "<your-bearer-token>",
  "features": {
    "auto_update_google_sheets": true
  }
```

##### HTTPS reverse proxying callbacks
As mentioned above, Google's webhooks api requires the callback URLs to use HTTPS. Rather than aquiring HTTPs certificates for all instances, instead, we have a single reverse proxying running at secure.nrt.io. This proxy receives the callbacks, then sends the webhook notifications to the corresponding instance. The source code for this proxy is at: https://github.com/unepwcmc/NRTGoogleDriveApiProxy
