window.nrtViz ||= {}

nrtViz.chartDataParser = (data) ->

  _.map(data.features, (el) -> el.attributes)