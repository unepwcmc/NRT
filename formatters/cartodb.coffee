DataConverter = require '../lib/data_converter'
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
      periodStart: DataConverter.convert('year', 'epoch', date)
      value: DataConverter.convert('percentage', 'decimal', value)
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
