assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')
async = require('async')
Q = require('q')
Promise = require('bluebird')

Theme = require('../../models/theme').model
Page = require('../../models/page').model

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

test("GET /:id/draft clones the Theme's Page and renders the theme", (done) ->
  theTheme = originalPage = null

  helpers.createTheme(
    title: 'An theme'
  ).then( (theme) ->

    theTheme = theme

    helpers.createPage(
      title: 'A page'
      parent_type: 'Theme'
      parent_id: theTheme.id
    )

  ).then( (page) ->

    originalPage = page

    Q.nfcall(
      request.get, {
        url: helpers.appurl("themes/#{theTheme.id}/draft")
      }
    )

  ).spread( (res, body) ->

    assert.equal res.statusCode, 200

    assert.match body, new RegExp(".*An theme.*")

    Q.nsend(
      Page.find(parent_id: theTheme.id, is_draft: true),
      'exec'
    )

  ).then( (clonedPage) ->

    assert.isNotNull clonedPage, 'Expected a draft version of the Page'
    assert.notStrictEqual(
      clonedPage.id,
      originalPage.id,
      "Expected clonedPage to have a different ID to the original Page"
    )

    done()

  ).catch( (err) ->
    console.error err
    throw err
  )
)

test("GET /:id/draft populates and shows theme's indicators", (done) ->
  theTheme = theIndicator = null
  expectedText = "Very bad"

  helpers.createTheme(
    title: 'An theme'
  ).then( (theme) ->

    theTheme = theme
    Promise.promisify(helpers.createIndicator, helpers)(
      name: "An indicator"
      theme: theme._id
    )
  ).then( (indicator) ->
    theIndicator = indicator
    helpers.createIndicatorData(
      indicator: indicator._id
      data: [{
        value: 100,
        year: 2013,
        text: "Good"
      }, {
        value: 10,
        year: 2014,
        text: expectedText
      }]
    )
  ).then( (indicatorData) ->
    helpers.createPage(
      parent_id: theIndicator._id
      parent_type: "Indicator"
    )
  ).then( (page) ->
    Promise.promisify(request.get, request)({
      url: helpers.appurl("themes/#{theTheme.id}/draft")
    })
  ).spread( (res, body) ->
    assert.match body, new RegExp(".*#{expectedText}.*")
    done()
  ).catch(done)
)

test('GET /:id/publish publishes the current draft and makes it publicly viewable', (done) ->
  theTheme = originalPage = draftPage = null

  helpers.createTheme(
    title: 'An theme'
  ).then( (theme) ->

    theTheme = theme

    helpers.createPage(
      title: 'A page'
      parent_type: 'Theme'
      parent_id: theTheme.id
    )

  ).then( (page) ->
    originalPage = page

    page.createDraftClone()
  ).then( (clonedPage) ->
    draftPage = clonedPage

    Q.nfcall(
      request.get, {
        url: helpers.appurl("themes/#{theTheme.id}/publish")
      }
    )
  ).spread( (res, body) ->

    assert.equal res.statusCode, 200

    assert.match body, new RegExp(".*An theme.*")

    Q.nsend(
      Page.find(parent_id: theTheme.id, is_draft: false),
      'exec'
    )

  ).then( (publishedPage) ->

    assert.isNotNull publishedPage, 'Expected a published version of the Page'
    assert.notStrictEqual(
      publishedPage.id,
      originalPage.id,
      "Expected published page to have a different ID from the original page"
    )

    Q.nsend(
      Page.find(parent_id: theTheme.id, is_draft: true),
      'exec'
    )
  ).then( (draftPages) ->

    assert.lengthOf draftPages, 0, "Expected no draft pages to exist"

    done()

  ).catch( (err) ->
    console.error err
    throw err
  )
)

test("GET /:id/discard_draft discards all drafts and renders the published version", (done) ->
  theTheme = originalPage = draftPage =null

  helpers.createTheme(
    title: 'An theme'
  ).then( (theme) ->

    theTheme = theme

    helpers.createPage(
      title: 'A page'
      parent_type: 'Theme'
      parent_id: theTheme.id
    )

  ).then( (page) ->
    originalPage = page

    page.createDraftClone()
  ).then( (clonedPage) ->
    draftPage = clonedPage

    Q.nfcall(
      request.get, {
        url: helpers.appurl("themes/#{theTheme.id}/discard_draft")
      }
    )

  ).spread( (res, body) ->

    assert.equal res.statusCode, 200

    assert.match body, new RegExp(".*An theme.*")

    Q.nsend(
      Page.find(parent_id: theTheme.id),
      'exec'
    )

  ).then( (pages) ->

    assert.lengthOf pages, 1

    done()

  ).catch( (err) ->
    console.error err
    throw err
  )
)

test("show all indicators with some data in theme page", (done) ->
  themeTitle = "Dat test theme"
  theme = new Theme(title: themeTitle)
  theIndicator = null

  Promise.promisify(theme.save, theme)().then( ->
    Promise.promisify(helpers.createIndicator, helpers)(
      name: 'An indicator'
      theme: theme._id
    )
  ).then((indicator) ->
    theIndicator = indicator

    helpers.createIndicatorData({
      indicator: theIndicator.id
    })
  ).then((indicatorData) ->
    Promise.promisify(request.get, request)({
      url: helpers.appurl("/themes/#{theme.id}")
    })
  ).spread((res, body) ->
    assert.equal res.statusCode, 200

    assert.match body, new RegExp(".*#{themeTitle}.*")
    assert.match body, new RegExp(".*#{theIndicator.name}.*")
    done()
  ).catch(done)
)
