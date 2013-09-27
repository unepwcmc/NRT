Theme = require("../../models/theme").model
_ = require('underscore')

exports.index = (req, res) ->
  Theme.find( (err, themes) ->
    if err?
      return res.send(500, "Could not retrieve themes")

    res.send(JSON.stringify(themes))
  )

exports.create = (req, res) ->
  params = req.body

  theme = new Theme(params)
  theme.save (err, theme) ->
    if err?
      return res.send(500, "Could not save theme")

    res.send(201, JSON.stringify(theme))

exports.show = (req, res) ->
  Theme.findOne(_id: req.params.theme, (err, theme) ->
    if err?
      return res.send(500, "Could not retrieve theme")

    theme.populatePageAttribute().then( (page) ->
      res.send(JSON.stringify(theme))
    ).fail( (err) ->
      console.error err
      throw new Error(err)
    )
  )

exports.update = (req, res) ->
  params = _.omit(req.body, '_id')

  Theme.update(
    {_id: req.params.theme},
    {$set: params},
    (err, rowsChanges) ->
      if err?
        console.error err
        res.send(500, "Could not update the theme")

      Theme.findOne(_id: req.params.theme, (err, theme) ->
        if err?
          console.error err
          res.send(500, "Could not retrieve the theme")

        res.send(200, JSON.stringify(theme))
      )
  )

exports.destroy = (req, res) ->
  Theme.remove(
    {_id: req.params.theme},
    (err, theme) ->
      if err?
        res.send(500, "Couldn't delete the theme")

      res.send(204)
  )

