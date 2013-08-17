User = require("../models/user").model

exports.index = (req, res) ->
  User.find (err, users) ->
    if err?
      return res.send(500, {errors: ["could not retrieve users"]})

    res.send(JSON.stringify(users))

exports.show = (req, res) ->
  User.find(req.params.id, (err, user) ->
    if err?
      return res.send(500, {errors: ["could not retrieve user"]})

    res.send(JSON.stringify(user: user))
  )

exports.create = (req, res) ->
  user = new User(
    email: req.body.email
    password: req.body.password
  )
  user.save (err, user) ->
    if err?
      return res.send(500, {errors: ["could not save user"]})

    res.send(JSON.stringify(user: user))

exports.destroy = (req, res) ->
  User.remove(
    {_id: req.params.id},
    (err, user) ->
      if err?
        res.send(500, "Couldn't delete the user")

      res.send(204)
  )
