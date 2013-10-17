User = require("../../models/user").model
_ = require('underscore')
mongoose = require('mongoose')
Q = require('q')

exports.index = (req, res) ->
  Q.nsend(User.find().select('-password'), 'exec')
  .then( (users) ->
    res.send(users)
  ).fail( (err) ->
    console.error err
    return res.send(500, "Could not retrieve users")
  )

exports.show = (req, res) ->
  Q.nsend(
    User
      .findOne(_id: req.params.id)
      .select('-password'),
      'exec'
  ).then( (user) ->

    res.send(user)

  ).fail( (err) ->
    console.error err
    return res.send(500, "Could not retrieve users")
  )

exports.create = (req, res) ->
  user = new User(
    email: req.body.email
    password: req.body.password
  )
  user.save (err, user) ->
    if err?
      return res.send(500, {errors: ["could not save user"]})

    res.send(user)

exports.destroy = (req, res) ->
  User.remove(
    {_id: req.params.user},
    (err, user) ->
      if err?
        res.send(500, "Couldn't delete the user")

      res.send(204)
  )
