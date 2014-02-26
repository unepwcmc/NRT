Promise = require('bluebird')
readline = require('readline')
request = Promise.promisifyAll(require('request'))

CommandRunner = require('../../bin/command-runner')

rl = readline.createInterface(
  input: process.stdin
  output: process.stdout
  terminal: false
)

normaliseDescription = (tagName) ->
  tagName.toLowerCase().replace(/\s+/, '-')

console.log "What server do you want to deploy to (e.g. staging, production):"

module.exports = new Promise( (resolve, reject) ->
  rl.once('line', (target) ->
    console.log "What does this deploy feature?"
    rl.once('line', (description) ->
      tagName = "#{target}-#{normaliseDescription(description)}"

      gitArgs = [
        "tag",
        "-a",
        "-m",
        "'#{description}'",
        "#{tagName}"
      ]

      console.log "Creating tag '#{tagName}'"
      gitTag = CommandRunner.spawn('git', gitArgs)

      gitTag.on('close', (code) ->
        if code > 0
          return reject("Unable to create tag #{tagName}")

        resolve()
      )
    )
  )
)
