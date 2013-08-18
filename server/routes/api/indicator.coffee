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
  Indicator.findOne(req.params.indicator, (err, indicator) ->
    if err?
      return res.send(500, "Could not retrieve indicator")

    res.send(JSON.stringify(indicator))
  )

exports.update = (req, res) ->
  Indicator.update(
    {_id: req.params.indicator},
    {$set: req.body},
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

exports.data = (req, res) ->
  Indicator.findOne _id: req.params.id, (err, indicator) ->
    if err?
      console.error err
      return res.send(404, "Could not find indicator #{req.params.id}")
    indicator.getIndicatorData (err, indicatorData) ->
      if err?
        console.error err
        return res.send(500, "Can't retrieve indicator data for #{req.params.id}")
      res.format 
        json: ->
          res.send(200, JSON.stringify(indicatorData))

  