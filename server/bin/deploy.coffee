console.log "Starting deploy"
CommandRunner = require('./command-runner')
Deploy = require('../lib/deploy')

tagName = process.argv[2]

Deploy.deploy(tagName).then( ->
  console.log 'Successfully deployed'
).catch( (err) ->
  console.log 'Deploy failed'
  console.error err
)
