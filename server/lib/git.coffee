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
