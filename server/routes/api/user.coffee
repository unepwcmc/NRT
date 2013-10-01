User = require("../../models/user").model
_ = require('underscore')
mongoose = require('mongoose')
Q = require('q')

exports.index = (req, res) ->
  Q.nsend(User, 'find')
  .then( (users) ->
    res.send(JSON.stringify(users))
  ).fail( (err) ->
    console.error err
    return res.send(500, "Could not retrieve users")
  )
