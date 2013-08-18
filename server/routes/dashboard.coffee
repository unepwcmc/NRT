_ = require('underscore')
moment = require('moment')

Report = require('../models/report').model

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
format = (arr) ->
  _.map arr, (obj) -> 
    formattedObj = {}
    for attr, val of obj.selectedValues
      if attr == "updatedAt" or attr == "createdAt"
        formattedObj[attr] = moment(val).format("MMM Do YYYY")
      else
        formattedObj[attr] = val

    percent_complete = Math.floor(Math.random()*(100-40+1)+40)
    formattedObj['percent_complete'] = percent_complete

    if percent_complete > 60
      formattedObj['color'] = '#5DB16B'
    else
      formattedObj['color'] = '#FDBC56'

    formattedObj
 
exports.index = (req, res) ->
  Report.find (err, reports) ->
    if err?
      console.error error
      return res.render(500, "Error fetching the reports")

    res.render "dashboard",
      reports: format(reports)
      indicators: []
