Narrative = require("../../models/narrative")

exports.new = (req, res) ->
  console.log req
  Narrative.create(
    title: req.query.title 
    content: req.query.content).success (narrative) -> 
      res.send(JSON.stringify(
        narrative: narrative
      ))

exports.create = (req, res) ->
  res.send('create narrative')

exports.show = (req, res) ->
  Narrative.find(req.query.id).success (narrative) ->
    res.send(narrative)

exports.edit = (req, res) ->
  res.send('edit narrative ' + req.params.id)

exports.update = (req, res) ->
  res.send('update narrative ' + req.params.id)

exports.destroy = (req, res) ->
  res.send('destroy narrative ' + req.params.id)