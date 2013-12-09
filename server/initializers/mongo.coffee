mongoose = require('mongoose')

getEnv = ->
  if process.env.NODE_ENV
    return process.env.NODE_ENV
  else
    return 'development'

module.exports = (env) ->
  env ||= getEnv()

  dbName = "demo_nrt_#{env}"

  console.log "Connecting to DB mongodb://localhost/#{dbName}"
  mongoose.connect("mongodb://localhost/#{dbName}")
