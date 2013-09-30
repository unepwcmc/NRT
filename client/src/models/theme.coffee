window.Backbone.Models || = {}

class window.Backbone.Models.Theme extends Backbone.RelationalModel
  idAttribute: '_id'

  urlRoot: '/api/themes'

  relations: [
    key: 'page'
    type: Backbone.HasOne
    relatedModel: 'Backbone.Models.Page'
    reverseRelation:
      key: 'parent'
      includeInJSON: false
  ]

#For backbone relational
Backbone.Models.Theme.setup()
