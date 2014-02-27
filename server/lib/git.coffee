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

exports.createTag = (tagName) ->
  return new Promise( (resolve, reject) ->
    createTagCommand = CommandRunner.spawn(
      "git", ["tag", "-a", tagName]
    )

    createTagCommand.on('close', (code) ->
      if code is 0
        resolve()
      else
        reject()
    )
  )
