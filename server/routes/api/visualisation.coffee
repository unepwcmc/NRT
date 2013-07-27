Visualisation = require("../../models/visualisation")

exports.create = (req, res) ->
  params = req.body
  Visualisation.create(
    data: params.data
    section_id: params.section_id
  ).success((visualisation) ->
    res.send(201,
      JSON.stringify(visualisation)
    )
  ).error((error) ->
    console.error error
    res.send(500,
      "Sorry, there was an error saving the visualisation"
    )
  )
