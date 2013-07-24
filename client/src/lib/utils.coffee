window.nrtViz ||= {}

# Here we have utility functions that are shared across visualizations.

nrtViz.utils = 

  calculateHeight: (width, widthRatio, heightRatio) ->
    width / widthRatio * heightRatio