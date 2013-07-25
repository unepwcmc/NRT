Report = require("../../models/report")

exports.index = (req, res) ->
  Report.findAll().success (reports) ->
    res.send(JSON.stringify(reports))

exports.create = (req, res) ->
  params = req.body

  errors = []
  ['title'].forEach( (attribute) ->
    unless params.hasOwnProperty(attribute)
      errors.push("#{attribute} is required")
  )

  if errors.length > 0
    return res.send(
      JSON.stringify(errors: errors)
    )

  Report.create(
    title: params.title
    brief: params.brief
    introduction: params.introduction
    conclusion: params.conclusion
  ).success (report) ->
    res.send(
      JSON.stringify(
        report: report
      )
    )

exports.show = (req, res) ->
  Report.find(req.query.id).success (report) ->
    res.send(
      JSON.stringify(
        report: report
      )
    )

exports.update = (req, res) ->
  res.send('update report ' + req.params.id)

exports.destroy = (req, res) ->
  res.send('destroy report ' + req.params.id)
