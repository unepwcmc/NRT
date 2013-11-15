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

  console.log "Forking deploy.coffee"
  cp.fork("#{process.cwd()}/bin/deploy.coffee")
  console.log "Forked!"

  res.send 200
