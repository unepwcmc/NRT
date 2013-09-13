Indicator = require('../models/indicator').model
_ = require('underscore')
async = require('async')
csv = require('express-csv')

exports.index = (req, res) ->
  Indicator.find( (err, indicators)->
    if err?
      console.error err
      return res.render(500, "Error fetching the indicators")

    res.render "indicators/index", indicators: indicators
  )

exports.show = (req, res) ->
  Indicator
    .findOne(_id: req.params.id)
    .exec( (err, indicator)->
      if err?
        console.error err
        return res.render(500, "Error fetching the indicator")

      res.render "indicators/show", indicator: indicator
    )
