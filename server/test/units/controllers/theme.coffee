assert = require('chai').assert
helpers = require '../../helpers'
async = require('async')
Promise = require('bluebird')
Q = require('q')
_ = require('underscore')
sinon = require('sinon')

Theme = require('../../../models/theme').model
Indicator = require('../../../models/indicator').model
ThemeController = require('../../../controllers/themes')
ThemePresenter = require('../../../lib/presenters/theme')
AppConfig = require('../../../initializers/config')


suite('Theme Controller')

test(".index given no DPSIR parameters it returns all indicators
 and an DPSIR object with everything enabled", (done) ->
  theme = new Theme(title: 'test theme')

  driverIndicator = new Indicator(
    theme: theme._id
    dpsir: driver: true
    primary: true
  )
  pressureIndicator = new Indicator(
    theme: theme._id
    dpsir: pressure: true
    primary: true
  )

  # Don't filter indicators
  filterIndicatorsWithDataStub = sinon.stub(Indicator, 'findWhereIndicatorHasData', ->
    Promise.resolve([driverIndicator, pressureIndicator])
  )

  Promise.join(
    Promise.promisify(theme.save, theme)(),
    Promise.promisify(driverIndicator.save, driverIndicator)(),
    Promise.promisify(pressureIndicator.save, pressureIndicator)()
  ).then(->

    stubReq = {}
    stubRes = {
      send: (code, body) ->
        filterIndicatorsWithDataStub.restore()
        done(new Error("Expected res.send not to be called, but called with #{code}: #{body}"))
      render: (templateName, data) ->
        try
          assert.lengthOf data.themes, 1,
            "Only expected our one theme to be returned"

          assert.lengthOf data.themes[0].indicators, 2,
            "Only expected all indicators to be returned"

          expectedDPSIR =
            driver: true
            pressure: true
            state: true
            impact: true
            response: true
          assert.deepEqual data.dpsir, expectedDPSIR,
            "Expected the controller to return a DPSIR object with everything enabled"

          filterIndicatorsWithDataStub.restore()
          done()
        catch err
          filterIndicatorsWithDataStub.restore()
          done(err)
    }

    try
      ThemeController.index(stubReq, stubRes)
    catch err
      filterIndicatorsWithDataStub.restore()
      done(err)

  ).catch( (err) ->
    filterIndicatorsWithDataStub.restore()
    done(err)
  )
)

test(".index given DPSIR parameters excluding everything except drivers,
  it only returns  indicators which are drivers", (done) ->
  theme = new Theme(title: 'test theme')
  driverIndicator = new Indicator(
    theme: theme._id
    dpsir: driver: true
    primary: true
  )
  pressureIndicator = new Indicator(
    theme: theme._id
    dpsir: pressure: true
    primary: true
  )

  # Don't filter indicators
  filterIndicatorsWithDataStub = sinon.stub(Indicator, 'findWhereIndicatorHasData', ->
    Promise.resolve([driverIndicator])
  )

  Promise.join(
    Promise.promisify(theme.save, theme)(),
    Promise.promisify(driverIndicator.save, driverIndicator)(),
    Promise.promisify(pressureIndicator.save, pressureIndicator)()
  ).then(->

    stubReq =
      query:
        dpsir:
          driver: true

    stubRes = {
      send: (code, body) ->
        filterIndicatorsWithDataStub.restore()
        done(new Error("Expected res.send not to be called, but called with #{code}: #{body}"))
      render: (templateName, data) ->
        try
          assert.lengthOf data.themes, 1,
            "Only expected our one theme to be returned"

          assert.lengthOf data.themes[0].indicators, 1,
            "Only expected one indicator (the driver) to be returned"

          indicator = data.themes[0].indicators[0]
          assert.strictEqual indicator._id.toString(), driverIndicator.id,
            "Expected the returned indicator to be the driver"

          expectedFilters = {theme: theme._id, '$or': ['dpsir.driver': true], primary: true}
          filterIndicatorsArgs = filterIndicatorsWithDataStub.getCall(0).args
          assert.deepEqual expectedFilters, filterIndicatorsArgs[0],
            "Expected findIndicatorWithData to be called with correct filters"

          filterIndicatorsWithDataStub.restore()
          done()
        catch err
          filterIndicatorsWithDataStub.restore()
          done(err)
    }

    try
      ThemeController.index(stubReq, stubRes)
    catch err
      filterIndicatorsWithDataStub.restore()
      done(err)

  ).catch( (err) ->
    filterIndicatorsWithDataStub.restore()
    done(err)
  )
)

