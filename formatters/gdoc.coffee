DataConverter = require '../lib/data_converter'

module.exports = (data) ->
  records = []
  for key, value of data.headers
    index = parseInt(key, 10)

    if index >= 4
      record =
        periodStart: DataConverter.convert('date', 'epoch', value.value)
        value: DataConverter.convert('percentage', 'decimal', data.data[0][key].value)


      if data.data.length > 1
        subIndicators = extractSubIndicators(
          data.data, key, DataConverter.convert('date', 'epoch', value.value)
        )
        record.subIndicator = subIndicators

      records.push record

  records

extractSubIndicators = (data, key, periodStart) ->
  subIndicators = []
  for i in [1..data.length - 1]
    row = data[i]

    subIndicators.push(
      subIndicator: row['3'].value
      value: DataConverter.convert('percentage', 'decimal', row[key].value)
      periodStart: periodStart
    )

  return subIndicators
