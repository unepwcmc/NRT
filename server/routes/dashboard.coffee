_ = require('underscore')
moment = require('moment')

Report = require '../models/report'
Indicator = require('../models/indicator')

# TODO: not completed.
groupReportsByDate = (reports) ->
  obj = {
    lastWeek: []
    yesterday: []
    today: []
  }
  yesterday = ""  #TODO
  today = ""      #TODO
  lastWeek = ""   #TODO
  _.each reports, (report) ->
    d = report.createdAt
    if d.isAfter(today) then obj.today.push report
    if d.isAfter(yesterday) and d.isBefore(today) then obj.today.push report
    if d.isAfter(lastWeek) and d.isBefore(yesterday)
      obj.lastWeek.push report
  obj

# Transforms a `sequelize magic` object into a plain good old JavaScript
# object, with a formatted date.
formatReports = (reports) ->
  formattedReports = _.map reports, (r) -> 
    formattedReport = {}
    formattedReport.updatedAt = moment(r.updatedAt).format("MMM Do YYYY")
    formattedReport.title = r.title
    formattedReport.introduction = r.introduction
    formattedReport
  formattedReports
    
exports.index = (req, res) ->
  # TODO: this is a mess, we need a better way of handling this hell of 
  # nested callbacks!
  Indicator.seedDummyIndicatorsIfNone().success(->
    Indicator.findAll().success((indicators)->
      Report.findAll().success((reports) ->
        res.render "dashboard",
          reports: formatReports(reports)
          indicators: indicators
        ).error((error)->
            console.error error  #TODO: This should be logged somewhere
            res.render(500, "Error fetching the reports")
          )
      )
    ).error((error) ->
    console.error error  #TODO: This should be logged somewhere
    res.render(500, "Error seeding DB")
  )
