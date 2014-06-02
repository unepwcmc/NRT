Promise = require('bluebird')
readline = require('readline')
crypto = require('crypto')
_ = require('underscore')

Git = require('../git')
GitHubDeploy = require('../git_hub_deploy')

rl = readline.createInterface(
  input: process.stdin
  output: process.stdout
  terminal: false
)

normaliseDescription = (tagName) ->
  tagName.toLowerCase().replace(/\s+/g, '-')

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

createAndPushTag = (target, description) ->
  hash = crypto.randomBytes(5).toString('hex')
  tagName = "#{target}-#{normaliseDescription(description)}-#{hash}"

  console.log "Creating tag '#{tagName}'"
  Git.createTag(
    tagName, description
  ).then( ->
    Git.push(tagName)
  ).return(tagName)

pollDeploysForTag = (tagName) ->
  theDeploys = []
  finishedDeploys = []

  new Promise( (resolve, reject) ->
    GitHubDeploy.getDeploysForTag(
      tagName
    ).then( (deploys) ->
      theDeploys = deploys
      Promise.all(_.invoke(deploys, 'pollStatus'))
    ).then( (deploysWithResolution) ->
      finishedDeploys = _.union(finishedDeploys, deploysWithResolution)

      if theDeploys.length is finishedDeploys.length
        resolve(finishedDeploys)
      else
        setTimeout( ->
          pollDeploysForTag(tagName).then(resolve, reject)
        , 1000)
    )
  )

outputDeploymentResults = (deploysWithResolution) ->
  new Promise( (resolve, reject) ->
    for deployWithResolution in deploysWithResolution
      console.log "Deploy to #{deployWithResolution.deploy.server.name} #{deployWithResolution.resolution}"
    resolve()
  )

module.exports = ->
  askForTarget().then( (target) ->
    Promise.join(target, askForDescription())
  ).spread( (target, description) ->
    createAndPushTag(target, description)
  ).then( (tagName) ->
    pollDeploysForTag(tagName)
  ).then( (deploysWithResolution) ->
    outputDeploymentResults(deploysWithResolution)
  )
