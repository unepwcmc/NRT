window.nrtViz ||= {}

nrtViz.barChart  = (conf={}) ->

  conf = _.extend conf, {
    # Follows d3 margin convention: http://bl.ocks.org/mbostock/3019563
    # Properties go clockwise from the top, as in CSS.
    margin:
     top: 20
     right: 20
     bottom: 40
     left: 30
    width: 760 #- margin.left - margin.right
    height: 500 #- margin.top - margin.bottom
    ####
    format: d3.format(".0")
    xScale: d3.scale.ordinal()
    yScale: d3.scale.linear()
    
  }

  calculateHeight = nrtViz.utils.calculateHeight
  width = conf.width - conf.margin.left
  # calculateHeight: (width, widthRatio, heightRatio) ->
  height = calculateHeight(conf.width, 2, 1.2) - conf.margin.bottom

  xAxis = d3.svg.axis().scale(conf.xScale).orient("bottom")
  yAxis = d3.svg.axis().scale(conf.yScale).orient("left")
    .tickFormat(conf.format)

  chart = (selection) ->
    xScale = conf.xScale
    yScale = conf.yScale
    margin = conf.margin
    # rangeRoundBands [min, max], padding, outer-padding
    xScale.rangeRoundBands [0, width], .1, .1
    yScale.range [height, 0]
    # Equivalent to: selection.node().__data__ 
    data = selection.datum()
    # Data input domains
    xScale.domain data.map (d) -> d.Year  # TODO
    yScale.domain [ 0, d3.max(data, (d) -> d.Percentage) ]  # TODO
    # Select the svg element, if it exists.
    svg = selection.selectAll("svg").data [data]
    # Otherwise, create the skeletal chart.
    gEnter = svg.enter().append("svg").append("g")
    gEnter.append("g").attr "class", "x axis"
    gEnter.append("g").attr "class", "y axis"
    # Set the outer dimensions.
    svg.attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    g = svg.select("g")
      # move right x pixels, move down y pixels:
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
    # Update the x-axis.
    g.select(".x.axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)
    # Update the y-axis.
    g.select(".y.axis")
      .call(yAxis)
    # bars!
    bar = svg.selectAll('.bar').data data
    #  .data (data) -> data.Percentage
    bar.enter()
      .append("rect")
      .attr("class", (d) -> "bar b_#{d.Year}")
      .attr("x", (d) -> xScale(d.Year) + margin.left)
      .attr("width", 0)
      .attr("y", (d) -> height )
      .attr("height", (d) -> 0)
      .style "fill", "LightSteelBlue "
    bar.exit().remove()
    bar.transition()
      .duration(500)
      .attr("x", (d) -> xScale(d.Year) + margin.left)
      .attr("width", xScale.rangeBand())
      .attr("y", (d) -> yScale(d.Percentage) + margin.top )
      .attr "height", (d) -> height - yScale(d.Percentage)

  chart.width = (c) ->
    return width  unless arguments.length
    width = c - conf.margin.left - conf.margin.right
    chart

  chart.height = (c) ->
    return height  unless arguments.length
    height = c - conf.margin.top - conf.margin.bottom
    chart

  {
    chart: chart
  }

