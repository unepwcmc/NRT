app = require('../app')
test_server = null

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
