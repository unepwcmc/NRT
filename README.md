Indicatorator
=================

Turns environmental parameter data into indicators, by adding text! 

## Running it

* `npm install`

**Development**

  * `npm start`

**Production**

  * `node index.js`

### Installing in Windows as a service:

Install the application on Windows as a service using
[NSSM](http://nssm.cc/). Configure NSSM as such:

###### Application:

* Path: C:\Path\To\node.exe
* Startup Directory: C:\Path\To\Indicatorator
* Options: .\index.js

###### I/O

Port all your IO to Indicatorator\logs\service.log to be able to read
STDOUT/ERR messages

###### Environment Variables

```
NODE_ENV=production
PORT=3002
```
