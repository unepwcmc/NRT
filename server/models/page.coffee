mongoose = require('mongoose')
Section = require('./section.coffee').schema
async = require('async')
_ = require('underscore')
sectionNestingModel = require('../mixins/section_nesting_model.coffee')
Q = require('q')

pageSchema = mongoose.Schema(
  title: String
  parent_id: mongoose.Schema.Types.ObjectId
  parent_type: String
  sections: [mongoose.Schema(
    title: String
    type: String
    indicator: {type: mongoose.Schema.Types.ObjectId, ref: 'Indicator'}
  )]
)

_.extend(pageSchema.statics, sectionNestingModel)

pageSchema.methods.getParent = ->
  Ownable = require("./#{@parent_type.toLowerCase()}.coffee").model
  return Q.nsend(Ownable, 'findOne', @parent_id)

pageSchema.methods.getOwnable = ->
  @getParent()

pageSchema.methods.canBeEditedBy = (user) ->
  deferred = Q.defer()

  @getOwnable().then( (ownable) ->
    if ownable.owner.toString() is user.id
      deferred.resolve()
    else
      deferred.reject(new Error('User is not the owner of this page'))
  ).fail( (err) ->
    deferred.resolve()
  )

  return deferred.promise

Page = mongoose.model('Page', pageSchema)

module.exports = {
  schema: pageSchema
  model: Page
}
