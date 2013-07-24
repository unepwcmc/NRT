
exports.index = (req, res) ->
  res.render "indicators",
    title: "Hello world, I'm a index page"

exports.show = (req, res) ->
  res.render "indicators/show",
    indicator: req.params.id
