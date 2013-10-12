Indicator = require("../../models/indicator").model
_ = require('underscore')
Q = require('q')

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
  Indicator.findOne(_id: req.params.indicator, (err, indicator) ->
    if err?
      return res.send(500, "Could not retrieve indicator")

    res.send(JSON.stringify(indicator))
  )

exports.update = (req, res) ->
  params = _.omit(req.body, '_id')

  Indicator.update(
    {_id: req.params.indicator},
    {$set: params},
    (err, rowsChanges) ->
      if err?
        console.error err
        res.send(500, "Could not update the indicator")

      Indicator.findOne(_id: req.params.indicator, (err, indicator) ->
        if err?
          console.error err
          res.send(500, "Could not retrieve the indicator")

        res.send(200, JSON.stringify(indicator))
      )
  )

exports.destroy = (req, res) ->
  Indicator.remove(
    {_id: req.params.indicator},
    (err, indicator) ->
      if err?
        res.send(500, "Couldn't delete the indicator")

      res.send(204)
  )

exports.dataAsCSV = (req, res) ->
  Indicator
    .findOne(_id: req.params.id)
    .exec( (err, indicator)->
      if err?
        console.error error
        return res.render(500, "Error fetching the indicator")

      indicator.getIndicatorDataForCSV req.query.filters, (err, indicatorData) ->
        if err?
          console.error err
          return res.send(500, "Can't retrieve indicator data for #{req.params.id}")

        res.csv(indicatorData)
    )

exports.data = (req, res) ->
  Indicator.findOne _id: req.params.id, (err, indicator) ->
    if err?
      console.error err
      return res.send(404, "Could not find indicator #{req.params.id}")

    indicator.getIndicatorData req.query.filters, (err, indicatorData) ->
      if err?
        console.error err
        return res.send(500, "Can't retrieve indicator data for #{req.params.id}")

      indicator.calculateIndicatorDataBounds (err, bounds) ->
        if err?
          console.error err
          return res.send(500, "unable to retrieve result bounds for indicator #{req.params.id}")

        res.format(
          json: ->
            res.send(200, JSON.stringify(
              results: indicatorData
              bounds: bounds
            ))
        )

exports.headlines = (req, res) ->
  Q.nsend(
    Indicator.findOne(_id: req.params.id),
    'exec'
  ).then( (indicator) ->

    unless indicator?
      error = "Could not find indicator with ID #{req.params.id}"
      console.error error
      return res.send(404, {error_message: error})

    indicator.getRecentHeadlines(req.params.count || 5)
  ).then( (headlines) ->

    res.send(200, headlines)

  ).fail((err) ->
    console.error err
    return res.render(500, "Error fetching the indicator")
  )
