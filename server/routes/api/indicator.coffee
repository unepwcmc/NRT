Indicator = require("../../models/indicator").model

exports.index = (req, res) ->
  Indicator.find( (err, indicators) ->
    if err?
      return res.send(500, "Could not retrieve indicators")

    res.send(JSON.stringify(indicators))
  )

exports.create = (req, res) ->
  params = req.body

  indicator = new Indicator(params)
  indicator.save (err, indicator) ->
    if err?
      return res.send(500, "Could not save indicator")

    res.send(201, JSON.stringify(indicator))

exports.show = (req, res) ->
  Indicator.findOne(req.query.id, (err, indicator) ->
    if err?
      return res.send(500, "Could not retrieve indicator")

    res.send(JSON.stringify(indicator))
  )

exports.update = (req, res) ->
  Indicator.update(
    {_id: req.params.indicator},
    req.body,
    (err, indicator) ->
      if err?
        console.error error
        res.send(500, "Could not update the indicator")

      res.send(200, JSON.stringify(indicator))
  )

exports.destroy = (req, res) ->
  Indicator.remove(
    {_id: req.params.indicator},
    (err, indicator) ->
      if err?
        res.send(500, "Couldn't delete the indicator")

      res.send(204)
  )
