Promise = require('bluebird')
AppConfig = require('../initializers/config')
request = Promise.promisifyAll(require('request'))

REQUEST_HEADERS =
  'Accept': 'application/vnd.github.cannonball-preview+json'
  'User-Agent': 'National Reporting Toolkit Deployment Bot 2000x'

module.exports = class GitHubDeploy
  constructor: (@tagName) ->

  start: ->
    new Promise( (resolve, reject) =>
      request.post({
        url: "https://api.github.com/repos/unepwcmc/NRT/deployments"
        headers: REQUEST_HEADERS
        auth: @githubConfig()
        body: JSON.stringify(
          description: @tagName
          payload: {}
          ref: @tagName
          force: true
        )
      }, (err, response) =>
        if err?
          reject(err)
        else if response.statusCode isnt 201
          reject(JSON.parse(response.body))
        else
          deployment = JSON.parse(response.body)
          @id = deployment.id
          console.log "Created deploy #{@id}"
          resolve()
      )
    )

  updateDeployState: (state, description) ->
    new Promise( (resolve, reject) =>
      request.post({
        url: "https://api.github.com/repos/unepwcmc/NRT/deployments/#{@id}/statuses"
        headers: REQUEST_HEADERS
        auth: @githubConfig()
        body: JSON.stringify(
          state: state
          description: description
        )
      }, (err, response) ->
        if err?
          reject(err)
        else if response.statusCode isnt 201
          reject(JSON.parse(response.body))
        else
          resolve()
      )
    )

  githubConfig: ->
    username: AppConfig.get('deploy').github.username
    password: AppConfig.get('deploy').github.password
