cp = require('child_process')

getBranchFromRef = (ref) ->
  refParts = ref.split("/")
  return refParts[refParts.length-1]

exports.index = (req, res) ->
  unless getBranchFromRef(req.body.ref) is "deploy"
    return res.send 500, "Only commits from deploy branch are accepted"

  cp.fork('bin/setup.coffee')

  res.send 200
