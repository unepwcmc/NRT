assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
async = require('async')
Q = require('q')
url = require('url')
_ = require('underscore')
sinon = require('sinon')
libxmljs = require("libxmljs")

Theme = require('../../models/theme').model

suite('Theme index')

test("With a series of themes and indicators, I should see their titles", (done) ->
  theme1 = new Theme({
    title: 'Theme 1'
  })
  theme1.indicators = [{
    title: "I am an indicator of theme 1"
    narrativeRecency: "Out of date"
    type: 'esri'
  }]
  theme2 = new Theme({
    title: 'Theme 2'
  })
  theme2.indicators = [{
    title: "theme 2 indicator"
    narrativeRecency: "Out of date"
    type: 'esri'
  }]
  themes = [theme1, theme2]

  getFatThemesStub = sinon.stub(Theme, 'find', (callback) ->
    callback(null, themes)
  )

  Q.nsend(
    request, 'get', {
      url: helpers.appurl('/themes')
    }
  ).spread((res, body) ->

    assert.equal res.statusCode, 200

    for theme in themes
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

test('when given no parameters it shows all DPSIR enabled', (done) ->
  Q.nsend(
    request, 'get', {
      url: helpers.appurl('/themes')
    }
  ).spread((res, body) ->

    assert.equal res.statusCode, 200

    html = libxmljs.parseHtml(body)

    dpsirListEl = html.get("//aside//ul[@class='dpsir']")

    activeDPSIRs = dpsirListEl.find("li[@class='active']")
    assert.lengthOf activeDPSIRs, 5,
      "Expected all of DPSIR to be enabled"

    done()
  ).fail(done)
)

test('when given DPSIR parameters it only shows the correct DPSIRs enabled', (done) ->
  Q.nsend(
    request, 'get', {
      url: helpers.appurl('/themes')
      qs: dpsir:
        driver: true
        pressure: false
    }
  ).spread((res, body) ->

    assert.equal res.statusCode, 200

    html = libxmljs.parseHtml(body)

    dpsirListEl = html.get("//aside//ul[@class='dpsir']")

    activeDPSIRs = dpsirListEl.find("li[@class='active']")
    assert.lengthOf activeDPSIRs, 1,
      "Expected only one DPSIR filter to be enabled"

    assert.strictEqual activeDPSIRs[0].text(), "D",
      "Expected the active DPSIR to be Driver"

    done()
  ).fail(done)
)
