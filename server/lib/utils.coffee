_ = require('underscore')
moment = require('moment')

module.exports =

  # Takes an array of objects with a sequelize query result structure and
  # returns an array of objects with all date values formatted
  formatDate: (arr, format="MMM Do YYYY") ->
    _.map arr, (obj) ->
      # We do not want to alter the original values
      obj = _.clone(obj.selectedValues)
      _.each obj, (value, key) ->
        if key == "updatedAt" or key == "createdAt"
          @[key] = moment(value).format(format)
      , obj
      obj