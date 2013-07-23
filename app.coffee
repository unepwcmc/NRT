express = require("express")
cons = require("consolidate")
http = require('http')
path = require('path')
lessMiddleware = require('less-middleware')
require('express-resource')
sass = require('node-sass')

# App requires

app = express()

sequelize = require('./model_bindings.coffee')(app.get('env'))
GLOBAL.sequelize = sequelize
bindRoutesForApp = require('./route_bindings.coffee')

app.set('port', process.env.PORT || 3000)

# assign the handlebars engine to .html files
app.engine "hbs", cons.handlebars
#app.set('view engine', 'ejs');

# set .html as the default extension 
app.set "view engine", "hbs"
app.set "views", __dirname + "/views"

app.use(sass.middleware(
  src: 'public/sass'
  dest: path.join(__dirname, 'public/css')
  debug: true
))

app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser("your secret here")
app.use express.session()
app.use app.router
#app.use require("less").middleware(__dirname + "/public")
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")

bindRoutesForApp(app)

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")


