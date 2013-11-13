Visualisation = require("../../models/visualisation").model

exports.index = (req, res) ->
  Visualisation.find( (err, visualisations) ->
    if err?
      console.error err
      return res.send(500, "Could not retrieve visualisations")

    res.send(JSON.stringify(visualisations))
  )

exports.create = (req, res) ->
  params = req.body

  visualisation = new Visualisation(params)
  visualisation.save (err, visualisation) ->
    if err?
      console.error err
      return res.send(500, "Could not save visualisation")

    Visualisation.findFatVisualisation(
      _id: visualisation._id,
      (err, visualisation) ->
        res.send(201, JSON.stringify(visualisation))
    )

exports.show = (req, res) ->
  Visualisation.findFatVisualisation(_id: req.params.visualisation, (err, visualisation) ->
    if err?
      console.error err
      return res.send(500, "Could not retrieve visualisation")

    res.send(JSON.stringify(visualisation))
  )

exports.update = (req, res) ->
  visualisationId = req.params.visualisation
  params = req.body
  delete params['_id']
  Visualisation.update(
    {_id: visualisationId},
    {$set: params},
    (err, rowsChanged) ->
      if err?
        console.error err
        res.send(500, "Could not update the visualisation")

      Visualisation.findFatVisualisation(
        _id: visualisationId,
        (err, visualisation) ->
          if err?
            console.error err
            res.send(500, "Could not update the visualisation")

          res.send(200, JSON.stringify(visualisation))
      )
  )

exports.destroy = (req, res) ->
  Visualisation.remove(
    {_id: req.params.visualisation},
    (err, visualisation) ->
      if err?
        console.error err
        res.send(500, "Couldn't delete the visualisation")

      res.send(204)
  )
