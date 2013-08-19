Visualisation = require("../../models/visualisation").model

exports.index = (req, res) ->
  Visualisation.find( (err, visualisations) ->
    if err?
      return res.send(500, "Could not retrieve visualisations")

    res.send(JSON.stringify(visualisations))
  )

exports.create = (req, res) ->
  params = req.body

  visualisation = new Visualisation(params)
  visualisation.save (err, visualisation) ->
    if err?
      return res.send(500, "Could not save visualisation")

    res.send(201, JSON.stringify(visualisation))

exports.show = (req, res) ->
  Visualisation.findOne(_id: req.params.visualisation, (err, visualisation) ->
    if err?
      return res.send(500, "Could not retrieve visualisation")

    res.send(JSON.stringify(visualisation))
  )

exports.update = (req, res) ->
  Visualisation.update(
    {_id: req.params.visualisation},
    {$set: req.body},
    (err, visualisation) ->
      if err?
        console.error error
        res.send(500, "Could not update the visualisation")

      res.send(200, JSON.stringify(visualisation))
  )

exports.destroy = (req, res) ->
  Visualisation.remove(
    {_id: req.params.visualisation},
    (err, visualisation) ->
      if err?
        res.send(500, "Couldn't delete the visualisation")

      res.send(204)
  )
