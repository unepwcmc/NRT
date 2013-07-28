Report = require('../models/report')

exports.index = (req, res) ->
  Report = require('../models/report.coffee')
  Report.findAll().success (reports) ->
    res.render "reports/index",
      reportsJSON: JSON.stringify(reports)
      title: "Report show page"

exports.show = (req, res) ->
  reportId = req.params.id
  Report.findFatReport(reportId).success((reportData)->
    console.log reportData
    res.render "reports/show",
      reportData: JSON.stringify reportData
  ).error((error) ->
    console.log error
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
    console.log reportData
    res.render "reports/present",
      reportData: JSON.stringify reportData
  ).error((error) ->
    console.log error
    res.render "404"
  )
