assert = require('chai').assert
helpers = require '../../helpers'
sinon = require 'sinon'
request = require 'request'
Promise = require 'bluebird'

CommandRunner = require('../../../bin/command-runner')
Git = require('../../../lib/git')
UpdateCode = require('../../../lib/update_code')

suite('UpdateCode')

test('.fromTag Sets the gits username,
pulls the given tag,
runs npm install in both client and server', (done) ->
  UpdateCode.fromTag().then( ->
    done()
  ).catch(done)
)
