Promise = require 'bluebird'
Git = require('./git')

exports.updateFromTag = ->
  new Promise( (resolve, reject) ->
    Git.setEmail('deploy@nrt.io').then(resolve).catch(reject)
  )

exports.deploy = ->
  new Promise( (resolve, reject) ->
    resolve()
  )
