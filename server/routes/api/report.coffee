Report = require("../../models/report")

exports.index = (req, res) ->
  Report.findAll().success (reports) ->
    res.send(JSON.stringify(reports))

Report.required_fields = ['title']
exports.create = (req, res) ->
  params = req.body

  errors = []
  Report.required_fields.forEach( (attribute) ->
    unless params.hasOwnProperty(attribute)
      errors.push("#{attribute} is required")
  )

  if errors.length > 0
    return res.send(500,
      JSON.stringify(errors: errors)
    )

  Report.create(
    title: params.title
    brief: params.brief
    introduction: params.introduction
    conclusion: params.conclusion
  ).success((report) ->
    res.send(
      JSON.stringify(
        report: report
      )
    )
  ).failure((err) ->
    res.send(500, JSON.stringify(errors: [err]))
  )

exports.show = (req, res) ->
  Report.find(req.query.id).success (report) ->
    res.send(
      JSON.stringify(
        report: report
      )
    )

exports.update = (req, res) ->
  Report.find(req.params.report).success((report) ->
    report.updateAttributes(req.body).success(->
      res.send(200, JSON.stringify(report))
    ).error((error) ->
      console.error error
      res.send(500, "Couldn't save the report")
    )
  ).error((error) ->
    console.error error
    res.send(404, "Couldn't find report #{req.params.report}")
  )

exports.destroy = (req, res) ->
  res.send('destroy report ' + req.params.id)
