assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
Promise = require('bluebird')
Browser = require("zombie")

Indicator = require('../../models/indicator').model

suite('Indicator Admin')

newFormLoaded = (window) ->
  element = window.document.getElementById("new-indicator-form")
  return element?

test("User can visit the admin page, click 'Add Indicator', enter a google
 spreadsheet key and import a new indicator ", (done)->

  browser = new Browser(debug: true)

  browser.on('error', (err) ->
    console.log "Browser error:"
    console.log err
  )

  spreadsheetKey = '43289432'

  browser.visit(
    helpers.appurl('/admin')
  ).then( ->

    assert.equal browser.statusCode, 200,
      "Expected get request to new to return http code 200"

    browser.clickLink('Add new indicator')
  ).then(->
    browser.wait(newFormLoaded, null)
  ).then(->

    browser.fill('Google Spreadsheet Key', spreadsheetKey)
    browser.pressButton('Import Indicator')
  ).then(->
    browser.wait()
  ).then(->
    if browser.errors.length > 0
      done(browser.errors)
    else
      done()
  ).catch(done)
)
