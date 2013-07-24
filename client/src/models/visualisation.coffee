window.Backbone.Models || = {}

class window.Backbone.Models.Visualisation extends Backbone.RelationalModel

  defaults:
    data:
      fields: [
        name: "Percentage"
        type: "esriFieldTypeDouble"
        unit: "percentage"
      ,
        name: "Year"
        type: "esriFieldTypeString"
        unit: "year"
      ]
      features: [
        attributes:
          Percentage: 28
          Year: 2010
      ,
        attributes:
          Percentage: 26
          Year: 2011
      ,
        attributes:
          Percentage: 32
          Year: 2012
      ,
        attributes:
          Percentage: 132
          Year: 2013
      ]

  formatDataForChart: ->
    _.map(@get("data").features, (el) -> el.attributes)