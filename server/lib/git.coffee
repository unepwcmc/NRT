Q = require 'q'
CommandRunner = require '../bin/command-runner'

exports.getBranch = ->
  deferred = Q.defer()

  getBranchCommand = CommandRunner.spawn(
    "git", ["rev-parse", "--abbrev-ref", "HEAD"]
  )
  branchName = ''

  getBranchCommand.stdout.on('data', (str) ->
    branchName = str
  )

  getBranchCommand.on('close', (code) ->
    if code is 0
      deferred.resolve(branchName)
    else
      deferred.reject('git branch command failed')
  )

  return deferred.promise
