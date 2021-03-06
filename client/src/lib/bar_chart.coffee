window.nrtViz ||= {}

nrtViz.barChart = (conf={}) ->

  conf = _.extend conf, {
    # Follows d3 margin convention: http://bl.ocks.org/mbostock/3019563
    # Properties go clockwise from the top, as in CSS.
    margin:
     top: 20
     right: 60
     bottom: 85
     left: 30
    width: 760
    height: 500
    format: d3.format(".0")
    xScale: d3.scale.ordinal()
    yScale: d3.scale.linear()
  }

  margin = conf.margin
  width = conf.width - conf.margin.left - conf.margin.right
  height = nrtViz.utils.calculateHeight(conf.width, 2, 1) - conf.margin.bottom - conf.margin.top

  xKey = conf.xKey
  yKey = conf.yKey

  xAxis = d3.svg.axis().scale(conf.xScale).orient("bottom")
  yAxis = d3.svg.axis().scale(conf.yScale).orient("left")
    .tickFormat(conf.format)

  setSvgDomElement = (selection, data) ->
    svg = selection.selectAll("svg").data data
    svg.enter().append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)

  setOuterGDomElement = (selection, data) ->
    g = selection.selectAll('g.wrapper').data [data]
    g.enter().append('g').attr("class", "wrapper")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

  setGYAxisDomElement = (gAxis) ->
    gAxis.append("g").attr("class", "y axis")

    gAxis.select(".y.axis")
      .attr("transform", "translate(25,0)")
      .call(yAxis)

  setGXAxisDomElement = (gAxis) ->
    gAxis.append("g").attr("class", "x axis")

    gAxis.select(".x.axis")
      .attr("transform", "translate(30," + height + ")")
      .call(xAxis)
      .selectAll("text")
        .attr("y", 2)
        .attr("x", 9)
        .attr("dy", "1em")
        .attr("transform", "rotate(45)")
        .style("text-anchor", "start")

  setGAxisDomElement = (selection, data) ->
    gAxis = selection.selectAll('g.axis').data [data]
    gAxis.enter().append('g').attr("class", "axis")

    setGXAxisDomElement(gAxis)
    setGYAxisDomElement(gAxis)

    gAxis

  setGBarsDomElement = (selection, data) ->
    gBars = selection.selectAll('g.bars').data [data]
    gBars.enter().append("g").attr("class", "bars")

  setBarsDomElements =  (args, barColor) ->
    bars = args.selection.selectAll('.bar').data args.data

    bars.enter()
      .append("rect")
      .attr("class", (d) -> "bar b_#{d[xKey]}")

      .attr("x", (d) -> args.xScale(d[xKey]) + margin.left)
      .attr("y", (d) -> args.yScale(d[yKey]))

      .attr("width", args.xScale.rangeBand())
      .attr("height", (d) -> height - args.yScale(d[yKey]))

      .style("fill", barColor)

    bars.exit().remove()

    bars

  chart = (selection, barColor) ->
    xScale = conf.xScale
    yScale = conf.yScale

    # rangeRoundBands [min, max], padding, outer-padding
    xScale.rangeRoundBands [0, width], .1, .1
    yScale.range [height, 0]

    # Equivalent to: selection.node().__data__
    data = selection.datum()

    # Data input domains
    xScale.domain data.map (d) -> d.formatted[xKey]
    yScale.domain [ 0, d3.max(data, (d) -> d[yKey]) ]

    # svg generators
    svg = setSvgDomElement selection, [data]
    gOuter = setOuterGDomElement svg, [data]
    gAxis = setGAxisDomElement gOuter, [data]
    gBars = setGBarsDomElement gOuter, [data]
    args =
      selection: gBars
      xScale: xScale
      yScale: yScale
      data: data

    bars = setBarsDomElements args, barColor

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
