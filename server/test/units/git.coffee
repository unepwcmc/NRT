assert = require('chai').assert
sinon = require 'sinon'

Git = require '../../lib/git'
CommandRunner = require '../../lib/command_runner'

suite('Git')

test('createTag creates a new tag for the given name and description', (done)->
  newTagName = "fancy-banana"
  newDescription = "Fancy Banana"

  spawnStub = sinon.stub(CommandRunner, 'spawn', ->
    process =
      on: (event, cb) ->
        if event is 'close'
          cb(0)

    return process
  )

  Git.createTag(newTagName, newDescription).then(->
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
        "'#{newDescription}'",
        "#{newTagName}"
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
  ).catch((err)->
    spawnStub.restore()
    done(err)
  )
)

test('.push pushes the given item', (done)->
  tagName = "fancy-banana"

  spawnStub = sinon.stub(CommandRunner, 'spawn', ->
    process =
      on: (event, cb) ->
        if event is 'close'
          cb(0)

    return process
  )

  Git.push(tagName).then(->
    try
      pushCall = spawnStub.firstCall

      assert.isNotNull pushCall, "Expected a process to be spawned"

      pushTagArgs = pushCall.args

      assert.strictEqual(
        "git",
        pushTagArgs[0],
        "Expected push task to spawn a git command"
      )

      expectedGitArgs = [
        "push",
        "origin",
        "#{tagName}"
      ]

      assert.deepEqual pushTagArgs[1], expectedGitArgs,
        """
          Expected git to be called with #{expectedGitArgs},
            but called with #{pushTagArgs}"""

      done()
    catch e
      done(e)
    finally
      spawnStub.restore()
  ).catch((err)->
    spawnStub.restore()
    done(err)
  )
)

test('setEmail sets the git user email config', (done)->
  spawnStub = sinon.stub(CommandRunner, 'spawn', ->
    process =
      on: (event, cb) ->
        if event is 'close'
          cb(0)

    return process
  )

  email = "deploy@nrt.io"
  Git.setEmail(email).then(->
    try
      setEmailCall = spawnStub.firstCall

      assert.isNotNull setEmailCall, "Expected a process to be spawned"

      setEmailArgs = setEmailCall.args

      assert.strictEqual(
        "git",
        setEmailArgs[0],
        "Expected deploy task to spawn a git command"
      )

      expectedGitArgs = [
        "config",
        "user.email",
        "'#{email}'"
      ]

      assert.deepEqual setEmailArgs[1], expectedGitArgs,
        """
          Expected git to be called with #{expectedGitArgs},
            but called with #{setEmailArgs}"""

      done()
    catch e
      done(e)
    finally
      spawnStub.restore()
  ).catch((err)->
    spawnStub.restore()
    done(err)
  )
)

test('.fetch runs git fetch', (done)->
  tagName = 'corporate-banana'
  spawnStub = sinon.stub(CommandRunner, 'spawn', ->
    return {
      on: (event, cb) ->
        if event is 'close'
          cb(0)
    }
  )

  Git.fetch().then(->
    try
      fetchCall = spawnStub.firstCall

      assert.isNotNull fetchCall, "Expected a process to be spawned"

      gitFetchArgs = fetchCall.args

      assert.strictEqual(
        "git",
        gitFetchArgs[0],
        "Expected deploy task to spawn a git command"
      )

      expectedGitArgs = [
        "fetch"
      ]

      assert.deepEqual gitFetchArgs[1], expectedGitArgs,
        """
          Expected git to be called with #{expectedGitArgs},
            but called with #{gitFetchArgs}"""

      done()
    catch e
      done(e)
    finally
      spawnStub.restore()
  ).catch((err)->
    spawnStub.restore()
    done(err)
  )
)


test('.checkout checkouts the given tag', (done)->
  tagName = 'corporate-banana'
  spawnStub = sinon.stub(CommandRunner, 'spawn', ->
    return {
      on: (event, cb) ->
        if event is 'close'
          cb(0)
    }
  )

  Git.checkout(tagName).then(->
    try
      fetchCall = spawnStub.firstCall

      assert.isNotNull fetchCall, "Expected a process to be spawned"

      gitFetchArgs = fetchCall.args

      assert.strictEqual(
        "git",
        gitFetchArgs[0],
        "Expected deploy task to spawn a git command"
      )

      expectedGitArgs = [
        "checkout",
        tagName
      ]

      assert.deepEqual gitFetchArgs[1], expectedGitArgs,
        """
          Expected git to be called with #{expectedGitArgs},
            but called with #{gitFetchArgs}"""

      done()
    catch e
      done(e)
    finally
      spawnStub.restore()
  ).catch((err)->
    spawnStub.restore()
    done(err)
  )
)

test('.checkout rejects with an error if it fails', (done) ->
  tagName = 'corporate-banana'
  spawnStub = sinon.stub(CommandRunner, 'spawn', ->
    return {
      on: (event, cb) ->
        if event is 'close'
          cb(1)
    }
  )

  Git.checkout(tagName).then(->
    spawnStub.restore()
    done(new Error("Expected command to fail"))
  ).catch((err)->
    try
      assert.strictEqual err.constructor.name, "Error",
        "Expect checkout to reject with an error"

      assert.strictEqual err.message, "Failed to checkout tag #{tagName}"

      done()
    catch assertErr
      done(assertErr)
    finally
    spawnStub.restore()
  )
)
