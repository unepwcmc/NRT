assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
_ = require('underscore')
async = require('async')

suite('API - Users')

test('GET index', (done) ->
  helpers.createUser().
    then( (user) ->
      request.get({
        url: helpers.appurl("api/users")
        json: true
      }, (err, res, body) ->
        assert.equal res.statusCode, 200

        users = body
        assert.equal users[0]._id, user.id
        assert.equal users[0].email, user.email

        done()
      )
    ).fail( (err) ->
      console.error err
      throw new Error(err)
    )
)
