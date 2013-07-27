Indicator = require('../models/indicator')

exports.index = (req, res) ->
  Indicator.findAll().success((indicators)->
    res.render "indicators",
      indicators: indicators
  ).error((error)->
    console.error error
    res.render(500, "Error fetching the indicators")
  )

exports.show = (req, res) ->
  res.render "indicators/show",
    indicator: req.params.id
