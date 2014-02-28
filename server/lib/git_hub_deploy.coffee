Promise = require('bluebird')
request = Promise.promisifyAll(require('request'))

module.exports = class GitHubDeploy
  constructor: (@tagName) ->

  start: ->
    new Promise( (resolve, reject) =>
      request.post({
        url: "https://api.github.com/repos/unepwcmc/NRT/deployments"
        body: JSON.stringify(
          description: @tagName
          payload: {}
          ref: @tagName
        )
      }, (err, response) =>
        if err?
          reject(err)
        else
          deployment = JSON.parse(response.body)
          @id = deployment.id
          resolve()
      )
    )

  updateDeployState: (state, description) ->
    new Promise( (resolve, reject) =>
      request.post({
        url: "https://api.github.com/repos/unepwcmc/NRT/deployments/#{@id}/statuses"
        body: JSON.stringify(
          state: state
          description: description
        )
      }, (err, response) ->
        if err?
          reject(err)
        else
          resolve()
      )
    )
