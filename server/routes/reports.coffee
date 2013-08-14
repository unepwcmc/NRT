Report = require('../models/report').model

exports.index = (req, res) ->
  Report = require('../models/report.coffee').model
  Report.find (err, reports) ->
    if !err?
      res.render "reports/index",
        reportsJSON: JSON.stringify(reports)
        title: "Report show page"

exports.show = (req, res) ->
  reportId = req.params.id
  Report.findFatReport(reportId).success((reportData)->
    res.render "reports/show",
      reportData: JSON.stringify reportData
  ).error((error) ->
    console.error error
    res.render "404"
  )

exports.new = (req, res) ->
  res.render "reports/show",
    reportData: JSON.stringify(
      title: "A new report"
    )

exports.present = (req, res) ->
  reportId = req.params.id
  Report.findFatReport(reportId).success((reportData)->
    res.render "reports/present",
      reportData: JSON.stringify reportData
  ).error((error) ->
    console.error error
    res.render "404"
  )
