Promise = require('bluebird')
CommandRunner = require '../bin/command-runner'

exports.getBranch = ->
  new Promise( (resolve, reject) ->
    getBranchCommand = CommandRunner.spawn(
      "git", ["rev-parse", "--abbrev-ref", "HEAD"]
    )
    branchName = ''

    getBranchCommand.stdout.on('data', (str) ->
      branchName = str
    )

    getBranchCommand.on('close', (code) ->
      if code is 0
        resolve(branchName)
      else
        reject('git branch command failed')
    )
  )

exports.createTag = (tagName, description) ->
  return new Promise( (resolve, reject) ->
    createTagCommand = CommandRunner.spawn(
      "git", ["tag", "-a", "-m", "'#{description}'", tagName]
    )

    createTagCommand.on('close', (code) ->
      if code is 0
        resolve()
      else
        reject("create tag command failed")
    )
  )

exports.push = (tagName) ->
  new Promise( (resolve, reject) ->
    pushCommand = CommandRunner.spawn(
      "git", ["push", "origin", tagName]
    )

    pushCommand.on('close', (code) ->
      if code is 0
        resolve()
      else
        reject("push command failed")
    )
  )

exports.setEmail = (email) ->
  new Promise( (resolve, reject) ->
    setConfigCommand = CommandRunner.spawn(
      "git", ["config", "user.email", "'#{email}'"]
    )

    setConfigCommand.on('close', (code) ->
      if code is 0
        resolve()
      else
        reject("Failed to set email in git config")
    )
  )

exports.fetch = ->
  new Promise( (resolve, reject) ->
    fetchCommand = CommandRunner.spawn(
      "git", ["fetch"]
    )

    fetchCommand.on('close', (code) ->
      if code is 0
        resolve()
      else
        reject("Failed to fetch changes from remote")
    )
  )

exports.checkout = (tagName) ->
  new Promise( (resolve, reject) ->
    checkoutCommand = CommandRunner.spawn(
      "git", ["checkout", tagName]
    )

    checkoutCommand.on('close', (code) ->
      if code is 0
        resolve()
      else
        reject("Failed to checkout tag #{tagName}")
    )
  )
