_ = require('underscore')

Report = require '../models/report'

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

exports.index = (req, res) ->
  Report.findAll().success (reports) ->
    res.render "dashboard",
      reports: reports
