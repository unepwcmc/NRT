User = require("../../models/user").model
_ = require('underscore')
mongoose = require('mongoose')
Q = require('q')

exports.index = (req, res) ->
  Q.nsend(User.find().select('-password'), 'exec')
  .then( (users) ->
    res.send(JSON.stringify(users))
  ).fail( (err) ->
    console.error err
    return res.send(500, "Could not retrieve users")
  )

exports.show = (req, res) ->
  User.find(_id: req.params.user, (err, user) ->
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
    {_id: req.params.user},
    (err, user) ->
      if err?
        res.send(500, "Couldn't delete the user")

      res.send(204)
  )
