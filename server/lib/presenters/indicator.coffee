Q = require 'q'
moment = require('moment')

HeadlineService = require('../services/headline')

DATE_FORMAT = 'D MMM YYYY'

module.exports = class IndicatorPresenter

  constructor: (@indicator) ->

  populateHeadlineRangesFromHeadlines: (headlines) ->
    @indicator.headlineRanges = {}
    xAxis = @indicator.indicatorDefinition?.xAxis

    if xAxis?
      newest = headlines[0][xAxis].toString()
      oldest = headlines[headlines.length - 1][xAxis].toString()

      @indicator.headlineRanges =
        oldest: moment(oldest).format(DATE_FORMAT)
        newest: moment(newest).format(DATE_FORMAT)

  populateIsUpToDate: ->
    deferred = Q.defer()

    if @indicator.narrativeRecency?
      @indicator.isUpToDate = HeadlineService.narrativeRecencyTextIsUpToDate(
        @indicator.narrativeRecency
      )
      deferred.resolve()
    else
      new HeadlineService(@indicator).calculateRecencyOfHeadline().then((narrativeRecency)=>
        @indicator.isUpToDate = HeadlineService.narrativeRecencyTextIsUpToDate(
          narrativeRecency
        )
        deferred.resolve()
      ).fail(deferred.reject)

    return deferred.promise

  populateNarrativeRecency: ->
    deferred = Q.defer()

    new HeadlineService(@indicator).calculateRecencyOfHeadline().then((recency)=>
      @indicator.narrativeRecency = recency
      deferred.resolve()
    ).fail(deferred.reject)

    return deferred.promise
