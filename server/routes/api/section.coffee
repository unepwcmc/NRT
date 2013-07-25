Section = require("../../models/section")
_ = require('underscore')


exports.index = (req, res) ->
  Section.findAll().success (sections) ->
        res.send(JSON.stringify(sections))

exports.create = (req, res) ->
  obj = _.pick(req.body, 'title', 'content')
  Section.create(obj).success (section) ->
    res.send(JSON.stringify(
      section: section
    ))

exports.show = (req, res) ->
  Section.find(req.query.id).success (section) ->
    res.send(JSON.stringify(
      section: section
    ))

exports.update = (req, res) ->
  res.send('update section ' + req.params.id)

exports.destroy = (req, res) ->
  res.send('destroy section ' + req.params.id)
