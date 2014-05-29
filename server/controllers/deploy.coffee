AppConfig = require('../initializers/config')
Deploy = require('../lib/deploy')
range_check = require('range_check')

tagRefersToServer = (tag, serverName) ->
  return new RegExp("^#{serverName}").test(tag)

getIpFromRequest = (req) ->
  req.headers['x-real-ip'] or req.connection.remoteAddress

GITHUB_IP_RANGE = "192.30.252.0/22"

ipIsFromGithub = (ip) ->
  range_check.in_range(ip, GITHUB_IP_RANGE)

exports.index = (req, res) ->
  remoteIp = getIpFromRequest(req)

  env = process.env.NODE_ENV
  env ||= 'development'
  if env isnt 'development'
    return res.send 401 unless ipIsFromGithub(remoteIp)

  console.log "Got deploy message from #{req.body.ref}"

  serverName = AppConfig.get('server')?.name
  tagName = req.body.ref

  unless tagRefersToServer(tagName, serverName)
    errMessage = "Only deploys for this server (#{serverName}) are accepted"
    console.log errMessage
    return res.send 500, errMessage

  console.log "Updating code from #{tagName}..."
  Deploy.deploy(tagName).then(->
    console.log "Code update finished, restarting server"
    process.exit()
  ).catch((err)->
    console.log "Error updating code:"
    console.error err
  )

  res.send 200
