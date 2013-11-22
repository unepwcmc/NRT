assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
fs = require('fs')
sinon = require('sinon')
Q = require('q')
CommandRunner = require('../../bin/command-runner')

suite('Deploy')

test('POST deploy after commit deploy branch on GitHub', (done) ->
  commitHookPayload = fs.readFileSync("#{process.cwd()}/test/data/github_commit.json", 'UTF8')

  commandSpawnStub = sinon.stub(CommandRunner, 'spawn', ->
    return {on: ->}
  )

  Q.nfcall(
    request.post, {
      url: helpers.appurl('/deploy')
      json: true
      body:
        payload: commitHookPayload
    }
  ).spread( (res, body) ->

    try
      assert.strictEqual commandSpawnStub.callCount, 1,
        "Expected CommandRunner.spawn to be called once"

      assert.equal res.statusCode, 200
      done()
    catch e
      done(e)
    finally
      commandSpawnStub.restore()

  ).fail( (err) ->
    console.error err
    commandSpawnStub.restore()
    done(err)
  )
)

test('POST deploy after commit to GitHub fails if branch is not deploy', (done) ->
  commitHookResponse = JSON.parse(
    fs.readFileSync("#{process.cwd()}/test/data/github_commit_master.json", 'UTF8')
  )

  commandSpawnStub = sinon.stub(CommandRunner, 'spawn', ->
    return {on: ->}
  )

  Q.nfcall(
    request.post, {
      url: helpers.appurl('/deploy')
      json: true
      body: commitHookResponse
    }
  ).spread( (res, body) ->

    try
      assert.strictEqual commandSpawnStub.callCount, 0,
        "Expected CommandRunner.spawn to not be called once"

      assert.equal res.statusCode, 500
      done()
    catch e
      done(e)
    finally
      commandSpawnStub.restore()

  ).fail( (err) ->
    commandSpawnStub.restore()
    done(err)
  )
)
