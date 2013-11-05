assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')
async = require('async')
sinon = require('sinon')
Q = require('q')

suite('API - Theme')

Theme = require('../../models/theme').model
Page = require('../../models/page').model

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

test("GET /themes/:id/fat returns the theme with its nested page ", (done) ->
  theme = null
  nestedPage = new Page()
  toObjectWithNestedPageStub = sinon.stub(Theme::, 'toObjectWithNestedPage', ->
    Q.fcall(=>
      object = @toObject()
      object.page = nestedPage
      object
    )
  )

  helpers.createThemesFromAttributes().then( (createdTheme) ->
    theme = createdTheme

    Q.nfcall(
      request.get, {
        url: helpers.appurl("api/themes/#{theme._id}/fat")
        json: true
      }
    )
  ).spread( (res, body) ->

    try
      assert.equal res.statusCode, 200,
        "Expected the query to succeed"

      assert.match res.headers['content-type'], /.*json.*/,
        "Expected the response to be JSON"

      reloadedTheme = body
      assert.equal reloadedTheme._id, theme.id,
        "Expected the query to return the correct theme"

      assert.property reloadedTheme, 'page',
        "Expected the page attribute to be populated"

      assert.ok toObjectWithNestedPageStub.calledOnce,
        "Expected theme.toObjectWithNestedPage to be called"

      assert.equal reloadedTheme.page._id, nestedPage.id,
        "Expected the page attribute to be the right page"

      done()
    catch err
      done(err)
    finally
      toObjectWithNestedPageStub.restore()

  ).fail( (err) ->
    toObjectWithNestedPageStub.restore()
    done(err)
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
