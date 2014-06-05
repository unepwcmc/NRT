Promise = require('bluebird')
crypto = require('crypto')
_ = require('underscore')

Git = require('./git')
GitHubDeploy = require('./git_hub_deploy')


class DeployLogger
  constructor: ->
    @printedStatusesPerDeploy = {}

  logLatestStatuses: (deploy) ->
    new Promise( (resolve, reject) =>
      @printedStatusesPerDeploy[deploy.id] ||= []
      for status in deploy.statuses
        printedStatus = "[ <#{deploy.server.name}> - #{status.createdAt} ] #{status.state}: #{status.description}"
        unless printedStatus in @printedStatusesPerDeploy[deploy.id]
          console.log(printedStatus)
          @printedStatusesPerDeploy[deploy.id].push(printedStatus)
      resolve()
    )

  outputDeploymentResults: (completedDeploys) ->
    new Promise( (resolve, reject) ->
      for completedDeploy in completedDeploys
        console.log "Deploy to #{completedDeploy.server?.name} #{completedDeploy.getResolution()}"
      resolve()
    )


module.exports = class DeployClient
  constructor: ->
    @logger = new DeployLogger()

  start: (target, description) ->
    createAndPushTag(
      target, description
    ).then( (tagName) =>
      @pollDeploysForTag(tagName)
    ).then( (completedDeploys) =>
      @logger.outputDeploymentResults(completedDeploys)
    )

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

  pollDeploysForTag: (tagName) ->
    theDeploys = []
    new Promise( (resolve, reject) =>
      GitHubDeploy.getDeploysForTag(
        tagName
      ).then( (deploys) ->
        theDeploys = deploys

        statusUpdatePromises = theDeploys.map( (deploy) ->
          deploy.populateStatuses()
        )
        Promise.all(statusUpdatePromises)
      ).then( =>
        statusLoggingPromises = theDeploys.map( (deploy) =>
          @logger.logLatestStatuses(deploy)
        )
        Promise.all(statusLoggingPromises)
      ).then( =>
        if theDeploys.every( (deploy) -> deploy.isCompleted())
          resolve(theDeploys)
        else
          setTimeout( =>
            @pollDeploysForTag(tagName).then(resolve).catch(reject)
          , 1000)
      )
    )
