assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
async = require('async')
url = require('url')
_ = require('underscore')

suite('Theme index')

test("With a series of themes and indicators, I should see their titles", (done) ->


  themeAttributes = [{
    title: 'Theme 1'
    externalId: 1
  },{
    title: 'Theme 2'
    externalId: 2
  }]

  helpers.createThemesFromAttributes(themeAttributes, (err, themes) ->
    if err
      console.error err
      throw new Error(err)
    
    indicatorAttributes = [{
      title: "I am an indicator of theme 1"
      theme: themes[0].externalId
    },{
      title: "theme 2 indicator"
      theme: themes[1].externalId
    }]

    helpers.createIndicatorModels(indicatorAttributes).success((indicators)->

      request.get {
        url: helpers.appurl('/themes')
      }, (err, res, body) ->
        assert.equal res.statusCode, 200

        for theme in themes
          assert.match body, new RegExp(".*#{theme.title}.*")

        for indicator in indicators
          assert.match body, new RegExp(".*#{indicator.title}.*")

        done()
      ).error((error) ->
        console.error error
        throw "Unable to create themes"
      )

    )
  )