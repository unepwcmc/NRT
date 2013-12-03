Indicator = require('../models/indicator')

exports.query = (req, res) ->
  new Indicator(req.params.id)
