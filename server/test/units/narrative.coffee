assert = require('chai').assert
helpers = require '../helpers'

suite('Narrative')
test('.create', (done) ->
  Narrative = require('../../models/narrative').model

  narrative = new Narrative(title: '1234', content: 'narrate this')
  narrative.save( (err, narrative) ->
    if err?
      throw "Could not save narrative"

    Narrative.count( (err, count)->
      unless err?
        assert.equal 1, count
        done()
    )
  )
)
