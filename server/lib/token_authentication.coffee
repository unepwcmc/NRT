authenticateToken = (token) ->
  env_token = process.env.AUTH_TOKEN

  if env_token? && token?
    return env_token == token

  return false

module.exports = (req, res, next) ->
  unless authenticateToken(req.query.token || null)
    return res.send(401, 'Unauthorised')

  next()
