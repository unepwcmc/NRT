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

suite('Theme Controller')

test(".index given DPSIR parameters excluding everything except drivers, I should only see indicators which are drivers")
###
(done) ->
  theme = new Theme(title: 'test theme')
  driverIndicator = new Indicator(
    theme: theme._id
    dpsir: driver: true
  )
  pressureIndicator = new Indicator(
    theme: theme._id
    dpsir: pressure: true
  )

  Q.nsend(
    theme, 'save'
  ).then(->
    Q.nsend(driverIndicator, 'save')
  ).then(->
    Q.nsend(pressureIndicator, 'save')
  ).then(->
    stubReq =
      params:
        dpsir:
          driver: true

    stubRes = {
      send: (code, body) ->
        done(new Error("Expected res.send not to be called, but called with #{code}: #{body}"))
      render: (templateName, data) ->
        try
          console.log data
          assert.lengthOf data.themes, 1,
            "Only expected our one theme to be returned"

          assert.lengthOf data.themes[0].indicators, 1,
            "Only expected one indicator (the driver) to be returned"

          indicator = data.themes[0].indicators[0]
          assert.deepEqual indicator, driverIndicator,
            "Expected the returned indicator to the the driver"
        catch err
          done(err)
    }

    ThemeController.index(stubReq, stubRes)

  ).fail(done)
)
###


test(".index only returns primary indicators", (done) ->
  theme = new Theme(title: 'test theme')
  primaryIndicator = new Indicator(
    theme: theme._id
    type: 'esri'
  )
  externalIndicator = new Indicator(
    theme: theme._id
    dpsir: pressure: true
    type: 'something else'
  )

  Q.nsend(
    theme, 'save'
  ).then(->
    Q.nsend(primaryIndicator, 'save')
  ).then(->
    Q.nsend(externalIndicator, 'save')
  ).then(->
    stubReq = {}

    stubRes = {
      send: (code, body) ->
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

          done()
        catch err
          done(err)
    }

    ThemeController.index(stubReq, stubRes)

  ).fail(done)
)

test(".index only indicators with data", (done) ->
  theme = new Theme(title: 'test theme')
  indicator1 = new Indicator(theme: theme._id)
  indicator2 = new Indicator(theme: theme._id)

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

    ThemeController.index(stubReq, stubRes)

  ).fail((err)->
    filterIndicatorsWithDataStub.restore()
    done(err)
  )
)
