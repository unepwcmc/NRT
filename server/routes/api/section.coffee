Section = require("../../models/section").model
_ = require('underscore')
async = require('async')

exports.index = (req, res) ->
  Section.find (err, sections) ->
    if err?
      console.error error
      return res.send(500, "Could not retrieve sections")

    res.send(JSON.stringify(sections))

exports.create = (req, res) ->
  params = req.body

  section = new Section(params)
  section.save (err, section) ->
    if err?
      console.error error
      return res.send(500, "Could not create section")

    Section
      .findOne(section._id)
      .populate('indicator narrative visualisation')
      .exec( (err, section) ->
        res.send(201, JSON.stringify(section))
      )

exports.show = (req, res) ->
  Section
    .findOne(req.params.section)
    .populate('indicator')
    .exec( (err, section) ->
      if err?
        console.error error
        return res.send(500, "Could not retrieve section")

      res.send(JSON.stringify(section))
    )

exports.update = (req, res) ->
  Section.update(
    {_id: req.params.section},
    req.body,
    (err, section) ->
      if err?
        console.error error
        res.send(500, "Error saving section #{section.title}")

      res.send(200, JSON.stringify(section))
  )

exports.destroy = (req, res) ->
  Section.remove(
    {_id: req.params.section},
    (err, section) ->
      if err?
        res.send(500, "Couldn't delete the section")

      res.send(204)
  )
