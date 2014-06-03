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
    console.log "What server(s) do you want to deploy to (use tags or server names separated by commas):"
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
  clearScreen = '\u001B[2J\u001B[0;0f'
  process.stdout.write clearScreen
  askForTarget().then( (target) ->
    Promise.join(target, askForDescription())
  ).spread( (target, description) ->
    DeployClient.start(target, description)
  )

startDeployTask().then( ->
  process.exit(0)
).catch( (err) ->
  console.error(err)
  process.exit(1)
)
