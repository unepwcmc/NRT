assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')
async = require('async')
Q = require('q')
sinon = require('sinon')
passportStub = require 'passport-stub'
Browser = require("zombie")

Indicator = require('../../models/indicator').model
Page = require('../../models/page').model
User = require('../../models/user').model

suite('Indicator show')

test("When given a valid indicator, I should get a 200 and see the name", (done)->
  indicatorName = "Dat test indicator"
  indicator = new Indicator(name: indicatorName)

  indicator.save( (err, indicator) ->
    request.get {
      url: helpers.appurl("/indicators/#{indicator.id}")
    }, (err, res, body) ->
      try
        assert.equal res.statusCode, 200

        assert.match body, new RegExp(".*#{indicatorName}.*")
        done()
      catch e
        done(e)
  )
)

test("When given a valid indicator, I should get a 200 and see the source", (done)->
  indicator = new Indicator(
    source: {
      name: 'Environment Agency - Abu Dhabi'
      url:  'http://www.ead.ae'
    }
  )

  theSource = 'The indicator data source'

  indicator.save( (err, indicator) ->
    request.get {
      url: helpers.appurl("/indicators/#{indicator.id}")
    }, (err, res, body) ->
      try
        assert.equal res.statusCode, 200

        assert.match body, new RegExp(".*#{indicator.source.name}.*"),
          "Expected to see the source name"
        assert.match body, new RegExp(".*#{indicator.source.url}.*"),
          "Expected to see the source URL"

        done()
      catch e
        done(e)
  )
)

test("When given a valid indicator with headlines,
  it returns 200 and shows the headline ranges", (done)->
  indicator = new Indicator()

  headlines =
    oldest: '13-11-2011'
    newest: '13-11-2013'
  IndicatorPresenter = require('../../lib/presenters/indicator')
  populateHeadlineRangeStub = sinon.stub(IndicatorPresenter::, 'populateHeadlineRangesFromHeadlines', ->
    @indicator.headlineRanges = headlines
  )

  indicator.save( (err, indicator) ->
    request.get {
      url: helpers.appurl("/indicators/#{indicator.id}")
    }, (err, res, body) ->
      try
        assert.equal res.statusCode, 200

        assert.strictEqual populateHeadlineRangeStub.callCount, 1,
          "Expected IndicatorPresenter::populateHeadlineRangesFromHeadlines to be called"

        assert.match body, new RegExp(".*#{headlines.oldest}.*")
        assert.match body, new RegExp(".*#{headlines.newest}.*")

        done()
      catch e
        done(e)
      finally
        populateHeadlineRangeStub.restore()
  )
)

test("When given a valid indicator it returns 200 and
  shows the narrative recency and if it is up to date", (done)->
  IndicatorPresenter = require('../../lib/presenters/indicator')
  indicator = new Indicator()

  narrativeRecency = 'Out-of-date'
  populateNarrativeRecencyStub = sinon.stub(IndicatorPresenter::, 'populateNarrativeRecency', ->
    Q.fcall(=> @indicator.narrativeRecency = narrativeRecency)
  )

  populateIsUpToDateStub = sinon.stub(IndicatorPresenter::, 'populateIsUpToDate', ->
    Q.fcall(=> @indicator.isUpToDate = false)
  )

  indicator.save( (err, indicator) ->
    request.get {
      url: helpers.appurl("/indicators/#{indicator.id}")
    }, (err, res, body) ->

      try
        assert.equal res.statusCode, 200

        assert.strictEqual populateNarrativeRecencyStub.callCount, 1,
          "Expected IndicatorPresenter::populateNarrativeRecency to be called"

        assert.strictEqual populateIsUpToDateStub.callCount, 1,
          "Expected IndicatorPresenter::populateIsUpToDate to be called"

        assert.match body, new RegExp(".*#{narrativeRecency}.*"),
          "Expected the page to include the narrative recency state"

        assert.match body, new RegExp(".*\.icon-warning-sign"),
          "Expected the warnign sign to show, as the indicator is out of date"

        done()
      catch e
        done(e)
      finally
        populateNarrativeRecencyStub.restore()
        populateIsUpToDateStub.restore()
  )
)

