Indicator = require("../../models/indicator").model
HeadlineService = require('../../lib/services/headline')
_ = require('underscore')
Q = require('q')
Promise = require('bluebird')
csv = require('csv')

exports.index = (req, res) ->
  if req.query.withData == 'true'
    findPromise = Indicator.findWhereIndicatorHasData()
  else
    findPromise = Promise.promisify(Indicator.find, Indicator)()

  findPromise.then((indicators) ->
    res.send(JSON.stringify(indicators))
  ).catch((err)->
    console.error err
    console.error err.stack
    res.send(500, "Could not retrieve indicators")
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

exports.fatShow = (req, res) ->
  Indicator.findOne(_id: req.params.id, (err, indicator) ->
    if err?
      return res.send(500, "Could not retrieve indicator")

    indicator.toObjectWithNestedPage().then( (fatIndicatorObject) ->
      res.json(fatIndicatorObject)
    ).fail( (err) ->
      console.error err
      res.send(500, "Failed to retrieve nested indicator attributes")
    )
  )

exports.update = (req, res) ->
  params = _.omit(req.body, ['_id'])
  params = Indicator.convertNestedParametersToAssociationIds(params)

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

      theIndicatorData = null

      Q.nsend(
        indicator, 'getIndicatorDataForCSV', req.query.filters
      ).then( (indicatorData) ->
        theIndicatorData = indicatorData

        indicator.generateMetadataCSV()
      ).then( (metadata) ->

        zip = new require('node-zip')()

        csv().from.array(theIndicatorData).to.string( (csvString, count) ->
          zip.file('data.csv', csvString)

          csv().from.array(metadata).to.string( (csvString, count) ->
            zip.file('metadata.csv', csvString)

            data = zip.generate({base64:false,compression:'DEFLATE'})

            res.set('Content-Type', 'application/zip')
            res.set('Content-Disposition',
              "attachment; filename=NRT #{indicator.shortName} Data.zip"
            )

            res.end(data, 'binary')
          )
        )

      ).fail( (err) ->
        console.error err
        console.error err.stack
        return res.send(500, "Failed to retrieve indicator data")
      )
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

    new HeadlineService(indicator).getRecentHeadlines(req.params.count || 5)
  ).then( (headlines) ->

    res.send(200, headlines)

  ).fail((err) ->
    console.error err
    return res.render(500, "Error fetching the indicator")
  )
