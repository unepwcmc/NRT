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

test("GET /:id/draft clones the Theme's Page and renders the theme", (done) ->
  theTheme = originalPage = null

  helpers.createTheme(
    title: 'An theme'
  ).then( (themes) ->

    theTheme = themes[0]

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

  ).fail( (err) ->
    console.error err
    throw err
  )
)

test('GET /:id/publish publishes the current draft and makes it publicly viewable', (done) ->
  theTheme = originalPage = draftPage = null

  helpers.createTheme(
    title: 'An theme'
  ).then( (themes) ->

    theTheme = themes[0]

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

  ).fail( (err) ->
    console.error err
    throw err
  )
)
