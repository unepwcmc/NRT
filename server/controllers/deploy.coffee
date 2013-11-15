cp = require('child_process')

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

  deployProcess = cp.fork("#{process.cwd()}/bin/deploy.coffee")
  deployProcess.stdout.on('data', (data) ->
    console.log(data.toString())
  )
  deployProcess.stderr.on('data', (data) ->
    console.log("Error: #{data.toString()}")
  )

  console.log "Forked!"

  res.send 200
