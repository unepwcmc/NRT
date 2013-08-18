Indicator = require("../../models/indicator").model
_ = require('underscore')

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
  Indicator.findOne(req.params.indicator, (err, indicator) ->
    if err?
      return res.send(500, "Could not retrieve indicator")

    res.send(JSON.stringify(indicator))
  )

exports.update = (req, res) ->
  params = _.omit(req.body, '_id')

  Indicator.update(
    {_id: req.params.indicator},
    {$set: params},
    (err, indicator) ->
      if err?
        console.error err
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
