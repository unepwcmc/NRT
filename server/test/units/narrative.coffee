assert = require('chai').assert
helpers = require '../helpers'

suite('Narrative')
test('.create', (done) ->
  Narrative = require '../../models/narrative'
  Narrative.create(title: '1234', content: 'narrate this').success( ->
    console.log 'created narrative'

    console.log(Narrative)
    Narrative.count().success((count)->
      assert.equal 1, count
      done()
    )
  )
)
