# National Reporting Toolkit

### Setup

- Install and setup [NVM](https://github.com/creationix/nvm), we're targeting
  the newest stable node, which at the time of writing is v0.10.13
- `npm install` in the project dir to get the libs
- `npm install -g handlebars coffee-script grunt-cli backbone-diorama` to compile the
  client application
- Create config/database.json entries for 'development' and 'test'
  environments. You will need to create the tables you named by hand.

## Running the application

##### Start the server

`node app.coffee`

##### Compile coffeescripts

`grunt watch`

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

### Server
In the test/ folder (unsurprisingly). We're using mocha with the qunit
interface and using the chai assertion syntax.

Run them with 

`npm test`

### Client
#### Running 'em
Fire up the app server in the test environment:

`NODE_ENV=test coffee app.coffee`

Then visit http://localhost:3000/tests

#### Writing 'em
The tests are written in mocha, using the qunit syntax with chai for asserts. Write tests in coffeescript in the clientTests/ folder.
