assert = require('chai').assert
helpers = require '../helpers'
async = require('async')
Q = require('q')
_ = require('underscore')
sinon = require('sinon')
Theme = require('../../models/theme').model
Indicator = require('../../models/indicator').model
ThemeController = require('../../controllers/themes')

suite('Theme Controller')

test(".index given DPSIR parameters excluding everything except drivers, I should only see indicators which are drivers", (done) ->
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
