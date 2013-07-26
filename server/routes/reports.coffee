exports.index = (req, res) ->
  res.render "reports",
    title: "Report show page"

exports.show = (req, res) ->
  reportId = req.params.id
  # Load report JSON from database
  # reportGathering.loadFatReport(reportId).success((reportData)->
  #   res.render "reports/show",
  #     reportData: reportData
  # ).error((error) ->
  #   console.log error
  #   res.render "404"
  # )
  res.render "reports/show",
    report_id: req.params.id

exports.present = (req, res) ->
  res.render "reports/present",
    report_id: req.params.id
