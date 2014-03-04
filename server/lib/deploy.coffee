Promise = require 'bluebird'
Git = require('./git')
GitHubDeploy = require('./git_hub_deploy')

exports.updateFromTag = (tagName, deploy)->
  new Promise( (resolve, reject) ->
    Git.setEmail('deploy@nrt.io').then( ->
      deploy.updateDeployState('pending', 'Fetching tags')
    ).then(
      Git.fetch
    ).then(->
      deploy.updateDeployState('pending', "Checking out tag '#{tagName}'")
    ).then(->
      Git.checkout(tagName)
    ).then(resolve).catch(reject)
  )

exports.npmInstallClient = ->

exports.npmInstallServer = ->

exports.grunt = ->

exports.deploy = (tagName) ->
  new Promise( (resolve, reject) ->
    deploy = new GitHubDeploy(tagName)
    deploy.start().then(->
      exports.updateFromTag(tagName, deploy)
    ).then(
      exports.grunt
    ).then(
      exports.npmInstallClient
    ).then(
      exports.npmInstallServer
    ).then(resolve).catch( (err) ->
      deploy.updateDeployState('failure', err.message).finally( ->
        reject(err)
      )
    )
  )
