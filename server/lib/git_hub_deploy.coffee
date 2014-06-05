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
    @statuses = []

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

  isCompleted: ->
    _.last(@statuses)?.state in ['success', 'failure']

  getResolution: ->
    _.last(@statuses)?.state

  populateStatuses: ->
    new Promise( (resolve, reject) =>
      requestOptions = mergeWithDefaultOptions(
        url: "https://api.github.com/repos/unepwcmc/NRT/deployments/#{@id}/statuses"
      )

      Promise.promisify(request.get, request)(
        requestOptions
      ).then( (response) =>
        # The .reverse() call is due to Github returning
        # statuses with a descending order on created_at :(
        parsedStatuses = JSON.parse(response.body).reverse()

        @statuses = parsedStatuses.map( (status) ->
          {
            createdAt: status.created_at,
            state: status.state,
            description: status.description
          }
        )
        resolve()
      ).catch(reject)
    )

  @githubConfig: ->
    githubConfig = AppConfig.get('deploy')?.github

    if githubConfig?
      return githubConfig
    else
      throw new Error("Unable to find 'deploy.github' attribute in config")
