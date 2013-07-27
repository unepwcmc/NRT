Narrative = require("../../models/narrative")

exports.index = (req, res) ->
  Narrative.findAll().success (narratives) ->
    res.send(JSON.stringify(narratives))

exports.create = (req, res) ->
  params = req.body
  Narrative.create(
    content: params.content
    section_id: params.section_id
  ).success((narrative) ->
    res.send(201,
      JSON.stringify(narrative)
    )
  ).error((error) ->
    console.error error
    res.send(500,
      "Sorry, there was an error saving the narrative"
    )
  )

exports.show = (req, res) ->
  Narrative.find(req.query.id).success (narrative) ->
    res.send(JSON.stringify(
      narrative: narrative
    ))

exports.update = (req, res) ->
  Narrative.find(req.params.narrative).success((narrative) ->
    narrative.updateAttributes(req.body).success(->
      res.send(200, JSON.stringify(narrative))
    ).error((error) ->
      console.error error
      res.send(500, "Couldn't save the narrative")
    )
  ).error((error) ->
    console.error error
    res.send(404, "Couldn't find narrative #{req.params.narrative}")
  )

exports.destroy = (req, res) ->
  res.send('destroy narrative ' + req.params.id)
