exports.index = (req, res) ->
  res.render "reports",
    title: "Report show page"

exports.show = (req, res) ->
  res.render "reports/show",
    report_id: req.params.id