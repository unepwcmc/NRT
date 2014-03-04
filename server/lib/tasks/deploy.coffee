Promise = require('bluebird')
readline = require('readline')
request = Promise.promisifyAll(require('request'))
crypto = require('crypto')

Git = require('../git')
GitHubDeploy = require('../git_hub_deploy')

rl = readline.createInterface(
  input: process.stdin
  output: process.stdout
  terminal: false
)

normaliseDescription = (tagName) ->
  tagName.toLowerCase().replace(/\s+/g, '-')

console.log "What server do you want to deploy to (e.g. staging, production):"

module.exports = new Promise( (resolve, reject) ->
  rl.once('line', (target) ->
    console.log "What does this deploy feature?"
    rl.once('line', (description) ->
      hash = crypto.randomBytes(5).toString('hex')
      tagName = "#{target}-#{normaliseDescription(description)}-#{hash}"

      console.log "Creating tag '#{tagName}'"
      Git.createTag(tagName, description).then( ->
        Git.push(tagName)
      ).then(->
        GitHubDeploy.getDeployForTag(tagName)
      ).then((deploy)->
        deploy.pollStatus()
      ).then(
        resolve
      ).catch(reject)
    )
  )
)
