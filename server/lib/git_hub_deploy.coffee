Promise = require('bluebird')
AppConfig = require('../initializers/config')
request = require('request')
_ = require('underscore')

REQUEST_HEADERS =
  'Accept': 'application/vnd.github.cannonball-preview+json'
  'User-Agent': 'National Reporting Toolkit Deployment Bot 2000x'

mergeWithDefaultOptions = (options) ->
  defaultOptions =
    headers: REQUEST_HEADERS
    auth: GitHubDeploy.githubConfig()

  return _.extend(defaultOptions, options)

module.exports = class GitHubDeploy
  constructor: (@tagName) ->
    @server = {}

  start: ->
    new Promise( (resolve, reject) =>
      requestOptions = mergeWithDefaultOptions(
        url: "https://api.github.com/repos/unepwcmc/NRT/deployments"
        body: JSON.stringify(
          description: @tagName
          payload: {
            server:
              name: AppConfig.get('server')?.name
          }
          ref: @tagName
          force: true
        )
      )

      request.post(requestOptions, (err, response) =>
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
      requestOptions = mergeWithDefaultOptions(
        url: "https://api.github.com/repos/unepwcmc/NRT/deployments/#{@id}/statuses"
        body: JSON.stringify(
          state: state
          description: description
        )
      )

      request.post(requestOptions, (err, response) ->
        if err?
          reject(err)
        else if response.statusCode isnt 201
          reject(JSON.parse(response.body))
        else
          resolve()
      )
    )

  @getDeploysForTag: (tagName) ->
    new Promise( (resolve, reject) ->
      requestOptions = mergeWithDefaultOptions(
        url: "https://api.github.com/repos/unepwcmc/NRT/deployments"
      )

      request.get(requestOptions, (err, response) ->
        if err?
          reject(err)
        else
          allDeploys = JSON.parse(response.body)
          deploys = _.filter(allDeploys, (deploy) ->
            deploy.description is tagName
          )

          if deploys.length isnt 0
            gitHubDeploys = deploys.map( (deploy) ->
              gitHubDeploy = new GitHubDeploy(tagName)
              gitHubDeploy.id = deploy.id
              gitHubDeploy.server = deploy.payload.server || {}
              gitHubDeploy
            )
            resolve(gitHubDeploys)
          else
            setTimeout((->
              GitHubDeploy.getDeploysForTag(tagName).then(resolve).catch(reject)
            ), 1000)
      )
    )

  pollStatus: ->
    new Promise( (resolve, reject) =>
      requestOptions = mergeWithDefaultOptions(
        url: "https://api.github.com/repos/unepwcmc/NRT/deployments/#{@id}/statuses"
      )

      request.get(requestOptions, (err, response) =>
        if err?
          reject(err)
        else
          statuses = JSON.parse(response.body)

          @printedStatusIDs ||= []
          for status in statuses
            unless status.id in @printedStatusIDs
              @printedStatusIDs.push status.id
              console.log "[ <#{@server.name}> - #{status.created_at} ] #{status.state}: #{status.description}"
              if status.state in ['success', 'failure']
                return resolve({deploy: @, resolution: status.state})

          setTimeout( =>
            @pollStatus().then(resolve).catch(reject)
          , 1000)
      )
    )

  @githubConfig: ->
    githubConfig = AppConfig.get('deploy')?.github

    if githubConfig?
      return githubConfig
    else
      throw new Error("Unable to find 'deploy.github' attribute in config")
