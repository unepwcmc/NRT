assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
Promise = require('bluebird')
Browser = require("zombie")
sinon = require("sinon")

Indicator = require('../../models/indicator').model
GDocIndicatorImporter = require('../../lib/gdoc_indicator_importer')

suite('Indicator Admin')

newFormLoaded = (window) ->
  element = window.document.getElementById("new-indicator-form")
  return element?

test("User can visit the admin page, click 'Add Indicator', enter a google
 spreadsheet key and import a new indicator ", (done)->

  importedIndicator =
    name: "Spiffing new indiator"

  gdocImportStub = sinon.stub(GDocIndicatorImporter, 'import', ->
    Promise.promisify(Indicator.create, Indicator)(importedIndicator)
  )

  browser = new Browser()

  browser.on('error', (err) ->
    console.log "Browser error:"
    console.log err
  )
  browser.on('console', (level, msg) ->
    console.log "Browser #{level}:"
    console.log msg
  )

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
    browser.wait()
  ).then(->

    tableText = browser.text('#indicator-table tr')
    assert.match tableText, new RegExp("#{importedIndicator.name}"),
      "Expected to see the new imported indicator in the table"

    if browser.errors.length > 0
      done(browser.errors)
    else
      done()
  ).catch((err) ->
    console.log "Some error was thrown"
    console.log err
    done(err)
  ).finally(->
    gdocImportStub.restore()
  )
)


test('GET /partials/admin/indicators/new returns a new indicator form', (done)->
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
