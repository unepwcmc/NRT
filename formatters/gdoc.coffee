module.exports = (data) ->
  records = []
  for key, value of data.headers
    index = parseInt(key, 10)

    if index >= 3
      records.push(
        periodStart: dateToEpoch(value.value)
        value: percentageToDecimal(data.data[key].value)
      )

  records

percentageToDecimal = (percentage) ->
  parseInt(percentage, 10) / 100

dateToEpoch = (date) ->
  new Date(date).getTime()
