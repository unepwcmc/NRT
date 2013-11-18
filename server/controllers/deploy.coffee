CommandRunner = require('../bin/command-runner')

getBranchFromRef = (ref) ->
  refParts = ref.split("/")
  return refParts[refParts.length-1]

exports.index = (req, res) ->
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
