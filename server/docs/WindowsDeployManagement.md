# Managing Windows deployment of the National Reporting Toolkit (NRT)
This document provides an overview of the configuration of NRT on a windows server.

## Services
The components of the NRT run as 2 services.

### NRT_Web_application
This is the Node.JS web application. By default, it is configured to run on
port 80. The application itself is located at <SERVER LOCATION HERE>. This
runs `node bin/server.js` in the web application `server/` directory.
It logs to `server/log/production.log` and `server/log/service.log`. This must
be running at all times.

### MongoDb
This the database for the web application. This must be running at all times.

## Installation
The installation instructions for the NRT web application
can be found in the [docs/Installation.md](server/docs/Installation.md)
file.
