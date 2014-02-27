Promise = require 'bluebird'
Git = require('./git')

exports.updateFromTag = (tagName)->
  new Promise( (resolve, reject) ->
    Git.setEmail('deploy@nrt.io').then( ->
      Git.fetch()
    ).then(->
      Git.checkout(tagName)
    ).then(resolve).catch(reject)
  )

exports.deploy = (tagName) ->
  new Promise( (resolve, reject) ->
    exports.updateFromTag(tagName).then(resolve).catch(reject)
  )
