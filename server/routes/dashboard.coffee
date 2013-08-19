_ = require('underscore')
async = require('async')

Report = require('../models/report').model
Indicator = require('../models/indicator').model

exports.index = (req, res) ->
  getReports = (callback) ->
    Report.find((err, reports) ->
      if err?
        callback(err)

      callback(null, reports)
    )

  getIndicators = (callback) ->
    Indicator.find((err, indicators) ->
      if err?
        callback(err)

      callback(null, indicators)
    )

  async.parallel(
    reports: getReports
    indicators: getIndicators
  , (err, items) ->
    if err?
      console.error error
      return res.render(500, "Error fetching the reports")

    res.render "dashboard",
      reports: items.reports
      indicators: items.indicators
  )
