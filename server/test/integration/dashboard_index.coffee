assert = require('chai').assert
helpers = require '../helpers'
request = require('request')
async = require('async')
url = require('url')
_ = require('underscore')

appurl = (path) ->
  url.resolve('http://localhost:3001', path)

