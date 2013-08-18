window.Backbone.Models || = {}

class window.Backbone.Models.Report extends Backbone.RelationalModel
  defaults:
    img: -> "/images/bkg#{Math.floor(Math.random()*4)}.jpg"
    bookmarked: false

  idAttribute: '_id'

  relations: [
    key: 'sections'
    type: Backbone.HasMany
    relatedModel: 'Backbone.Models.Section'
    collectionType: 'Backbone.Collections.SectionCollection'
    reverseRelation:
      key: 'report'
  ]

  url: =>
    if @get('_id')
      "/api/reports/#{@get('_id')}"
    else
      "/api/reports"

#For backbone relational
Backbone.Models.Report.setup()
