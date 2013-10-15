assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
async = require('async')
Q = require('q')
url = require('url')
_ = require('underscore')

suite('Theme index')

test("With a series of themes and indicators, I should see their titles", (done) ->
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
      url: helpers.appurl('/themes')
    }, (err, res, body) ->

      assert.equal res.statusCode, 200

      for theme in theThemes
        assert.match body, new RegExp(".*#{theme.title}.*")

      for indicator in theIndicators
        assert.match body, new RegExp(".*#{indicator.title}.*")

      done()
  ).fail((error) ->
    console.error error
    throw "Unable to create themes"
  ).fail( (err) ->
    console.error err
    throw new Error(err)
  )
)
