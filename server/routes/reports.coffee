Report = require('../models/report')

exports.index = (req, res) ->
  res.render "reports",
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

exports.present = (req, res) ->
  res.render "reports/present",
    report_id: req.params.id
