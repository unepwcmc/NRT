exports.index = (req, res) ->
  res.render "reports/index",
    title: "Report show page"

exports.show = (req, res) ->
  res.render "reports/show",
    report_id: req.params.id

exports.present = (req, res) ->
  res.render "reports/present",
    report_id: req.params.id
