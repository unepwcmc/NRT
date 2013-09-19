window.nrtViz ||= {}

nrtViz.lineChart  = (conf={}) ->

  conf = _.extend conf, {
    # Follows d3 margin convention: http://bl.ocks.org/mbostock/3019563
    # Properties go clockwise from the top, as in CSS.
    margin:
     top: 20
     right: 20
     bottom: 40
     left: 30
    width: 760
    height: 500
    ####
    format: d3.format(".0")
    xScale: d3.scale.linear() #TODO?: d3.time.scale()
    yScale: d3.scale.linear()
    colour: "LightSteelBlue"
    areaColour: "Lavender"
  }

  margin = conf.margin
  calculateHeight = nrtViz.utils.calculateHeight
  width = conf.width - conf.margin.left - conf.margin.right
  height = calculateHeight(conf.width, 2, .9) - conf.margin.bottom -
    conf.margin.top
  xKey = conf.xKey
  yKey = conf.yKey
  # TODO: enable axis configurations
  xAxis = d3.svg.axis().scale(conf.xScale).tickSize(-height)
    .tickFormat(d3.format(""))
  yAxis = d3.svg.axis().scale(conf.yScale).orient("left")
    .tickFormat(conf.format)

  areaGenerator = d3.svg.area().interpolate("monotone")
  .x((d) ->
    conf.xScale d[xKey]
  )
  .y0(height)
  .y1((d) ->
    conf.yScale d[yKey]
  )

  lineGenerator = d3.svg.line().interpolate("monotone")
  .x((d) ->
    conf.xScale d[xKey]
  ).y((d) ->
    conf.yScale d[yKey]
  )

  setSvgDomElement = (selection, data) ->
    svg = selection.selectAll("svg").data data
    svg.enter().append("svg")
      .attr("class", "line-chart")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    
  setOuterGDomElement = (selection, data) ->
    g = selection.selectAll('g.wrapper').data [data]
    g.enter().append('g').attr("class", "wrapper")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

  setGAxisDomElement = (selection, data) ->
    gAxis = selection.selectAll('g.axis').data [data]
    gAxis.enter().append('g').attr("class", "axis")
    gAxis.append("g").attr("class", "x axis")
    gAxis.append("g").attr("class", "y axis")
    # Update the x-axis.
    gAxis.select(".x.axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)
    # Update the y-axis.
    gAxis.select(".y.axis")
      .call(yAxis)
    gAxis

  setClipPath = (selection) ->
    selection.append("clipPath")
      .attr("id", "clip")
    .append("rect")
      .attr("width", width)
      .attr("height", height)
    selection

  setAreaDomElement = (selection, data) ->
    # TODO: would be nice to have entry and exit points.
    selection.append('path')
      .datum(data)
      .attr("class", "area")
      .attr("clip-path", "url(#clip)")
      .attr("d", areaGenerator)
      .style("fill", conf.areaColour)
      
  setLineDomElement = (selection, data) ->
    selection.append('path')
      .datum(data)
      .attr("class", "line")
      .attr("clip-path", "url(#clip)")
      .attr("d", lineGenerator)
      .style("stroke", conf.colour)


  chart = (selection) ->
    xScale = conf.xScale
    yScale = conf.yScale
    xScale.range [0, width]
    yScale.range [height, 0]
    # Equivalent to: selection.node().__data__ 
    data = selection.datum()
    # Data input domains
    xScale.domain [data[0][xKey], data[data.length - 1][xKey]]
    xAxis.tickValues _.map(data, (d) -> d[xKey])
    yScale.domain([ 0, d3.max(data, (d) -> d[yKey]) ]).nice()
    # svg generators
    svg = setSvgDomElement selection, [data]
    gOuter = setOuterGDomElement svg, [data]
    svg = setClipPath svg
    setAreaDomElement gOuter, data
    gAxis = setGAxisDomElement gOuter, [data]
    setLineDomElement gOuter, data


  chart.width = (c) ->
    return width  unless arguments.length
    width = c - conf.margin.left - conf.margin.right
    chart

  chart.height = (c) ->
    return height  unless arguments.length
    height = c - conf.margin.top - conf.margin.bottom
    chart

  chart.colour = (c) ->
    return colour  unless arguments.length
    colour = conf.colour = c
    chart

  chart.areaColour = (c) ->
    return areaColour  unless arguments.length
    areaColour = conf.areaColour = c
    chart

  {
    chart: chart
  }
