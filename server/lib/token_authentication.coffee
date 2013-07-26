authenticateToken = (token) ->
  env_token = process.env.AUTH_TOKEN

  if env_token? && token?
    return env_token == token

  return false

module.exports = (req, res, next) ->
  if authenticateToken(req.query.token || null)
    next()
  else
    res.send(401, 'Unauthorised')
