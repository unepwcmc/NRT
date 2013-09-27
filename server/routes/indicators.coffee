Indicator = require('../models/indicator').model
Theme = require('../models/theme').model
_ = require('underscore')
async = require('async')
csv = require('express-csv')

exports.index = (req, res) ->
  Theme.getFatThemes( (err, themes) ->
    if err?
      console.error err
      return res.render(500, "Error fetching the themes")
    res.render "indicators/index", themes: themes
  )

exports.show = (req, res) ->
  Indicator
    .findOne(_id: req.params.id, (err, indicator) ->
      if err?
        console.error err
        return res.render(500, "Error fetching the indicator")

      indicator.toObjectWithNestedPage().then((indicatorObject) ->
        res.render("indicators/show",
          indicator: indicator, indicatorJSON: JSON.stringify(indicatorObject)
        )
      ).fail((err) ->
        console.error err
        return res.render(500, "Error fetching the indicator page")
      )
    )
