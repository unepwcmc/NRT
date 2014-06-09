assert = require('chai').assert
_ = require('underscore')
async = require('async')

helpers = require '../helpers'
Visualisation = require('../../models/visualisation').model

suite('Visualisation')

test('.create', (done) ->
  visualisation = new Visualisation(data: {some: 'data'})
  visualisation.save (err, visualisation) ->
    if err?
      throw new Error("Visualisation save failed")

    Visualisation.count (err, count) ->
      if err?
        throw new Error("Failed to find visualisation")

      assert.equal 1, count
      done()
)

test('.create with nested indicator', (done) ->
  helpers.createIndicator( (err, indicator) ->
    visualisation = new Visualisation(
      data: {some: 'data'}
      indicator: indicator._id
    )

    visualisation.save (err, visualisation) ->
      if err?
        throw new Error("Visualisation save failed")

      Visualisation
        .findOne(_id: visualisation._id)
        .populate('indicator')
        .exec( (err, visualisation) ->
          assert.isDefined visualisation.indicator

          assert.strictEqual(
            visualisation.indicator._id.toString(),
            indicator._id.toString()
          )

          done()
        )
  )
)

test('get "fat" visualisation with all related children by report ID', (done) ->
  helpers.createIndicator( (err, indicator) ->
    visualisation = new Visualisation(
      data: {some: 'data'}
      indicator: indicator._id
    )

    visualisation.save (err, visualisation) ->
      if err?
        throw new Error("Visualisation save failed")

      Visualisation.findFatVisualisation({_id: visualisation._id}, (err, visualisation) ->
        assert.isDefined visualisation.indicator

        assert.strictEqual(
          visualisation.indicator._id.toString(),
          indicator._id.toString()
        )

        done()
      )
  )
)
