
# Setup
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

## Configuration
Your application needs configuration files for the environment it will
be run in. View the [configuration README](server/config/README.md) for
possible options.

### Installing in windows as a service:
Install the application on windows as a service using
[NSSM](http://nssm.cc/). Configure NSSM as such:

##### Application:
* Path: C:\Path\To\node.exe
* Startup Directory: C:\Path\To\NRT\server
* Options: .\bin\server.js

##### I/O
Port all your IO to NRT\server\logs\service.log to be able to read
STDOUT/ERR messages

##### Environment Variables
```
NODE_ENV=production
AUTH_TOKEN=changeme
PORT=80
```

##### Check your path
If you're intending to use this deployment for automated deploy, check that
your environment variables are setup for the SYSTEM user which which will run
the service. Otherwise, your deploy will fail with missing commands.

# Running the application

## Development

### Start the server

In **development**, supervisor is used to handle exceptions:

`cd server/ && npm start`

### Asset compilation

*For more info, check out the [asset README](client/README.md).*

`cd client && grunt && grunt watch`

### Logging in

In development, the users will be seeded on application boot. To login,
pick a user from `server/lib/users.json`, e.g.

    nrt@nrt.com
    password

## Seeding data
Data is seeded and updated from the /admin route. If you wish to add new
indicators, or update the existing ones, have a look at the
[Indicatoration](server/components/indicatorator/README.md) documentation.
If backup data is ok, just click 'Seed from backup'

### Faking Indicator Data Backups
There is a [JSON Generator](http://json-generator.com) script which
generates data in the same format as the indicator data backup in
`server/lib/indicator_data.json`. To generate fake data backups:

  1. Grab the contents of the file and enter it into the JSON generator
  2. Save the generated output to the backup file at
     `server/lib/indicator_data.json`
  3. Seed from backup by visiting `/admin` and clicking 'seed from
     backup'

## Production

### Start the server

**Windows**

* `cd server`
* `npm run-script win-production`

**Unix**

* `cd server/ && npm run-script production`

### Asset compilation

*For more info, check out the [asset README](client/README.md).*

`cd client && grunt`

### Authentication and logging in

In production, no users are seeded and have to be created manually.
However, you can use an LDAP server for authentication once it has been
configured. Note that for EAD LDAP use, you must be within the EAD VPN.

#### LDAP

NRT can connect to a LDAP to authenticate and create users.
LDAP is configured by the file `server/config/ldap.json`, and an example
can be found in `server/config/ldap.json.example`. See the [deployment secrets
document](https://docs.google.com/a/peoplesized.com/document/d/1dYMO3PJhRlTDQ2BEUUOcLwqX0IfJ5UP_UYyfQllnXeQ/)
for the production details you need.

LDAP is a optional feature which can be disabled in the application config:
https://github.com/unepwcmc/NRT/tree/master/server/config#example

