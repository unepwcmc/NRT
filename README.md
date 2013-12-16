[![Build Status](https://travis-ci.org/unepwcmc/NRT.png)](https://travis-ci.org/unepwcmc/NRT)

# National Reporting Toolkit

NRT is an online system to help Governments collect, analyse and publish
environmental information quickly and easily. It’s being built by the
UNEP World Conservation Monitoring Centre, in partnership with the
United Nations Environment Programme (UNEP) and the Abu Dhabi Global
Environmental Data Initiative (AGEDI). You can find out more at
[nrt.io](http://nrt.io)

## Setup
Grab the dependencies by running the script for your platform in
`installers/`. If you're doing this on a development machine, you probably want
to review the installers first and remove any dependencies you already have
installed (don't worry, they're short!)

* **OS X**: Uses [homebrew](http://brew.sh) to install the dependecies. 
* **Ubuntu**: Uses apt-get
* **Windows**: 
  * Ensure powershell is installed, then run install.bat as Admin
  * After the install has completed, setup the application with:

  `cd server/ && npm run-script setup`

#### Installing in windows as a service:
Install the application on windows as a service using [NSSM](http://nssm.cc/). Configure NSSM as such:

###### Application:
* Path: C:\Path\To\node.exe
* Startup Directory: C:\Path\To\NRT\server
* Options: .\bin\server.js

###### I/O
Port all your IO to NRT\server\logs\service.log to be able to read STDOUT/ERR messages

###### Environment Variables
```
NODE_ENV=production
AUTH_TOKEN=changeme
PORT=80
```

###### Check your path
If you're intending to use this deployment for automated deploy, check that
your environment variables are setup for the SYSTEM user which which will run
the service. Otherwise, your deploy will fail with missing commands.

## Running the application

### Development

#### Start the server

In **development**, supervisor is used to handle exceptions:

`cd server/ && npm start`

#### Compile coffeescripts

`cd client && grunt watch`

#### Logging in

In development, the users will be seeded on application boot. To login,
pick a user from `server/lib/users.json`, e.g.

    nrt@nrt.com
    password

### Seeding data
Data is seeded and updated from the /admin route. If you wish to update the
indicators, you'll also need the
[Indicatorator](https://github.com/unepwcmc/Indicatorator) running. If backup
data is ok, just click 'Seed from backup'

### Production

#### Start the server

**Windows**

* `cd server`
* `npm run-script win-production`

**Unix**

* `cd server/ && npm run-script production`

#### Compile coffeescripts

`cd client && grunt watch`

#### Authentication and logging in

In production, no users are seeded and have to be created manually.
However, you can use an LDAP server for authentication once it has been
configured. Note that for EAD LDAP use, you must be within the EAD VPN.

##### LDAP

LDAP is configured by the file `server/config/ldap.json`, and an example
can be found in `server/config/ldap.json.example`. See the [deployment secrets
document](https://docs.google.com/a/peoplesized.com/document/d/1dYMO3PJhRlTDQ2BEUUOcLwqX0IfJ5UP_UYyfQllnXeQ/)
for the production details you need.

**In development, LDAP is disabled.**

#### Automatic deployments

Once the application has been setup manually for the first time on a
server, you can automatically deploy new code pushed to the `deploy`
branch on Github.

Only one step of setup is required:

  1. Add a WebHook [service hook](https://github.com/unepwcmc/NRT/settings/hooks)
     that points at your server's deploy route
     (`http://youdomain.com/deploy`).

Github will notify the server of any changes, and the application should
automatically pull the new code and update the server's local
repository. **Make sure you are running your application with `forever`
or it will not restart after a deploy**.

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

##### Using Q for deferreds in tests

Q.js is used through-out the application to prevent callback pyramids. One
thing to note when using it, particularly in tests, is that you must specify a
fail callback as well as success for every deferred, or your application will
silently fail. In tests, you can usually just handle do this by passing mocha's
`done` function to fail, e.g:

```coffeescript
test('somePromiseFunction', (done) ->
  somePromiseFunction.then(->
    # some assertions
    done()
  ).fail(done) # This will call done with an error as first argument, which triggers mocha's error state
)
```

#### Client

##### Running 'em

Ensure you've run `grunt` to compile the tests, and fire up the app
server:

`npm start`

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

    curl http://<domain>/api/users\?token\=my-very-secret-token

#### Adding a user

    curl -X POST -d "email=hats@boats.com&password=password" http://<domain>/api/users\?token\=my-very-secret-token

#### Deleting a user

    curl -i -X DELETE http://<domain>/api/users/<id>\?token\=my-very-secret-token


## Production

WCMC team should already have access to [this document](https://docs.google.com/a/peoplesized.com/document/d/1dYMO3PJhRlTDQ2BEUUOcLwqX0IfJ5UP_UYyfQllnXeQ/)
