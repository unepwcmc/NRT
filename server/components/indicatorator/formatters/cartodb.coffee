_ = require('underscore')

module.exports = (data) ->
  headers = data[0]

  headers = stripMetadataFromRow(headers)
  dates = _.sortBy(_.values(headers), (element) -> element)

  data = data[1]
  values = _.values(stripMetadataFromRow(data))

  records = []
  dates.forEach( (date, index) ->
    value = values[index]

    records.push(
      periodStart: date
      value: value
    )
  )

  return records

stripMetadataFromRow = (row) ->
  index = 4

  values = {}
  while row["field_#{index}"]?
    key = "field_#{index}"
    values[key] = row[key]
    index += 1

  return values
