AppConfig = require('../initializers/config')
Deploy = require('../lib/deploy')
range_check = require('range_check')
_ = require('underscore')

tagRefersToServer = (tag, serverTags) ->
  chunks = tag.split('-')
  if chunks[0] is 'deploy'

    deploymentTags = chunks[1]
    deploymentTags = deploymentTags.split(',')
    return _.intersection(deploymentTags, serverTags).length isnt 0

  else
    return false

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

  serverTags = AppConfig.get('deploy')?.tags || []
  serverName = AppConfig.get('server')?.name
  serverTags.unshift(serverName) if serverName?

  tagName = req.body.ref

  unless tagRefersToServer(tagName, serverTags)
    errMessage = "Only deploys with tag(s) #{serverTags.join(',')} are accepted"
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