test("/indicators/:id When given a valid indicator it returns 200 and
  shows the correct DPSIR content", (done)->
  libxmljs = require("libxmljs")

  indicator = new Indicator(
    dpsir:
      driver: true
      pressure: false
  )

  indicator.save( (err) ->
    request.get {
      url: helpers.appurl("/indicators/#{indicator.id}")
    }, (err, res, body) ->

      try
        assert.equal res.statusCode, 200

        html = libxmljs.parseHtml(body)

        dpsirListEl = html.get("//ul[@class='dpsir']")
        assert.isDefined dpsirListEl, "Expected to see a UL containing the DPSIR list"

        activeDPSIRs = dpsirListEl.find("li[@class='active']")
        assert.lengthOf activeDPSIRs, 1,
          "Expected one of DPSIR to be active"

        assert.strictEqual activeDPSIRs[0].text(), "D",
          "Expected the active DPSIR to be Driver"

        done()
      catch e
        done(e)
  )
)

test("When given an indicator that doesn't exist, I should get a 404 response", (done)->
  indicatorId = new Indicator().id

  request.get {
    url: helpers.appurl("/indicators/#{indicatorId}")
  }, (err, res, body) ->
    if err?
      done(err)
    try
      assert.equal res.statusCode, 404
      done()
    catch e
      done(e)
)

test("GET /:id/draft clones the Indicator's Page and renders the indicator", (done) ->
  theIndicator = originalPage = null

  user = new User(email: "hats", password: "boats")
  passportStub.login user

  helpers.createIndicatorModels([
    name: 'An indicator'
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

    try
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

  ).catch( (err) ->
    done(err)
  )
)

test("GET /:id/draft redirects back if the user is not logged in", (done) ->
  theIndicator = originalPage = null

  helpers.createIndicatorModels([
    name: 'An indicator'
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

    assert.notMatch body, new RegExp(".*An indicator.*")

    done()

  ).catch(done)
)

test("GET /:id/discard_draft discards all drafts and renders the published version", (done) ->
  theIndicator = originalPage = draftPage =null

  user = new User(email: "hats", password: "boats")
  passportStub.login user

  helpers.createIndicatorModels([
    name: 'An indicator'
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
        url: helpers.appurl("indicators/#{theIndicator.id}/discard_draft")
      }
    )

  ).spread( (res, body) ->

    assert.equal res.statusCode, 200

    assert.match body, new RegExp(".*An indicator.*")

    Q.nsend(
      Page.find(parent_id: theIndicator.id),
      'exec'
    )

  ).then( (pages) ->

    assert.lengthOf pages, 1

    done()

  ).catch(done)
)

test("GET /:id/discard_draft redirects back if the user is not logged in", (done) ->
  theIndicator = originalPage = draftPage = null

  helpers.createIndicatorModels([
    name: 'An indicator'
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
        url: helpers.appurl("indicators/#{theIndicator.id}/discard_draft")
      }
    )

  ).spread( (res, body) ->

    assert.equal res.statusCode, 200

    assert.notMatch body, new RegExp(".*An indicator.*")

    done()

  ).catch(done)
)

test('GET /:id/publish publishes the current draft and makes it publicly
  viewable', (done) ->
  theIndicator = originalPage = draftPage = null

  user = new User(email: "hats", password: "boats")
  passportStub.login user

  helpers.createIndicatorModels([
    name: 'An indicator'
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

  ).catch(done)
)

test('GET /:id/publish redirects back if the user is not logged in', (done) ->
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

    assert.notMatch body, new RegExp(".*An indicator.*")

    done()

  ).catch(done)
)

test('GET /indicators/new returns a new indicator form', (done)->
  browser = new Browser()
  browser.runScripts = false

  browser.visit(
    helpers.appurl('/indicators/new')
  ).then(->
    assert.equal browser.statusCode, 200,
      "Expected the request to succeed"

    form = browser.query('form[action="/indicators/import_gdoc"]')
    assert.isNotNull form, "Expected to see a form with the correct action"

    assert.isNotNull browser.query('input[name="spreadsheetKey"]', form),
      "Expected to see a spreadsheetKey input element"

    done()
  ).catch(done)
)