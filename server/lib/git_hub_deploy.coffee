Promise = require('bluebird')
AppConfig = require('../initializers/config')
request = Promise.promisifyAll(require('request'))
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

  start: ->
    new Promise( (resolve, reject) =>
      requestOptions = mergeWithDefaultOptions(
        url: "https://api.github.com/repos/unepwcmc/NRT/deployments"
        body: JSON.stringify(
          description: @tagName
          payload: {}
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

  @getDeployForTag: (tagName) ->
    new Promise( (resolve, reject) ->
      requestOptions = mergeWithDefaultOptions(
        url: "https://api.github.com/repos/unepwcmc/NRT/deployments"
      )

      request.get(requestOptions, (err, response) ->
        if err?
          reject(err)
        else
          deploys = JSON.parse(response.body)
          deploy = _.findWhere(deploys, {description: tagName})

          if deploy?
            resolve(deploy)
          else
            setTimeout((->
              GitHubDeploy.getDeployForTag(tagName).then(resolve).catch(reject)
            ), 1000)
      )
    )

  pollStatus: ->
    new Promise( (resolve, reject) =>
      request.get(
        url: "https://api.github.com/repos/unepwcmc/NRT/deployments/#{@id}/statuses"
      , (err, response) =>
        if err?
          reject(err)
        else
          statuses = JSON.parse(response.body)

          @printedStatusIDs ||= []
          for status in statuses
            unless status.id in @printedStatusIDs
              @printedStatusIDs.push status.id
              console.log "[#{status.createdAt}] #{status.state}: #{status.description}"
              if status.state in ['finished', 'failure']
                return resolve()
          
          setTimeout( =>
            @pollStatus().then(resolve).catch(reject)
          , 1000)
      )
    )

  @githubConfig: ->
    githubConfig = AppConfig.get('deploy').github

    if githubConfig?
      return githubConfig
    else
      throw new Error("Unable to find 'github' attribute in config")
