window.Backbone.Models || = {}

class window.Backbone.Models.Report extends Backbone.RelationalModel
  defaults:
    img: -> "/images/bkg#{Math.floor(Math.random()*4)}.jpg"

  relations: [
    key: 'sections'
    type: Backbone.HasMany
    relatedModel: 'Backbone.Models.Section'
    collectionType: 'Backbone.Collections.SectionCollection'
    reverseRelation:
      key: 'report'
  ]

  url: "/api/report"
