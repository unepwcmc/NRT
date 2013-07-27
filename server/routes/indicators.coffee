Indicator = require('../models/indicator')
_ = require('underscore')
async = require('async')

exports.index = (req, res) ->
  Indicator.seedDummyIndicatorsIfNone().success(->
    Indicator.findAll().success((indicators)->
      res.render "indicators/index",
        indicators: indicators
    ).error((error)->
      console.error error
      res.render(500, "Error fetching the indicators")
    )
  ).error((error) ->
    console.error error
    res.render(500, "Error seeding DB")
  )

exports.show = (req, res) ->
  res.render "indicators/show",
    indicator: req.params.id
