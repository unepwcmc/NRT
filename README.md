# National Reporting Toolkit

### Setup

- Install and setup [NVM](https://github.com/creationix/nvm), we're targeting
the newest stable node, which at the time of writing is v0.10.13
- `npm install` in the project dir to get the libs

## Application structure

#### app.coffee
Application entry point. Includes required modules and starts the server

#### route_bindings.coffee
Binds the server paths (e.g. '/indicators/') to the routes in the route folder

#### routes/
Contains the 'actions' in the application, grouped into modules by their 
responsibility. These are mapped to paths by route_bindings.coffee

#### models/
mysql ORM initialization

#### public/clientApp
A [BackboneDiorama](https://github.com/th3james/BackboneDiorama/) application

## Tests
Tests go in the test/ folder (unsurprisingly). We're using mocha with the qunit
interface and using the chai assertion syntax.

Run them with 

`npm test`
