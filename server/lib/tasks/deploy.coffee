Promise = require('bluebird')
readline = require('readline')
request = Promise.promisifyAll(require('request'))

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
      url = "https://api.github.com/v3/repos/unepwcmc/NRT/releases"

      tagName = "#{target}-#{normaliseDescription(description)}"

      releaseOptions = {
        tag_name: tagName
        name: description
        body: description
      }

      request.postAsync(
        url: url
        json: releaseOptions
      ).then(resolve).catch(reject)
    )
  )
)
