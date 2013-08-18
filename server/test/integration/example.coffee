assert = require('chai').assert
helpers = require '../helpers'
request = require('request')

suite('Application')
test('get root url', (done) ->
  request.get 'http://localhost:3001/', (err, res, body) ->
    assert.equal 200, res.statusCode
    done()
)
