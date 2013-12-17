mongoose = require('mongoose')
AppConfig = require('./config')

getEnv = ->
  if process.env.NODE_ENV
    return process.env.NODE_ENV
  else
    return 'development'

module.exports = (env) ->
  env ||= getEnv()

  dbConfig = AppConfig.get('db')

  unless dbConfig?
    throw new Error("Couldn't connect to database, no db config found in application config. See the app config README for setup instructions.")

  unless dbConfig.name?
    throw new Error("Couldn't connect to database, db config doesn't specify a name. See the app config README for setup instructions.")

  dbName = "#{dbConfig.name}_#{env}"

  console.log "Connecting to DB mongodb://localhost/#{dbName}"
  mongoose.connect("mongodb://localhost/#{dbName}")
