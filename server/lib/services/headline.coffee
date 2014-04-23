Q = require('q')
_ = require('underscore')
async = require('async')

calculateRecency = (indicator, callback) ->
  new HeadlineService(indicator).calculateRecencyOfHeadline().then((recency)->
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

NARRATIVE_RECENCY_STATES =
  inDate:
    upToDate: "Up to date"
    noData: "No Data"
  outOfDate:
    outOfDate: "Newer data available"


class HeadlineService
  constructor: (@indicator) ->

  @populateNarrativeRecencyOfIndicators: (indicators) ->
    deferred = Q.defer()

    async.each indicators, calculateRecency, (err) ->
      if err?
        deferred.reject(err)
      else
        deferred.resolve()

    return deferred.promise

  @roundHeadlineValues: (headlines) ->
    for headline in headlines
      unless isNaN(headline.value)
        headline.value = Math.round(headline.value*10)/10

    return headlines

  @narrativeRecencyTextIsUpToDate: (text) ->
    upToDateStates = _.map(NARRATIVE_RECENCY_STATES.inDate, (value) ->
      value
    )
    _.contains(upToDateStates, text)

  convertDataToHeadline: (data) ->
    data = @parseDateInHeadlines(data)
    data = HeadlineService.roundHeadlineValues(data)
    return data

  parseDateInHeadlines: (headlines) ->
    xAxis = @indicator.indicatorDefinition?.xAxis

    if xAxis?
      for headline in headlines
        headline.periodEnd = getPeriodEnd(
          headline[xAxis],
          @indicator.indicatorDefinition.period
        )

    return headlines

  calculateRecencyOfHeadline: ->
    deferred = Q.defer()

    @indicator.populatePage().then( =>
      @getNewestHeadline()
    ).then( (dataHeadline) =>

      unless dataHeadline?
        return deferred.resolve(NARRATIVE_RECENCY_STATES.inDate.noData)

      pageHeadline = @indicator.page.headline

      unless pageHeadline? && pageHeadline.periodEnd?
        return deferred.resolve(NARRATIVE_RECENCY_STATES.outOfDate.outOfDate)

      if moment(pageHeadline.periodEnd).isBefore(dataHeadline.periodEnd)
        deferred.resolve(NARRATIVE_RECENCY_STATES.outOfDate.outOfDate)
      else
        deferred.resolve(NARRATIVE_RECENCY_STATES.inDate.upToDate)

    ).fail( (err) ->
      deferred.reject(err)
    )

    return deferred.promise

  sortHeadlines = (headlines) ->
    _.sortBy(headlines, (headline) ->
      moment(headline.periodEnd)
    )

  getRecentHeadlines: (amount) ->
    deferred = Q.defer()

    Q.nsend(
      @indicator, 'getIndicatorData'
    ).then( (headlineData) =>

      headlines = @convertDataToHeadline(headlineData)

      headlines = sortHeadlines(headlines)
      headlines = _.last(headlines, amount) if amount?

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

module.exports = HeadlineService
