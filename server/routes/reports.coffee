exports.index = (req, res) ->
  Report = require('../models/report.coffee')
  Report.findAll().success (reports) ->
    res.render "reports/index",
      reportsJSON: JSON.stringify(reports)
      title: "Report show page"

exports.show = (req, res) ->
  res.render "reports/show",
    report_id: req.params.id

exports.present = (req, res) ->
  res.render "reports/present",
    report_id: req.params.id
