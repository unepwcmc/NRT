_ = require('underscore')

module.exports = (req, res, next) ->
  httpVerbWhitelist = ['GET']

  return next() if process.env.NODE_ENV == 'test'
  return next() if req.isAuthenticated() or _.contains(httpVerbWhitelist, req.method)

  return res.send(401, 'Unauthorised')
