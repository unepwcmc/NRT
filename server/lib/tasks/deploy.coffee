Promise = require('bluebird')
readline = require('readline')
request = Promise.promisifyAll(require('request'))
crypto = require('crypto')

Git = require('../git')

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
      hash = crypto.randomBytes(5).toString('hex')
      tagName = "#{target}-#{normaliseDescription(description)}-#{hash}"

      console.log "Creating tag '#{tagName}'"
      Git.createTag(tagName, description).then(resolve).error(reject)
    )
  )
)
