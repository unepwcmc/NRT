
exports.index = (req, res) ->
  res.render "index",
    title: "Hello world, I'm a index page"

exports.show = (req, res) ->
  res.render "indicator",
    indicator: req.params.id
