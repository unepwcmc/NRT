Promise = require('bluebird')
crypto = require('crypto')
_ = require('underscore')

Git = require('./git')
GitHubDeploy = require('./git_hub_deploy')


normaliseDescription = (tagName) ->
  tagName.toLowerCase().replace(/\s+/g, '-')

createAndPushTag = (target, description) ->
  hash = crypto.randomBytes(5).toString('hex')
  tagName = "deploy-#{target}-#{normaliseDescription(description)}-#{hash}"

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
      console.log "Deploy to #{deployWithResolution.deploy.server?.name} #{deployWithResolution.resolution}"
    resolve()
  )

module.exports =
  start: (target, description) ->
    createAndPushTag(
      target, description
    ).then( (tagName) ->
      pollDeploysForTag(tagName)
    ).then( (deploysWithResolution) ->
      outputDeploymentResults(deploysWithResolution)
    )
