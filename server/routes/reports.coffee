Report = require('../models/report.coffee').model

exports.index = (req, res) ->
  Report.find (err, reports) ->
    if !err?
      res.render "reports/index",
        reportsJSON: JSON.stringify(reports)
        title: "Report show page"

exports.show = (req, res) ->
  reportId = req.params.id

  Report.findFatReport(reportId, (err, report) ->
    if err?
      console.error err
      return res.render(500, "Could not retrieve report")

    res.render "reports/show", reportData: JSON.stringify report
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
