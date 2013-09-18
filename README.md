# National Reporting Toolkit

## Setup

* Install and setup NodeJS (0.10.13)
* `npm install -g handlebars coffee-script grunt-cli`
* `npm install` in the `client/` and `server/` dirs to get the libs
* Install mongodb locally (on Mac with [Homebrew](http://brew.sh/) installed, `brew install mongodb`) and start it with
  `mongod`.

Most secrets you need are [here](https://docs.google.com/a/peoplesized.com/document/d/1dYMO3PJhRlTDQ2BEUUOcLwqX0IfJ5UP_UYyfQllnXeQ/).

## Running the application

#### Start the server

In **development**, supervisor is used to handle exceptions:

`cd server/ && npm run-script development`

In **production**:

`cd server/ && npm start`

#### Compile coffeescripts

`cd client && grunt watch`

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
Mongoose schemas, and model instantiation.

### Client

A [BackboneDiorama](https://github.com/th3james/BackboneDiorama/) application

## Development

### Tests

#### Server

In the `server/test/` folder (unsurprisingly). We're using mocha with the qunit
interface and using the chai assertion syntax.

Run them with

`npm test`

#### Client

##### Running 'em

Ensure you've run `grunt` to compile the tests, and fire up the app
server in the test environment:

`NODE_ENV=test npm start`

Then visit [http://localhost:3000/tests](http://localhost:3000/tests)

##### Writing 'em

The tests are written in mocha, using the qunit syntax with chai for
asserts. Write tests in Coffeescript in the `client/test/src/` folder and
compile them with `grunt`.

### Debugging

#### Server

You can use `node-inspector` to debug the server components.

* Install and run `node-inspector`
    * `npm install -g node-inspector`
    * `node-inspector &`
* Run the server with `npm run-script debug`
* Navigate to [the debugger](http://127.0.0.1:8080/debug?port=5858) in
  your browser.

You can now check out console logs and use breakpoints (in your code
with `debugger` and in the inspector itself) inside your browser.

### Workflow

#### Tabs (nope)
No tabs please, 2 spaces in all languages (HTML, CSS, Coffeescript...)

#### Line-length
80 characters

#### Commit workflow
Work on feature branches, commit often with small commits with only one change
to the code. When you're ready to merge your code into the master branch,
submit a pull request and have someone else review it.

#### Commenting your code
Writing small (<10 lines), well named functions is preferable to comments, but
obviously comment when your code isn't intuitive.

#### Documentation
New developers will expected to be able to get the application up and running
on their development machines purely by reading the README. Doing anything in
the app workflow which isn't intuitive? Make sure it's in here.


## User Management

A simple user management system is in place, with a CRUD (minus the U)
API. A secret token is required to authenticate yourself and manage
users. This token is set by an environment variable, `AUTH_TOKEN`.

For example, run your app as so:

    AUTH_TOKEN=my-very-secret-token npm start

#### Listing all users

    curl http://<domain>/users\?token\=my-very-secret-token

#### Adding a user

    curl -X POST -d "email=hats@boats.com&password=password" http://<domain>/users\?token\=my-very-secret-token

#### Deleting a user

    curl -i -X DELETE http://<domain>/users/<id>\?token\=my-very-secret-token
