fs = require('fs')
require("sequelize-mysql").mysql
Sequelize = require("sequelize-mysql").sequelize

readDbConfigFromFile = (env)->
  JSON.parse(
    fs.readFileSync("#{process.cwd()}/config/database.json", 'UTF8')
  )[env]

readDbConfigFromEnv = ->
  name: process.env.DB_NAME
  username: process.env.DB_USERNAME
  password: process.env.DB_PASSWORD
  host: process.env.DB_HOST

module.exports = exports = (env) ->
  dbConfig = readDbConfigFromFile(env)
  if !dbConfig?
    dbConfig = readDbConfigFromEnv()
  new Sequelize(dbConfig.name, dbConfig.username, dbConfig.password,
    dialect: "mysql",
    host: dbConfig.host
    logging: false
  )
