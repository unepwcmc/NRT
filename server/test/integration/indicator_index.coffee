assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
async = require('async')
url = require('url')
Q = require('q')
_ = require('underscore')

suite('Indicator index')

test("With a series of indicators, I should see their titles", (done) ->
  theThemes = theIndicators = null
  themeAttributes = [{
    title: 'Theme 1'
  },{
    title: 'Theme 2'
  }]

  helpers.createThemesFromAttributes(
    themeAttributes
  ).then( (themes) ->
    theThemes = themes

    indicatorAttributes = [{
      title: "I am an indicator of theme 1"
      theme: themes[0]._id
    },{
      title: "theme 2 indicator"
      theme: themes[1]._id
    }]

    helpers.createIndicatorModels(
      indicatorAttributes
    )
  ).then( (indicators)->
    theIndicators = indicators
    deferred = Q.defer()

    # create indicator data
    createIndicatorData = (indicator, callback) ->
      helpers.createIndicatorData({
        indicator: indicator
        data: [{}]
      }, ->
        callback()
      )

    async.each theIndicators, createIndicatorData, (err) ->
      if err?
        deferred.reject(err)
      else
        deferred.resolve()

    return deferred.promise
  ).then( ->
    request.get {
      url: helpers.appurl('/indicators')
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      for theme in theThemes
        assert.match body, new RegExp(".*#{theme.title}.*")

      for indicator in theIndicators
        assert.match body, new RegExp(".*#{indicator.title}.*")

      done()
  ).fail( (err) ->
    console.err err
  )
)
