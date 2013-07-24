fs = require('fs')
require("sequelize-mysql").mysql
Sequelize = require("sequelize-mysql").sequelize

module.exports = exports = (env) ->
  dbConfig = JSON.parse(
    fs.readFileSync("#{process.cwd()}/config/database.json", 'UTF8')
  )[env]
  new Sequelize(dbConfig.name, dbConfig.username, dbConfig.password,
    dialect: "mysql"
  )
