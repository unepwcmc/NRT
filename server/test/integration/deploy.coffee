assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
fs = require('fs')
sinon = require('sinon')
Q = require('q')
CommandRunner = require('../../bin/command-runner')
range_check = require('range_check')

suite('Deploy')

test('POST deploy after commit deploy branch on GitHub', (done) ->
  commitHookPayload = fs.readFileSync("#{process.cwd()}/test/data/github_commit.json", 'UTF8')

  rangeCheckStub = sinon.stub(range_check, 'in_range', -> true)

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
      rangeCheckStub.restore()
      commandSpawnStub.restore()

  ).fail( (err) ->
    console.error err
    rangeCheckStub.restore()
    commandSpawnStub.restore()
    done(err)
  )
)

test('POST deploy after commit to GitHub fails if branch is not deploy', (done) ->
  rangeCheckStub = sinon.stub(range_check, 'in_range', -> true)

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
      rangeCheckStub.restore()

  ).fail( (err) ->
    rangeCheckStub.restore()
    commandSpawnStub.restore()
    done(err)
  )
)

test("POST deploy fails if the IP is not of GitHub's servers", (done) ->
  rangeCheckStub = sinon.stub(range_check, 'in_range', -> false)

  Q.nfcall(
    request.post, {
      url: helpers.appurl('/deploy')
      json: true
      body: {}
    }
  ).spread( (res, body) ->

    try
      assert.equal res.statusCode, 401

      done()
    catch e
      done(e)
    finally
      rangeCheckStub.restore()

  ).fail( (err) ->
    rangeCheckStub.restore()
    done(err)
  )
)

test("POST deploy succeeds if the IP matches one of GitHub's servers", (done) ->
  rangeCheckStub = sinon.stub(range_check, 'in_range', -> true)

  Q.nfcall(
    request.post, {
      url: helpers.appurl('/deploy')
      json: true
      body: {}
    }
  ).spread( (res, body) ->

    try
      assert.notEqual res.statusCode, 401

      done()
    catch e
      done(e)
    finally
      rangeCheckStub.restore()

  ).fail( (err) ->
    rangeCheckStub.restore()
    done(err)
  )
)
