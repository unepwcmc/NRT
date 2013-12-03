Indicator = require('../models/indicator')

exports.query = (req, res) ->
  Indicator
    .find(req.params.id)
    .then((indicator)->
      res.send(200, JSON.stringify(indicator))
    ).fail((err) ->
      console.error err
      res.send(500, err)
    )
