Narrative = require("../../models/narrative").model
_ = require('underscore')

exports.index = (req, res) ->
  Narrative
    .find()
    .exec (err, narratives) ->
      if err?
        return res.send(500,
          "Sorry, there was an error retrieving narratives"
        )

      res.send(JSON.stringify(narratives))

exports.create = (req, res) ->
  params = req.body

  narrative = new Narrative(params)
  narrative.save (err, narrative) ->
    if err?
      console.error err
      return res.send(500,
        "Sorry, there was an error saving the narrative"
      )

    res.send(201,
      JSON.stringify(narrative)
    )

exports.show = (req, res) ->
  Narrative
    .findOne(_id: req.params.narratife)
    .exec (err, narrative) ->
      if err?
        return res.send(500,
          "Sorry, there was an error retrieving the narrative"
        )

      res.send(JSON.stringify(narrative))

exports.update = (req, res) ->
  params = _.omit(req.body, '_id')

  Narrative.update(
    {_id: req.params.narratife},
    {$set: params},
    (err, narrative) ->
      if err?
        res.send(500, "Couldn't save the narrative")

      res.send(200, JSON.stringify(narrative))
  )

exports.destroy = (req, res) ->
  Narrative.remove(
    {_id: req.params.narrative},
    (err, narrative) ->
      if err?
        res.send(500, "Couldn't delete the narrative")

      res.send(204)
  )
