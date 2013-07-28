Section = require("../../models/section")
_ = require('underscore')


exports.index = (req, res) ->
  Section.findAll().success (sections) ->
        res.send(JSON.stringify(sections))

exports.create = (req, res) ->
  obj = _.pick(req.body, 'title', 'report_id')
  Section.create(obj).success (section) ->
    res.send(201, JSON.stringify(
      section
    ))

exports.show = (req, res) ->
  Section.find(req.params.section).success (section) ->
    res.send(JSON.stringify(
      section
    ))

exports.update = (req, res) ->
  obj = _.pick(req.body, 'title', 'report_id')
  Section.find(req.params.section).success((section) ->
    section.updateAttributes(obj).success((section) ->
      res.send(200, JSON.stringify(
        section
      ))
    ).error((error) ->
      console.error error
      res.send(500, "Error saving section #{section.title}")
    )
  ).error((error)->
    console.error error
    res.send(404, "Unable to find section #{req.params.id} to update")
  )

exports.destroy = (req, res) ->
  res.send('destroy section ' + req.params.id)
