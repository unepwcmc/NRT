_ = require('underscore')

httpVerbWhitelist = ['GET']
if process.env.NODE_ENV is 'production'
  httpVerbWhitelist = []

tokenAuthVerbs = ['POST', 'DELETE', 'PUT']

module.exports = (req, res, next) ->
  return next() if process.env.NODE_ENV is 'test'

  if /^\/api\/users/.test(req.path)
    if _.contains(tokenAuthVerbs, req.method)
      return next()

    return res.redirect('/login')

  return next() if /^\/login/.test(req.path)
  return next() if /^\/deploy/.test(req.path)
  return next() if req.isAuthenticated() or _.contains(httpVerbWhitelist, req.method)

  return res.redirect('/login')
