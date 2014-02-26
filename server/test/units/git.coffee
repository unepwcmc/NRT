assert = require('chai').assert
helpers = require '../helpers'
sinon = require 'sinon'

Git = require '../../lib/git'
CommandRunner = require '../../bin/command-runner'

suite('Git')

test('getBranch returns the current branch', (done) ->

  currentBranch = 'add-blink-tags'

  spawnStub = sinon.stub(CommandRunner, 'spawn', ->
    process =
      on: (event, cb) ->
        if event is 'close'
          cb(0)
      stdout:
        on: (event, cb) ->
          if event is 'data'
            cb(currentBranch)

    return process
  )

  Git.getBranch().then((branchName) ->
    try
      assert.isTrue spawnStub.calledWith("git", ["rev-parse", "--abbrev-ref", "HEAD"]),
        "Expected CommandRunner.spawn to be called with 'git rev-parse --abbrev-ref HEAD'"

      assert.strictEqual branchName, currentBranch,
        "Expected the current branch name to be returned"

      done()
    catch err
      done(err)
    finally
      spawnStub.restore()

  ).fail(->
    spawnStub.restore()
    done(err)
  )
)
