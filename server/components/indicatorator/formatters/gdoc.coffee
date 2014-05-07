module.exports = (data) ->
  records = []
  for rowIndex, rowContent of data

    if rowIndex != '1' # Avoid headers
      records.push({
        periodStart: rowContent['1'].value
        value: rowContent['2'].value
      })

  records