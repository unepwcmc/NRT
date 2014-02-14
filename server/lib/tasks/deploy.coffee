Promise = require('bluebird')
Promise.longStackTraces()
readline = require('readline')
request = Promise.promisifyAll(require('request'))

rl = Promise.promisifyAll(
  readline.createInterface(
    input: process.stdin
    output: process.stdout
    terminal: false
  )
)

console.log "What server do you want to deploy to (e.g. staging, production):"

theTarget = null
module.exports = rl.onceAsync('line').then( (target) ->
  theTarget = target

  console.log "What does this deploy feature?"
  rl.onceAsync('line')
).then( (tagName) ->
  url = "https://api.github.com/v3/repos/unepwcmc/NRT/releases"

  name = tagName
  tagName = "#{theTarget}-#{tagName.toLowerCase().replace(/\s+/, '-')}"

  releaseOptions = {
    tag_name: tagName
    name: name
    body: name
  }

  request.postAsync(
    url: url
    json: releaseOptions
  )
)
