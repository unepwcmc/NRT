Promise = require('bluebird')
path = require('path')
fs = require('fs')

require('../../initializers/config').initialize()
require('../../initializers/mongo')()
Indicator = require('../../models/indicator').model

module.exports = new Promise( (resolve, reject) ->
  fileName = process.argv[2]
  unless fileName?
    console.error """
      You must provide a path to a valid JSON file as argument
      to this command
    """
    process.exit(1)

  if fileName[0] != '/'
    seedsPath = path.join(process.cwd(), fileName)
  else
    seedsPath = fileName

  Indicator.seedData(
    seedsPath
  ).then( ->
    console.log("Indicator(s) successfully imported")
  ).catch( (err) ->
    console.log "ERROR"
    console.log(err)
  ).finally(
    process.exit
  )
)
