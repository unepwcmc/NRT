assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')
async = require('async')

Theme = require('../../models/theme').model

suite('Theme show')

test("When given a valid theme, I should get a 200 and see the title", (done)->
  themeTitle = "Dat test theme"
  theme = new Theme(title: themeTitle)

  theme.save( (err, theme) ->
    request.get {
      url: helpers.appurl("/themes/#{theme.id}")
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      assert.match body, new RegExp(".*#{themeTitle}.*")
      done()
  )
)

