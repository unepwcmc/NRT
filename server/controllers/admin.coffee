Indicator = require('../models/indicator').model
IndicatorData = require('../models/indicator_data').model
Promise = require('bluebird')
renderPartial = require('../lib/render_handlebars_partial')

exports.updateIndicatorData = (req, res) ->
  Promise.promisify(Indicator.findOne, Indicator)(
    _id: req.params.id
  ).then( (indicator) ->
    indicator.updateIndicatorData()
  ).then( (indicatorData) ->
    return res.send(201, "Successfully updated indicator:\n #{JSON.stringify indicatorData}")
  ).catch((err) ->
    console.log err
    console.log err.stack
    return res.send(500, "Error updating the indicator")
  )

exports.updateAll = (req, res) ->
  Promise.promisify(Indicator.find, Indicator)(
    {}
  ).then( (indicators) ->
    res.render 'admin/updateAll', indicators: indicators
  ).catch((err) ->
    console.log err.stack
    return res.send(500, "Error getting indicators")
  )

exports.seedIndicatorData = (req, res) ->
  Promise.promisify(Indicator.find, Indicator)(
    {}
  ).then(
    IndicatorData.seedData
  ).then( ->
    res.send 200, "Seeded indicator data"
  ).catch((err) ->
    console.log err.stack
    return res.send(500, "Error seeding indicator data")
  )

exports.partials = {}
exports.partials.indicatorsTable = (req, res) ->
  Promise.promisify(Indicator.find, Indicator)(
    {}
  ).then( (indicators) ->
    res.send 200, renderPartial('admin/indicators', indicators)
  ).catch((err) ->
    console.error err.stack
    return res.send(500, "Error getting indicators")
  )

exports.partials.newIndicator = (req, res) ->
  res.render("partials/admin/new_indicator")
