assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')
async = require('async')

suite('API - Theme')

Theme = require('../../models/theme').model

test("GET show", (done) ->
  helpers.createTheme().then( (theme) ->
    request.get({
      url: helpers.appurl("api/themes/#{theme.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      reloadedTheme = body
      assert.equal reloadedTheme._id, theme.id
      assert.equal reloadedTheme.content, theme.content

      done()
    )
  ).fail( (err) ->
    console.error err
    throw new Error(err)
  )
)

test('GET index', (done) ->
  helpers.createThemesFromAttributes([{},{}]).then( (themes) ->
    request.get({
      url: helpers.appurl("api/themes")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      themeJson = body

      assert.equal themeJson.length, themes.length
      jsonTitles = _.map(themeJson, (theme)->
        theme.title
      )
      themeTitles = _.map(themes, (theme)->
        theme.title
      )

      assert.deepEqual jsonTitles, themeTitles
      done()
    )
  ).fail((err) ->
    console.error err
    throw new Error(err)
  )
)
