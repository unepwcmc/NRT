Indicator = require('../models/indicator')

exports.query = (req, res) ->
  Indicator
    .find(req.params.id)
    .then( (indicator) ->
      indicator.query()
    ).then( (data) ->
      res.send(200, data)
    ).fail( (err) ->
      console.error err
      res.send(500, err)
    )
