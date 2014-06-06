assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
Promise = require('bluebird')
sinon = require("sinon")

Indicator = require('../../models/indicator').model
GDocIndicatorImporter = require('../../lib/gdoc_indicator_importer')

suite('Indicator Admin')

test("User can visit the admin page, click 'Add Indicator', enter a google
 spreadsheet key and import a new indicator", (done)->
  Browser = require("zombie")

  importedIndicator =
    name: "Spiffing new indiator"

  gdocImportStub = sinon.stub(GDocIndicatorImporter, 'import', ->
    Promise.promisify(Indicator.create, Indicator)(importedIndicator)
  )

  browser = new Browser()

  spreadsheetKey = '43289432'

  browser.visit(
    helpers.appurl('/admin')
  ).then( ->
    assert.equal browser.statusCode, 200,
      "Expected get request to new to return http code 200"

    browser.clickLink('Add new indicator')
  ).then(->
    browser.fill('Spreadsheet Key', spreadsheetKey)
    browser.pressButton('Import Indicator')
  ).then(->

    tableText = browser.text('#indicator-table tr')
    assert.match tableText, new RegExp("#{importedIndicator.name}"),
      "Expected to see the new imported indicator in the table"

    if browser.errors.length > 0
      done(browser.errors)
    else
      done()
  ).catch((err) ->
    done(err)
  ).finally(->
    gdocImportStub.restore()
  )
)


test('GET /partials/admin/indicators/new returns a new indicator form', (done)->
  Browser = require("zombie")
  browser = new Browser()
  browser.runScripts = false

  browser.visit(
    helpers.appurl('/partials/admin/indicators/new')
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
