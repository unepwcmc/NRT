app = require('../app')
test_server = null
url = require('url')

before( (done) ->
  app.start 3001, (err, server) ->
    test_server = server
    done()
)

after( (done) ->
  test_server.close () -> done()
)

beforeEach( (done) ->
  global.sequelize.sync({force: true}).success(() -> done())
)

exports.appurl = (path) ->
  url.resolve('http://localhost:3001', path)
