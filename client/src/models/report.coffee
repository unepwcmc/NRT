window.Backbone.Models || = {}

class window.Backbone.Models.Report extends Backbone.RelationalModel
  defaults:
    img: -> "/images/bkg#{Math.floor(Math.random()*3)}.jpg"
    title: "A new report"

  idAttribute: '_id'

  relations: [{
    key: 'page'
    type: Backbone.HasOne
    relatedModel: 'Backbone.Models.Page'
    reverseRelation:
      key: 'parent'
      includeInJSON: false
  },{
    key: 'owner'
    type: Backbone.HasOne
    relatedModel: 'Backbone.Models.User'
    includeInJSON: Backbone.Models.User::idAttribute
  }]

  urlRoot: "/api/reports"

  initialize: ->
    @listenTo(@, "change:#{Backbone.Models.Report::idAttribute}", @updatePageAssociation)

  updatePageAssociation: =>
    page = @get('page')
    if page?
      page.set('parent_id', @get(Backbone.Models.Report::idAttribute))
      page.set('parent_type', 'Report')

#For backbone relational
Backbone.Models.Report.setup()
