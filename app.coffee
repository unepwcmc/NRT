express = require("express")
cons = require("consolidate")
#models = require('./models')
sequelize = require('./models/init.coffee')
GLOBAL.sequelize = sequelize
routes = require('./routes')
http = require('http')
path = require('path')
lessMiddleware = require('less-middleware')

app = express()

app.set('port', process.env.PORT || 3000)

# assign the handlebars engine to .html files
app.engine "html", cons.handlebars
#app.set('view engine', 'ejs');

# set .html as the default extension 
app.set "view engine", "html"
app.set "views", __dirname + "/views"


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

app.get "/", routes.index
#app.get "/users", user.list
http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")


