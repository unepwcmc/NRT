assert = require('chai').assert
helpers = require '../helpers'

Narrative = require '../../models/narrative'

suite('Narrative')
test('.create', ->
  Narrative.create(title: '1234', content: 'narrate this').success( ->
    Narrative.findAndCountAll().success((count)->
      assert.equal 1, count
    )
  )
)
