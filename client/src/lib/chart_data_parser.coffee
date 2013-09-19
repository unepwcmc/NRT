window.nrtViz ||= {}

# Here we have the functions that parse the incoming raw data (ESRI REST 
#  Services, etc...) into a d3 friendly format.

nrtViz.chartDataParser = (data) ->
  _.map(data.features, (el) -> el.attributes)

nrtViz.chartTicksFilter= (data, lenght) ->
  lenght ||= 10
  if data.lenght > lenght
    return _.filter(data, (val) -> isNumber(val) and (val % 2 == 0) )
  return data