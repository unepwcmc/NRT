mongoose = require('mongoose')

getEnv = ->
  if process.env.NODE_ENV
    return process.env.NODE_ENV
  else
    return 'development'

module.exports = (env) ->
  env ||= getEnv()

  console.log "Connecting to DB mongodb://localhost/nrt_#{env}"
  mongoose.connect("mongodb://localhost/nrt_#{env}")
