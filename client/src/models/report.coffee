window.Backbone.Models || = {}

class window.Backbone.Models.Report extends Backbone.RelationalModel
  defaults:
    img: -> "/images/bkg#{Math.floor(Math.random()*3)}.jpg"
    title: "A new report"

  idAttribute: '_id'

  relations: [
    key: 'page'
    type: Backbone.HasOne
    relatedModel: 'Backbone.Models.Page'
    reverseRelation:
      key: 'parent'
      includeInJSON: false
  ]

  urlRoot: "/api/reports"

#For backbone relational
Backbone.Models.Report.setup()
