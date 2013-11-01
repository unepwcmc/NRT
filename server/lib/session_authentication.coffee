_ = require('underscore')

httpVerbWhitelist = ['GET']

module.exports = (req, res, next) ->
  if process.env.NODE_ENV is 'production'
    httpVerbWhitelist = []

  return next() if /^\/login/.test(req.path)
  return next() if process.env.NODE_ENV == 'test'
  return next() if req.isAuthenticated() or _.contains(httpVerbWhitelist, req.method)

  return res.redirect('/login')
