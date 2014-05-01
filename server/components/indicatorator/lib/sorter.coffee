async = require('async')
Q     = require('q')

convertSortingOrder = (order) ->
  SORTING_ORDERS = {asc: 1, desc: -1}
  return SORTING_ORDERS[order.toLowerCase()] or throw new Error("No known sorting order '#{order}'")

exports.sortData = (sorting, data) ->
  deferred     = Q.defer()
  sortingOrder = convertSortingOrder(sorting.order)

  async.sortBy(data, (datum, next) ->
    next(null, datum[sorting.field]*sortingOrder)
  , (err, results) ->
    return deferred.reject(err) if err?
    deferred.resolve(results)
  )

  return deferred.promise