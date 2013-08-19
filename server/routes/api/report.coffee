Report = require("../../models/report").model
Section = require("../../models/section").model
_ = require('underscore')
mongoose = require('mongoose')

exports.index = (req, res) ->
  Report
    .find()
    .exec( (err, reports) ->
      if err?
        return res.send(500, "Could not retrieve reports")

      res.send(JSON.stringify(reports))
    )

exports.create = (req, res) ->
  params = req.body

  report = new Report(params)
  report.save (err, report) ->
    if err?
      console.error err
      return res.send(500, "Could not save report")

    Report
      .findOne(_id: report._id)
      .populate('sections')
      .exec( (err, report) ->
        res.send(201, JSON.stringify(report))
      )

exports.show = (req, res) ->
  Report.findFatReport(req.params.report, (err, report) ->
    if err?
      console.error err
      return res.send(500, "Could not retrieve report")

    res.send(JSON.stringify(report))
  )

exports.update = (req, res) ->
  reportId = req.params.report

  params = _.omit(req.body, ['sections', '_id'])
  updateAttributes = $set: params

  if req.body.sections?
    sections = _.map(req.body.sections, (section) ->
      return new mongoose.Types.ObjectId(section._id)
    )

    updateAttributes.$pushAll = {
      sections: sections
    }

  Report.update(
    {_id: reportId},
    updateAttributes,
    (err, rowsChanged) ->
      if err?
        console.error err
        res.send(500, "Could not update the report")

      Report
        .findOne(_id: reportId)
        .populate('sections')
        .exec( (err, report) ->
          res.send(200, JSON.stringify(report))
        )
  )

exports.destroy = (req, res) ->
  Report.remove(
    {_id: req.params.report},
    (err, report) ->
      if err?
        res.send(500, "Couldn't delete the report")

      res.send(204)
  )
