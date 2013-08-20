assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
url = require('url')
async = require('async')

suite('API - Visualisation')

Visualisation = require('../../models/visualisation').model

test('POST create', (done) ->
  data =
    data: "new visualisation"
    type: 'BarChart'

  request.post({
    url: helpers.appurl('api/visualisations/')
    json: true
    body: data
  },(err, res, body) ->
    id = body.id

    assert.equal res.statusCode, 201

    Visualisation
      .findOne(id)
      .exec( (err, visualisation) ->
        assert.equal visualisation.data, data.data
        assert.equal visualisation.type, data.type
        done()
      )
  )
)

test('POST create with nested indicator', (done) ->
  helpers.createIndicator( (err, indicator) ->
    if err?
      throw 'Could not create indicator'

    request.post({
      url: helpers.appurl('api/visualisations/')
      json: true
      body:
        data: {walter: 'white'}
        indicator: indicator._id
    },(err, res, body) ->
      id = body.id

      assert.equal res.statusCode, 201

      Visualisation
        .findOne(id)
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
)

test("GET show", (done) ->
  helpers.createVisualisation( (err, visualisation) ->
    request.get({
      url: helpers.appurl("api/visualisations/#{visualisation.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      reloadedVisualisation = body
      assert.equal reloadedVisualisation._id, visualisation.id
      assert.equal reloadedVisualisation.content, visualisation.content

      done()
    )
  )
)

test("GET show returns nested indicator", (done) ->
  helpers.createIndicator( (err, indicator) ->
    if err?
      throw 'Could not create indicator'

    helpers.createVisualisation(
      {indicator: indicator._id},
      (err, visualisation) ->
        request.get({
          url: helpers.appurl("api/visualisations/#{visualisation.id}")
          json: true
        }, (err, res, body) ->
          assert.equal res.statusCode, 200

          reloadedVisualisation = body
          assert.equal reloadedVisualisation._id, visualisation.id
          assert.equal reloadedVisualisation.content, visualisation.content

          assert.isDefined reloadedVisualisation.indicator

          assert.strictEqual(
            reloadedVisualisation.indicator._id.toString(),
            indicator._id.toString()
          )

          done()
        )
    )
  )
)

test('GET index', (done) ->
  helpers.createVisualisation( (err, visualisation) ->
    request.get({
      url: helpers.appurl("api/visualisations")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      visualisations = body
      assert.equal visualisations[0]._id, visualisation.id
      assert.equal visualisations[0].content, visualisation.content

      done()
    )
  )
)

test('DELETE visualisation', (done) ->
  helpers.createVisualisation( (err, visualisation) ->
    request.del({
      url: helpers.appurl("api/visualisations/#{visualisation.id}")
      json: true
    }, (err, res, body) ->
      assert.equal res.statusCode, 204

      Visualisation.count( (err, count)->
        unless err?
          assert.equal 0, count
          done()
      )
    )
  )
)

test('PUT visualisation', (done) ->
  helpers.createVisualisation( (err, visualisation) ->
    new_data = "Updated data"
    request.put({
      url: helpers.appurl("/api/visualisations/#{visualisation.id}")
      json: true
      body:
        data: new_data
    }, (err, res, body) ->
      id = body._id

      assert.equal res.statusCode, 200

      Visualisation
        .findOne(id)
        .exec( (err, visualisation) ->
          assert.equal visualisation.data, new_data
          done()
      )
    )
  )
)

test('PUT visualisation with indicator reference', (done) ->
  helpers.createIndicator( (err, indicator) ->
    helpers.createVisualisation( (err, visualisation) ->
      new_data = "Updated data"
      request.put({
        url: helpers.appurl("/api/visualisations/#{visualisation.id}")
        json: true
        body:
          indicator: indicator._id
      }, (err, res, body) ->
        id = body._id

        assert.equal res.statusCode, 200

        Visualisation
          .findOne(id)
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
  )
)

test('PUT visualisation with existing indicator with new indicator', (done) ->
  async.series([
    helpers.createIndicator,
    helpers.createIndicator,
    helpers.createVisualisation
  ], (err, results) ->
    if err?
      console.error err
      return done()

    updateVisualisation(results, assertVisualisationUpdated)
  )

  updateVisualisation = (results, callback) ->
    indicator = results[0]
    newIndicator = results[1]
    visualisation = results[2]

    request.put({
      url: helpers.appurl("/api/visualisations/#{visualisation.id}")
      json: true
      body:
        indicator: newIndicator._id
    }, (err, res, body) ->
      assert.equal res.statusCode, 200

      visualisationAttributes = body
      callback(visualisationAttributes, newIndicator)
    )

  assertVisualisationUpdated = (visualisation, indicator) ->
    Visualisation
      .findOne(visualisation._id)
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
