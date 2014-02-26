assert = require('chai').assert
helpers = require '../../helpers'
sinon = require 'sinon'
readline = require 'readline'
request = require 'request'

CommandRunner = require('../../../bin/command-runner')

suite('Deploy')

test('Asks for the server target and tag name, then creates a new tag', (done) ->
  readlineCount = 0
  responses = ['staging', 'New feature']

  sinon.stub(readline, 'createInterface', ->
    once: (event, callback) ->
      readlineCount += 1
      callback(responses[readlineCount-1])
  )

  spawnStub = sinon.stub(CommandRunner, 'spawn', ->
    process =
      on: (event, cb) ->
        if event is 'close'
          cb(0)

    return process
  )

  require('../../../lib/tasks/deploy').then(->
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
        "-m",
        "'#{responses[1]}'",
        "staging-new-feature"
      ]

      assert.deepEqual createTagArgs[1], expectedGitArgs,
        """
          Expected the git to be called with #{expectedGitArgs},
            but called with #{createTagArgs}"""

      done()

    catch err
      done(err)
    finally
      spawnStub.restore()

  ).catch(done)
)
