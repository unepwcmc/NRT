assert = require('chai').assert
helpers = require '../helpers'
async = require('async')
Q = require('q')
_ = require('underscore')
sinon = require('sinon')
Theme = require('../../models/theme').model
Indicator = require('../../models/indicator').model
ThemeController = require('../../controllers/themes')
ThemePresenter = require('../../lib/presenters/theme')
AppConfig = require('../../initializers/config')


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
  filterIndicatorsWithDataStub = sinon.stub(ThemePresenter::, 'filterIndicatorsWithData', ->
    Q.fcall(->)
  )

  Q.nsend(
    theme, 'save'
  ).then(->
    Q.nsend(driverIndicator, 'save')
  ).then(->
    Q.nsend(pressureIndicator, 'save')
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

  ).fail( (err) ->
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
  filterIndicatorsWithDataStub = sinon.stub(ThemePresenter::, 'filterIndicatorsWithData', ->
    Q.fcall(->)
  )

  Q.nsend(
    theme, 'save'
  ).then(->
    Q.nsend(driverIndicator, 'save')
  ).then(->
    Q.nsend(pressureIndicator, 'save')
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

  ).fail( (err) ->
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

  Q.nsend(
    theme, 'save'
  ).then(->
    Q.nsend(primaryIndicator, 'save')
  ).then(->
    Q.nsend(externalIndicator, 'save')
  ).then(->
    hasDataStub = sinon.stub(Indicator::, 'hasData', -> Q.fcall(->true))

    stubReq = {}

    stubRes = {
      send: (code, body) ->
        hasDataStub.restore()
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

          hasDataStub.restore()
          done()
        catch err
          hasDataStub.restore()
          done(err)
    }

    try
      ThemeController.index(stubReq, stubRes)
    catch
      hasDataStub.restore()
      done(err)

  ).fail( (err) ->
    hasDataStub.restore()
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

  filterIndicatorsWithDataStub = sinon.stub(ThemePresenter::, 'filterIndicatorsWithData', ->
    @theme.indicators = [@theme.indicators[0]]
    Q.fcall(->)
  )

  Q.nsend(
    theme, 'save'
  ).then(->
    Q.nsend(indicator1, 'save')
  ).then(->
    Q.nsend(indicator2, 'save')
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

  ).fail((err)->
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

  # Stub to prevent filtering of indicators
  filterIndicatorsWithDataStub = sinon.stub(ThemePresenter::, 'filterIndicatorsWithData', ->
    Q.fcall(->)
  )

  Q.nsend(
    theme, 'save'
  ).then(->
    Q.nsend(driverIndicator, 'save')
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
          console.log data.dpsir

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

  ).fail((err)->
    filterIndicatorsWithDataStub.restore()
    done(err)
  )
)
