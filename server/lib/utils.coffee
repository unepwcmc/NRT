_ = require('underscore')
moment = require('moment')

module.exports =

  # Takes a sequelize query result array and returns an array
  # of simple JavaScript objects with all dates formatted.
  formatDate: (arr, format="MMM Do YYYY") ->
    _.map arr, (obj) ->
      obj = obj.selectedValues
      _.each obj, (value, key) ->
        if key == "updatedAt" or key == "createdAt"
          @[key] = moment(value).format(format)
      , obj
      obj