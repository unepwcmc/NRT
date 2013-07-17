exports.show = (req, res) ->
  res.render "reports/show",
    report_id: req.params.id
