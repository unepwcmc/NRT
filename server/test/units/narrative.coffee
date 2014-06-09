assert = require('chai').assert

suite('Narrative')
test('.create', (done) ->
  Narrative = require('../../models/narrative').model

  narrative = new Narrative(title: '1234', content: 'narrate this')
  narrative.save( (err, narrative) ->
    if err?
      throw new Error("Could not save narrative")

    Narrative.count( (err, count)->
      unless err?
        assert.equal 1, count
        done()
    )
  )
)
