app = require('../app.coffee')
port = process.env.PORT || 3000
port = 80 if app.get("env") == "production"

app.start(port, (err) ->
  if err
    console.error err
    process.exit 1
  else
    console.log "Express server listening on port " + port
)
