assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')
async = require('async')
Q = require('q')

Indicator = require('../../models/indicator').model
Page = require('../../models/page').model

suite('Indicator show')

test("When given a valid indicator, I should get a 200 and see the title", (done)->
  indicatorTitle = "Dat test indicator"
  indicator = new Indicator(title: indicatorTitle)

  indicator.save( (err, indicator) ->
    request.get {
      url: helpers.appurl("/indicators/#{indicator.id}")
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      assert.match body, new RegExp(".*#{indicatorTitle}.*")
      done()
  )
)

test("When given an indicator that doesn't exist, I should get a 404 response", (done)->
  indicatorId = new Indicator().id

  request.get {
    url: helpers.appurl("/indicators/#{indicatorId}")
  }, (err, res, body) ->
    if err?
      console.error err
      throw new Error(err)
    assert.equal res.statusCode, 404

    done()
)

test("GET /:id/draft clones the Indicator's Page and renders the indicator", (done) ->
  theIndicator = originalPage = null

  helpers.createIndicatorModels([
    title: 'An indicator'
  ]).then( (indicators) ->

    theIndicator = indicators[0]

    helpers.createPage(
      title: 'A page'
      parent_type: 'Indicator'
      parent_id: theIndicator.id
    )

  ).then( (page) ->

    originalPage = page

    Q.nfcall(
      request.get, {
        url: helpers.appurl("indicators/#{theIndicator.id}/draft")
      }
    )

  ).spread( (res, body) ->

    assert.equal res.statusCode, 200

    assert.match body, new RegExp(".*An indicator.*")

    Q.nsend(
      Page.find(parent_id: theIndicator.id, is_draft: true),
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

test('GET /:id/publish publishes the current draft and makes it publicly
  viewable', (done) ->
  theIndicator = originalPage = draftPage = null

  helpers.createIndicatorModels([
    title: 'An indicator'
  ]).then( (indicators) ->

    theIndicator = indicators[0]

    helpers.createPage(
      title: 'A page'
      parent_type: 'Indicator'
      parent_id: theIndicator.id
    )

  ).then( (page) ->
    originalPage = page

    page.createDraftClone()
  ).then( (clonedPage) ->
    draftPage = clonedPage

    Q.nfcall(
      request.get, {
        url: helpers.appurl("indicators/#{theIndicator.id}/publish")
      }
    )
  ).spread( (res, body) ->

    assert.equal res.statusCode, 200

    assert.match body, new RegExp(".*An indicator.*")

    Q.nsend(
      Page.find(parent_id: theIndicator.id, is_draft: false),
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
      Page.find(parent_id: theIndicator.id, is_draft: true),
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
