module.exports = (data) ->
  records = []
  for key, value of data.headers
    index = parseInt(key, 10)

    if index >= 4
      record =
        periodStart: dateToEpoch(value.value)
        value: percentageToDecimal(data.data[0][key].value)


      if data.data.length > 1
        subIndicators = extractSubIndicators(data.data, key, dateToEpoch(value.value))
        record.subIndicator = subIndicators

      records.push record

  records

extractSubIndicators = (data, key, periodStart) ->
  subIndicators = []
  for i in [1..data.length - 1]
    row = data[i]

    subIndicators.push(
      subIndicator: row['3'].value
      value: percentageToDecimal(row[key].value)
      periodStart: periodStart
    )

  return subIndicators

percentageToDecimal = (percentage) ->
  parseInt(percentage, 10) / 100

dateToEpoch = (date) ->
  new Date(date).getTime()
