Indicator = require("../../models/indicator")

exports.index = (req, res) ->
  Indicator.findAll().success (indicators) ->
    res.send(JSON.stringify(indicators))
