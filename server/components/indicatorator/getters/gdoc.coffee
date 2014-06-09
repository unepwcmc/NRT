_ = require('underscore')
Promise = require('bluebird')
GDocWrapper = require("../../../lib/gdoc_wrapper")

module.exports = class GDoc
  constructor: (@indicator) ->

  fetch: ->
    GDocWrapper.importByKey(
      @indicator.indicatorationConfig.spreadsheetKey
    ).then( (gdoc) ->
      gdoc.getWorksheetData('Data')
    )
