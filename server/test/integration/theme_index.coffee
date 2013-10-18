assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
async = require('async')
Q = require('q')
url = require('url')
_ = require('underscore')
sinon = require('sinon')
Theme = require('../../models/theme').model

suite('Theme index')

test("With a series of themes and indicators, I should see their titles", (done) ->
  themeAttributes = [{
    title: 'Theme 1'
    indicators: [{
      title: "I am an indicator of theme 1"
      narrativeRecency: "Out of date"
    }]
  },{
    title: 'Theme 2'
    indicators: [{
      title: "theme 2 indicator"
      narrativeRecency: "Out of date"
    }]
  }]

  getFatThemesStub = sinon.stub(Theme, 'getFatThemes', (callback) ->
    callback(null, themeAttributes)
  )

  Q.nsend(
    request, 'get', {
      url: helpers.appurl('/themes')
    }
  ).spread((res, body) ->

    assert.equal res.statusCode, 200

    for theme in themeAttributes
      assert.match body, new RegExp(".*#{theme.title}.*")

      for indicator in theme.indicators
        assert.match body, new RegExp(".*#{indicator.title}.*")

    done()

  ).fail( (err) ->
    console.error err

    throw new Error(err)
  ).finally(->
    getFatThemesStub.restore()
  )
)
