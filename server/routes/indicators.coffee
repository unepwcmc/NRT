Indicator = require('../models/indicator')
_ = require('underscore')
async = require('async')

createSomeIndicators = (attributes) ->
  successCallback = errorCallback = promises = null

  createFunctions = _.map(attributes, (attributeSet) ->
    return (callback) ->
      return Indicator.create(attributeSet)
        .success((indicators)->
          callback(null, indicators)
        ).error(callback)
  )

  async.parallel(
    createFunctions,
    (error, results) ->
      if error?
        errorCallback(error, results) if errorCallback?
      else
        successCallback(results) if successCallback?
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

exports.index = (req, res) ->
  Indicator.findAll().success((indicators)->
    res.render "indicators/index",
      indicators: indicators
  ).error((error)->
    console.error error
    res.render(500, "Error fetching the indicators")
  )

exports.show = (req, res) ->
  res.render "indicators/show",
    indicator: req.params.id
