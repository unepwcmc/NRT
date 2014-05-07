assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
Q = require('q')
passportStub = require 'passport-stub'

suite('User Sessions')

test('GET /login renders a log in form', (done) ->
  Q.nfcall(
    request.get, {
      url: helpers.appurl("/login")
    }
  ).spread( (res, body) ->

    assert.equal res.statusCode, 200

    assert.match body, new RegExp(".*form.*")
    assert.match body, new RegExp(".*Username.*")
    assert.match body, new RegExp(".*Password.*")

    done()

  ).catch((err) ->
    console.error err
    throw err
  )
)


test('POST /login redirects to GET / if successful', (done) ->
  user =
    email: "walt"
    password: "jessepinkman"

  helpers.createUser(
    user
  ).then( (theUser) ->
    Q.nfcall(
      request.post, {
        url: helpers.appurl("/login")
        json: true
        body:
          username: user.email
          password: user.password
      }
    )
  ).spread( (res, body) ->

    assert.strictEqual res.statusCode, 302
    assert.strictEqual res.headers.location, '/'

    done()

  ).catch((err) ->
    console.error err
    throw err
  )
)

test('POST /login redirects to the GET /login if unsuccessful', (done) ->
  Q.nfcall(
    request.post, {
      url: helpers.appurl("/login")
      json: true
      body:
        email: "george_oscar_bluth"
        password: "michael"
    }
  ).spread( (res, body) ->

    assert.strictEqual res.statusCode, 302
    assert.strictEqual res.headers.location, '/login'

    done()

  ).catch((err) ->
    console.error err
    throw err
  )
)
