window.Backbone ||= {}
window.Backbone.Collections ||= {}

class Backbone.Collections.SectionCollection extends Backbone.Collection
  model: Backbone.Models.Section
  
  reorderByCid: (cids) ->
    orderedModels = []
    for cid in cids
      orderedModels.push @get(cid)
    
    @reset(orderedModels)
