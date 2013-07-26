User = require("../models/user")

exports.index = (req, res) ->
  User.findAll().success (users) ->
    res.send(JSON.stringify(users))

exports.show = (req, res) ->
  User.find(req.params.id).success (user) ->
    res.send(JSON.stringify(user: user))

exports.create = (req, res) ->
  User.create(
    email: req.body.email
    password: req.body.password
  ).success( (user) ->
    res.send(JSON.stringify(user: user))
  ).failure( (err) ->
    res.send(JSON.stringify(error: err))
  )

exports.destroy = (req, res) ->
  User.find(req.params.id).success( (user) ->
    user.destroy().
    success( ->
      res.send(JSON.stringify(message: "user destroyed"))
    ).failure( (err) ->
      res.send(JSON.stringify(error: err))
    )
  ).failure( (err) ->
    res.send(JSON.stringify(error: err))
  )
