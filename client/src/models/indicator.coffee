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

  getFieldType: (fieldName) ->
    fieldDefinitions = @get('indicatorDefinition')?.fields
    if fieldDefinitions?
      fieldDefinition = _.find(fieldDefinitions, (definition)->
        definition.name is fieldName
      )

      if fieldDefinition?.type
        return fieldDefinition.type
      else
        return 'Unknown'
    else
      return 'Unknown'

#For backbone relational
Backbone.Models.Indicator.setup()
