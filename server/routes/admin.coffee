Indicator = require('../models/indicator').model
Q = require('q')

exports.updateIndicatorData = (req, res) ->
  Q.nsend(
    Indicator.findOne(_id: req.params.id),
    'exec'
  ).then( (indicator) ->
    indicator.updateIndicatorData()
  ).then( (indicatorData) ->
    return res.send(201, "Successfully updated indicator:\n #{JSON.stringify indicatorData}")
  ).fail((err) ->
    console.log err
    console.log err.stack
    return res.send(500, "Error updating the indicator")
  )

exports.updateAll = (req, res) ->
  Q.nsend(
    Indicator.find(), 
    'exec'
  ).then( (indicators) ->
    console.log indicators
    res.render 'admin/updateAll', indicators: indicators
  ).fail((err) ->
    console.log err.stack
    return res.send(500, "Error getting indicators")
  )
