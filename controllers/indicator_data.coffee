Indicator = require('../models/indicator')

exports.query = (req, res) ->
  Indicator
    .find(req.params.id)
    .then( ->
      res.send(200, 'sucess')
    ).fail( (err) ->
      console.error err
      res.send(500, err)
    )
