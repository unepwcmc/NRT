Promise = require 'bluebird'
Git = require('./git')
GitHubDeploy = require('./git_hub_deploy')
CommandRunner = require('../lib/command_runner')

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
  new Promise( (resolve, reject) ->
    originalDir = process.cwd()
    process.chdir('../client')

    npmInstall = CommandRunner.spawn('npm', ['install'])
    npmInstall.on('close', (statusCode) ->
      if statusCode is 0
        process.chdir(originalDir)
        resolve()
      else
        reject(new Error("npm install exited with status code #{statusCode}"))
    )
  )

exports.npmInstallServer = ->
  new Promise( (resolve, reject) ->
    npmInstall = CommandRunner.spawn('npm', ['install'])
    npmInstall.on('close', (statusCode) ->
      if statusCode is 0
        resolve()
      else
        reject(new Error("npm install exited with status code #{statusCode}"))
    )
  )

exports.grunt = ->
  new Promise( (resolve, reject) ->
    originalDir = process.cwd()
    process.chdir('../client')

    grunt = CommandRunner.spawn('grunt')
    grunt.on('close', (statusCode) ->
      if statusCode is 0
        process.chdir(originalDir)
        resolve()
      else
        reject(new Error("grunt exited with status code #{statusCode}"))
    )
  )

exports.deploy = (tagName) ->
  new Promise( (resolve, reject) ->
    deploy = new GitHubDeploy(tagName)
    deploy.start().then(->
      exports.updateFromTag(tagName, deploy)
    ).then(->
      deploy.updateDeployState('pending', 'Installing client libs')
    ).then(
      exports.npmInstallClient
    ).then(->
      deploy.updateDeployState('pending', 'Compiling assets with grunt')
    ).then(
      exports.grunt
    ).then(->
      deploy.updateDeployState('pending', 'Installing server libs')
    ).then(
      exports.npmInstallServer
    ).then(->
      deploy.updateDeployState('success', 'Deploy completed successfully')
    ).then(
      resolve
    ).catch( (err) ->
      deploy.updateDeployState('failure', err.message).finally( ->
        reject(err)
      )
    )
  )
