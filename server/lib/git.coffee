Promise = require('bluebird')
CommandRunner = require '../bin/command-runner'

exports.createTag = (tagName, description) ->
  return new Promise( (resolve, reject) ->
    createTagCommand = CommandRunner.spawn(
      "git", ["tag", "-a", "-m", "'#{description}'", tagName]
    )

    createTagCommand.on('close', (code) ->
      if code is 0
        resolve()
      else
        reject(new Error("create tag command failed"))
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
        reject(new Error("push command failed"))
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
        reject(new Error("Failed to set email in git config"))
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
        reject(new Error("Failed to fetch changes from remote"))
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
        reject(new Error("Failed to checkout tag #{tagName}"))
    )
  )
