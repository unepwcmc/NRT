Q = require('q')
_ = require('underscore')
async = require('async')

calculateRecency = (indicator, callback) ->
  indicator.calculateRecencyOfHeadline().then((recency)->
    indicator.narrativeRecency = recency
    callback()
  ).fail((err) ->
    callback(err)
  )

durationMap =
  annual:
    unit: 'years'
    amount: 1
  quarterly:
    unit: 'months'
    amount: 3

getPeriodEnd = (date, period) ->
  duration = durationMap[period]
  duration ||= durationMap.annual

  moment(date.toString())
    .add(duration.unit, duration.amount)
    .subtract('days', 1)
    .format("D MMM YYYY")

module.exports = {
  statics:
    calculateNarrativeRecency: (indicators) ->
      deferred = Q.defer()

      async.each indicators, calculateRecency, (err) ->
        if err?
          deferred.reject(err)
        else
          deferred.resolve()

      return deferred.promise

    roundHeadlineValues: (headlines) ->
      for headline in headlines
        unless isNaN(headline.value)
          headline.value = Math.round(headline.value*10)/10

      return headlines

  methods:
    convertDataToHeadline: (data) ->
      Indicator = require('../models/indicator.coffee').model

      data = @parseDateInHeadlines(data)
      data = Indicator.roundHeadlineValues(data)
      return data

    parseDateInHeadlines: (headlines) ->
      xAxis = @indicatorDefinition?.xAxis

      if xAxis?
        for headline in headlines
          headline.periodEnd = getPeriodEnd(
            headline[xAxis],
            @indicatorDefinition.period
          )

      return headlines

    calculateRecencyOfHeadline: ->
      deferred = Q.defer()

      @populatePage().then( =>
        @getNewestHeadline()
      ).then( (dataHeadline) =>

        unless dataHeadline?
          return deferred.resolve("No Data")

        pageHeadline = @page.headline

        unless pageHeadline? && pageHeadline.periodEnd?
          return deferred.resolve("Out of date")

        if moment(pageHeadline.periodEnd).isBefore(dataHeadline.periodEnd)
          deferred.resolve("Out of date")
        else
          deferred.resolve("Up to date")

      ).fail( (err) ->
        deferred.reject(err)
      )

      return deferred.promise

    getRecentHeadlines: (amount) ->
      Indicator = require('../models/indicator.coffee').model

      deferred = Q.defer()

      Q.nsend(
        @, 'getIndicatorData'
      ).then( (data) =>

        headlineData = data
        headlineData = _.last(data, amount) if amount?
        headlines = @convertDataToHeadline(headlineData)

        deferred.resolve(headlines.reverse())

      ).fail( (err) ->
        deferred.reject(err)
      )

      return deferred.promise

    getNewestHeadline: ->
      deferred = Q.defer()

      @getRecentHeadlines(1).then((headlines) ->
        deferred.resolve headlines[0]
      ).fail( (err) ->
        deferred.reject err
      )

      return deferred.promise
}