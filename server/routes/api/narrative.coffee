Narrative = require("../../models/narrative")

exports.index = (req, res) ->
  Narrative.findAll().success (narratives) ->
    res.send(JSON.stringify(narratives))

exports.create = (req, res) ->
  params = req.body
  Narrative.create(
    title: params.title 
    content: params.content
  ).success (narrative) -> 
    res.send(JSON.stringify(
      narrative: narrative
    ))

exports.show = (req, res) ->
  Narrative.find(req.query.id).success (narrative) ->
    res.send(JSON.stringify(
      narrative: narrative
    ))

exports.update = (req, res) ->
  res.send('update narrative ' + req.params.id)

exports.destroy = (req, res) ->
  res.send('destroy narrative ' + req.params.id)
