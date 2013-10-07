app = require('../app.coffee')
port = process.env.PORT || 3000
port = 80 if "production" is process.env.NODE_ENV

app.start(port, (err) ->
  if err
    console.error err
    process.exit 1
  else
    console.log "Express server listening on port " + port
)
