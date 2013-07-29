_ = require('underscore')
moment = require('moment')

module.exports =

  # takes an array of objects (these can be sequelize query results) and
  # returns an array of objects with all date values formatted
  formatDate: (arr, format="MMM Do YYYY") ->
    _.map arr, (obj) ->
      obj = obj.selectedValues
      _.each obj, (value, key) ->
        if key == "updatedAt" or key == "createdAt"
          @[key] = moment(value).format(format)
      , obj
      obj