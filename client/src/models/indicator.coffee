window.Backbone.Models || = {}

class window.Backbone.Models.Indicator extends Backbone.RelationalModel
  idAttribute: '_id'

  urlRoot: '/api/indicators'

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


#For backbone relational
Backbone.Models.Indicator.setup()
