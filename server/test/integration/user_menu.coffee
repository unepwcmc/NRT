assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
Q = require('q')
passportStub = require 'passport-stub'

Indicator = require('../../models/indicator').model

suite('User menu bar')

test("When logged in and visiting the theme index page, I see my name", (done)->
  theUser = null
  helpers.createUser(
    name: 'Lovely User'
  ).then((user) ->
    theUser = user
    passportStub.login user

    Q.nfcall(
      request.get, {
        url: helpers.appurl("/themes/")
      }
    )
  ).spread( (res, body) ->

    assert.equal res.statusCode, 200

    assert.match body, new RegExp(".*Hello #{theUser.name}.*")
    done()

  ).fail((err) ->
    console.error err
    throw err
  )
)
