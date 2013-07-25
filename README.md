# National Reporting Toolkit

### Setup

* Install and setup [NVM](https://github.com/creationix/nvm)
  * We're targeting v0.10.13
* `npm install -g handlebars coffee-script grunt-cli`
* `npm install` in the `client/` and `server/` dirs to get the libs
* Copy `server/config/database.json.example` to
  `server/config/database.json` and fill it with your local mysql
  config. You will need to create the tables you named by hand.
* Install mysql locally (`brew install mysql`, or `sudo apt-get install mysql-server`)

## Running the application

##### Start the server

`cd server/ && npm start`

##### Compile coffeescripts

`cd client && grunt`

## Application structure

### Server

#### app.coffee
Application entry point. Includes required modules and starts the server

#### route_bindings.coffee
Binds the server paths (e.g. '/indicators/') to the routes in the route folder

#### routes/
Contains the 'actions' in the application, grouped into modules by their
responsibility. These are mapped to paths by route_bindings.coffee

#### models/
mysql ORM initialization

### Client

A [BackboneDiorama](https://github.com/th3james/BackboneDiorama/) application

## Tests

### Server

In the `test/` folder (unsurprisingly). We're using mocha with the qunit
interface and using the chai assertion syntax.

Run them with

`npm test`

### Client

#### Running 'em

Ensure you've run `grunt` to compile the tests, and fire up the app
server in the test environment:

`NODE_ENV=test coffee app.coffee`

Then visit http://localhost:3000/tests

#### Writing 'em

The tests are written in mocha, using the qunit syntax with chai for
asserts. Write tests in coffeescript in the `test/` folder and
compile them with `grunt`.

## Development workflow

### Tabs (nope)
No tabs please, 2 spaces in all languages (HTML, CSS, Coffeescript...)

### Line-length
80 characters

### Commit workflow
Work on feature branches, commit often with small commits with only one change
to the code. When you're ready to merge your code into the master branch,
submit a pull request and have someone else review it.

### Commenting your code
Writing small (<10 lines), well named functions is preferable to comments, but
obviously comment when your code isn't intuitive.

### Documentation
New developers will expected to be able to get the application up and running
on their development machines purely by reading the README. Doing anything in
the app workflow which isn't intuitive? Make sure it's in here.
