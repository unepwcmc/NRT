assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
fs = require('fs')
Q = require('q')

suite('Deploy')

test('POST deploy after commit to GitHub', (done) ->
  commitHookResponse = JSON.parse(
    fs.readFileSync("#{process.cwd()}/test/data/github_commit.json", 'UTF8')
  )

  Q.nfcall(
    request.post, {
      url: helpers.appurl('/deploy')
      json: true
      body: commitHookResponse
    }
  ).spread( (res, body) ->

    assert.equal res.statusCode, 200
    done()

  ).fail( (err) ->
    console.error err
    throw new Error(err)
  )
)

test('POST deploy after commit to GitHub fails if branch is not deploy', (done) ->
  commitHookResponse = JSON.parse(
    fs.readFileSync("#{process.cwd()}/test/data/github_commit_master.json", 'UTF8')
  )

  Q.nfcall(
    request.post, {
      url: helpers.appurl('/deploy')
      json: true
      body: commitHookResponse
    }
  ).spread( (res, body) ->

    assert.equal res.statusCode, 500
    done()

  ).fail( (err) ->
    console.error err
    throw new Error(err)
  )
)
