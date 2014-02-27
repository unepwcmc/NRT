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

  ).catch(->
    spawnStub.restore()
    done(err)
  )
)

test('createTag creates a new tag for the given name', (done)->
  newTagName = "fancy-banana"

  spawnStub = sinon.stub(CommandRunner, 'spawn', ->
    process =
      on: (event, cb) ->
        if event is 'close'
          cb(0)

    return process
  )

  Git.createTag(newTagName).then(->
    try
      createTagCall = spawnStub.firstCall

      assert.isNotNull createTagCall, "Expected a process to be spawn"

      createTagArgs = createTagCall.args

      assert.strictEqual(
        "git",
        createTagArgs[0],
        "Expected deploy task to spawn a git command"
      )

      expectedGitArgs = [
        "tag",
        "-a",
        "fancy-banana"
      ]

      assert.deepEqual createTagArgs[1], expectedGitArgs,
        """
          Expected the git to be called with #{expectedGitArgs},
            but called with #{createTagArgs}"""

      done()
    catch e
      done(e)
    finally
      spawnStub.restore()
  ).catch(->
    spawnStub.restore()
    done(err)
  )
)
