window.Utilities ||= {}

Utilities.cssClassify = (text) ->
  if text?
    classifiedText = text.toLowerCase()
    classifiedText = classifiedText.replace(/\ /g, '-')
    return classifiedText


window.nrtViz ||= {}

# Here we have utility functions that are shared across visualizations.

nrtViz.utils =
  calculateHeight: (width, widthRatio, heightRatio) ->
    width / widthRatio * heightRatio
