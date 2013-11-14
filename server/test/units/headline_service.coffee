assert = require('chai').assert
helpers = require '../helpers'
async = require('async')
_ = require('underscore')
Q = require 'q'
sinon = require 'sinon'

HeadlineService = require('../../services/headline')
Indicator = require('../../models/indicator').model
IndicatorData = require('../../models/indicator_data').model
Page = require('../../models/page').model

suite('HeadlineService')

test('.getRecentHeadlines returns the given number of most recent headlines
  in decending date order with the period end calculated for annual
  indicator data', (done)->
  indicatorData = [
    {
      "year": 2000,
      "value": 2
      "text": 'Poor'
    }, {
      "year": 2001,
      "value": 9
      "text": 'Great'
    }, {
      "year": 2002,
      "value": 4
      "text": 'Fair'
    }
  ]

  indicatorDefinition =
    xAxis: 'year'
    yAxis: 'value'
    textField: 'text'
    fields: [{
      name: 'year'
      type: 'integer'
    }, {
      name: "value",
      type: "integer"
    }, {
      name: 'text'
      name: 'text'
    }]

  theIndicator = null

  Q.nsend(
    Indicator, 'create',
      indicatorDefinition: indicatorDefinition
  ).then( (indicator) ->
    theIndicator = indicator

    Q.nsend(
      IndicatorData, 'create'
        indicator: theIndicator
        data: indicatorData
    )
  ).then( ->
    headlineService = new HeadlineService(theIndicator)
    headlineService.getRecentHeadlines(2)
  ).then( (data) ->

    assert.lengthOf data, 2, "Expected 2 headlines to be returned"

    mostRecentHeadline = data[0]

    assert.strictEqual(mostRecentHeadline.year, 2002,
      "Expected most recent headline year value to be 2002")
    assert.strictEqual(mostRecentHeadline.value, 4,
      "Expected most recent headline value to be 4")
    assert.strictEqual(mostRecentHeadline.text, "Fair",
      "Expected most recent headline text to be 'Fair'")

    assert.strictEqual(mostRecentHeadline.periodEnd, "31 Dec 2002",
      "Expected most recent headline period end to be '31 Dec 2002")

    done()

  ).fail(done)
)

test('.getRecentHeadlines successfully returns all headline when the
  number of headlines requested is undefined', (done)->
  indicatorData = [
    {
      "year": 1999,
      "value": 3
      "text": 'Poor'
    },
    {
      "year": 2000,
      "value": 2
      "text": 'Poor'
    }
  ]

  indicator = new Indicator()
  sinon.stub(indicator, 'getIndicatorData', (callback) ->
    callback(null, indicatorData)
  )

  headlineService = new HeadlineService(indicator)
  headlineService.getRecentHeadlines()
  .then( (data) ->

    assert.lengthOf data, 2, "Expected 2 headlines to be returned"

    mostRecentHeadline = data[0]

    assert.strictEqual(mostRecentHeadline.year, 2000,
      "Expected most recent headline year value to be 2000")
    assert.strictEqual(mostRecentHeadline.value, 2,
      "Expected most recent headline value to be 2")
    assert.strictEqual(mostRecentHeadline.text, "Poor",
      "Expected most recent headline text to be 'Poor'")

    done()

  ).fail(done)
)

test('.getNewestHeadline returns the most recent headline', (done)->
  indicatorData = [
    {
      "year": 2001,
      "value": 9
      "text": 'Great'
    }, {
      "year": 2002,
      "value": 4
      "text": 'Fair'
    }
  ]

  indicatorDefinition =
    xAxis: 'year'
    yAxis: 'value'
    textField: 'text'
    fields: [{
      name: 'year'
      type: 'integer'
    }, {
      name: "value",
      type: "integer"
    }, {
      name: 'text'
      name: 'text'
    }]

  theIndicator = null

  Q.nsend(
    Indicator, 'create',
      indicatorDefinition: indicatorDefinition
  ).then( (indicator) ->
    theIndicator = indicator

    Q.nsend(
      IndicatorData, 'create'
        indicator: theIndicator
        data: indicatorData
    )
  ).then( ->
    headlineService = new HeadlineService(theIndicator)
    headlineService.getNewestHeadline()
  ).then( (mostRecentHeadline) ->

    assert.strictEqual(mostRecentHeadline.year, 2002,
      "Expected most recent headline year value to be 2002")
    assert.strictEqual(mostRecentHeadline.value, 4,
      "Expected most recent headline value to be 4")
    assert.strictEqual(mostRecentHeadline.text, "Fair",
      "Expected most recent headline text to be 'Fair'")

    done()

  ).fail(done)
)

test('.calculateRecencyOfHeadline when given an indicator with a headline date
  older than the most recent data returns "Out of date"', (done) ->
  indicator = new Indicator()
  headlineService = new HeadlineService(indicator)

  sinon.stub(headlineService, 'getNewestHeadline', ->
    deferred = Q.defer()
    deferred.resolve {periodEnd: '31 Dec 2012'}
    return deferred.promise
  )

  page = new Page(parent_type: 'Indicator', headline: {periodEnd: '30 Dec 2012'})
  sinon.stub(indicator, 'populatePage', ->
    deferred = Q.defer()
    deferred.resolve indicator.page = page
    return deferred.promise
  )

  headlineService.calculateRecencyOfHeadline().then( (recencyText) ->
    assert.strictEqual "Out of date", recencyText
    done()
  ).fail(done)
)

