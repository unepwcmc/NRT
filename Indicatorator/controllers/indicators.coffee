Indicator = require('../models/indicator')

exports.query = (req, res) ->
  Indicator
    .find(req.params.id)
    .then( (indicator) ->
      indicator.query()
    ).then( (data) ->
      res.send(200, data)
    ).fail( (err) ->
      console.error err.stack
      res.send(500, err)
    )

exports.index = (req, res) ->
  Indicator.all().then((definitions)->
    res.send 200, definitions
  ).fail( (err) ->
    console.error err.stack
    res.send(500, err)
  )

