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
format = (arr) ->
  _.map arr, (obj) -> 
    formattedObj = {}
    for attr, val of obj.selectedValues
      if attr == "updatedAt" or attr == "createdAt"
        formattedObj[attr] = moment(val).format("MMM Do YYYY")
      else
        formattedObj[attr] = val
    formattedObj['type'] = obj['daoFactoryName'].toLowerCase()

    percent_complete = Math.floor(Math.random()*(100-40+1)+40)
    formattedObj['percent_complete'] = percent_complete

    if percent_complete > 60
      formattedObj['color'] = '#5DB16B'
    else
      formattedObj['color'] = '#FDBC56'

    formattedObj
 
exports.index = (req, res) ->
  # TODO: this is a mess, we need a better way of handling this hell of 
  # nested callbacks!
  Indicator.seedDummyIndicatorsIfNone().success(->
    Indicator.findAll().success((indicators)->
      Report.findAll().success((reports) ->
        # Select 5 random items for notifications
        notifications = []

        for i in [1..2]
          index = Math.floor(Math.random()*reports.length)
          item  = reports[index]
          notifications.push item

        for i in [1..3]
          index = Math.floor(Math.random()*indicators.length)
          item  = indicators[index]
          notifications.push item

        res.render "dashboard",
          notifications: _.shuffle(format(notifications))
          reports: _.last(format(reports), 5)
          work_in_progress: _.last(format(reports), 5)
          indicators: _.last(format(indicators), 5)
        ).error((error)->
            console.error error  #TODO: This should be logged somewhere
            res.render(500, "Error fetching the reports")
          )
      )
    ).error((error) ->
    console.error error  #TODO: This should be logged somewhere
    res.render(500, "Error seeding DB")
  )