test('.calculateRecencyOfHeadline when given an indicator with a headline date
  equal to or newer than the most recent data returns "Up to date"', (done) ->
  indicator = new Indicator()
  headlineService = new HeadlineService(indicator)

  sinon.stub(headlineService, 'getNewestHeadline', ->
    deferred = Q.defer()
    deferred.resolve {periodEnd: '31 Dec 2012'}
    return deferred.promise
  )

  page = new Page(parent_type: 'Indicator', headline: {periodEnd: '01 Jan 2013'})
  sinon.stub(indicator, 'populatePage', ->
    deferred = Q.defer()
    deferred.resolve indicator.page = page
    return deferred.promise
  )

  headlineService.calculateRecencyOfHeadline().then( (recencyText) ->
    assert.strictEqual "Up to date", recencyText
    done()
  ).fail(done)
)

test('.calculateRecencyOfHeadline when given an indicator with no data
  returns "No Data"', (done) ->
  indicator = new Indicator()
  headlineService = new HeadlineService(indicator)

  page = new Page(parent_type: 'Indicator')
  sinon.stub(indicator, 'populatePage', ->
    deferred = Q.defer()
    deferred.resolve indicator.page = page
    return deferred.promise
  )

  headlineService.calculateRecencyOfHeadline().then( (recencyText) ->
    assert.strictEqual "No Data", recencyText
    done()
  ).fail(done)
)

test('.calculateRecencyOfHeadline when given a headline with
  no periodEnd returns "Out of date"', (done) ->
  indicator = new Indicator()

  headlineService = new HeadlineService(indicator)
  sinon.stub(headlineService, 'getNewestHeadline', ->
    deferred = Q.defer()
    deferred.resolve {text: "OH HAI"}
    return deferred.promise
  )

  page = new Page(parent_type: 'Indicator', headline: {text: "Not reported on", value: "-"})
  sinon.stub(indicator, 'populatePage', ->
    deferred = Q.defer()
    deferred.resolve indicator.page = page
    return deferred.promise
  )

  headlineService.calculateRecencyOfHeadline().then( (recencyText) ->
    assert.strictEqual "Out of date", recencyText
    done()
  ).fail(done)
)

test("#roundHeadlineValues truncates decimals to 1 place", ->
  result = HeadlineService.roundHeadlineValues([{value: 0.123456789}])

  assert.strictEqual result[0].value, 0.1
)

test("#roundHeadlineValues when given a value which isn't a number, does nothing", ->
  result = HeadlineService.roundHeadlineValues([{value: 'hat'}])

  assert.strictEqual result[0].value, 'hat'
)

test(".parseDateInHeadlines on an indicator with xAxis 'date' (which is an integer),
  and no period specified, when given an integer date headline row,
  adds a 'periodEnd' attribute with the date one year in after the 'date' value", ->
  indicator = new Indicator(
    indicatorDefinition:
      xAxis: "date",
     fields: [
       {
         name: "date",
         type: "integer"
       }
     ]
  )

  headlineData = [
    date: 1997
  ]

  headlineService = new HeadlineService(indicator)

  convertedHeadlines = headlineService.parseDateInHeadlines(headlineData)
  convertedHeadline = convertedHeadlines[0]

  assert.strictEqual convertedHeadline.periodEnd, "31 Dec 1997",
    "Expected the periodEnd attribute to be calculated"
)

test(".parseDateInHeadlines on an indicator with no xAxis defined does no processing", ->
  indicator = new Indicator()

  headlineData = [
    date: 1997
  ]

  headlineService = new HeadlineService(indicator)

  convertedHeadline = headlineService.parseDateInHeadlines(headlineData)

  assert.ok _.isEqual(convertedHeadline, headlineData),
    "Expected the headline data not to be modified"
)

test(".parseDateInHeadlines on an indicator where the frequency is 'quarterly' 
  sets periodEnd to 3 months after the initial 'date'", ->

  indicator = new Indicator(
    indicatorDefinition:
      period: 'quarterly'
      xAxis: 'date'
      fields: [
        name: 'date'
      ]
  )

  headlineData = [
    date: "2013-04-01T01:00:00.000Z"
  ]

  headlineService = new HeadlineService(indicator)

  convertedHeadlines = headlineService.parseDateInHeadlines(headlineData)
  convertedHeadline = convertedHeadlines[0]

  assert.strictEqual convertedHeadline.periodEnd, "30 Jun 2013",
    "Expected the periodEnd to be 3 months from the period start"
)

test("#populateNarrativeRecencyOfIndicators populates the narrative recency attribute for 
the given indicators", (done)->
  indicator = new Indicator()
  indicators = [indicator]

  calculateRecencyStub = sinon.stub(HeadlineService::, 'calculateRecencyOfHeadline', ->
    Q.fcall(->
      'Up-to-date'
    )
  )
    
  HeadlineService.populateNarrativeRecencyOfIndicators(indicators).then(->

    assert.property indicator, 'narrativeRecency',
      "Expected the narrativeRecency to be populated"
    assert.strictEqual indicator.narrativeRecency, "Up-to-date",
      "Expected the narrativeRecency to be 'Up-to-date'"

    calculateRecencyStub.restore()
    done()

  ).fail((err)->
    calculateRecencyStub.restore()
    done(err)
  )
)

test("#narrativeRecencyTextIsUpToDate given text which is in the list of up to
date statuses returns true", ->
  assert.isTrue HeadlineService.narrativeRecencyTextIsUpToDate('Up to date')
)

test("#narrativeRecencyTextIsUpToDate given text which is not in the list of up to
date statuses returns false", ->
  assert.isFalse HeadlineService.narrativeRecencyTextIsUpToDate('Out of date')
)
