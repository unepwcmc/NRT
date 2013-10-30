_ = require('underscore')

httpVerbWhitelist = ['GET']

module.exports = (req, res, next) ->
  return next() if process.env.NODE_ENV == 'test'
  return next() if req.isAuthenticated() or _.contains(httpVerbWhitelist, req.method)

  return res.send(401, 'Unauthorised')
