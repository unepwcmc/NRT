Q = require('q')
_ = require('underscore')

module.exports =
  statics: {}
  methods:
    convertResponseToIndicatorData: (data) ->
      unless _.isArray(data)
        throw "Can't convert poorly formed indicator data response:\n#{
          JSON.stringify(data)
        }\n expected response to be an array"

      return {
        indicator: @_id
        data: data
      }

    validateIndicatorDataFields: (indicatorData) ->
      firstRow = indicatorData.data[0]

      errorMsg = "Error validating indicator data for indicator '#{@title}'\n* "
      errors = []

      for field in @indicatorDefinition.fields
        unless field.source?
          errors.push "Indicator field definition doesn't include a source attribute: #{
            JSON.stringify(field)
          }"

      if errors.length is 0
        return true
      else
        errorMsg += errors.join('\n* ')
        errorMsg += "\n Data: #{JSON.stringify(indicatorData.data)}"
        throw new Error(errorMsg)

    replaceIndicatorData: (newIndicatorData) ->
      IndicatorData = require('../models/indicator_data').model
      deferred = Q.defer()

      IndicatorData.findOneAndUpdate(
        {indicator: @},
        newIndicatorData,
        {upsert: true}
        (err, indicatorData) ->
          if err?
            deferred.reject(err)
          else
            deferred.resolve(indicatorData)
      )

      return deferred.promise

    updateIndicatorData: ->
      deferred = Q.defer()

      Indicatorator = require('../components/indicatorator/lib/indicatorator')

      Indicatorator.getData(
        @
      ).then( (data) =>
        newIndicatorData = @convertResponseToIndicatorData(data)
        if @validateIndicatorDataFields(newIndicatorData)
          return @replaceIndicatorData(newIndicatorData)
        else
          throw new Error("Validation of indicator data fields failed")
      ).then( (indicatorData) ->
        deferred.resolve(indicatorData)
      ).catch( (err) ->
        deferred.reject(err)
      )

      return deferred.promise
