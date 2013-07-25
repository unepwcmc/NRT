window.Backbone.Models || = {}

class window.Backbone.Models.Report extends Backbone.Model
  defaults:
    sections: []
    img: -> "/images/bkg#{Math.floor(Math.random()*4)}.jpg"
