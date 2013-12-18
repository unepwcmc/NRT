# Managing Windows deployment of the National Reporting Toolkit (NRT)
This document provides an overview of the configuration of NRT on a windows server.

## Services
The components of the NRT run as 3 services.

### NRT_Web_application
This is the Node.JS web application. By default, it is configured to run on
port 80. The application itself is located at <SERVER LOCATION HERE>. This
runs the `npm run win-production` in the web application `server/` directory.
It logs to `server/log/production.log` and `server/log/service.log`. This must
be running at all times.

### MongoDb
This the database for the web application. This must be running at all times.

### Indicatorator_Web_App
Another Node.JS web application. This provides a bridge between the NRT web
application and the environmental data feeds. The application itself is located
at <SERVER LOCATION HERE>. This service should be running, but if it goes down,
the site will still function, but without updates.

## Installation
The installation instructions for both the NRT web application and the
indicatorator are in the README.md files in their root directory.

