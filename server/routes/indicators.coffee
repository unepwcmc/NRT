Indicator = require('../models/indicator').model
_ = require('underscore')
async = require('async')

exports.index = (req, res) ->
  Indicator.find( (err, indicators)->
    if err?
      console.error err
      return res.render(500, "Error fetching the indicators")

    res.render "indicators/index", indicators: indicators
  )

exports.show = (req, res) ->
  res.render "indicators/show",
    indicator: req.params.id

