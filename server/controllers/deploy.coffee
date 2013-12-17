CommandRunner = require('../bin/command-runner')
range_check = require('range_check')

getBranchFromRef = (ref) ->
  refParts = ref.split("/")
  return refParts[refParts.length-1]

getIpFromRequest = (req) ->
  req.connection.remoteAddress

GITHUB_IP_RANGE = "192.30.252.0/22"

ipIsFromGithub = (ip) ->
  range_check.in_range(ip, GITHUB_IP_RANGE)

exports.index = (req, res) ->
  remoteIp = getIpFromRequest(req)
  return res.send 401 unless ipIsFromGithub(remoteIp)

  parsedPayload = JSON.parse(req.body.payload)

  console.log "Got deploy message from #{parsedPayload.ref}"
  unless getBranchFromRef(parsedPayload.ref) is "deploy"
    console.log "Ignoring, only deploys on pushes from deploy"
    return res.send 500, "Only commits from deploy branch are accepted"

  console.log "Forking #{process.cwd()}/bin/deploy.coffee"

  deployProcess = CommandRunner.spawn "coffee #{process.cwd()}/bin/deploy.coffee"

  console.log "Forked!"

  deployProcess.on('close', ->
    console.log "deploy finished, restarting server"
    process.exit()
  )

  res.send 200
