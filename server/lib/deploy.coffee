Promise = require 'bluebird'
Git = require('./git')
GitHubDeploy = require('./git_hub_deploy')

exports.updateFromTag = (tagName, deploy)->
  new Promise( (resolve, reject) ->
    Git.setEmail('deploy@nrt.io').then( ->
      deploy.updateDeployState('pending', 'Fetching tags')
      Git.fetch()
    ).then( ->
      deploy.updateDeployState('pending', "Checking out tag '#{tagName}'")
      Git.checkout(tagName)
    ).then(resolve).catch(reject)
  )

exports.deploy = (tagName) ->
  new Promise( (resolve, reject) ->
    deploy = new GitHubDeploy(tagName)
    deploy.start().then(->
      exports.updateFromTag(tagName, deploy)
    ).then(resolve).catch(reject)
  )
