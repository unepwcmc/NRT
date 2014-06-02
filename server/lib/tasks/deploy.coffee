Promise = require('bluebird')
readline = require('readline')

DeployClient = require('../deploy_client')

rl = readline.createInterface(
  input: process.stdin
  output: process.stdout
  terminal: false
)


askForTarget = ->
  new Promise( (resolve, reject) ->
    console.log "What server do you want to deploy to (e.g. staging, production):"
    rl.once('line', resolve)
  )

askForDescription = ->
  new Promise( (resolve, reject) ->
    console.log "What does this deploy feature?"
    rl.once('line', (description) ->
      resolve(description)
    )
  )

startDeployTask = ->
  askForTarget().then( (target) ->
    Promise.join(target, askForDescription())
  ).spread( (target, description) ->
    DeployClient.start(target, description)
  )

startDeployTask()
