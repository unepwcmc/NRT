Sequelize = require("sequelize-mysql").sequelize
fs = require('fs')
async = require('async')
_ = require('underscore')

Indicator = sequelize.define('Indicator',
  id:
    type: Sequelize.INTEGER
    primaryKey: true
  title:
    type: Sequelize.STRING
    allowNull: false
  description:
    type: Sequelize.TEXT
)

readDummyIndicators = ->
  JSON.parse(
    fs.readFileSync("#{process.cwd()}/lib/sample_indicators.json", 'UTF8')
  )

buildAsyncIndicatorCreateFunctions = (attributes)->
  _.map(attributes, (attributeSet) ->
    return (callback) ->
      return Indicator.create(attributeSet)
        .success((indicators)->
          callback(null, indicators)
        ).error(callback)
  )

Indicator.seedDummyIndicatorsIfNone = ->
  successCallback = errorCallback = promises = null

  Indicator.count().success((count) ->
    if count == 0
      attributes = readDummyIndicators()
      async.parallel(
        buildAsyncIndicatorCreateFunctions(attributes),
        (error, results) ->
          if error?
            errorCallback(error, results) if errorCallback?
          else
            successCallback(results) if successCallback?
      )
    else
      successCallback([]) if successCallback?
  ).error((error) ->
    console.error error
  )

  promises = {
    success: (callback)->
      successCallback = callback
      return promises
    error: (callback)->
      errorCallback = callback
      return promises
  }
  return promises


Indicator.sync()

module.exports = Indicator
