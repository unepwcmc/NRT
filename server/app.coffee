express = require("express")
exphbs  = require('express3-handlebars')
http = require('http')
path = require('path')
lessMiddleware = require('less-middleware')
require('express-resource')
sass = require('node-sass')
passport = require('passport')

app = express()

sequelize = require('./model_bindings.coffee')(app.get('env'))
GLOBAL.sequelize = sequelize
bindRoutesForApp = require('./route_bindings.coffee')

app.set('port', process.env.PORT || 3000)

# assign the handlebars engine to .html files
app.engine "hbs", exphbs()
app.set "view engine", "hbs"
app.set "views", __dirname + "/views"

app.use(sass.middleware(
  src: 'public/sass'
  dest: path.join(__dirname, 'public/css')
  debug: true
))

app.use passport.initialize()
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser("your secret here")
app.use express.session()
app.use app.router
app.use express.static(path.join(__dirname, "public"))

app.use express.errorHandler()  if "development" is app.get("env")

bindRoutesForApp(app)

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")


