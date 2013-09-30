Report = require('../models/report.coffee').model

exports.index = (req, res) ->
  Report.find (err, reports) ->
    if !err?
      res.render "reports/index",
        reportsJSON: JSON.stringify(reports)
        title: "Report show page"

exports.show = (req, res) ->
  reportId = req.params.id

  Report.findOne(reportId, (err, report) ->
    if err?
      console.error err
      return res.render(500, "Could not retrieve report")

    if report?
      report.toObjectWithNestedPage().then( (reportObject) ->
        res.render "reports/show", reportData: JSON.stringify reportObject
      ).fail( (err) ->
        console.error err
        res.render(500)
      )
    else
      res.render(404)
  )

exports.new = (req, res) ->
  res.render "reports/show"

exports.present = (req, res) ->
  reportId = req.params.id

  Report.findOne(reportId, (err, report)->
    if err? or !report?
      console.error err
      return res.render(500, "Could not retrieve report")

    res.render "reports/present", reportData: JSON.stringify(report)
  )
