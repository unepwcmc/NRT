_ = require('underscore')

httpVerbWhitelist = ['GET']
if process.env.NODE_ENV is 'production'
  httpVerbWhitelist = []

module.exports = (req, res, next) ->
  return next() if /^\/login/.test(req.path)
  return next() if process.env.NODE_ENV == 'test'
  return next() if req.isAuthenticated() or _.contains(httpVerbWhitelist, req.method)

  return res.redirect('/login')
