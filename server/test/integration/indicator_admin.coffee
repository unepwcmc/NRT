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

  gdocImportStub = sinon.stub(GDocIndicatorImporter, 'import', ->
    Promise.resolve()
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
    browser.fill('Google Spreadsheet Key', spreadsheetKey)
    browser.pressButton('Import Indicator')
  ).then(->
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