test(".index only returns primary indicators", (done) ->
  theme = new Theme(title: 'test theme')
  primaryIndicator = new Indicator(
    theme: theme._id
    primary: true
  )
  externalIndicator = new Indicator(
    theme: theme._id
    dpsir: pressure: true
    primary: false
  )

  # Don't filter indicators
  filterIndicatorsWithDataStub = sinon.stub(Indicator, 'findWhereIndicatorHasData', ->
    Promise.resolve([primaryIndicator])
  )

  Promise.join(
    Promise.promisify(theme.save, theme)(),
    Promise.promisify(primaryIndicator.save, primaryIndicator)(),
    Promise.promisify(externalIndicator.save, externalIndicator)()
  ).spread((save1, save2, save3)->

    stubReq = {}

    stubRes = {
      send: (code, body) ->
        filterIndicatorsWithDataStub.restore()
        done(new Error("Expected res.send not to be called, but called with #{code}: #{body}"))
      render: (templateName, data) ->
        try
          assert.lengthOf data.themes, 1,
            "Only expected our one theme to be returned"

          assert.lengthOf data.themes[0].indicators, 1,
            "Only expected one indicator (the primary indicator) to be returned"

          indicator = data.themes[0].indicators[0]
          assert.strictEqual indicator._id.toString(), primaryIndicator.id,
            "Expected the returned indicator to be the primary indicator"

          filterIndicatorsWithDataStub.restore()
          done()
        catch err
          filterIndicatorsWithDataStub.restore()
          done(err)
    }

    try
      ThemeController.index(stubReq, stubRes)
    catch
      filterIndicatorsWithDataStub.restore()
      done(err)

  ).catch( (err) ->
    filterIndicatorsWithDataStub.restore()
    done(err)
  )
)

test(".index only indicators with data", (done) ->
  theme = new Theme(title: 'test theme')
  indicator1 = new Indicator(
    theme: theme._id, primary: true
  )
  indicator2 = new Indicator(
    theme: theme._id, primary: true
  )

  # Don't filter indicators
  filterIndicatorsWithDataStub = sinon.stub(Indicator, 'findWhereIndicatorHasData', ->
    Promise.resolve([indicator1])
  )

  Promise.join(
    Promise.promisify(theme.save, theme)(),
    Promise.promisify(indicator1.save, indicator1)(),
    Promise.promisify(indicator2.save, indicator2)()
  ).then(->
    stubReq = {}

    stubRes = {
      send: (code, body) ->
        filterIndicatorsWithDataStub.restore()
        done(new Error("Expected res.send not to be called, but called with #{code}: #{body}"))
      render: (templateName, data) ->
        try
          assert.strictEqual filterIndicatorsWithDataStub.callCount, 1,
            "Expected ThemePresenter::filterIndicatorsWithData to be called once"

          assert.lengthOf data.themes, 1, "Only expected one theme to be returned"
          assert.lengthOf data.themes[0].indicators, 1,
            "Expected the theme's indicators to be filtered to only element"

          filterIndicatorsWithDataStub.restore()
          done()
        catch err
          filterIndicatorsWithDataStub.restore()
          done(err)
    }

    try
      ThemeController.index(stubReq, stubRes)
    catch err
      filterIndicatorsWithDataStub.restore()
      done(err)

  ).catch((err)->
    filterIndicatorsWithDataStub.restore()
    done(err)
  )
)

test(".index given DPSIR parameters driver:false, the clause should be ignored", (done) ->
  theme = new Theme(title: 'test theme')
  driverIndicator = new Indicator(
    theme: theme._id,
    primary: true
    dpsir: driver: true
  )

  # Don't filter indicators
  filterIndicatorsWithDataStub = sinon.stub(Indicator, 'findWhereIndicatorHasData', ->
    Promise.resolve([driverIndicator])
  )

  Promise.join(
    Promise.promisify(theme.save, theme)(),
    Promise.promisify(driverIndicator.save, driverIndicator)()
  ).then(->
    stubReq = {
      query:
        dpsir:
          driver: false
    }

    stubRes = {
      send: (code, body) ->
        filterIndicatorsWithDataStub.restore()
        done(new Error("Expected res.send not to be called, but called with #{code}: #{body}"))
      render: (templateName, data) ->
        try
          assert.lengthOf data.themes, 1, "Expected one theme to be returned"
          assert.lengthOf data.themes[0].indicators, 1,
            "Expected the one driver indicator to be returned, regardless of the filter"

          assert.strictEqual(
            data.themes[0].indicators[0]._id.toString(),
            driverIndicator._id.toString(),
            "Expected the driver indicator to be returned, regardless of the filter"
          )

          filterIndicatorsWithDataStub.restore()
          done()
        catch err
          filterIndicatorsWithDataStub.restore()
          done(err)
    }

    try
      ThemeController.index(stubReq, stubRes)
    catch err
      filterIndicatorsWithDataStub.restore()
      done(err)

  ).catch((err)->
    filterIndicatorsWithDataStub.restore()
    done(err)
  )
)
