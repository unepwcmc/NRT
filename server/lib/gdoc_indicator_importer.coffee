Promise = require 'bluebird'
_ = require 'underscore'
request = require 'request'

GDocWrapper = require('./gdoc_wrapper')
Indicator = require('../models/indicator').model
Theme = require('../models/theme').model
AppConfig = require('../initializers/config')

DEFAULT_INDICATOR_DEFINITION =
  "period": "yearly",
  "xAxis": "year",
  "yAxis": "value",
  "geometryField": "geometry",
  "fields": [
    {
      "source": {
        "name": "periodStart",
        "type": "integer"
      },
      "name": "year",
      "type": "integer"
    }, {
      "source": {
        "name": "value",
        "type": "text"
      },
      "name": "value",
      "type": "decimal"
    }, {
      "source": {
        "name": "text",
        "type": "text"
      },
      "name": "text",
      "type": "text"
    }
  ]

mergeAttributesWithDefaults = (attributes) ->
  attributes.indicatorDefinition = _.extend(
    DEFAULT_INDICATOR_DEFINITION, attributes.indicatorDefinition
  )
  return attributes

extractRangesFromWorksheet = (worksheet) ->
  index = 2

  ranges = []
  while (range = worksheet[index.toString()])?
    ranges.push(
      threshold: parseFloat(range['1'].value, 10)
      text: range['2'].value
    )
    index = index + 1

  return ranges

module.exports = class GDocIndicatorImporter
  constructor: (@key) ->
    @indicatorProperties = {
      indicatorationConfig:
        source: 'gdoc'
        spreadsheetKey: @key
    }

  @import: (key) ->
    GDocWrapper.importByKey(key).then((spreadsheet) ->
      Promise.all([
        spreadsheet.getWorksheetData('Definition'),
        spreadsheet.getWorksheetData('Ranges')
      ])
    ).spread((definitionWorksheet, rangesWorksheet) ->
      indicatorImporter = new GDocIndicatorImporter(key)
      indicatorImporter.setDefinitionFromWorksheet(
        definitionWorksheet
      ).then( ->
        indicatorImporter.setRangesFromWorksheet(rangesWorksheet)
        indicatorImporter.createOrUpdateIndicator()
      )
    )

  setDefinitionFromWorksheet: (worksheet) ->
    themeTitle = worksheet['2']['2'].value

    return Theme.findOrCreateByTitle(themeTitle).then((theme) =>
      _.extend(@indicatorProperties, {
        shortName: worksheet['2']['1'].value
        name: worksheet['2']['1'].value
        theme: theme._id
        indicatorDefinition:
          unit: worksheet['2']['3'].value
          shortUnit: worksheet['2']['3'].value
      })
    )

  setRangesFromWorksheet: (worksheet) ->
    @indicatorProperties.indicatorationConfig.range = extractRangesFromWorksheet(
      worksheet
    )

  createOrUpdateIndicator: ->
    existingIndicator = Promise.promisify(Indicator.findOne, Indicator)(
      'indicatorationConfig.spreadsheetKey': @indicatorProperties.indicatorationConfig.spreadsheetKey
    ).then( (indicator) =>
      @indicatorProperties = mergeAttributesWithDefaults(@indicatorProperties)
      if indicator?
        Promise.promisify(indicator.update, indicator)(@indicatorProperties)
      else
        Promise.promisify(Indicator.create, Indicator)(@indicatorProperties)
    )

  registerChangeCallback: ->
    new Promise((resolve, reject) =>

      oauthKey = AppConfig.get('google_oauth_key')
      if !oauthKey?
        return reject(new Error("To register for Google Sheet changes you must provide a google OAuth bearer token in the  'google_oauth_key' attribute in your application config."))

      body = {
        id: @key
        type: "web_hook"
        address: "https://secure.nrt.io/indicators/#{@key}/change_event"
        token: "instance=#{AppConfig.get("instance_name")}"
      }

      request.post({
        url: "https://www.googleapis.com/drive/v2/files/#{@key}/watch"
        headers:
          "Authorization": "Bearer #{AppConfig.get('google_oauth_key')}"
        body: JSON.stringify(body)
      }, (err, res, body) ->
        if err?
          return reject(err)
        unless res.statusCode is 200
          return reject(new Error(
            "Error registering change callback: #{res.statusCode} #{body}"
          ))

        resolve()
      )
    )
