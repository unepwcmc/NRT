module.exports = (data) ->
  records = []
  for key, value of data.headers
    index = parseInt(key, 10)

    if index >= 3
      records.push(
        periodStart: dateToEpoch(value.value)
        value: data.data[key].value
      )

  records

dateToEpoch = (date) ->
  new Date(date).getTime()
